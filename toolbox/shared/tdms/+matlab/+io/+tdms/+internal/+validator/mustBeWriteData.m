function mustBeWriteData(value)



    try
        mustBeA(value,["cell","table","timetable"]);
        if iscell(value)
            for v=value
                matlab.io.tdms.internal.validator.mustBeWriteDataTable(v{1});
            end
        else
            matlab.io.tdms.internal.validator.mustBeWriteDataTable(value);
        end
    catch ME
        if ME.identifier=="MATLAB:validators:mustBeA"
            eid="tdms:TDMS:InvalidWriteData";
            throwAsCaller(MException(eid,message(eid,class(value))));
        else
            throwAsCaller(ME)
        end
    end
end

