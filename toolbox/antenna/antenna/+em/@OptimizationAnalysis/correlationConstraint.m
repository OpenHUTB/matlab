% function constraintvalue = correlationConstraint(obj, propValues)
% % Initialize
% 
% DesiredCorrelation = obj.OptimStruct.Value{strcmpi(obj.OptimStruct.ConstraintsFunctionName, 'Correlation')};
% operator = obj.OptimStruct.Operator{strcmpi(obj.OptimStruct.ConstraintsFunctionName, 'Correlation')};
% checkConsVal = 0;
% ConflictingBound = false;
% 
% % Set
% setValues2Antenna(obj, propValues);
% 
% % Analyze
% try
%     element1 = 1;
%     element2 = 2;
%     corr(1) = correlation(obj, obj.OptimStruct.Bandwidth, element1, element2);
%     checkConsVal = mean(corr);
% catch ME
%     ConflictingBound = true;
% end
% 
% % Return
% constraintvalue = processConstraint(obj, DesiredCorrelation, checkConsVal, operator, ConflictingBound, checkConsVal, 'Correlation');
% end