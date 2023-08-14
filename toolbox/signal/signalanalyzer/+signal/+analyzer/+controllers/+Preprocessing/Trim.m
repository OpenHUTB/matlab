

classdef Trim<signal.analyzer.controllers.Preprocessing.PreprocessorActionBase

    properties(Hidden)
PreprocessType
CursorPosition
PreserveStartTime
    end

    methods(Hidden)

        function this=Trim(settings)

            this.Engine=Simulink.sdi.Instance.engine;

            this.PreprocessType=settings.actionName;
            this.CursorPosition=settings.cursorPositions;
            this.PreserveStartTime=settings.preserveStartTime;
        end


        function[successFlag,signalValues,exceptionKeyword,currentParameters]=processData(this,sigID,cleanUpHandle,currentParameters)





            this.NeedCleanUp=true;
            finishup=onCleanup(@()cleanUpHandle());
            exceptionKeyword='';
            signalValues=this.getSignalValues(sigID);
            timeValues=signalValues.Time;
            tmMode=this.Engine.getSignalTmMode(sigID);
            try
                cursorPosition=this.CursorPosition.L;

                if cursorPosition>max(timeValues)

                    if this.PreprocessType=="trimleft"
                        exceptionKeyword='signalLessThanTwoDataPointsErrorMsg';
                    elseif this.PreprocessType=="trimright"
                        exceptionKeyword='crosshairOutOfRangeErrorMsg';
                    end
                    successFlag=false;
                    this.NeedCleanUp=false;
                    return;
                elseif cursorPosition<min(timeValues)

                    if this.PreprocessType=="trimleft"
                        exceptionKeyword='crosshairOutOfRangeErrorMsg';
                    elseif this.PreprocessType=="trimright"
                        exceptionKeyword='signalLessThanTwoDataPointsErrorMsg';
                    end
                    successFlag=false;
                    this.NeedCleanUp=false;
                    return;
                end

                if this.PreprocessType=="trimleft"
                    keptTimeIndices=timeValues>=cursorPosition;
                elseif this.PreprocessType=="trimright"
                    keptTimeIndices=timeValues<=cursorPosition;
                end

                if sum(keptTimeIndices)<2


                    exceptionKeyword='signalLessThanTwoDataPointsErrorMsg';
                    successFlag=false;
                    this.NeedCleanUp=false;
                    return;
                end


                trimmedTimeValues=timeValues(keptTimeIndices);

                if tmMode=="samples"
                    trimmedTimeValues=trimmedTimeValues-trimmedTimeValues(1);
                elseif~this.PreserveStartTime


                    isIrregular=signal.internal.utilities.isIrregular(timeValues);
                    if isIrregular
                        trimmedTimeValues=trimmedTimeValues-trimmedTimeValues(1);
                    else





                        effectiveFs=signal.internal.utilities.getEffectiveFs(trimmedTimeValues,isIrregular);
                        trimmedTimeValues=(0:length(trimmedTimeValues)-1)./effectiveFs;
                    end
                end




                set(signalValues,"Data",signalValues.Data(keptTimeIndices),"Time",trimmedTimeValues);

                successFlag=true;


                this.NeedCleanUp=false;

            catch ME
                successFlag=false;
            end
        end
    end
end