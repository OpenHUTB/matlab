function mustBeRowTimes(value)



    try
        mustBeA(value,["duration","datetime","string","char"]);
    catch ME
        eid="tdms:TDMS:InvalidRowTimes";
        error(message(eid));
    end
end