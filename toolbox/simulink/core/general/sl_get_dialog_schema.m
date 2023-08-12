function dlgstruct = sl_get_dialog_schema( h, name )




try 
if isa( h, 'Simulink.Block' )
if strcmp( name, 'Simulink:Dialog:Info' )
dlgstruct = slimblockinfoddg( h, name );
elseif strcmp( name, 'Simulink:Dialog:Domain' )
dlgstruct = Simulink.DomainSpecPropertyDDG.getDomainSpecDialogSchema( h.Handle );
else 
dlgstruct = blockpropddg( h, name );
end 
return ;
end 

if isa( h, 'Simulink.Annotation' )
switch ( h.annotationType )
case 'note_annotation'
if strcmp( name, 'slim_annotation_dlg' )
dlgstruct = slimannotationddg( h, name );
else 
dlgstruct = annotationddg( h, name );
end 
case 'image_annotation'
if strcmp( name, 'slim_annotation_dlg' )
dlgstruct = slimimageddg( h, name );
else 
dlgstruct = imageddg( h, name );
end 
case 'area_annotation'
if strcmp( name, 'slim_annotation_dlg' )
dlgstruct = slimboxddg( h, name );
else 
dlgstruct = boxddg( h, name );
end 
otherwise 
throw( MException( 'Simulink:sl_get_dialog_schema:BadParam',  ...
'Annotation type not in [note_annotation, image_annotation, area_annotation]' ) );
end 
return ;
end 

switch class( h )
case 'Simulink.Parameter'
dlgstruct = dataddg( h, name, 'data' );
case 'Simulink.Signal'
dlgstruct = dataddg( h, name, 'signal' );
case { 'Simulink.BlockDiagram' }
if strcmp( name, 'Simulink:Model:Info' )
dlgstruct = slimmodelinfoddg( h, name );
elseif strcmp( name, 'Simulink:Model:Domain' )
dlgstruct = Simulink.DomainSpecPropertyDDG.getDomainSpecDialogSchema( h.Handle );
else 
dlgstruct = modelddg( h, name );
end 
case 'Simulink.AliasType'
dlgstruct = aliastypeddg( h, name );
case { 'Simulink.Bus', 'Simulink.ConnectionBus' }
isSlidStructureType = false;
dlgstruct = busddg( h, name, isSlidStructureType );
case 'Simulink.StructType'
dlgstruct = structtypeddg( h, name );
case 'Simulink.BusElement'
dlgstruct = buselementddg( h, name );
case 'Simulink.ConnectionElement'
dlgstruct = connectionelementddg( h, name );
case 'slid.Function'
dlgstruct = functionddg( h, name );
case 'slid.FunctionType'
dlgstruct = functionddg( h, name );
case 'Simulink.FunctionSignature'
dlgstruct = fcncallobjddg( h, name );
case 'Simulink.FunctionArgument'
dlgstruct = fcncallargddg( h, name );
case 'Simulink.StructElement'
dlgstruct = structelementddg( h, name );
case 'Simulink.NumericType'
dlgstruct = numerictypeddg( h, name );
case 'Simulink.StringType'
dlgstruct = stringtypeddg( h, name );
case { 'Simulink.Root' }
dlgstruct = rootddg( h );
case { 'Simulink.Line'
'Simulink.Port'
'Simulink.Segment' }
dlgstruct = sigpropddg( h );
case 'Simulink.Variant'
dlgstruct = variantddg( h, name );
case 'Simulink.VariantConfigurationData'


[ isInstalled, err ] = slvariants.internal.utils.getVMgrInstallInfo( 'Simulink.VariantConfigurationData' );
if ~isInstalled
throwAsCaller( err );
end 
if slfeature( 'vmgrv2ui' ) < 1
dlgstruct = variantconfigurationddg( h, name );
else 
dlgstruct = variantConfigurationsDDG( h, name );
end 
case 'Simulink.VariantControl'
dlgstruct = variantcontrolddg( h, name );
case 'Simulink.VariantVariable'
dlgstruct = variantvariableddg( h, name );
case 'Simulink.LookupTable'
dlgstruct = lookuptableddg( h, name );
case 'Simulink.Breakpoint'
dlgstruct = breakpointobjectddg( h, name );
case 'Simulink.SlidDAProxy'
slidObject = h.getObject(  );
if isa( slidObject, 'slid.Parameter' )
object = slidObject.WorkspaceObjectSharedCopy;
if isa( object, 'Simulink.Parameter' )
dlgstruct = dataddg( h, name, 'data' );
else 
dlgstruct = dataddg_mxarray( h );
end 
elseif isa( slidObject, 'slid.LookupTable' )
dlgstruct = lookuptableddg( h, name );
elseif isa( slidObject, 'slid.Breakpoint' )
dlgstruct = breakpointobjectddg( h, name );
elseif isa( slidObject, 'slid.Function' )
source = h.getPropValue( 'Source' );
dlgstruct = functionddg( slidObject, name, source );
elseif isa( slidObject, 'slid.StructureType' )
isSlidStructureType = true;
dlgstruct = busddg( h, name, isSlidStructureType );
elseif isa( slidObject, 'slid.FunctionType' )
source = h.getPropValue( 'Source' );
dlgstruct = functionddg( slidObject, name, source );
elseif isa( slidObject, 'slid.BusType' )
source = h.getPropValue( 'Source' );
dlgstruct = compositebusddg( slidObject, name, source );
elseif isa( slidObject, 'sl.data.adapter.DataDefinition' )
name = slidObject.name;

mfmdl = mf.zero.Model;
dataSrcInfo1 = sl.data.srccache.DataSourceInfo.createObject( slidObject.source,  ...
slidObject.section, mfmdl );
conn = sl.data.srccache.CacheConnection.createConnection( dataSrcInfo1, mfmdl );
object = conn.getDataByName( name, mfmdl ).getMatValue;
metaClass = metaclass( object );
package = metaClass.ContainingPackage;
if ~isempty( package )
objdlgstruct = sl_get_dialog_schema( object, name );
else 


s.Name = h.getPropValue( 'Name' );
s.Value = object;
s.DataType = class( object );
if isreal( object )
s.Complexity = 'real';
else 
s.Complexity = 'complex';
end 
s.Dimensions = [ '[', int2str( size( object ) ), ']' ];
objdlgstruct = dataddg_mxarray( s );
end 
for i = 1:numel( objdlgstruct.Items )
if isfield( objdlgstruct.Items{ i }, 'DialogRefresh' )
objdlgstruct.Items{ i }.DialogRefresh = 0;
end 
end 
dlgstruct = wrapDlgStructForSource( h, objdlgstruct );
elseif isa( slidObject, 'slid.Opaque' )
name = h.getPropValue( 'Name' );
object = slidObject.getSlValue(  );
metaClass = metaclass( object );
package = metaClass.ContainingPackage;
if ~isempty( package )
objdlgstruct = sl_get_dialog_schema( object, name );
else 


s.Name = h.getPropValue( 'Name' );
s.Value = object;
s.DataType = class( object );
if isreal( object )
s.Complexity = 'real';
else 
s.Complexity = 'complex';
end 
s.Dimensions = [ '[', int2str( size( object ) ), ']' ];
objdlgstruct = dataddg_mxarray( s );
end 
dlgstruct = wrapDlgStructForSource( h, objdlgstruct );
elseif isa( slidObject, 'slid.Signal' )
dlgstruct = dataddg( h, name, 'signal' );
end 

if isa( slidObject, 'sl.data.adapter.DataDefinition' )


if ~sl.data.adapter.AdapterManagerV2.hasWritingAdapters( slidObject.source )
dlgstruct.DisableDialog = 1;
end 
elseif ( slfeature( 'SLModelBroker' ) ||  ...
slfeature( 'SLLibrarySLDD' ) > 0 ||  ...
slfeature( 'SLDDBroker' ) ) &&  ...
~isa( slidObject, 'slid.Function' ) &&  ...
~isa( slidObject, 'slid.FunctionType' )
source = h.getPropValue( 'Source' );
if ~isempty( source )
tmpModel = mf.zero.Model;
ref = slid.broker.Resource.createResourceFromURI( source, tmpModel );
registry = sl.data.adapter.AdapterRegistry.getInstance( '' );
if ~isempty( ref ) && isempty( registry.getAdaptersForWriting( ref ) )
dlgstruct.DisableDialog = 1;
end 
end 
end 
otherwise 
if ( isa( h, 'Simulink.Parameter' ) )
dlgstruct = dataddg( h, name, 'data' );
elseif ( isa( h, 'Simulink.Signal' ) )
dlgstruct = dataddg( h, name, 'signal' );
elseif ( isa( h, 'Simulink.NumericType' ) )
dlgstruct = numerictypeddg( h, name );
elseif ( isa( h, 'Simulink.ImageType' ) )
dlgstruct = imagetypeddg( h, name );
elseif ( isa( h, 'Simulink.BusElement' ) )
dlgstruct = buselementddg( h, name );
elseif ( isa( h, 'Simulink.ConnectionElement' ) )
dlgstruct = connectionelementddg( h, name );
elseif ( isa( h, 'Simulink.Bus' ) )
isSlidStructureType = false;
dlgstruct = busddg( h, name, isSlidStructureType );
elseif ( isa( h, 'Simulink.ConnectionBus' ) )
isSlidStructureType = false;
dlgstruct = busddg( h, name, isSlidStructureType );
elseif ( isa( h, 'Simulink.ServiceBus' ) )
isSlidStructureType = false;
dlgstruct = servicebusddg( h, name, isSlidStructureType );
elseif ( isa( h, 'Simulink.AliasType' ) )
dlgstruct = aliastypeddg( h, name );
elseif ( isa( h, 'Simulink.LookupTable' ) )
dlgstruct = lookuptableddg( h, name );
elseif ( isa( h, 'Simulink.Breakpoint' ) )
dlgstruct = breakpointobjectddg( h, name );
else 
dlgstruct = genericddg( h );
end 
end 
catch err
dlgstruct = errorddg_l( h, name, err.message );
end 
end 

function dlgStruct = errorddg_l( h, name, errmsg )
txt.Name = errmsg;
txt.Type = 'text';
txt.WordWrap = true;
txt.RowSpan = [ 1, 1 ];
spacer.Type = 'panel';
spacer.RowSpan = [ 2, 2 ];
dlgStruct.LayoutGrid = [ 2, 1 ];
dlgStruct.RowStretch = [ 0, 1 ];
dlgStruct.Items = { txt, spacer };
dlgStruct.DialogTitle = [ class( h ), ': ', name ];
end 

function dlgStruct = wrapDlgStructForSource( h, objdlgstruct )
objSource = slid.broker.Resource.getFileNameWithExtension( h.getPropValue( 'Source' ) );
sourceLinkLbl.Name = [ DAStudio.message( 'Simulink:dialog:Source' ), ': ' ];
sourceLinkLbl.RowSpan = [ 1, 1 ];
sourceLinkLbl.ColSpan = [ 1, 1 ];
sourceLinkLbl.Type = 'text';
sourceLinkLbl.Tag = 'SourceLable_tag';
sourceLinkLbl.Buddy = 'Source_tag';

sourceLink.Name = objSource;
sourceLink.RowSpan = [ 1, 1 ];
sourceLink.ColSpan = [ 2, 5 ];
sourceLink.Type = 'hyperlink';
sourceLink.Tag = 'Source_tag';
sourceLink.MatlabMethod = 'open';
sourceLink.MatlabArgs = { slid.broker.Resource.removeTag( h.getPropValue( 'Source' ) ) };
sourceLink.Buddy = 'SourceLable_tag';

entryMetadataGrp.Name = '';
entryMetadataGrp.Type = 'group';
entryMetadataGrp.Items = { sourceLinkLbl, sourceLink };
entryMetadataGrp.LayoutGrid = [ 1, 1 ];
entryMetadataGrp.RowSpan = [ 2, 2 ];
entryMetadataGrp.ColSpan = [ 1, 2 ];

objectGrp.Name = '';
objectGrp.Type = 'group';
objectGrp.RowSpan = [ 1, 1 ];
objectGrp.ColSpan = [ 1, 2 ];
objectGrp.Items = objdlgstruct.Items;
if isfield( objdlgstruct, 'LayoutGrid' )
objectGrp.LayoutGrid = objdlgstruct.LayoutGrid;
end 
if isfield( objdlgstruct, 'RowStretch' )
objectGrp.RowStretch = objdlgstruct.RowStretch;
end 
if isfield( objdlgstruct, 'ColStretch' )
objectGrp.ColStretch = objdlgstruct.ColStretch;
end 

dlgStruct = objdlgstruct;
dlgStruct.Items = { objectGrp, entryMetadataGrp };
dlgStruct.LayoutGrid = [ 2, 2 ];
dlgStruct.RowStretch = [ 0, 0 ];
dlgStruct.ColStretch = [ 0, 0 ];



dlgStruct.PreApplyArgs = { '%dialog', 'doPreApply', h };
dlgStruct.PreApplyCallback = 'sl_get_dialog_schema_cb';
dlgStruct.PostApplyArgs = { '%dialog', 'doPostApply', h };
dlgStruct.PostApplyCallback = 'sl_get_dialog_schema_cb';
dlgStruct.HelpMethod = 'helpview';
dlgStruct.HelpArgs = { [ docroot, '/mapfiles/simulink.map' ], 'datadictionary' };

end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpHfST1Q.p.
% Please follow local copyright laws when handling this file.

