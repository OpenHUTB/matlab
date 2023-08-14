classdef SignalEditorUtil<handle






    methods(Static)


        function outSignal=createSignalVariable(sigType,timeIn,dataVals,units,interp)





            switch sigType

            case message("sl_sta:editor:insertsigtypeloggedtimeseries").getString

                aTsToInsert=SignalEditorUtil.createTimeSeries(timeIn,dataVals,units,interp);
                outSignal=Simulink.SimulationData.Signal;
                outSignal.Values=aTsToInsert;

            case message("sl_sta:editor:insertsigtypeloggedtimetable").getString

                aTsToInsert=SignalEditorUtil.createTimeTable(timeIn,dataVals,units,interp);
                outSignal=Simulink.SimulationData.Signal;
                outSignal.Values=aTsToInsert;

            case message("sl_sta:editor:insertsigtypetimeseries").getString

                outSignal=SignalEditorUtil.createTimeSeries(timeIn,dataVals,units,interp);

            case message("sl_sta:editor:insertsigtypetimetable").getString

                outSignal=SignalEditorUtil.createTimeTable(timeIn,dataVals,units,interp);

            otherwise

                error(message('sl_sta:editor:unrecognizedvariabletype',...
                message("sl_sta:editor:insertsigtypetimeseries").getString,...
                message("sl_sta:editor:insertsigtypetimetable").getString,...
                message("sl_sta:editor:insertsigtypeloggedtimeseries").getString,...
                message("sl_sta:editor:insertsigtypeloggedtimetable").getString));
            end
        end


        function outTS=createTimeSeries(timeIn,dataVals,units,interp)




            if isStringScalar(dataVals)
                outTS=timeseries();
                outTS.Data=dataVals;
                outTS.Time=timeIn;
            else
                outTS=timeseries(dataVals,timeIn);
            end

            outTS.DataInfo.Units=units;
            outTS.DataInfo.Interpolation=tsdata.interpolation(interp);
        end


        function outTT=createTimeTable(timeIn,dataVals,units,interp)




            Var1=dataVals;
            outTT=timetable(seconds(timeIn),Var1);
            outTT.Properties.VariableUnits={units};

            if strcmpi(interp,'linear')

                outTT.Properties.VariableContinuity={'continuous'};
            else
                outTT.Properties.VariableContinuity={'step'};
            end
        end
    end



    methods(Static)

        function evaluatedValue=evalExpressionInWorkspaces(inValueString,varargin)


            try
                dataToUse=eval(inValueString);
            catch ME_DATA

                dataToUse=evalin('base',inValueString);

            end

            evaluatedValue=dataToUse;
        end



        function isValidWaveformValue=isValidWaveformValue(inValueString)

            try
                dataToUse=SignalEditorUtil.evalExpressionInWorkspaces(inValueString);
            catch ME_DATA

                isValidWaveformValue=false;
                return

            end

            inValue=Simulink.sta.editor.formatDataValues(dataToUse);



            MUST_BE_SCALAR=isscalar(inValue);
            IS_NUMERIC=isnumeric(inValue);
            IS_ENUM=isenum(inValue);
            IS_FI=isfi(inValue);
            IS_LOGICAL=islogical(inValue);

            if IS_NUMERIC
                IS_NOT_NAN=~isnan(inValue);
                IS_NOT_INF=~isinf(inValue);
            else
                IS_NOT_NAN=true;
                IS_NOT_INF=true;
            end



            NOT_NAN_AND_NOT_INF=IS_NOT_NAN&&IS_NOT_INF;

            DATA_TYPE_VALID=IS_NUMERIC||IS_ENUM||IS_FI||IS_LOGICAL;

            isValidWaveformValue=MUST_BE_SCALAR&&DATA_TYPE_VALID&&NOT_NAN_AND_NOT_INF;

        end


        function[isTimeValueValid,inValue]=isValidWaveformTimeValue(inValueString)
            inValue=inValueString;
            try
                timeToUse=SignalEditorUtil.evalExpressionInWorkspaces(inValueString);
            catch ME_TIME

                isTimeValueValid=false;
                return
            end

            inValue=Simulink.sta.editor.formatTimeValues(timeToUse);

            MUST_BE_SCALAR=isscalar(inValue);
            IS_DOUBLE=isa(inValue,'double');
            IS_NUMERIC=isnumeric(inValue);

            if IS_NUMERIC
                IS_NOT_NAN=~isnan(inValue);
                IS_NOT_INF=~isinf(inValue);
            else
                IS_NOT_NAN=true;
                IS_NOT_INF=true;
            end

            NOT_NAN_AND_NOT_INF=IS_NOT_NAN&&IS_NOT_INF;

            isTimeValueValid=MUST_BE_SCALAR&&IS_DOUBLE&&IS_NUMERIC&&NOT_NAN_AND_NOT_INF;
        end



        function isTimePropGood=isValidWaveformTimeProperties(startTString,triggerTString,finalTString,varargin)

            isTimePropGood=false;

            if~isempty(varargin)

                try
                    isStartT=SignalEditorUtil.isValidWaveformTimeValue(startTString);

                    triggerT=SignalEditorUtil.isValidWaveformTimeValue(triggerTString);

                    durationT=SignalEditorUtil.isValidWaveformTimeValue(varargin{1});
                catch
                    return
                end

                startT=SignalEditorUtil.evalExpressionInWorkspaces(startTString);

                triggerT=SignalEditorUtil.evalExpressionInWorkspaces(triggerTString);

                durationT=SignalEditorUtil.evalExpressionInWorkspaces(varargin{1});
                finalT=triggerT+durationT;

            else
                try
                    isStartT=SignalEditorUtil.isValidWaveformTimeValue(startTString);

                    triggerT=SignalEditorUtil.isValidWaveformTimeValue(triggerTString);

                    finalT=SignalEditorUtil.isValidWaveformTimeValue(finalTString);
                catch
                    return
                end

                startT=SignalEditorUtil.evalExpressionInWorkspaces(startTString);

                triggerT=SignalEditorUtil.evalExpressionInWorkspaces(triggerTString);

                finalT=SignalEditorUtil.evalExpressionInWorkspaces(finalTString);
            end







            isTimePropGood=startT<triggerT&&triggerT<=finalT;


        end
    end
end
