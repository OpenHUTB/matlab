

classdef Crop<signal.analyzer.controllers.Preprocessing.PreprocessorActionBase

    properties(Hidden)
CursorPosition
PreserveStartTime
    end

    methods(Hidden)

        function this=Crop(settings)

            this.Engine=Simulink.sdi.Instance.engine;

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
                leftCursorPosition=this.CursorPosition.L;
                rightCursorPosition=this.CursorPosition.R;
                if leftCursorPosition>max(timeValues)||rightCursorPosition<min(timeValues)

                    exceptionKeyword='signalLessThanTwoDataPointsErrorMsg';
                    successFlag=false;
                    this.NeedCleanUp=false;
                    return;
                end

                if rightCursorPosition>max(timeValues)

                    rightCursorPosition=max(timeValues);
                end

                if leftCursorPosition<min(timeValues)

                    leftCursorPosition=min(timeValues);
                end



                keptTimeIndices=timeValues>=leftCursorPosition&timeValues<=rightCursorPosition;

                if sum(keptTimeIndices)<2
                    exceptionKeyword='signalLessThanTwoDataPointsErrorMsg';
                    successFlag=false;
                    this.NeedCleanUp=false;
                    return;
                end


                croppedTimeValues=timeValues(keptTimeIndices);

                if tmMode=="samples"
                    croppedTimeValues=croppedTimeValues-croppedTimeValues(1);
                elseif~this.PreserveStartTime


                    isIrregular=signal.internal.utilities.isIrregular(timeValues);
                    if isIrregular
                        croppedTimeValues=croppedTimeValues-croppedTimeValues(1);
                    else





                        effectiveFs=signal.internal.utilities.getEffectiveFs(croppedTimeValues,isIrregular);
                        croppedTimeValues=(0:length(croppedTimeValues)-1)./effectiveFs;
                    end
                end




                set(signalValues,"Data",signalValues.Data(keptTimeIndices),"Time",croppedTimeValues);

                successFlag=true;


                this.NeedCleanUp=false;

            catch ME
                successFlag=false;
            end
        end
    end
end