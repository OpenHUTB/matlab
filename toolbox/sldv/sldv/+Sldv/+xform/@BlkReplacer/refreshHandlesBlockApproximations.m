function refreshHandlesBlockApproximations( obj )




approxErrorsInfo = obj.ApproxErrorsInfo;
if ~isempty( approxErrorsInfo )
newApproxErrorsInfo = [  ];
for idx = 1:length( approxErrorsInfo )
errorData = approxErrorsInfo( idx );
errorDataMapped.blockH = get_param( errorData.blockFullPath, 'Handle' );
errorDataMapped.blockType = errorData.blockType;
errorDataMapped.maxError = errorData.maxError;
errorDataMapped.errorDetail = errorData.errorDetail;
if isempty( newApproxErrorsInfo )
newApproxErrorsInfo = errorDataMapped;
else 
newApproxErrorsInfo( end  + 1 ) = errorDataMapped;%#ok<AGROW>
end 
end 
obj.ApproxErrorsInfo = newApproxErrorsInfo;
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpkZevHY.p.
% Please follow local copyright laws when handling this file.

