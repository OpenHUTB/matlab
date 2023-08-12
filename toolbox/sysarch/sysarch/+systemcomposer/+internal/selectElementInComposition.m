function selectElementInComposition( elem )






for i = 1:length( elem )
if isa( elem( i ), 'systemcomposer.arch.BaseComponent' ) ||  ...
isa( elem( i ), 'systemcomposer.arch.Connector' ) ||  ...
isa( elem( i ), 'systemcomposer.arch.ComponentPort' ) ||  ...
isa( elem( i ), 'systemcomposer.arch.Architecture' ) ||  ...
isa( elem( i ), 'systemcomposer.arch.ArchitecturePort' )
elem( i ) = elem( i ).getImpl;
end 

if ~isa( elem( i ), 'systemcomposer.architecture.model.design.BaseComponent' ) &&  ...
~isa( elem( i ), 'systemcomposer.architecture.model.design.BaseConnector' ) &&  ...
~isa( elem( i ), 'systemcomposer.architecture.model.design.ComponentPort' ) &&  ...
~isa( elem( i ), 'systemcomposer.architecture.model.design.Architecture' ) &&  ...
~isa( elem( i ), 'systemcomposer.architecture.model.design.ArchitecturePort' )
return ;
end 

designElem = elem( i );

handle = getHandleForElement( designElem );
if ( handle ==  - 1 )
return ;
end 

if isa( designElem, 'systemcomposer.architecture.model.design.BaseComponent' )
if ( i == 1 )
blockPath = systemcomposer.internal.getBlockPath( designElem );
blockPath.openParent;


editor = getLastActiveEditor(  );
editor.clearSelection(  );
end 
Simulink.scrollToVisible( handle, 'ensureFit', 'on', 'panMode', 'minimal' );
set_param( handle, 'Selected', 'On' );

elseif isa( designElem, 'systemcomposer.architecture.model.design.BaseConnector' )
parentComp = designElem.p_Component;
if isempty( parentComp )

parentComp = designElem.p_Architecture.getParentComponent;
end 

if ~isempty( parentComp )
blockPath = systemcomposer.internal.getBlockPath( parentComp );
blockPath.open;
else 
modelId = systemcomposer.services.proxy.ModelIdentifier.getModelIdentifier( mf.zero.getModel( designElem ) );
open_system( modelId.URI );
end 


if ( i == 1 )
editor = getLastActiveEditor(  );
editor.clearSelection(  );
end 
if length( handle ) == 1
set_param( handle, 'Selected', 'On' );
else 
dstPortHandle = getHandleForElement( designElem.getDestination );
segHandle = getSegmentHandleWithDstPort( handle, dstPortHandle );
if segHandle ~=  - 1
set_param( segHandle, 'Selected', 'On' )
end 
end 
elseif isa( designElem, 'systemcomposer.architecture.model.design.ComponentPort' )
parentComp = designElem.getComponent;
blockPath = systemcomposer.internal.getBlockPath( parentComp );
blockPath.openParent


Simulink.scrollToVisible( getHandleForElement( parentComp ), 'ensureFit', 'on', 'panMode', 'minimal' );
editor = getLastActiveEditor(  );
if ( i == 1 )
editor.clearSelection(  );
end 
editor.select( SLM3I.SLDomain.handle2DiagramElement( handle ) );
elseif isa( designElem, 'systemcomposer.architecture.model.design.Architecture' )
open_system( designElem.getName );
elseif isa( designElem, 'systemcomposer.architecture.model.design.ArchitecturePort' )
parentArch = designElem.getArchitecture;
if ~isempty( parentArch.getParentComponent )
parentComp = parentArch.getParentComponent;
blockPath = systemcomposer.internal.getBlockPath( parentComp );
blockPath.openParent;
else 
open_system( parentArch.getName );
end 


if ( i == 1 )
editor = getLastActiveEditor(  );
editor.clearSelection(  );
Simulink.scrollToVisible( handle, 'ensureFit', 'on', 'panMode', 'minimal' );
end 
set_param( handle, 'Selected', 'On' );
end 
end 

end 


function h = getHandleForElement( elem )

if isa( elem, 'systemcomposer.architecture.model.design.Architecture' )
h = get_param( elem.getName, 'Handle' );
return ;
end 

if isprop( elem, 'p_Redefines' ) && ~isempty( elem.p_Redefines )
h = getHandleForElement( elem.p_Redefines );
return ;
end 

modelId = systemcomposer.services.proxy.ModelIdentifier.getModelIdentifier( mf.zero.getModel( elem ) );
load_system( modelId.URI );
h = systemcomposer.utils.getSimulinkPeer( elem );




end 

function editor = getLastActiveEditor(  )
allStudios = DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
assert( numel( allStudios ) > 0 );
st = allStudios( 1 );
editor = st.App.getActiveEditor(  );
end 

function h = getSegmentHandleWithDstPort( handles, dstPortHandle )

h =  - 1;
for i = 1:numel( handles )
segmentObj = get_param( handles( i ), 'Object' );
if dstPortHandle == segmentObj.DstPortHandle
h = handles( i );
return ;
end 
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmplnqWb5.p.
% Please follow local copyright laws when handling this file.

