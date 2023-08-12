





function varargout = webClientRegistry( cmd, varargin )
R36
cmd( 1, 1 )string{ mustBeMember( cmd, [ "get", "add", "remove" ] ) } = "get"
end 
R36( Repeating )
varargin
end 

mlock;
persistent clients;
if isempty( clients )
clients = containers.Map(  );
end 

switch cmd
case "get"
narginchk( 0, 2 );
matches = clients.values(  );
if nargin > 1
predicate = varargin{ 1 };
matches = matches( cellfun( predicate, matches ) );
end 
varargout{ 1 } = matches;
case { "add", "remove" }
narginchk( 2, 2 );
nargoutchk( 0, 0 );
client = varargin{ 1 };
validateattributes( client, { 'codergui.WebClient' }, { 'scalar' } );
if cmd == "add"
clients( client.Id ) = client;
else 
if clients.isKey( client.Id )
clients.remove( client.Id );
end 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpVJlkaa.p.
% Please follow local copyright laws when handling this file.

