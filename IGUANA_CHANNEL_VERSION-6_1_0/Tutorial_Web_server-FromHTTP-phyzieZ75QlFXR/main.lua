-- The main function is the first function called from Iguana.
-- The Data argument will contain the message to be processed.

function main(Data)

   -- # Send a copy of the request to the logs
   queue.push{data=Data}


   -- # Parse incoming request to get method, uri, body
   local R = net.http.parseRequest{data=Data}
   trace(R)

   -- ## Parse URI/Location
   local path = string.split(R.location,'/')
   -- Tip: You can also use:
   -- local path = R.location:split('/')
   local id = (path[4])
   local resource = (path[3])

   trace(R.body)

   -- ## Parse body of incoming message into JSON node tree
   local patientDemos
   if R.body ~= '' then
      patientDemos = json.parse{data= R.body}
   end

   -- # Route message to business logic depending on request
   local response
   local code

   if R.method == 'GET' then
      trace("We will execute a SELECT on the database.")

   elseif R.method == 'POST' then
      if not(patientDemos.patient.sender) then
         response = 'Please add patient.sender to JSON message with the contents of MSH[3][1].'
         code = 400
      else   
         response = "You are on your way to web client mastery!"
         code = 200
         trace("We will merge our record to the database")
         -- Insert record
         
      end
   end

   -- Give a response!
   net.http.respond{body=response,code=code}

end


