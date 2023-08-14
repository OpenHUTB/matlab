function accumType=getAccumTypeForSum(this,slbh,hOutType)





    rto=get_param(slbh,'RuntimeObject');


    numdw=rto.NumDworks;


    accumTypeStr=get_param(slbh,'AccumDataTypeStr');
    isInherit=strcmp(accumTypeStr,'Inherit: Inherit via internal rule');


    if isInherit||(numdw==0)
        accumType=hOutType;
    else

        dw=rto.Dwork(1);

        accumsltype=dw.Datatype;

        accumType=getpirsignaltype(accumsltype);










        adstr_sb_done=false;
        adstr=get_param(slbh,'AccumDataTypeStr');
        try
            adstr_eval=slResolve(adstr,slbh);
        catch me %#ok<NASGU>

            adstr_sb_done=true;
        end

        if~adstr_sb_done
            adstr_nt=[];
            if isa(adstr_eval,'Simulink.NumericType')

                adstr_nt=adstr_eval;
            else
                try
                    adstr_eval2=slResolve(adstr_eval,slbh);
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
                error(message('hdlcoder:validate:unsupporteddatatype'));
            end
        end
    end


