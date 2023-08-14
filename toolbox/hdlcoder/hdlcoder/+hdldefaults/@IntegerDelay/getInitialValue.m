function scalarIC=getInitialValue(~,hC,slbh)


    if hC.PirInputSignals(1).Type.isRecordType||hC.PirInputSignals(1).Type.isArrayOfRecords


        scalarIC=[];
    else

        scalarIC=0;
        rto=get_param(slbh,'RuntimeObject');
        np=get(rto,'NumRuntimePrms');
        for n=1:np
            if strcmp(rto.RuntimePrm(n).get.Name,'InitialCondition')
                scalarIC=rto.RuntimePrm(n).Data;
                break;
            end
        end
    end
end
