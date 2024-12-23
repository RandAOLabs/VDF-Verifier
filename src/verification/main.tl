local bint = require('verification.utils.bint')(512, 32)
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

global function computedCheckpointOutput(input: string, modulus: string, expectedOutput: string): boolean, string
  print("entered")
  assert((TotalSquarings % NumSegments == 0), "Failure: Total Squarings and Number of Segments")
  local segmentLength = TotalSquarings / NumSegments
  print("Segment Length: " .. json.encode(segmentLength))

  local bintInput = bint.fromstring(input)
  print("Input: " .. json.encode(bint.tobase(bintInput, 10, true)))

  local updatedResult: BigInteger = bintInput

  local bintModulus = bint.fromstring(modulus)
  print("Modulus: " .. json.encode(bint.tobase(bintModulus, 10, true)))

  local bintExpectedOutput = bint.fromstring(expectedOutput)
  print("Expected Output: " .. json.encode(bint.tobase(bintExpectedOutput, 10, true)))
  
  for i = 1, segmentLength do
    updatedResult = bint.upowmod(updatedResult, bint.frominteger(Exponent), bintModulus)  
    print("Updated result at stage: " .. i .. " " .. json.encode(bint.tobase(updatedResult, 10, true)))
  end

  print("Real Output: " .. tostring(bint.tobase(updatedResult, 10, true)))

  if bint.eq(updatedResult, bintExpectedOutput) then
    print("matched")
    return true, ""
  else
    print("failed")
    return false, "Failure: Expected =/= Computed Output"
  end
end

local function checkModulusResult(input: string, modulus: string, expectedOutput: string): boolean
  local bintInput = bint.fromstring(input)
  print("Input: " .. json.encode(bint.tobase(bintInput, 10, true)))
  local bintModulus = bint.fromstring(modulus)
  print("Modulus: " .. json.encode(bint.tobase(bintModulus, 10, true)))
  local bintExpectedOutput = bint.fromstring(expectedOutput)
  print("Expected Output: " .. json.encode(bint.tobase(bintExpectedOutput, 10, true)))
  
  local result = bint.umod(bintInput, bintModulus)
  print("Result: " .. json.encode(bint.tobase(result, 10, true)))
  return bint.eq(result, bintExpectedOutput)
end


local function validateOutputHandler(msg: Message): boolean
  print("entered output")
  local data = (json.decode(msg.Data as string) as ValidateOutputData)
  local request_id = data.request_id
  local segment_id = data.segment_id
  local input = data.input
  local expected_output = data.expected_output
  local modulus = "0x7FFFFFFFF"

  local success = checkModulusResult(input, modulus, expected_output)
  
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

local function validateCheckpointHandler(msg: Message): boolean
  print("entered checkpoint")
  local data = (json.decode(msg.Data as string) as ValidateCheckpointData)
  local request_id = data.request_id
  local segment_id = data.segment_id
  local checkpoint_input = data.checkpoint_input
  local modulus = data.modulus
  local expected_output = data.expected_output

  local success, _ = computedCheckpointOutput(checkpoint_input, modulus, expected_output)
  
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
Handlers.add('validateCheckpoint', Handlers.utils.hasMatchingTag('Action', 'Validate-Checkpoint'), validateCheckpointHandler)
Handlers.add('validateOutput', Handlers.utils.hasMatchingTag('Action', 'Validate-Output'), validateOutputHandler)

print("Successfully loaded verification process")