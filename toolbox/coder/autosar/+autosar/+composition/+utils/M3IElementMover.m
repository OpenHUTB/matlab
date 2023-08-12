classdef M3IElementMover < handle





properties ( Constant, Access = private )
XmlOptionPackageToClassNameMap = containers.Map(  ...
{ 'InterfacePackage',  ...
'CompuMethodPackage',  ...
'ConstantSpecificationPackage',  ...
'DataTypeMappingPackage',  ...
'ModeDeclarationGroupPackage',  ...
'SwAddressMethodPackage',  ...
'SwBaseTypePackage',  ...
'SwRecordLayoutPackage',  ...
'SystemConstantPackage',  ...
'UnitPackage' },  ...
{ 'Simulink.metamodel.arplatform.interface.PortInterface',  ...
'Simulink.metamodel.types.CompuMethod',  ...
'Simulink.metamodel.types.ConstantSpecification',  ...
'Simulink.metamodel.arplatform.common.DataTypeMappingSet',  ...
'Simulink.metamodel.arplatform.common.ModeDeclarationGroup',  ...
'Simulink.metamodel.arplatform.common.SwAddrMethod',  ...
'Simulink.metamodel.types.SwBaseType',  ...
'Simulink.metamodel.types.SwRecordLayout',  ...
'Simulink.metamodel.arplatform.variant.SystemConst',  ...
'Simulink.metamodel.types.Unit' } );
end 

properties ( SetAccess = immutable, GetAccess = private )
ModelName;
M3IModel;
M3IMappedComponent;
ARPropsObj;
end 

methods ( Access = public )
function this = M3IElementMover( modelName )
this.ModelName = modelName;
this.M3IModel = autosar.api.Utils.m3iModel( modelName );
this.M3IMappedComponent = autosar.api.Utils.m3iMappedComponent( modelName );
this.ARPropsObj = autosar.api.getAUTOSARProperties( this.ModelName, true );
end 

function moveElementsToMatchXmlOptions( this )




this.moveAppAndImpDataTypes(  );
this.moveDataConstraints(  );
this.moveAllPackagedElements(  );
end 

function moveMappedComponent( this, dstPkg )

newCompQName = [ dstPkg, '/', this.M3IMappedComponent.Name ];
currentCompQName = autosar.api.Utils.getQualifiedName( this.M3IMappedComponent );
if ~strcmp( currentCompQName, newCompQName )
this.ARPropsObj.set( 'XmlOptions', 'ComponentQualifiedName', newCompQName );
end 
end 
end 

methods ( Static, Access = public )
function moveElementsByMetaClass( metaClass, dstPkg, m3iModel )



m3iPkgElms = autosar.mm.Model.findObjectByMetaClass( m3iModel, metaClass, true, true );

autosar.composition.utils.M3IElementMover.moveElements(  ...
m3iPkgElms, dstPkg );
end 

function moveElementsByNameAndMetaClass( elementName, metaClass, dstPkg, m3iModel, namedargs )
R36
elementName
metaClass
dstPkg
m3iModel
namedargs.CaseSensitive = false;
namedargs.UserFilter = [  ];
end 

caseSensitive = namedargs.CaseSensitive;

if isempty( dstPkg )
return ;
end 



m3iElements = autosar.mm.Model.findObjectByMetaClass( m3iModel, metaClass, true, true );

if ~isempty( namedargs.UserFilter )
m3iElements = m3i.filterSeq( namedargs.UserFilter, m3iElements );
end 

m3iElements = m3i.filterSeq( @( x )( caseSensitive && strcmp( elementName, x.Name ) ) ||  ...
( ~caseSensitive && strcmpi( elementName, x.Name ) ), m3iElements );

for i = 1:m3iElements.size(  )
m3iElement = m3iElements.at( i );
autosar.composition.utils.M3IElementMover.moveElement( m3iElement, dstPkg );
end 
end 
end 

methods ( Access = private )


function moveAppAndImpDataTypes( this )




import autosar.mm.util.XmlOptionsDefaultPackages


dataTypePkg = XmlOptionsDefaultPackages.getXmlOptionsPackage( this.ModelName, 'DataTypePackage' );
applicationTypesPkg = XmlOptionsDefaultPackages.getXmlOptionsPackage( this.ModelName, 'ApplicationDataTypePackage' );


metaClass = Simulink.metamodel.foundation.ValueType.MetaClass;
m3iDataTypes = autosar.mm.Model.findObjectByMetaClass( this.M3IModel, metaClass, true, true );
m3iAppDataTypes = m3i.filterSeq( @( x )x.IsApplication, m3iDataTypes );
m3iImpDataTypes = m3i.filterSeq( @( x )~x.IsApplication, m3iDataTypes );




platformTypeNames = autosar.mm.util.BuiltInTypeMapper.getAUTOSARPlatformTypeNames( isAdaptive = false );
m3iImpDataTypes = m3i.filterSeq( @( x )~any( strcmp( platformTypeNames, x.Name ) ), m3iImpDataTypes );


autosar.composition.utils.M3IElementMover.moveElements(  ...
m3iAppDataTypes, applicationTypesPkg );


autosar.composition.utils.M3IElementMover.moveElements(  ...
m3iImpDataTypes, dataTypePkg );
end 


function moveDataConstraints( this )


import autosar.mm.util.XmlOptionsDefaultPackages


dataConstrsPkg = XmlOptionsDefaultPackages.getXmlOptionsPackage( this.ModelName, 'DataConstraintPackage' );
internalDataConstrsPkg = XmlOptionsDefaultPackages.getXmlOptionsPackage( this.ModelName, 'InternalDataConstraintPackage' );


metaClass = Simulink.metamodel.types.DataConstr.MetaClass;
m3iConstrs = autosar.mm.Model.findObjectByMetaClass( this.M3IModel, metaClass, true, true );

fh = @( x )( x.PrimitiveType.size(  ) > 0 && x.PrimitiveType.at( 1 ).IsApplication );
fhNegate = @( x )( x.PrimitiveType.size(  ) <= 0 || ~x.PrimitiveType.at( 1 ).IsApplication );
m3iDataConstrs = m3i.filterSeq( fh, m3iConstrs );
m3iInternalDataConstrs = m3i.filterSeq( fhNegate, m3iConstrs );


autosar.composition.utils.M3IElementMover.moveElements(  ...
m3iDataConstrs, dataConstrsPkg );

autosar.composition.utils.M3IElementMover.moveElements(  ...
m3iInternalDataConstrs, internalDataConstrsPkg );
end 

function moveAllPackagedElements( this )



import autosar.mm.util.XmlOptionsDefaultPackages
import autosar.mm.util.XmlOptionsAdapter

xmlOptionPackages = this.XmlOptionPackageToClassNameMap.keys;

m3iModelContext = autosar.api.internal.M3IModelContext.createContext(  ...
this.ModelName );
relevantPkgs = XmlOptionsAdapter.getXmlOptionNamesForPackages( m3iModelContext );


relevantPkgs = [ relevantPkgs, { 'InterfacePackage' } ];

pkgsForMove = xmlOptionPackages( ismember( xmlOptionPackages, relevantPkgs ) );
for i = 1:length( pkgsForMove )

dstPkg = XmlOptionsDefaultPackages.getXmlOptionsPackage( this.ModelName, pkgsForMove{ i } );
className = this.XmlOptionPackageToClassNameMap( pkgsForMove{ i } );
metaClass = eval( [ className, '.MetaClass' ] );
autosar.composition.utils.M3IElementMover.moveElementsByMetaClass(  ...
metaClass, dstPkg, this.M3IModel );
end 
end 
end 

methods ( Static, Access = private )

function moveElements( m3iPkgElms, dstPkg )

for ii = 1:m3iPkgElms.size(  )
m3iPkgElm = m3iPkgElms.at( ii );
autosar.composition.utils.M3IElementMover.moveElement( m3iPkgElm, dstPkg );
end 
end 

function moveElement( m3iPkgElm, dstPkg )

if ~isa( m3iPkgElm.containerM3I, 'Simulink.metamodel.arplatform.common.Package' )
return 
end 
if ~autosar.composition.utils.M3IElementMover.shouldMoveElement( m3iPkgElm )
return 
end 
m3iPkgSrc = m3iPkgElm.containerM3I;
m3iPkgDest = autosar.mm.Model.getOrAddARPackage( m3iPkgElm.rootModel, dstPkg );
if ~isequal( m3iPkgDest, m3iPkgSrc )
autosar.composition.utils.M3IElementMover.appendPackagedElement( m3iPkgElm, m3iPkgDest );
end 
end 

function appendPackagedElement( m3iPkgElm, m3iPkgDest )


if ~any( strcmp( m3i.mapcell( @( x )x.Name, m3iPkgDest.packagedElement ), m3iPkgElm.Name ) )
m3iPkgDest.packagedElement.append( m3iPkgElm );
end 
end 

function moveIt = shouldMoveElement( m3iPkgElm )

if autosar.mm.arxml.Exporter.isExternalReference( m3iPkgElm )

moveIt = false;
return ;
elseif autosar.mm.arxml.Exporter.isPackagedElementImported( m3iPkgElm )

moveIt = false;
return ;
elseif isa( m3iPkgElm, 'Simulink.metamodel.arplatform.interface.ParameterInterface' )








moveIt = false;
return ;
else 
moveIt = true;
end 
end 
end 
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpO6LuAz.p.
% Please follow local copyright laws when handling this file.

