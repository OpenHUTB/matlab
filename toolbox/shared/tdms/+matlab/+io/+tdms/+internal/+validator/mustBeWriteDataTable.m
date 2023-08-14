function mustBeWriteDataTable(value)




    try
        mustBeA(value,["table","timetable"]);
        mustBeNonempty(value.Properties.VariableNames);
    catch ME
        switch ME.identifier
        case "MATLAB:validators:mustBeA"
            eid="tdms:TDMS:InvalidWriteDataTable";
            throwAsCaller(MException(eid,message(eid,class(value))));
        case "MATLAB:validators:mustBeNonempty"
            eid="tdms:TDMS:MustHaveTableVariables";
            throwAsCaller(MException(eid,message(eid)));
        otherwise
            throwAsCaller(ME);
        end
    end
end

