function SFLoggingInfo(obj)





    machine=getStateflowMachine(obj);
    if isempty(machine)
        return;
    end

    if isR2011aOrEarlier(obj.ver)

        obj.appendRule('<state<loggingInfo:remove>>');

        obj.appendRule('<data<loggingInfo:remove>>');
    end

    if isR2013bOrEarlier(obj.ver)

        allCharts=sf('get',machine.Id,'machine.charts');
        for i=1:length(allCharts)
            allLocalData=sf('find',sf('DataOf',allCharts(i)),'data.scope','LOCAL_DATA');
            for j=1:length(allLocalData)
                dataH=idToHandle(sfroot,allLocalData(j));

                dataTypeStr=dataH.DataType;
                busTypeName=regexp(dataTypeStr,'\w+$','match');
                try
                    busObj=evalin('base',busTypeName{1});
                    if isa(busObj,'Simulink.Bus')
                        removeLogging(dataH);
                    end
                catch

                end
            end
        end
    end

    if isR2015bOrEarlier(obj.ver)

        allCharts=sf('get',machine.Id,'machine.charts');
        for i=1:length(allCharts)
            chartH=sf('IdToHandle',allCharts(i));
            allOutputData=sf('find',...
            sf('find',sf('DataOf',allCharts(i)),'data.scope','OUTPUT_DATA'),...
            '.loggingInfo.logSignal',1);
            for j=1:length(allOutputData)
                dataH=sf('IdToHandle',allOutputData(j));
                removeLogging(dataH);
                obj.reportWarning('Stateflow:misc:OutputLoggingInPrevVersion',dataH.name,chartH.name);
            end
        end
    end


end

function removeLogging(busDataH)
    busLoggingInfo=busDataH.LoggingInfo;
    busLoggingInfo.DataLogging=0;
    busLoggingInfo.DecimateData=0;
    busLoggingInfo.Decimation=2;
    busLoggingInfo.LimitDataPoints=0;
    busLoggingInfo.NameMode='SignalName';
    busLoggingInfo.MaxPoints=5000;
    busLoggingInfo.LoggingName=busDataH.name;

    busDataH.TestPoint=0;
end
