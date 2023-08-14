function pirdt=convertSLUserType2PirType(DTstr,slbh)










    conversion_done=false;
    pirdt.pirtype=[];
    pirdt.inheritance='';


    if strcmp(DTstr,'Inherit: Inherit via internal rule')
        pirdt.inheritance='internal';
        return;
    end

    if strcmp(DTstr,'Inherit: Same as input')
        pirdt.inheritance='input';
        return;
    end


    if~isempty(regexpi(DTstr,'^Inherit:','match','once'))
        pirdt.inheritance=DTstr;
        return;
    end

    try
        DTstr_eval=slResolve(DTstr,slbh);
    catch me %#ok<NASGU>

        pirdt.pirtype=pirelab.convertSLType2PirType(DTstr);
        return;
    end

    if~conversion_done
        DTstr_nt=[];
        if isa(DTstr_eval,'Simulink.NumericType')

            DTstr_nt=DTstr_eval;
        else
            try
                DTstr_eval2=slResolve(DTstr_eval,slbh);
            catch me %#ok<NASGU>

                conversion_done=true;
            end

            if isa(DTstr_eval,'Simulink.NumericType')
                DTstr_nt=DTstr_eval2;
            else
                conversion_done=true;
            end
        end
    end



    if~conversion_done&&isa(DTstr_nt,'Simulink.NumericType')
        if(DTstr_nt.SlopeAdjustmentFactor~=1||...
            DTstr_nt.Bias~=0)
            error(message('hdlcoder:validate:unsupporteddatatype'));
        end
    end

    pirdt.pirtype=pir_fixpt_t(DTstr_nt.Signed,DTstr_nt.WordLength,...
    -DTstr_nt.FractionLength);


end