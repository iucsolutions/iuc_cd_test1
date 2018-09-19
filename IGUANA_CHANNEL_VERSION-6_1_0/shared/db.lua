local database = {}
 
-- VARIABLES
-- These variables will help us build our database if one does not exist already.

local DB_NAME = "demographics2.db"
local DROP_TABLE_COMMAND = "DROP TABLE IF EXISTS patients"
local CREATE_TABLE_COMMAND = [[
CREATE TABLE patients
(
id INTEGER NOT NULL PRIMARY KEY,
firstName Text(255),
lastName Text(255),
city text(255),
state text(30),
zip text(15),
phoneHome text(30),
phoneWork text(30),
race text(30),
gender text(15),
ssn text(15)
)
]]

-- FUNCTIONS
 
-- use to create connection object when needed
local function connCreate()
   return db.connect{api=db.SQLITE, name=DB_NAME}
end

-- This function resets the state of the store table by first deleting it and then
-- recreating it.
function database.resetTableState()
   -- This operation is performed as a database transaction to prevent another
   -- Translator script from accidentally attempting to access the store table
   -- while it has been temporarily deleted.
   local conn = connCreate()
   conn:begin()
   conn:execute{sql=DROP_TABLE_COMMAND, live=true}
   conn:execute{sql=CREATE_TABLE_COMMAND, live=true}
   conn:commit()
   conn:close()
end

-- This function maps from our incoming message body to our staging table/node tree
function database.mappings(patient,table) 

   table.patients[1].id = patient.id
   table.patients[1].firstName = patient.name_first
   table.patients[1].lastName = patient.name_last
   table.patients[1].city = patient.city
   table.patients[1].state = patient.state
   table.patients[1].zip = patient.zip
   table.patients[1].phoneHome = patient.phone_home
   table.patients[1].phoneWork = patient.phone_work
   table.patients[1].race = patient.race
   table.patients[1].gender = patient.gender
   table.patients[1].ssn = patient.ssn

   return table
end


-- Merge into database.
function database.postPatient(table)
   local conn = connCreate()
   db.merge{api=db.SQLITE,name='demographics2.db',data=table,live=true}  
   
   -- Example code if you don't use the db.merge function ...      
   --   local R = conn:query('REPLACE INTO patients(id, firstName, lastName, city, state, zip, phoneHome, phoneWork, race, gender, ssn) VALUES(' .. 
   --      conn:quote(patient.id) .. ',' .. 
   --     conn:quote(patient.name_first) .. ',' .. 
   --      conn:quote(patient.name_last) .. ',' .. 
   --     conn:quote(patient.city) .. ',' .. 
   --     conn:quote(patient.state) .. ',' .. 
   --     conn:quote(patient.zip) .. ',' .. 
   --     conn:quote(patient.phone_home) .. ',' .. 
   --     conn:quote(patient.phone_work) .. ',' .. 
   --     conn:quote(patient.race) .. ',' .. 
   --     conn:quote(patient.gender) .. ',' .. 
   --     conn:quote(patient.ssn) .. ')')

   local test = conn:query('Select * from patients')
   trace (test)
   conn:close()
end

-- Gets patient from database.
function database.getPatient(id)
   -- local conn = connCreate()
   local conn = db.connect{api=db.SQLITE, name=DB_NAME}
   local R = conn:query('SELECT * FROM patients WHERE id = ' .. id)
   trace (R)
   conn:close()
   return R
end
 
-- Local Functions
-- INITIALIZE DB: This automatically ensures the SQLlite database exists and has the store table present at script compile time.   
local function init()
   local conn = connCreate()
   local R = conn:query('SELECT * from sqlite_master WHERE type="table" and tbl_name="demographics"')
   conn:close()
   
   trace(#R)
   if #R == 0 then
      database.resetTableState()
   end
end

init() -- DO NOT REMOVE: Calls init() (once only) at script compile time to perform the initialization
return database
 