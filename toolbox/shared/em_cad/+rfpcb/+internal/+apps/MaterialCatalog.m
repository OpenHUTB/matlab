classdef MaterialCatalog < handle





properties 
PanelView
end 

methods 
function obj = MaterialCatalog( PanelView )


R36
PanelView( 1, 1 )rfpcb.internal.apps.PropertyPanelView
end 
obj.PanelView = PanelView;
end 

function rtn = autoPopulate( obj, src )










import rfpcb.internal.apps.*;

valueString = 'Value';
if strcmp( src.UserData.PropertyName, 'Name' )
chooseMaterial = src.( valueString );
switch class( src.UserData.ParentObject )
case 'metal'

Catalog = MetalCatalog;
CatalogList = Catalog.Materials.Name;
if any( strcmpi( CatalogList, chooseMaterial ) )

numConduct = Catalog.Materials.Conductivity( strcmpi( CatalogList, chooseMaterial ) );
src.UserData.ParentObject.Conductivity = numConduct;
obj.PanelView.PropertyEditFields{ src.UserData.Index + 1 }.( valueString ) =  ...
numeric2str( numConduct );
obj.PanelView.PropertyEditFields{ src.UserData.Index + 1 }.UserData.PreviousValue =  ...
numeric2str( numConduct );

thickness = applyUnit( obj.PanelView.Model,  ...
Catalog.Materials.Thickness( strcmpi( CatalogList, chooseMaterial ) ),  ...
Catalog.Materials.Units{ strcmpi( CatalogList, chooseMaterial ) } );
src.UserData.ParentObject.Thickness = thickness;
obj.PanelView.PropertyEditFields{ src.UserData.Index + 2 }.( valueString ) =  ...
numeric2str( thickness );
obj.PanelView.PropertyEditFields{ src.UserData.Index + 2 }.UserData.PreviousValue =  ...
numeric2str( thickness );

updateCatalog( chooseMaterial );
end 
case 'dielectric'

Catalog = DielectricCatalog;
CatalogList = Catalog.Materials.Name;






chooseMaterial = strsplit( chooseMaterial, ',' );
chooseMaterial = strtrim( chooseMaterial );
if iscell( chooseMaterial )

if any( cell2mat( cellfun( @( x )any( strcmpi( CatalogList, x ) ),  ...
chooseMaterial, 'UniformOutput', false ) ) )
isPresent = 1;
else 
isPresent = 0;
end 
noOfMaterials = length( chooseMaterial );

src.UserData.ParentObject.Name = chooseMaterial;
else 
if any( strcmpi( CatalogList, chooseMaterial ) )
isPresent = 1;
else 
isPresent = 0;
end 
noOfMaterials = 1;
end 

if isPresent
thicknessVector = zeros( 1, noOfMaterials );
epsilonRVector = zeros( 1, noOfMaterials );
lossTangentVector = zeros( 1, noOfMaterials );


chooseThickness = src.UserData.ParentObject.Parent.Height;


for m = 1:noOfMaterials
if iscell( chooseMaterial )
currMaterial = chooseMaterial{ m };
else 
currMaterial = chooseMaterial;
end 



try 
SubstrateChosen = dielectric( currMaterial );
epsilonRVector( m ) = SubstrateChosen.EpsilonR;
lossTangentVector( m ) = SubstrateChosen.LossTangent;
catch 


epsilonRVector( m ) = 1;
lossTangentVector( m ) = 0;
end 
end 

for s = 1:noOfMaterials
thicknessVector( s ) = chooseThickness / noOfMaterials;
end 



src.UserData.ParentObject.EpsilonR = epsilonRVector;
obj.PanelView.PropertyEditFields{ src.UserData.Index + 1 }.( valueString ) =  ...
numeric2str( epsilonRVector );
obj.PanelView.PropertyEditFields{ src.UserData.Index + 1 }.UserData.PreviousValue =  ...
numeric2str( epsilonRVector );

src.UserData.ParentObject.LossTangent = lossTangentVector;
obj.PanelView.PropertyEditFields{ src.UserData.Index + 2 }.( valueString ) =  ...
numeric2str( lossTangentVector );
obj.PanelView.PropertyEditFields{ src.UserData.Index + 2 }.UserData.PreviousValue =  ...
numeric2str( lossTangentVector );

src.UserData.ParentObject.Thickness = thicknessVector;
obj.PanelView.PropertyEditFields{ src.UserData.Index + 3 }.( valueString ) =  ...
numeric2str( thicknessVector );
obj.PanelView.PropertyEditFields{ src.UserData.Index + 3 }.UserData.PreviousValue =  ...
numeric2str( thicknessVector );

if noOfMaterials == 1 && isPresent
updateCatalog( chooseMaterial );
else 
updateCatalog( 'Multiple' );
end 
end 
end 
rtn = chooseMaterial;
else 
rtn = src.( valueString );
end 
function updateCatalog( materialName )

obj.PanelView.PropertyEditFields{ src.UserData.Index - 1 }.Value =  ...
obj.PanelView.PropertyEditFields{ src.UserData.Index - 1 }.Items{  ...
strcmpi( obj.PanelView.PropertyEditFields{ src.UserData.Index - 1 }.Items, materialName ) };
end 
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmph4xubQ.p.
% Please follow local copyright laws when handling this file.

