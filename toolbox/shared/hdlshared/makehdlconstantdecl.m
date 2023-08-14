function result=makehdlconstantdecl(index,value,varargin)








    hN=pirNetworkForFilterComp;
    elaborateemitMode=~isempty(hN);

    if elaborateemitMode

        constValue=varargin{1};
        pirelab.getConstComp(hN,index,constValue);
        result='';

    elseif hdlispirbased

















        index.makeConstant(value);
        result='';

    else
        if hdlgetparameter('isvhdl')
            result=makevhdlconstantdecl(index,value);
        elseif hdlgetparameter('isverilog')
            result=makeverilogconstantdecl(index,value);
        else
            error(message('HDLShared:directemit:UnknownTargetLanguage',hdlgetparameter('target_language')));
        end

    end
end
