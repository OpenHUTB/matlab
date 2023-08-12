classdef Toolstrip < handle & matlab.mixin.SetGet






properties ( Access = protected )
App
Model
end 

properties ( Access = protected, Dependent )
hMessageTag
end 

methods 

function rtn = get.hMessageTag( obj )
switch obj.Model.Tag
case 'transmissionLineDesigner'
rtn = 'rfpcb:transmissionlinedesigner';
end 
end 
end 

methods ( Access = protected )
function obj = Toolstrip( Model, App )



obj.App = App;
obj.Model = Model;
end 
end 

methods ( Access = protected )



function createDefaultLayoutSection( obj, options )
R36
obj
options.AccessTab = 'DesignerTab';
options.AccessButton = 'DefaultLayoutNewTab';
options.Tag = 'defaultLayoutNewTab';
end 
import matlab.ui.internal.toolstrip.*;

layoutSection = Section( 'Layout' );
layoutSection.Tag = 'layoutSection';
obj.App.( options.AccessTab ).add( layoutSection );
layoutBtnCol = layoutSection.addColumn(  );
layoutBtnCol.Tag = 'layoutColumn';
obj.App.( options.AccessButton ) = Button( 'Default Layout', Icon.LAYOUT_24 );
obj.App.( options.AccessButton ).Description = getString( message( "rfpcb:transmissionlinedesigner:DefaultLayoutButton" ) );
obj.App.( options.AccessButton ).Tag = options.Tag;
layoutBtnCol.add( obj.App.( options.AccessButton ) );
end 

end 
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmp7BMZQm.p.
% Please follow local copyright laws when handling this file.

