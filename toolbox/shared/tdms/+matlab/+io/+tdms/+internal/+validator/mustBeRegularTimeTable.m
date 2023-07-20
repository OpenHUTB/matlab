function mustBeRegularTimeTable(value)




    if~(istimetable(value)&&isregular(value))
        eid="tdms:TDMS:mustBeRegularTimeTable";
        throwAsCaller(MException(eid,message(eid,class(value))));
    end

end

