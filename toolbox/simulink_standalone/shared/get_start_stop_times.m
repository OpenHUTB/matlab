function[startT,stopT]=get_start_stop_times(buildData)

    iMdl=buildData.mdl;
    iTimeSpan=buildData.timeSpan;

    if~isempty(iTimeSpan)
        if length(iTimeSpan)==1
            startT=0;
            stopT=iTimeSpan(1);
        else
            startT=iTimeSpan(1);
            stopT=iTimeSpan(end);
        end
    else
        timeNames={'StartTime','StopTime'};
        timeValues=[];

        for i=1:length(timeNames)
            timeName=timeNames{i};
            timeExpr=get_param(iMdl,timeName);

            [timeValues.(timeName),success]=eval_string_with_workspace_resolution(...
            timeExpr,...
            iMdl,...
buildData...
            );

            if~success
                DAStudio.error(...
                'Simulink:ConfigSet:ConfigSetEvalErr',...
                timeExpr,...
                timeName,...
                iMdl);
            end
        end

        assert(...
        isstruct(timeValues)&&...
        isfield(timeValues,timeNames{1})&&...
        isfield(timeValues,timeNames{2})...
        );

        startT=timeValues.StartTime;
        stopT=timeValues.StopTime;
    end
end
