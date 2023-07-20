function result=hdlentitynameexists(nname)





    if hdlisfiltercoder
        if isempty(hdlgetparameter('entitynamelist'))
            result=0;
        else
            loc=strcmpi(nname,hdlgetparameter('entitynamelist'));
            if any(loc)
                result=1;
            else
                result=0;
            end
        end
    else
        hCurrentDriver=hdlcurrentdriver;
        result=hCurrentDriver.entityNameExists(nname);
    end



