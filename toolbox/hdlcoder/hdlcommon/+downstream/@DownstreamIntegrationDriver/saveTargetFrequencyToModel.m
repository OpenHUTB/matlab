function saveTargetFrequencyToModel( obj, modelName, targetFrequency )


if ~obj.isMLHDLC && ~obj.getloadingFromModel
if ( hdlget_param( modelName, 'TargetFrequency' ) ~= targetFrequency )
hdlset_param( modelName, 'TargetFrequency', targetFrequency );
end 
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpPrJHKO.p.
% Please follow local copyright laws when handling this file.

