function mustBeStartTime(value)



    try
        mustBeScalarOrEmpty(value);
        mustBeA(value,["duration","datetime"]);
    catch ME
        eid="MATLAB:timetable:InvalidStartTime";
        error(message(eid));
    end
end