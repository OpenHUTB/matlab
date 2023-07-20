classdef SDIBaselineComparison<handle











    properties(SetAccess=private)
signalPathIDs
    end

    methods
        function clearSignalTolerances(~,runID)




            run=Simulink.sdi.getRun(runID);


            count=run.signalCount;
            for c=1:count
                signal=run.getSignalByIndex(c);


                signal.AbsTol=0;
                signal.RelTol=0;
                signal.TimeTol=0;
            end
        end

        function bindConstraints(this,baselineRunID,constraints)
            for rIndex=1:length(baselineRunID)
                baselineRun=Simulink.sdi.getRun(baselineRunID(rIndex));
                pathMap=this.getBasePathMap(baselineRun);


                for cIndex=1:numel(constraints)
                    this.signalPathIDs{cIndex}=constraints{cIndex}.tostring;
                    if pathMap.isKey(this.signalPathIDs{cIndex})
                        signalIDs=pathMap(this.signalPathIDs{cIndex});
                        tolValue=constraints{cIndex}.value;
                        tolMode=constraints{cIndex}.getMode();
                        for sIndex=1:numel(signalIDs)
                            signal=Simulink.sdi.getSignal(signalIDs(sIndex));
                            signal.(tolMode)=tolValue;
                        end
                    end
                end
            end
        end

        function[pass,maxDifferences]=evaluateConstraints(this,baselineRunID,compareRunID)
            diffRun=Simulink.sdi.compareRuns(baselineRunID,compareRunID);
            [pathMapConstraintsMatch,pathMapMaxViolation]=this.getDiffPathMap(diffRun);


            pass=true;
            maxDifferences=[];
            for cIndex=1:numel(this.signalPathIDs)
                cStr=this.signalPathIDs{cIndex};
                if pathMapConstraintsMatch.isKey(cStr)

                    pass=pass&pathMapConstraintsMatch(cStr);


                    maxDifferences=[maxDifferences,pathMapMaxViolation(cStr)];%#ok<AGROW>
                end
            end

            if isempty(maxDifferences)
                maxDifferences=0;
            end

        end

        function pathMap=getBasePathMap(~,run)


            pathMap=containers.Map();

            for sIndex=1:run.SignalCount
                signal=run.getSignalByIndex(sIndex);
                signalKey=[signal.BlockPath,sprintf(':%i',signal.PortIndex)];
                if pathMap.isKey(signalKey)


                    pathMap(signalKey)=[pathMap(signalKey),signal.ID];
                else
                    pathMap(signalKey)=signal.ID;
                end
            end
        end

        function[pathMapConstraintsMatch,pathMapMaxDifference]=getDiffPathMap(~,run)
            pathMapConstraintsMatch=containers.Map();
            pathMapMaxDifference=containers.Map();
            for sIndex=1:run.Count
                result=run.getResultByIndex(sIndex);
                signal=Simulink.sdi.getSignal(result.SignalID1);
                key=[signal.BlockPath,sprintf(':%i',signal.PortIndex)];
                maxDifference=result.MaxDifference;






                if isempty(maxDifference)
                    maxDifference=0;
                end

                if pathMapConstraintsMatch.isKey(key)
                    pathMapConstraintsMatch(key)=pathMapConstraintsMatch(key)&result.Match;
                    pathMapMaxDifference(key)=[pathMapMaxDifference(key),maxDifference];
                else
                    pathMapConstraintsMatch(key)=result.Match;
                    pathMapMaxDifference(key)=maxDifference;
                end
            end
        end

        function b=validateSDIRun(~,sdiRun)





            if~isempty(sdiRun)&&isinteger(sdiRun)
                b=Simulink.sdi.isValidRunID(sdiRun);
            else
                b=false;
            end
        end

        function b=hasMatchingSignals(this,firstSDIRunID,secondSDIRunID,signalsWithTolerances)







            if this.validateSDIRun(firstSDIRunID)
                run=Simulink.sdi.getRun(firstSDIRunID);
                runMap=this.getBasePathMap(run);
                firstRunSignals=runMap.keys;
            else


                b=false;
                return;
            end




            if this.validateSDIRun(secondSDIRunID)
                run=Simulink.sdi.getRun(secondSDIRunID);
                runMap=this.getBasePathMap(run);
                secondRunSignals=runMap.keys;
            else


                b=false;
                return;
            end







            b=all(ismember(signalsWithTolerances,firstRunSignals))&&...
            all(ismember(signalsWithTolerances,secondRunSignals));

        end

    end
end
