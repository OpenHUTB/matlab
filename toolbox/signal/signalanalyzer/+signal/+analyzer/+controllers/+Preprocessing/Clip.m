

classdef Clip<signal.analyzer.controllers.Preprocessing.PreprocessorActionBase

    properties(Hidden)
PreprocessType
CursorPosition
    end

    methods(Hidden)

        function this=Clip(settings)

            this.Engine=Simulink.sdi.Instance.engine;

            this.PreprocessType=settings.actionName;
            this.CursorPosition=settings.cursorPositions;
        end


        function[successFlag,signalValues,message,currentParameters]=processData(this,sigID,cleanUpHandle,currentParameters)





            this.NeedCleanUp=true;
            finishup=onCleanup(@()cleanUpHandle());
            message='';
            signalObj=this.Engine.getSignalObject(sigID);
            signalValues=this.getSignalValues(sigID);
            isComplex=strcmpi(signalObj.Complexity,'complex');
            currentParameters.isComplex=isComplex;

            try
                cursorPosition=this.CursorPosition.T;

                if this.PreprocessType=="clipabove"
                    if~isComplex
                        signalValues.Data(signalValues.Data>cursorPosition)=cursorPosition;
                    else
                        realPart=real(signalValues.Data);
                        realPart(realPart>cursorPosition)=cursorPosition;
                        imaginaryPart=imag(signalValues.Data);
                        imaginaryPart(imaginaryPart>cursorPosition)=cursorPosition;
                        signalValues.Data=realPart+1i*imaginaryPart;
                    end
                elseif this.PreprocessType=="clipbelow"
                    if~isComplex
                        signalValues.Data(signalValues.Data<cursorPosition)=cursorPosition;
                    else
                        realPart=real(signalValues.Data);
                        realPart(realPart<cursorPosition)=cursorPosition;
                        imaginaryPart=imag(signalValues.Data);
                        imaginaryPart(imaginaryPart<cursorPosition)=cursorPosition;
                        signalValues.Data=realPart+1i*imaginaryPart;
                    end
                end

                successFlag=true;


                this.NeedCleanUp=false;

            catch ME
                successFlag=false;
            end
        end
    end
end