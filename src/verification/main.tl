local json = require('json')

-- Define types
global Name: string
global Description: string
global TotalSquarings: number
global NumSegments: number
global Exponent: integer
global SuccessMessage: string

global record ValidatePuzzleData
  request_id: string
  segment_id: string
  input: string
  modulus: string
  p: string
  q: string
end

global record HashEntropyData
  requestId: string
  components: {string}
end

global record PhiResult
  phi: string
  n: string
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

global function validatePuzzleHandler(msg: Message): boolean
  print("entered validate puzzle")
  local data = (json.decode(msg.Data as string) as ValidatePuzzleData)
  local request_id = data.request_id
  local segment_id = data.segment_id
  local input = data.input
  local modulus = data.modulus
  local p = data.p
  local q = data.q
  local phi = ""
  local n = ""
  
  
  local phiResult = compute_phi_and_n(p, q) as PhiResult

  if phiResult then
    phi = phiResult.phi
    n = phiResult.n
    print("phi(N):" .. phi)
    print("N = p * q:" .. n)
  else
    print("Computation failed.")
    msg.reply({ Action = "Failed-Puzzle-Verification", Data = "Error" })
    return false
  end

  if modulus ~= n then
    print("N != p * q")
    msg.reply({ Action = "Failed-Puzzle-Verification", Data = "Error" })
    return false
  end

  local puzzleResult = solve_time_lock_puzzle(input, tostring(TotalSquarings), modulus, n)

  if puzzleResult then
    local response = {
      request_id = request_id,
      segment_id = segment_id,
      puzzle_result = puzzleResult,
    }
    msg.reply({ Action = "Puzzle-Verification", Data = json.encode(response) })
    return true
 else
    msg.reply({ Action = "Failed-Puzzle-Verification", Data = "Error" })
    return false
 end
end
global function doot()

  local inputs = { "deadbeef", "facefeed", "baadc0de" }
  local out = entropy_hash_luaint(inputs)
  print("Out: " .. json.encode(out))
end
global function hashEntropy(msg: Message): boolean 
  print("entered hash entropy")
  local data = (json.decode(msg.Data) as HashEntropyData)
  local components = data.components
  print("components: " .. json.encode(components))
  local dataArray = {}
  for _, value in ipairs(components) do
    table.insert(dataArray, value)
  end
  print("dataArray: " .. json.encode(dataArray))
  local hashedEntropy = entropy_hash_luaint(dataArray)
  
  if hashedEntropy then
    msg.reply({ Action = "Hash-Entropy", Data =  hashedEntropy})
  else
    msg.reply({ Action = "Failed-Hash-Entropy", Data = json.encode({request_id = data.requestId, error = "Error"}) })
    return false
  end
  return true
end

-- Add handlers
Handlers.add('info', Handlers.utils.hasMatchingTag('Action', 'Info'), infoHandler)
Handlers.add('ping', Handlers.utils.hasMatchingTag('Action', 'Ping'), pingHandler)
Handlers.add('validatePuzzle', Handlers.utils.hasMatchingTag('Action', 'Validate-Puzzle'), validatePuzzleHandler)
Handlers.add('hashEntropy', Handlers.utils.hasMatchingTag('Action', 'Hash-Entropy'), hashEntropy)

print("Successfully loaded verification process")