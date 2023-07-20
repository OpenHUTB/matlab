function name=hdlentitytop














    if hdlisfiltercoder
        enl=hdlgetparameter('entitynamelist');

        if~isempty(enl)
            name=enl{end};
        else
            name='';
        end
    else
        hCurrentDriver=hdlcurrentdriver;
        name=hCurrentDriver.getEntityTop;
    end



