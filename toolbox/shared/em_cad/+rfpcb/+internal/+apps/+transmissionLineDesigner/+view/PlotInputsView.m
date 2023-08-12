classdef PlotInputsView < handle






properties 
AnalysisPlots
end 

properties 
PlotInputsSection
PlotFrequencyLabel
PlotFrequencyEditField
PlotFrequencyUnitDropdown
FrequencyRangeLabel
FrequencyRangeEditField
FrequencyRangeUnitDropdown

PlotsDropdownGalleryButton
PlotsGalleryPopup
PlotsDropdownGallery
PlotsGalleryCategory
SparametersButton
CurrentButton
ChargeButton
end 

methods 

function obj = PlotInputsView( AnalysisPlots, options )




R36
AnalysisPlots( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.AnalysisPlots{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.model.AnalysisPlots;
options.Parent( 1, 1 )matlab.ui.internal.toolstrip.Tab{ mustBeNonempty } = matlab.ui.internal.toolstrip.Tab( 'Design' );
end 
obj.AnalysisPlots = AnalysisPlots;


create( obj, options.Parent );
log( obj.AnalysisPlots.Logger, '% Plot Inputs section created.' );
end 


function enable( obj )

if isempty( obj.AnalysisPlots.TransmissionLine )
obj.PlotInputsSection.disableAll;
else 
obj.PlotInputsSection.enableAll;
end 
end 


function update( obj )


R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.PlotInputsView
end 

enable( obj );
end 
end 

methods ( Access = private )

function create( obj, Tab )


R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.PlotInputsView{ mustBeNonempty };
Tab( 1, 1 )matlab.ui.internal.toolstrip.Tab{ mustBeNonempty };
end 

import matlab.ui.internal.toolstrip.*;

[ frequency, unit ] = generateAppFrequency( obj.AnalysisPlots );
[ rangeString, ~ ] = generateFreqRange( obj.AnalysisPlots );
unitIndex = find( strcmp( obj.AnalysisPlots.UNITS, unit ) );
unitIndex = unitIndex( 1 );


obj.PlotInputsSection = Section( 'Plot Inputs' );
obj.PlotInputsSection.Tag = 'plotInputsSection';
Tab.add( obj.PlotInputsSection );

labelColumn = obj.PlotInputsSection.addColumn( 'Width', 115 );
labelColumn.Tag = 'plotFrequencyLabelsColumn';
obj.PlotFrequencyLabel = Label( 'Plot Frequency' );
obj.PlotFrequencyLabel.Tag = 'plotFrequencyLabel';
labelColumn.add( obj.PlotFrequencyLabel );

obj.FrequencyRangeLabel = Label( 'Frequency Range' );
obj.FrequencyRangeLabel.Tag = 'frequencyRangeLabel';
labelColumn.add( obj.FrequencyRangeLabel );

editFieldColumn = obj.PlotInputsSection.addColumn( 'Width', 75 );
editFieldColumn.Tag = 'plotFrequencyEditFieldColumn';
obj.PlotFrequencyEditField = EditField( frequency );
obj.PlotFrequencyEditField.Description = getString( message( 'rfpcb:transmissionlinedesigner:DesignFrequency' ) );
obj.PlotFrequencyEditField.Tag = 'plotFrequencyEditField';
editFieldColumn.add( obj.PlotFrequencyEditField );

obj.FrequencyRangeEditField = EditField( rangeString );
obj.FrequencyRangeEditField.Description = getString( message( 'rfpcb:transmissionlinedesigner:DesignFrequency' ) );
obj.FrequencyRangeEditField.Tag = 'frequencyRangeEditField';
editFieldColumn.add( obj.FrequencyRangeEditField );

unitColumn = obj.PlotInputsSection.addColumn( 'Width', 65 );
unitColumn.Tag = 'plotFrequencyUnitsColumn';
obj.PlotFrequencyUnitDropdown = DropDown(  );
obj.PlotFrequencyUnitDropdown.Description = getString( message( 'rfpcb:transmissionlinedesigner:DesignFrequencyUnit' ) );
obj.PlotFrequencyUnitDropdown.replaceAllItems( obj.AnalysisPlots.UNITS );
obj.PlotFrequencyUnitDropdown.SelectedIndex = unitIndex;
obj.PlotFrequencyUnitDropdown.Tag = 'plotFrequencyUnitDropdown';
unitColumn.add( obj.PlotFrequencyUnitDropdown );

obj.FrequencyRangeUnitDropdown = DropDown(  );
obj.FrequencyRangeUnitDropdown.Description = getString( message( 'rfpcb:transmissionlinedesigner:DesignFrequencyUnit' ) );
obj.FrequencyRangeUnitDropdown.replaceAllItems( obj.AnalysisPlots.UNITS );
obj.FrequencyRangeUnitDropdown.SelectedIndex = unitIndex;
obj.FrequencyRangeUnitDropdown.Tag = 'frequencyRangeUnitDropdown';
unitColumn.add( obj.FrequencyRangeUnitDropdown );

dropdownGalleryCol = obj.PlotInputsSection.addColumn(  );
dropdownGalleryCol.Tag = 'plotsGalleryColumn';

obj.PlotsGalleryPopup = GalleryPopup( 'GalleryItemTextLineCount', 1 );
obj.PlotsGalleryPopup.Tag = 'plotsGalleryPopup';

iconPath = fullfile( matlabroot, 'toolbox', 'shared', 'em_cad', '+rfpcb', '+internal', '+apps', '+transmissionLineDesigner', '+src', 'analysisPlots.png' );
obj.PlotsDropdownGalleryButton = DropDownGalleryButton( obj.PlotsGalleryPopup, 'Add Plots', iconPath );
obj.PlotsDropdownGalleryButton.Tag = 'plotsDropdownGalleryButton';

obj.PlotsDropdownGallery = Gallery( obj.PlotsGalleryPopup,  ...
'MaxColumnCount', 1,  ...
'MinColumnCount', 1 );
obj.PlotsDropdownGallery.Tag = 'plotsDropdownGallery';

obj.PlotsGalleryCategory = GalleryCategory( 'Plots' );
obj.PlotsGalleryPopup.add( obj.PlotsGalleryCategory );

iconPath = fullfile( matlabroot, 'toolbox', 'shared', 'em_cad', '+rfpcb', '+internal', '+apps', '+transmissionLineDesigner', '+src', '+analysisIcons', 'sparameters.png' );
obj.SparametersButton = ToggleGalleryItem( 'Sparameters', iconPath );
obj.SparametersButton.Description = getString( message( 'rfpcb:transmissionlinedesigner:SparametersButton' ) );
obj.SparametersButton.Tag = 'sparametersButton';
obj.PlotsGalleryCategory.add( obj.SparametersButton );

iconPath = fullfile( matlabroot, 'toolbox', 'shared', 'em_cad', '+rfpcb', '+internal', '+apps', '+transmissionLineDesigner', '+src', '+analysisIcons', 'current.png' );
obj.CurrentButton = ToggleGalleryItem( 'Current', iconPath );
obj.CurrentButton.Description = getString( message( 'rfpcb:transmissionlinedesigner:CurrentButton' ) );
obj.CurrentButton.Tag = 'currentButton';
obj.PlotsGalleryCategory.add( obj.CurrentButton );

iconPath = fullfile( matlabroot, 'toolbox', 'shared', 'em_cad', '+rfpcb', '+internal', '+apps', '+transmissionLineDesigner', '+src', '+analysisIcons', 'charge.png' );
obj.ChargeButton = ToggleGalleryItem( 'Charge', iconPath );
obj.ChargeButton.Description = getString( message( 'rfpcb:transmissionlinedesigner:ChargeButton' ) );
obj.ChargeButton.Tag = 'chargeButton';
obj.PlotsGalleryCategory.add( obj.ChargeButton );

dropdownGalleryCol.add( obj.PlotsDropdownGalleryButton );

Tab.add( obj.PlotInputsSection );

obj.PlotInputsSection.disableAll;
end 
end 
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpOIOtip.p.
% Please follow local copyright laws when handling this file.

