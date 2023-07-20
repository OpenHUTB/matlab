function mustBeSampleRate(value)




    try
        mustBePositive(value);
        mustBeNumeric(value);
        mustBeScalarOrEmpty(value);
    catch ME
        eid="MATLAB:timetable:InvalidSampleRate";
        error(message(eid));
    end
end