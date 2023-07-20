function stdLogicVector=isStdLogicVector(this,vtype,sltype)







    if hdlgetparameter('isvhdl')
        if isempty(findstr(vtype,'std_logic_vector'))||findstr(vtype,'std_logic_vector')==0
            stdLogicVector=false;
        else
            stdLogicVector=true;
        end
    else
        if strcmpi(sltype,'real')
            stdLogicVector=false;
        else
            stdLogicVector=true;
        end
    end

