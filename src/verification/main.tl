local json = require('json')

-- Define types
global Name: string
global Description: string
global TotalSquarings: number
global NumSegments: number
global Exponent: integer
global SuccessMessage: string

global record ValidateCheckpointData 
  request_id: string
  segment_id: string
  checkpoint_input: string
  modulus: string
  expected_output: string
end

global record ValidateOutputData
  request_id: string
  segment_id: string
  input: string
  expected_output: string
end

global record ResponseData
  Target: string
  Action: string
  Data: string
end

-- Initialize global variables
Name = Name or "Verifier"
Description = Description or "RandAO Verification Process"
TotalSquarings = 5000
NumSegments = 10
Exponent = 2
SuccessMessage = "200: Success"

-- Helper function to send a response
global function sendResponse(target: string, action: string, data: any): ResponseData
  return {
    Target = target,
    Action = action,
    Data = json.encode(data)
  }
end

-- Handler functions
local function infoHandler(msg: Message)
  ao.send({
    Target = msg.From,
    Name = Name,
    Description = Description
  })
end

local function pingHandler(msg: Message): boolean
  print("entered ping")
  msg.reply({ Action = "Pong", Data = SuccessMessage })
  return true
end

global function validateOutputHandler(msg: Message): boolean
  print("entered output")
  local data = (json.decode(msg.Data as string) as ValidateOutputData)
  local request_id = data.request_id
  local segment_id = data.segment_id
  local input = string.sub(data.input, 3)
  local expected_output = data.expected_output
  local modulus = "7FFFFFFFF"

  print("input: " .. input .. " modulus: " .. modulus .. " expected_output: " .. expected_output)

  local success = check_modulus_result(input, modulus, expected_output)
  print("success: " .. tostring(success))

  local response = {
    request_id = request_id,
    valid = success,
    segment_id = segment_id,
 }

 if success then
    msg.reply({ Action = "Post-Verification", Data = json.encode(response) })
    return true
 else
    msg.reply({ Action = "Failed-Post-Verification", Data = "Error" })
    return false
 end
end

global function validateCheckpointHandler(msg: Message): boolean
  print("entered checkpoint")
  local data = (json.decode(msg.Data as string) as ValidateCheckpointData)
  local request_id = data.request_id
  local segment_id = data.segment_id
  local checkpoint_input = string.sub(data.checkpoint_input, 3)
  local modulus = string.sub(data.modulus, 3)
  local expected_output = string.sub(data.expected_output, 3)
  local exponent = tostring(math.floor(TotalSquarings / NumSegments))

  print("checkpoint_input: " .. checkpoint_input .. "exponent: " .. exponent .. " modulus: " .. modulus .. " expected_output: " .. expected_output)

  local success = compute_mod_exp(checkpoint_input, exponent, modulus, expected_output)
  print("success: " .. tostring(success))

  local response = {
    request_id = request_id,
    segment_id = segment_id,
    valid = success,
 }

 if success then
    msg.reply({ Action = "Post-Verification", Data = json.encode(response) })
    return true
 else
    msg.reply({ Action = "Failed-Post-Verification", Data = "Error" })
    return false
 end
end

-- Add handlers
Handlers.add('info', Handlers.utils.hasMatchingTag('Action', 'Info'), infoHandler)
Handlers.add('ping', Handlers.utils.hasMatchingTag('Action', 'Ping'), pingHandler)
Handlers.add('validateCheckpoint', Handlers.utils.hasMatchingTag('Action', 'Validate-Checkpoint'), validateCheckpointHandler)
Handlers.add('validateOutput', Handlers.utils.hasMatchingTag('Action', 'Validate-Output'), validateOutputHandler)

print("Successfully loaded verification process")