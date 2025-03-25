-- Global type definitions for Lua runtime environment

-- ao namespace for Arweave Oracle functions
global type ao = {
  id: string,
  send: function(message: table): boolean
}

-- Message type used in handlers
global type Message = {
  From: string,
  Name: string,
  Target: string,
  Tags: {string:string},
  Data: string | table,
  reply: function(message: table): boolean
}


-- JSON module type definition
global type json = {
  encode: function(data: any): string,
  decode: function(str: string): any
}
