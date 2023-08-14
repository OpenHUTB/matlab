function names=hdlentitynames
















    if hdlisfiltercoder
        names=hdlgetparameter('entitynamelist');
    else
        hCurrentDriver=hdlcurrentdriver;
        names=hCurrentDriver.PirInstance.getEntityNames;
    end


    if~isempty(names)



        if hdlgetparameter('vhdl_package_required')&&...
            ~isempty(names{1})&&...
            ~strcmp(names{1},hdlgetparameter('vhdl_package_name'))
            names={hdlgetparameter('vhdl_package_name'),names{:}};
        elseif~hdlgetparameter('vhdl_package_required')&&...
            strcmp(names{1},hdlgetparameter('vhdl_package_name'))
            names={names{2:end}};
        end
    else
        names={};
    end






