classdef(Hidden=true)SparklinesSidebarCommands<handle

    methods(Static)
        function displayDataInSDI(bdHandle,portHandle,streamIndex,seriesName,interpolation)




            time=SLM3I.SLCommonDomain.sparklinesData(bdHandle,portHandle,streamIndex,0);
            data=SLM3I.SLCommonDomain.sparklinesData(bdHandle,portHandle,streamIndex,1);
            interpolationMode=SLM3I.SLCommonDomain.sparklinesDataInterpolationMode(bdHandle,portHandle,streamIndex);
            interpolation='linear';
            if interpolationMode==1
                interpolation='zoh';
            end

            sparkline_series=timeseries(data,time);
            sparkline_series.Name=seriesName;


            run=Simulink.sdi.Run.create;
            run.Name='Sparklines';
            run.Description='Data exported from Sparklines';


            run.add('vars',sparkline_series);


            sparkline_sig=run.getSignalByIndex(1);
            sparkline_sig.Checked=true;
            sparkline_sig.InterpMethod=interpolation;


            Simulink.sdi.view;
        end



        function copyDataToWorkspace(bdHandle,portHandle,streamIndex,variableName)

            data=SLM3I.SLCommonDomain.sparklinesData(bdHandle,portHandle,streamIndex,2);

            assignin('base',variableName,data);
        end
    end
end