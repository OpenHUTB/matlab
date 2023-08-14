function T=getaccumforsum(bfp,opsize,opbp,opsigned)




















    rto=get_param(bfp,'RuntimeObject');


    numdw=rto.NumDworks;

    if(numdw==0)
        T.size=opsize;
        T.bp=opbp;
        T.signed=opsigned;
    else
        dw=rto.Dwork(1);
        dt=dw.Datatype;

        [T.size,T.bp,T.signed]=hdlgetsizesfromtype(dt);










        adstr_sb_done=false;
        adstr=get_param(bfp,'AccumDataTypeStr');
        try
            adstr_eval=slResolve(adstr,bfp);
        catch me %#ok<NASGU>

            adstr_sb_done=true;
        end

        if~adstr_sb_done
            adstr_nt=[];
            if isa(adstr_eval,'Simulink.NumericType')

                adstr_nt=adstr_eval;
            else
                try
                    adstr_eval2=slResolve(adstr_eval,bfp);
                catch me %#ok<NASGU>

                    adstr_sb_done=true;
                end

                if isa(adstr_eval,'Simulink.NumericType')
                    adstr_nt=adstr_eval2;
                else
                    adstr_sb_done=true;
                end
            end
        end



        if~adstr_sb_done&&isa(adstr_nt,'Simulink.NumericType')
            if(adstr_nt.SlopeAdjustmentFactor~=1||...
                adstr_nt.Bias~=0)
                error(message('hdlcoder:makehdl:unsupporteddatatype'));
            end
        end
    end


