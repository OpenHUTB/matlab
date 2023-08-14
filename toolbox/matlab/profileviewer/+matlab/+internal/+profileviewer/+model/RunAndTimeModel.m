classdef RunAndTimeModel<handle





    properties(SetAccess=protected,Hidden)
        LastRunAndTime=''
        LastRunAndTimeError=''
        RunAndTimeHistory=''
    end

    methods(Hidden)

        function obj=RunAndTimeModel
            mlock;
        end

        function setLastRunAndTime(obj,lastRunAndTimeExpression)
            obj.LastRunAndTime=lastRunAndTimeExpression;
        end

        function lastRunAndTimeExpression=getLastRunAndTimePayload(obj)
            lastRunAndTimeExpression=obj.LastRunAndTime;

            obj.LastRunAndTime='';
        end

        function setLastRunAndTimeError(obj,lastRunAndTimeError)
            obj.LastRunAndTimeError=lastRunAndTimeError;
        end

        function lastRunAndTimeError=getLastRunAndTimeErrorPayload(obj)
            lastRunAndTimeError=obj.LastRunAndTimeError;

            obj.LastRunAndTimeError='';
        end

        function historyData=getRunAndTimeHistory(obj)
            historyData=obj.RunAndTimeHistory;
        end

        function setRunAndTimeHistory(obj,historyData)
            obj.RunAndTimeHistory=historyData;
        end
    end
end
