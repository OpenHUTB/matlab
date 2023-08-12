classdef TransmissionLineGallery < handle




properties 
TransmissionLineGalleryModel
end 

properties 
ConfigurationSection

GalleryHandle
GalleryPopupHandle

GalleryCats

GalleryItems

CategoryItems
end 

methods 

function obj = TransmissionLineGallery( TransmissionLineGalleryModel, options )


R36
TransmissionLineGalleryModel( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.TransmissionLineGalleryModel{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.model.TransmissionLineGalleryModel;
options.Parent( 1, 1 )matlab.ui.internal.toolstrip.Tab{ mustBeNonempty } = matlab.ui.internal.toolstrip.Tab( 'Design' );
end 
obj.TransmissionLineGalleryModel = TransmissionLineGalleryModel;


create( obj, options.Parent );
log( obj.TransmissionLineGalleryModel.Logger, '% Configuration section created.' );
end 


function update( obj )


tLine = obj.TransmissionLineGalleryModel.TransmissionLine;
if isa( tLine, 'microstripLine' )
if sum( tLine.Substrate.Thickness ) > tLine.Height
tag = 'microstripBuried';
else 
tag = 'microstripLine';
end 
elseif isempty( tLine )
tag = '';
end 
selectItem( obj, tag );
end 
end 

methods ( Access = private )

function create( obj, Tab )

R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.TransmissionLineGallery{ mustBeNonempty };
Tab( 1, 1 )matlab.ui.internal.toolstrip.Tab{ mustBeNonempty };
end 

import matlab.ui.internal.toolstrip.*;


obj.ConfigurationSection = Section( 'Configuration' );
obj.ConfigurationSection.Tag = 'configurationSection';

galleryCol = obj.ConfigurationSection.addColumn(  );
galleryCol.Tag = 'transmissionLineGalleryColumn';
iconPath = fullfile( matlabroot, 'toolbox',  ...
'shared', 'em_cad', '+rfpcb', '+internal',  ...
'+apps', '+transmissionLineDesigner', '+src' );
constructGalleryView( obj );
galleryCol.add( obj.GalleryHandle );
Tab.add( obj.ConfigurationSection );
end 

function constructGalleryView( obj )

import matlab.ui.internal.toolstrip.*;


obj.GalleryPopupHandle = GalleryPopup( 'ShowSelection', true,  ...
'GalleryItemTextLineCount', obj.TransmissionLineGalleryModel.GalleryItemTextLineCount );
constructGalleryItems( obj );


dispatchGalleryItems( obj );
for i = 1:length( obj.GalleryCats )

obj.GalleryPopupHandle.add( obj.GalleryCats{ i } );
end 


obj.GalleryHandle = Gallery( obj.GalleryPopupHandle, 'MaxColumnCount',  ...
obj.TransmissionLineGalleryModel.MaxColumnCount,  ...
'MinColumnCount',  ...
obj.TransmissionLineGalleryModel.MinColumnCount );
obj.GalleryHandle.Tag = obj.TransmissionLineGalleryModel.Tag;
end 

function constructGalleryItems( obj )



import matlab.ui.internal.toolstrip.*;


path = obj.TransmissionLineGalleryModel.Path;


obj.GalleryItems = {  };
for i = 1:length( obj.TransmissionLineGalleryModel.Names )
tmpName = [ newline, obj.TransmissionLineGalleryModel.NickNames{ i } ];

if ispc
iconPath = [ path ...
, '\', obj.TransmissionLineGalleryModel.Names{ i }, '.png' ];
else 
iconPath = [ path ...
, '/', obj.TransmissionLineGalleryModel.Names{ i }, '.png' ];
end 

obj.GalleryItems{ end  + 1 } = ToggleGalleryItem( tmpName, iconPath );
obj.GalleryItems{ end  }.Tag = obj.TransmissionLineGalleryModel.Names{ i };
obj.GalleryItems{ end  }.Description = getString( message( 'rfpcb:transmissionlinedesigner:TransmissionLineGallery', obj.TransmissionLineGalleryModel.Names{ i } ) );
end 
end 


function dispatchGalleryItems( obj )

import matlab.ui.internal.toolstrip.*;
obj.GalleryCats = {  };

categories = unique( obj.TransmissionLineGalleryModel.Families );
for i = 1:length( categories )

obj.GalleryCats{ end  + 1 } = GalleryCategory( categories{ i } );
obj.CategoryItems{ end  + 1 } = {  };
end 
for i = 1:length( obj.TransmissionLineGalleryModel.Names )
[ ~, index ] = ismember( obj.TransmissionLineGalleryModel.Families{ i }, categories );
obj.GalleryCats{ index }.add( obj.GalleryItems{ i } );
obj.CategoryItems{ index }{ end  + 1 } = obj.GalleryItems{ i };
end 
end 

function selectItem( obj, itemName )

for i = 1:length( obj.GalleryItems )
if strcmp( itemName, obj.GalleryItems{ i }.Tag )


obj.GalleryItems{ i }.Value = true;
else 

obj.GalleryItems{ i }.Value = false;
end 
end 

end 
end 
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpp9aUYa.p.
% Please follow local copyright laws when handling this file.

