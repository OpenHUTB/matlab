classdef GalleryView < rfpcb.internal.apps.AppGallery





methods 
function obj = GalleryView( Model, App )


obj@rfpcb.internal.apps.AppGallery( Model, App );
end 

function constructGalleryView( obj, options )
R36
obj
options.Path char = '';
options.GalleryItemTextLineCount = 1;
options.MaxColumnCount = 5;
options.MinColumnCount = 3;
options.Tag = 'transmissionLineGallery';
options.Names cell = obj.Model.Names;
end 
import matlab.ui.internal.toolstrip.*;


obj.galleryPopup = GalleryPopup( 'ShowSelection', true,  ...
'GalleryItemTextLineCount', options.GalleryItemTextLineCount );
constructGalleryItems( obj, 'Path', options.Path, 'Names', options.Names );


dispatchGalleryItems( obj );
for i = 1:length( obj.galleryCats )

obj.galleryPopup.add( obj.galleryCats{ i } );
end 


obj.gallery = Gallery( obj.galleryPopup, 'MaxColumnCount',  ...
options.MaxColumnCount,  ...
'MinColumnCount',  ...
options.MinColumnCount );
obj.gallery.Tag = options.Tag;
end 

function updateGallery( obj )


obj.galleryPopup.disableAll(  );
enableRemainingItems( obj );
end 


function constructGalleryItems( obj, options )


R36
obj
options.Path char = '';
options.Names cell = obj.Model.Names;
end 
import matlab.ui.internal.toolstrip.*;


if isempty( options.Path )
path = fullfile( matlabroot, 'toolbox',  ...
'shared', 'em_cad', '+rfpcb', '+internal',  ...
'+apps', '+transmissionLineDesigner', '+src' );
else 
path = options.Path;
end 

obj.galleryItems = {  };
for i = 1:length( options.Names )
tmpName = [ newline, obj.Model.NickNames{ i } ];

if ispc
iconPath = [ path ...
, '\', options.Names{ i }, '.png' ];
else 
iconPath = [ path ...
, '/', options.Names{ i }, '.png' ];
end 

obj.galleryItems{ end  + 1 } = ToggleGalleryItem( tmpName, Icon.MATLAB_24 );
obj.galleryItems{ end  }.Tag = options.Names{ i };
obj.galleryItems{ end  }.Description = getString( message( 'rfpcb:transmissionlinedesigner:TransmissionLineGallery', options.Names{ i } ) );
end 
end 


function dispatchGalleryItems( obj )

import matlab.ui.internal.toolstrip.*;
obj.galleryCats = {  };

categories = unique( obj.Model.Families );
for i = 1:length( categories )

obj.galleryCats{ end  + 1 } = GalleryCategory( categories{ i } );
obj.categoryItems{ end  + 1 } = {  };
end 
for i = 1:length( obj.Model.Names )
[ ~, index ] = ismember( obj.Model.Families{ i }, categories );
obj.galleryCats{ index }.add( obj.galleryItems{ i } );
obj.categoryItems{ index }{ end  + 1 } = obj.galleryItems{ i };
end 
end 

function enableRemainingItems( obj )




for i = 1:length( obj.categoryItems )
for j = 1:length( obj.categoryItems{ i } )
[ flg, ~ ] = ismember( obj.categoryItems{ i }{ j }.Tag, obj.Model.FilteredAntennas );
if flg
obj.categoryItems{ i }{ j }.Enabled = true;
end 
end 
end 
end 

function rtn = getEnabledItems( obj )


rtn = {  };
for i = 1:length( obj.galleryItems )
if obj.galleryItems{ i }.Enabled
rtn{ end  + 1 } = obj.galleryItems{ i };%#ok<AGROW>
end 
end 
end 

end 
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpRv32sj.p.
% Please follow local copyright laws when handling this file.

