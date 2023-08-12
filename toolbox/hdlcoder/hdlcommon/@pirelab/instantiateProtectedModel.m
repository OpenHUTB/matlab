function hBlackBoxComp = instantiateProtectedModel( varargin )






p = inputParser;

p.addParameter( 'Network', '' );
p.addParameter( 'Name', '' );
p.addParameter( 'SLHandle',  - 1 );
p.addParameter( 'InportNames', {  } );
p.addParameter( 'OutportNames', {  } );
p.addParameter( 'InportSignals', [  ] );
p.addParameter( 'OutportSignals', [  ] );
p.addParameter( 'AddClockPort', 'off' );
p.addParameter( 'AddClockEnablePort', 'off' );
p.addParameter( 'AddResetPort', 'off' );
p.addParameter( 'ClockInputPort', '' );
p.addParameter( 'ClockEnableInputPort', '' );
p.addParameter( 'ResetInputPort', '' );
p.addParameter( 'InlineConfigurations', 'on' );
p.addParameter( 'GenericList', '' );
p.addParameter( 'EntityName', '' );
p.addParameter( 'Latency', 0 );
p.addParameter( 'VHDLArchitectureName', [  ] );
p.addParameter( 'VHDLLibraryName', '' );
p.addParameter( 'ClockEnablePorts', [  ] );

p.parse( varargin{ : } );
args = p.Results;

hN = args.Network;
compFileName = args.Name;
inportNames = args.InportNames;
outportNames = args.OutportNames;
slHandle = args.SLHandle;
clockEnablePorts = args.ClockEnablePorts;

[ ~, compName, ~ ] = fileparts( compFileName );

hBlackBoxComp = hN.addComponent( 'black_box_comp', 'instantiation', 0, 0 );

for ii = 1:length( inportNames )
if ~isempty( inportNames{ ii } )
hBlackBoxComp.addInputPort( inportNames{ ii } );
end 
end 

for ii = 1:length( outportNames )
if ~isempty( outportNames{ ii } )
hBlackBoxComp.addOutputPort( outportNames{ ii } );
end 
end 


params = {  };


hBlackBoxImpl = hdldefaults.SubsystemBlackBoxHDLInstantiation;

implParams = {  ...
'AddClockPort', args.AddClockPort,  ...
'AddClockEnablePort', args.AddClockEnablePort,  ...
'AddResetPort', args.AddResetPort,  ...
'InlineConfigurations', args.InlineConfigurations,  ...
'GenericList', args.GenericList,  ...
'EntityName', args.EntityName,  ...
'Latency', args.Latency,  ...
'VHDLLibraryName', args.VHDLLibraryName
 };



if ~isempty( args.ClockInputPort )
implParams{ end  + 1 } = 'ClockInputPort';
implParams{ end  + 1 } = args.ClockInputPort;
end 

if ~isempty( args.ClockEnableInputPort )
implParams{ end  + 1 } = 'ClockEnableInputPort';
implParams{ end  + 1 } = args.ClockEnableInputPort;
end 

if ~isempty( args.ResetInputPort )
implParams{ end  + 1 } = 'ResetInputPort';
implParams{ end  + 1 } = args.ResetInputPort;
end 

if ~isempty( args.VHDLArchitectureName )
implParams{ end  + 1 } = 'VHDLArchitectureName';
implParams{ end  + 1 } = args.VHDLArchitectureName;
end 

if ~isempty( args.VHDLLibraryName )
implParams{ end  + 1 } = 'VHDLLibraryName';
implParams{ end  + 1 } = args.VHDLLibraryName;
end 

clockEnablePortNames = '';
clockEnablePorts = clockEnablePorts{ 1 };
if numel( clockEnablePorts )
clockEnablePortNames = { clockEnablePorts( : ).signalName };
end 
if numel( clockEnablePortNames )
args.AddClockEnablePort = 'on';
implParams{ end  + 1 } = 'MultipleClockEnableInputPorts';
implParams{ end  + 1 } = clockEnablePortNames;
end 

hBlackBoxImpl.setImplParams( implParams );


firstArgs = { hBlackBoxImpl, hBlackBoxComp };
userData.CodeGenFunction = 'emit';
userData.CodeGenParams = [ firstArgs, params ];
userData.generateSLBlockFunction = 'generateSLBlock';
userData.generateSLBlockParams = firstArgs;
userData.latency = args.Latency;
userData.VHDLLibraryName = args.VHDLLibraryName;
hBlackBoxComp.ImplementationData = userData;


hBlackBoxComp.SimulinkHandle = slHandle;
hBlackBoxComp.Name = compName;


hBlackBoxComp.setIsProtectedModel( true );

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpyV3WId.p.
% Please follow local copyright laws when handling this file.

