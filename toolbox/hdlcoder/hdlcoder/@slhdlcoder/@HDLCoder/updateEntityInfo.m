function updateEntityInfo( this, p )







this.CurrentNetwork = p.getTopNetwork;

inPorts = this.CurrentNetwork.PirInputPorts;
for i = 1:length( inPorts )
signal = inPorts( i ).Signal;
if ~isempty( signal ) &&  ...
isempty( signal.VType )
signal.VType( pirgetvtype( signal ) );
end 
end 

outPorts = this.CurrentNetwork.PirOutputPorts;
for i = 1:length( outPorts )
signal = outPorts( i ).Signal;
if ~isempty( signal ) &&  ...
isempty( signal.VType )
signal.VType( pirgetvtype( signal ) );
end 
end 


vNtwks = p.Networks;
numNtwks = length( vNtwks );


genSingleFileHDL = this.getParameter( 'ConcatenateHDLModules' );

if genSingleFileHDL
vNtwks = p.getTopNetwork(  );
numNtwks = 1;
else 

tNtwks = [  ];
for ii = 1:numNtwks
if strcmpi( vNtwks( ii ).getKind(  ), 'verbatim' )
tNtwks = [ vNtwks( ii ), tNtwks ];%#ok<AGROW>
else 
tNtwks = [ tNtwks, vNtwks( ii ) ];%#ok<AGROW>
end 
end 
vNtwks = tNtwks;
end 

for ii = 1:numNtwks
hN = vNtwks( ii );
p.addEntityNameAndPath( hN.Name, hN.FullPath );
end 

if this.getParameter( 'isvhdl' )
if p.VhdlPackageGenerated
p.addEntityNameAndPath( this.getParameter( 'vhdl_package_name' ), '' );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp4UZFiR.p.
% Please follow local copyright laws when handling this file.

