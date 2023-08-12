function manualvariant_cb( aAction )




switch ( aAction )
case 'open'
i_OpenCallback(  );
case 'mask_numchoice_callback'
i_MaskNumChoiceCallback(  );
case 'mask_init'
i_MaskInit(  );
end 


function i_OpenCallback(  )
if strcmp( get_param( bdroot( gcs ), 'Lock' ), 'on' )
return ;
end 

aParent = get_param( gcb, 'Parent' );
aParentObj = get_param( aParent, 'Object' );
if isempty( aParentObj ) || aParentObj.isLinked
return ;
end 

aActiveVariant = get_param( gcb, 'LabelModeActiveChoice' );
aVariantControls = get_param( gcb, 'VariantControls' );
if isempty( aVariantControls )
return ;
end 





simMode = get_param( bdroot( gcbh ), 'SimulationStatus' );
if strcmp( simMode, 'running' ) || strcmp( simMode, 'paused' ) || strcmp( simMode, 'compiled' )
return 
end 

iIndex = find( ismember( aVariantControls, aActiveVariant ) );
if isempty( iIndex )
iIndex = 0;
end 

iIndex = iIndex + 1;
if ( iIndex > length( aVariantControls ) )
iIndex = 1;
end 

set_param( gcb, 'LabelModeActiveChoice', aVariantControls{ iIndex } );
end 

function i_MaskInit(  )
aVariantControls = get_param( gcb, 'VariantControls' );
iNumPorts = str2num( get_param( gcb, 'NumChoices' ) );%#ok<ST2NM>

if length( aVariantControls ) ~= iNumPorts
aVariantControls = cell( iNumPorts, 1 );
for i = 1:iNumPorts
aVariantControls{ i } = [ 'V_', num2str( i ) ];
end 

set_param( gcb, 'VariantControls', aVariantControls );


aActiveVariant = get_param( gcb, 'LabelModeActiveChoice' );
iIndex = find( ismember( aVariantControls, aActiveVariant ), 1 );
if isempty( iIndex )
set_param( gcb, 'LabelModeActiveChoice', aVariantControls{ 1 } );
end 
end 

aActiveVariant = get_param( gcb, 'LabelModeActiveChoice' );
if isempty( aActiveVariant )

set_param( gcb, 'LabelModeActiveChoice', aVariantControls{ 1 } );
throw( MException( message( 'Simulink:Masking:ResetMaskParameterValueToDefault', '', 'LabelModeActiveChoice', gcb ) ) );
end 
end 

function i_MaskNumChoiceCallback(  )
aVariantControls = get_param( gcb, 'VariantControls' );
iNumPorts = str2num( get_param( gcb, 'NumChoices' ) );%#ok<ST2NM>

if length( aVariantControls ) ~= iNumPorts
aVariantControls = cell( iNumPorts, 1 );
for i = 1:iNumPorts
aVariantControls{ i } = [ 'V_', num2str( i ) ];
end 

set_param( gcb, 'VariantControls', aVariantControls );


aActiveVariant = get_param( gcb, 'LabelModeActiveChoice' );
iIndex = find( ismember( aVariantControls, aActiveVariant ), 1 );
if isempty( iIndex )
set_param( gcb, 'LabelModeActiveChoice', aVariantControls{ 1 } );
end 
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpscfYjp.p.
% Please follow local copyright laws when handling this file.

