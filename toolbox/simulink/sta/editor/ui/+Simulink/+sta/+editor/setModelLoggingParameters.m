function setModelLoggingParameters(originalModel,modelToGenerate,varargin)








    if~isempty(originalModel)

        DataTypeOverride=get_param(originalModel,'DataTypeOverride');
        DataTypeOverrideAppliesTo=get_param(originalModel,'DataTypeOverrideAppliesTo');
        MinMaxOverflowLogging=get_param(originalModel,'MinMaxOverflowLogging');
        FixedStep=get_param(originalModel,'FixedStep');
        startTime=get_param(originalModel,'StartTime');
        stopTime=get_param(originalModel,'StopTime');

        loggingFormat=get_param(originalModel,'DatasetSignalFormat');
    else

        DataTypeOverride='UseLocalSettings';
        DataTypeOverrideAppliesTo='AllNumericTypes';
        MinMaxOverflowLogging='UseLocalSettings';
        FixedStep='10';
        startTime='0';
        stopTime='10';
        loggingFormat='timeseries';
    end


    modelH=get_param(modelToGenerate,'Handle');
    set_param(modelH,'SaveFormat','Dataset');



    if~isempty(varargin)


        if isfield(varargin{1},'startTime')
            startTime=varargin{1}.startTime;
        end

        if isfield(varargin{1},'stopTime')
            stopTime=varargin{1}.stopTime;
        end

        if isfield(varargin{1},'FixedStep')
            FixedStep=varargin{1}.FixedStep;
        end

    end


    if isempty(str2num(startTime))||~isfinite(str2num(startTime))%#ok<ST2NM>


        evaluatedStartTime=Simulink.sta.editor.evalinWorkspaceAndSimulink(originalModel,startTime);
        if isempty(evaluatedStartTime)||~isfinite(evaluatedStartTime)||~isscalar(evaluatedStartTime)

            startTime='0';
        end
    end

    if isempty(str2num(stopTime))||~isfinite(str2num(stopTime))%#ok<ST2NM>

        evaluatedStopTime=Simulink.sta.editor.evalinWorkspaceAndSimulink(originalModel,stopTime);
        if isempty(evaluatedStopTime)||~isfinite(evaluatedStopTime)||~isscalar(evaluatedStopTime)

            stopTime='10';
        end
    end

    if~strcmpi(FixedStep,'auto')&&(isempty(str2num(FixedStep))||~isfinite(str2num(FixedStep)))%#ok<ST2NM>

        evaluatedFixedStep=Simulink.sta.editor.evalinWorkspaceAndSimulink(originalModel,FixedStep);
        if isempty(evaluatedFixedStep)||~isfinite(evaluatedFixedStep)||~isscalar(evaluatedFixedStep)

            FixedStep='10';
        end
    end



    set_param(modelH,'StartTime',startTime);
    set_param(modelH,'StopTime',stopTime);
    set_param(modelH,'Solver','VariableStepAuto');
    set_param(modelH,'FixedStep',FixedStep);
    set_param(modelH,'DataTypeOverride',DataTypeOverride);
    set_param(modelH,'DataTypeOverrideAppliesTo',DataTypeOverrideAppliesTo);
    set_param(modelH,'MinMaxOverflowLogging',MinMaxOverflowLogging);
    set_param(modelH,'OutputOption','SpecifiedOutputTimes');


    set_param(modelH,'LoadExternalInput','off');


    set_param(modelH,'SaveFormat','Dataset');


    set_param(modelH,'DatasetSignalFormat',loggingFormat);




    startTimeNumeric=str2double(startTime);


    if isnan(startTimeNumeric)
        [fromBase,~]=slResolve(startTime,originalModel);

        if isnumeric(fromBase)&&isscalar(fromBase)
            startTimeNumeric=fromBase;
        else
            fromBase=str2double(startTime);

            if~isnan(fromBase)
                startTimeNumeric=fromBase;
            end
        end
    end

    stopTimeNumeric=str2double(stopTime);

    if isnan(stopTimeNumeric)
        [fromBase,~]=slResolve(stopTime,originalModel);

        if isnumeric(fromBase)&&isscalar(fromBase)
            stopTimeNumeric=fromBase;
        else
            fromBase=str2double(stopTime);

            if~isnan(fromBase)
                stopTimeNumeric=fromBase;
            end
        end
    end


    IS_START_OR_STOP_NaN=isnan(startTimeNumeric)||isnan(stopTimeNumeric);


    if strcmp(startTime,stopTime)||...
        (~IS_START_OR_STOP_NaN&&startTimeNumeric==stopTimeNumeric)
        str=sprintf('[%s]',startTime);
    else
        str=sprintf('[ %s %s ]',startTime,stopTime);
    end

    set_param(modelH,'OutputTimes',str);
