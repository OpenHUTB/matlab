function returnValue = selectiveParamUndoRedoAlwaysApplyHelper( requestedAction )







persistent blockMaskTypesCell;

if isempty( blockMaskTypesCell ) && ~iscell( blockMaskTypesCell )
blockMaskTypesCell = {  ...
'SubSystem::Digital DATCOM Forces and Moments',  ...
'PMComponent::LC Bandpass Pi',  ...
'PMComponent::Coplanar Waveguide Transmission Line',  ...
'PMComponent::S-Parameters Amplifier',  ...
'MATLABSystem::ASystemObjectThatCannotBeFoundNow' };
end 

if strcmp( requestedAction, 'GetList' )
returnValue = blockMaskTypesCell;
else 
returnValue = [  ];
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpZ0hP2m.p.
% Please follow local copyright laws when handling this file.

