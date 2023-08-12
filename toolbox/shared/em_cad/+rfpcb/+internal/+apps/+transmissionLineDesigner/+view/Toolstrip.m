classdef Toolstrip < rfpcb.internal.apps.Toolstrip





methods 

function obj = Toolstrip( Model, App )


R36
Model( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.AppModel = rfpcb.internal.apps.transmissionLineDesigner.model.AppModel;
App( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.AppView = rfpcb.internal.apps.transmissionLineDesigner.view.AppView;
end 
obj@rfpcb.internal.apps.Toolstrip( Model, App );
create( obj );
end 


function enable( obj, varargin )








p = inputParser;
validSections = @( x )validatestring( x, { 'ConfigurationSection',  ...
'NewButton', 'OpenButton',  ...
'DesignFrequencySection' },  ...
'enable', 'Item' );
p.addParameter( 'Item', 'All', @( x )~isempty( validSections( x ) ) );
parse( p, varargin{ : } );

switch p.Results.Item
case 'All'
enableAll( obj.App.TabGroup )
otherwise 
enablingItem = get( obj.App, p.Results.Item );
if isa( enablingItem, 'matlab.ui.internal.toolstrip.Section' )
enableAll( enablingItem );
else 
enablingItem.Enabled = true;
end 
end 
end 

function disable( obj, varargin )









p = inputParser;
validSections = @( x )validatestring( x, { 'ConfigurationSection' }, 'disable', 'Item' );
p.addParameter( 'Item', 'All', @( x )~isempty( validSections( x ) ) );
parse( p, varargin{ : } );

switch p.Results.Item
case 'All'
disableAll( obj.App.TabGroup )
otherwise 
disablingItem = get( obj.App, p.Results.Item );
if isa( disablingItem, 'matlab.ui.internal.toolstrip.Section' )
disableAll( get( obj.App, p.Results.Item ) );
else 
disablingItem.Enabled = false;
end 
end 
end 


function create( obj )


import matlab.ui.internal.toolstrip.*;
obj.App.DesignTab = Tab( 'Design' );
obj.App.DesignTab.Tag = 'designerTab';


obj.App.FileSectionView = rfpcb.internal.apps.transmissionLineDesigner.view.FileSectionView( obj.Model.FileSectionModel, 'Parent', obj.App.DesignTab );


obj.App.TransmissionLineGallery = rfpcb.internal.apps.transmissionLineDesigner.view.TransmissionLineGallery( obj.Model.TransmissionLineGalleryModel, 'Parent', obj.App.DesignTab );


obj.App.DesignView = rfpcb.internal.apps.transmissionLineDesigner.view.DesignView( obj.Model.Design, 'Parent', obj.App.DesignTab );


obj.App.PlotInputsView = rfpcb.internal.apps.transmissionLineDesigner.view.PlotInputsView( obj.Model.AnalysisPlots, 'Parent', obj.App.DesignTab );


obj.App.SettingsView = rfpcb.internal.apps.transmissionLineDesigner.view.SettingsView( obj.Model.Settings, 'Parent', obj.App.DesignTab );


createDefaultLayoutSection( obj,  ...
'AccessTab', 'DesignTab',  ...
'AccessButton', 'DefaultLayoutButton',  ...
'Tag', 'defaultLayoutButton' );
log( obj.Model.Logger, '% Default Layout section created.' );


obj.App.ExportSectionView = rfpcb.internal.apps.transmissionLineDesigner.view.ExportSectionView( obj.Model.ExportSectionModel, 'Parent', obj.App.DesignTab );
end 
end 
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpIBy9qS.p.
% Please follow local copyright laws when handling this file.

