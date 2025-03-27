local json = require "json"


local phi = "1551017a3dc330141c6131344c28faba879b768d64212ea3426369c7303bd039d0b983ed83d78c42fdea5534cd285ffd78cfcd140c202d43d19e07e77eaf344fd4fb2a73fe333487f4fc5ba2588786b524e84098bda4eac41375a13816e863f9e74fc62218c99910bc237cc58cdc12923edf0c95d986c8623d18ebd202339d5c0f1d731922cbdef141c0545f4ef52a005d27ffa778ab4c7c369f97087fcbe758813645d8f3a12e7808318689917717e114562ae871b0eac772abe20f91289d1313a800711776ed527a1dc047cfbc79230c7c6e4382c62df93b526626b45b13fdbab559ac1dcdb697b082d239536cee5fcef6706ef4d9f2a18f4e579728cf2c40"
local x = "2dc1c123598b7126188bb51aeab9f010bf925c6c4eed9ecccb89b398aeac52a43fed5f1081799900152e8bdcbe43fec9c2696b9a2695ed9db8e03a2b6e9af2a3a553d9cd98b5c499c3190e82e3d568cad03cc5d68ca3544de66a6d8d3516d28f8fb66b7ab09554a172e39f1b3c227ee84e71b3b84b458b41750d06c84f8c0e6fe7bb86328939f17ba3246da8fb521cbd1cea44c90c7b089ca8c061a46a2dd04511a59ccdf3c8d6cccf9814f865c22e941cbfcfa4aab02947a971793d28517d5e872e47dfff04957c162074134b4a75455ad2d65257a9dd5279dc82a65cd41d10fd165367c91d05f4bb6a2d6462f127e5c4bde3ba3067cde96d2af3a424d1e404"
local t = "3000000"
local N = "1551017a3dc330141c6131344c28faba879b768d64212ea3426369c7303bd039d0b983ed83d78c42fdea5534cd285ffd78cfcd140c202d43d19e07e77eaf344fd4fb2a73fe333487f4fc5ba2588786b524e84098bda4eac41375a13816e863f9e74fc62218c99910bc237cc58cdc12923edf0c95d986c8623d18ebd202339d5cad07d3c5e71d4d50f693f71443bae6f29419d0a51700bee147f5f3aa8381fc336b8003f86f04effb577fdc38b0440cdc1b162efa64e640f45606deff9e37cdbcc1df8a941588031fe65aaecf97deae092f3e8771f80f45435a52d6f483bc435a2ffc8559b859c0dd2e7c81c5ec701f179b57d9c22b6d40222bdde852682b995b"
local p = "3313c679051a03bf31d552fe70a0c2d19f11704fa2a46f309b221ae0c8c63e51a0c1d8ac74baaf98c086865735bb8e09dc008a711f6ad14036d9685940d0280ff8e2073452cccf84625995f0ad1f83d59b395887adfcc98e048808a9e0fbfe8744a177ab2a39cef14149468e7bb481d9c3ff31de9ad6ca36ef088aea7c6670a1"
local q = "6ad69a33bf376aa082fe4fb68424fa2097e060adfbb10334763441c13aefd6894987e57306a911ea8ec7cf57e91166f12abf79a0d3ca84ecac819496cc3f0899b55582eeab44464909e358971b02b1108788c0a6c74c4dbc1a786823ee6530d530a5b40270523b543cb068fe1d4eaede086237749bbc8349ad8705d0c2f5fc7b"



function Runnit()
    local res = solve_time_lock_puzzle(x, t, phi, N)
    print("Type: " .. tostring(type(res)))
    print("Raw: " .. tostring(res))
    return res
end

Handlers.add(
  "PhiN",
  Handlers.utils.hasMatchingTag("Action", "PhiN"),
  function (msg)
    local phiN = compute_phi_and_n(p,q)
    print("Lua type:" .. tostring(type(phiN)))
    print("Phi N:" .. json.encode(phiN))
    print("Phi:" .. json.encode(phiN.phi))
    print("N:" .. json.encode(phiN.n))
    Send({
        Target = msg.From,
        Data = json.encode(phiN),
    })
end)

Handlers.add(
  "SolveLock",
  Handlers.utils.hasMatchingTag("Action", "SolveLock"),
  function (msg)
    local puzzle_result = solve_time_lock_puzzle(x, t, phi, N)
    print("Lua type:", tostring(type(puzzle_result)))
    print("Puzzle result:", json.encode(puzzle_result))

    Send({
        Target = msg.From,
        Data = json.encode(puzzle_result),
    })
end)