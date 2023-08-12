function property = sl_get_property_schema( h, inspector_mode )




property = [  ];

if isa( h, 'Simulink.Block' )
isAUTOSARCompositionSubDomain = isChildOfArchitecture( h.handle, 'AUTOSARArchitecture' );


isSysarchCompositionSubDomain =  ...
isChildOfArchitecture( h.handle, 'Architecture' ) ||  ...
isAUTOSARCompositionSubDomain ||  ...
isChildOfArchitecture( h.handle, 'SoftwareArchitecture' );

switch class( h )
case 'Simulink.MATLABSystem'
property = matlab.system.ui.PropertySchema.create( h );
case { 'Simulink.SimscapeBlock',  ...
'Simulink.SimscapeMultibodyBlock',  ...
'Simulink.SimscapeComponentBlock',  ...
'Simulink.SimscapeFaultBlock',  ...
'Simulink.PMComponent' }
if nargin > 1
property = pmsl_getcustomizedpropertyschema( h, inspector_mode );
else 
property = pmsl_getcustomizedpropertyschema( h );
end 
case { 'Simulink.SubSystem' }
isSysarchAdapterSubDomain = strcmp( get_param( h.handle,  ...
'SimulinkSubDomain' ), 'ArchitectureAdapter' );
if strcmp( get_param( h.Handle, 'DialogController' ), 'NetworkEngine.DynNeUtilDlgSource' )
if nargin > 1
property = pmsl_getcustomizedpropertyschema( h, inspector_mode );
else 
property = pmsl_getcustomizedpropertyschema( h );
end 
elseif blockisa( h, 'DocBlock' )
property = Simulink.DocBlockPropertySchema( h );
else 
if isSysarchAdapterSubDomain
property = systemcomposer.internal.arch.internal.propertyinspector.SysarchAdapterPropertySchema( h );
elseif isSysarchCompositionSubDomain
property = systemcomposer.internal.arch.internal.propertyinspector.SysarchPropertySchema( h );
else 
property = Simulink.BlockPropertySchema( h );
end 
end 
case { 'Simulink.ModelReference' }
if isSysarchCompositionSubDomain
property = systemcomposer.internal.arch.internal.propertyinspector.SysarchPropertySchema( h );
else 
property = Simulink.BlockPropertySchema( h );
end 
case { 'Simulink.Inport', 'Simulink.Outport', 'Simulink.PMIOPort' }





editor = getLastActiveEditor;
if ( ~isempty( editor ) )

if ( strcmpi( get_param( getParentDiagramHandle( editor ), 'SimulinkSubDomain' ), 'Architecture' ) ||  ...
strcmpi( get_param( getParentDiagramHandle( editor ), 'SimulinkSubDomain' ), 'SoftwareArchitecture' ) )
property = systemcomposer.internal.arch.internal.propertyinspector.SysarchPropertySchema( h, editor.blockDiagramHandle );
elseif ( strcmpi( get_param( getParentDiagramHandle( editor ), 'SimulinkSubDomain' ), 'AUTOSARArchitecture' ) ) &&  ...
strcmp( get_param( h.Handle, 'IsBusElementPort' ), 'on' )
property = systemcomposer.internal.arch.internal.propertyinspector.SysarchPropertySchema( h, editor.blockDiagramHandle );
elseif slfeature( 'DeviceDriverModelMapping' ) > 0 &&  ...
modelIsMappedToApplication( bdroot( h.handle ) )
property = target.internal.peripheral.ui.PortPropertySchema( h );
else 
property = Simulink.BlockPropertySchema( h );
end 
else 
if isAUTOSARCompositionSubDomain && strcmp( get_param( h.Handle, 'IsBusElementPort' ), 'on' )
property = systemcomposer.internal.arch.internal.propertyinspector.SysarchPropertySchema( h );
elseif isSysarchCompositionSubDomain
property = systemcomposer.internal.arch.internal.propertyinspector.SysarchPropertySchema( h );
else 
property = Simulink.BlockPropertySchema( h );
end 
end 
otherwise 
property = Simulink.BlockPropertySchema( h );
end 
return ;
end 

switch class( h )

case { 'Simulink.Annotation' }
property = Simulink.AnnotationPropertySchema( h );
case { 'Simulink.BlockDiagram' }
if strcmp( get_param( h.Handle, 'SimulinkSubDomain' ), 'Architecture' ) ||  ...
strcmp( get_param( h.Handle, 'SimulinkSubDomain' ), 'AUTOSARArchitecture' ) ||  ...
strcmp( get_param( h.Handle, 'SimulinkSubDomain' ), 'SoftwareArchitecture' )
property = systemcomposer.internal.arch.internal.propertyinspector.SysarchPropertySchema( h );
else 
property = Simulink.ModelPropertySchema( h );
end 
case { 'Simulink.Line' }
if strcmp( get_param( h.Parent, 'SimulinkSubDomain' ), 'Architecture' ) ||  ...
strcmp( get_param( h.Parent, 'SimulinkSubDomain' ), 'AUTOSARArchitecture' ) ||  ...
strcmp( get_param( h.Parent, 'SimulinkSubDomain' ), 'SoftwareArchitecture' )
property = systemcomposer.internal.arch.internal.propertyinspector.SysarchLinePropertySchema( h );
else 
property = Simulink.LinePropertySchema( h );
end 
case 'Simulink.Segment'
appName = bdroot( h.Parent );
if strcmp( get_param( h.Parent, 'SimulinkSubDomain' ), 'Architecture' ) ||  ...
strcmp( get_param( h.Parent, 'SimulinkSubDomain' ), 'SoftwareArchitecture' )
studio = ZCStudio.StudioIntegManager.getMostRecentlyActiveStudio( appName );
if ~isempty( studio ) && studio.App.hasSpotlightView(  )
property = systemcomposer.internal.arch.internal.propertyinspector.SysarchLinePropertySchema( h );
end 
end 
case { 'Simulink.Port' }

parentSystem = get_param( h.Parent, 'Parent' );
if strcmp( get_param( parentSystem, 'SimulinkSubDomain' ), 'Architecture' ) ||  ...
strcmp( get_param( parentSystem, 'SimulinkSubDomain' ), 'AUTOSARArchitecture' ) ||  ...
strcmp( get_param( parentSystem, 'SimulinkSubDomain' ), 'SoftwareArchitecture' )
bdH = get_param( bdroot( h.Parent ), 'Handle' );
property = systemcomposer.internal.arch.internal.propertyinspector.SysarchPropertySchema( h, bdH );
else 
property = Simulink.PortPropertySchema( h );
end 
end 
end 

function hdl = getParentDiagramHandle( editor )
try 
hdl = editor.getDiagram.handle;
catch 
hdl = editor.blockDiagramHandle;
end 
end 

function tf = isChildOfArchitecture( hdl, subdomain )
tf = strcmp( get_param( get_param( hdl, 'Parent' ), 'SimulinkSubDomain' ), subdomain );
end 

function tf = modelIsMappedToApplication( mdlH )

mapping = Simulink.CodeMapping.getCurrentMapping( mdlH );
tf = ~isempty( mapping ) && isa( mapping, 'Simulink.CoderDictionary.ModelMapping' ) &&  ...
strcmp( mapping.DeploymentType, 'Application' );
end 

function editor = getLastActiveEditor(  )
studios = DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
editor = [  ];
if ( ~isempty( studios ) )
studio = studios( 1 );
studioApp = studio.App;
editor = studioApp.getActiveEditor;
end 
end 






% Decoded using De-pcode utility v1.2 from file /tmp/tmp2qEsXb.p.
% Please follow local copyright laws when handling this file.

