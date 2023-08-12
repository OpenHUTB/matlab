classdef DesignView < handle






properties 

Design
end 

properties 
DesignFrequencySection
DesignFrequencyLabel
ImpedanceLabel
DesignFrequencyEditField
ImpedanceEditField
DesignFrequencyUnitDropdown
ImpedanceUnitLabel
UpdateDesignButton
end 

methods 

function obj = DesignView( Design, options )

R36
Design( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Design{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.model.Design;
options.Parent( 1, 1 )matlab.ui.internal.toolstrip.Tab{ mustBeNonempty } = matlab.ui.internal.toolstrip.Tab( 'Design' );
end 
obj.Design = Design;


create( obj, options.Parent );
log( obj.Design.Logger, '% Design frequency section created.' );
end 


function update( obj )
obj.UpdateDesignButton.Enabled = true;
end 
end 

methods ( Access = private )

function create( obj, Tab )
R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.DesignView{ mustBeNonempty };
Tab( 1, 1 )matlab.ui.internal.toolstrip.Tab{ mustBeNonempty };
end 

import matlab.ui.internal.toolstrip.*;

[ frequency, unit ] = generateAppFrequency( obj.Design );
unitIndex = find( strcmp( obj.Design.UNITS, unit ) );
unitIndex = unitIndex( 1 );


obj.DesignFrequencySection = Section( 'Design Inputs' );
obj.DesignFrequencySection.Tag = 'designParametersSection';
Tab.add( obj.DesignFrequencySection );

labelColumn = obj.DesignFrequencySection.addColumn( 'Width', 115 );
labelColumn.Tag = 'designLabelsColumn';
obj.DesignFrequencyLabel = Label( 'Design Frequency' );
obj.DesignFrequencyLabel.Tag = 'designFrequencyLabel';
labelColumn.add( obj.DesignFrequencyLabel );

obj.ImpedanceLabel = Label( 'Impedance' );
obj.ImpedanceLabel.Tag = 'impedanceLabel';
labelColumn.add( obj.ImpedanceLabel );

editFieldColumn = obj.DesignFrequencySection.addColumn( 'Width', 75 );
editFieldColumn.Tag = 'designEditFieldsColumn';
obj.DesignFrequencyEditField = EditField( frequency );
obj.DesignFrequencyEditField.Description = getString( message( 'rfpcb:transmissionlinedesigner:DesignFrequency' ) );
obj.DesignFrequencyEditField.Tag = 'designFrequencyEditField';
editFieldColumn.add( obj.DesignFrequencyEditField );

obj.ImpedanceEditField = EditField( rfpcb.internal.apps.numeric2str( obj.Design.Impedance ) );
obj.ImpedanceEditField.Description = getString( message( 'rfpcb:transmissionlinedesigner:Impedance' ) );
obj.ImpedanceEditField.Tag = 'impedanceEditField';
editFieldColumn.add( obj.ImpedanceEditField );

unitColumn = obj.DesignFrequencySection.addColumn( 'Width', 65 );
unitColumn.Tag = 'designUnitColumn';
obj.DesignFrequencyUnitDropdown = DropDown(  );
obj.DesignFrequencyUnitDropdown.Description = getString( message( 'rfpcb:transmissionlinedesigner:DesignFrequencyUnit' ) );
obj.DesignFrequencyUnitDropdown.replaceAllItems( obj.Design.UNITS );
obj.DesignFrequencyUnitDropdown.SelectedIndex = unitIndex;
obj.DesignFrequencyUnitDropdown.Tag = 'designFrequencyUnitDropdown';
unitColumn.add( obj.DesignFrequencyUnitDropdown );
obj.ImpedanceUnitLabel = Label( 'ohm' );
unitColumn.add( obj.ImpedanceUnitLabel );

updateDesignColumn = obj.DesignFrequencySection.addColumn(  );
updateDesignColumn.Tag = 'updateDesignColumn';
obj.UpdateDesignButton = Button( 'Update Design', Icon.RUN_24 );
obj.UpdateDesignButton.Description = getString( message( 'rfpcb:transmissionlinedesigner:UpdateDesignButton' ) );
obj.UpdateDesignButton.Tag = 'updateDesignButton';
updateDesignColumn.add( obj.UpdateDesignButton );
end 

end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpCe6fnB.p.
% Please follow local copyright laws when handling this file.

