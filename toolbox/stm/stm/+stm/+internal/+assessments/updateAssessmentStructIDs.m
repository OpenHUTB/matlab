





function assessStructArray = updateAssessmentStructIDs( assessStructArray, idx )

R36
assessStructArray
idx( 1, 1 )double
end 

for i = 1:length( assessStructArray )
assessStructArray{ i }.id = assessStructArray{ i }.id + idx;
if assessStructArray{ i }.parent ~=  - 1
assessStructArray{ i }.parent = assessStructArray{ i }.parent + idx;
end 
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp5hU5_6.p.
% Please follow local copyright laws when handling this file.

