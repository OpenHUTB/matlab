classdef PreprocessorActionBase<handle


    properties(Hidden)


NeedCleanUp
        Engine;
    end

    methods(Hidden,Abstract)
        [successFlag,data,exceptionKeyword,currentParameters]=processData(this,sigID,cleanUpHandle,currentParameters);
    end

    methods(Hidden)
        function this=PreprocessorActionBase(~)

            this.Engine=Simulink.sdi.Instance.engine;
        end



        function flag=isPreprocessorOnlySupportsSuperParents(this)%#ok<MANU>
            flag=false;
        end

        function flag=isPreprocessorCanModifyTime(this)%#ok<MANU>
            flag=false;
        end

        function signalValues=getSignalValues(this,sigID)
            runID=this.Engine.sigRepository.getAllRunIDs('sigAnalyzer');
            signalValues=signal.sigappsshared.SignalUtilities.getSignalValue(this.Engine,runID,sigID,true);
        end
    end

end

