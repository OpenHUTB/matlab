function mustBeTimeStep(value)
    try
        mustBeScalarOrEmpty(value);
        mustBeA(value,["duration","calendarDuration"]);
    catch ME
        eid="MATLAB:timetable:InvalidTimeStep";
        error(message(eid));
    end
end