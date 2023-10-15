function assessStructArray = updateAssessmentStructIDs( assessStructArray, idx )

arguments
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
