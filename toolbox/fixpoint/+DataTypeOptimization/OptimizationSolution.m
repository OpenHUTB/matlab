classdef(Sealed)OptimizationSolution<handle


    properties(SetAccess=private)
        Cost=Inf;
        Pass=false;
        MaxDifference=Inf;
        RunID=[];
        RunName='';

    end

    properties(Hidden)
        definitionDomainIndex=[];
        maxDifferences=Inf;
        simOut=[];
        simIn=[];
        internalRunID=[];
        internalRunName={};
    end

    properties(SetAccess=private,Hidden)
        isFullySpecified=false;
        id='';
    end

    methods

        function this=OptimizationSolution()
        end

        function id=get.id(this)


            id=['solution_',fixed.internal.utility.shaHex(sprintf('%i',this.definitionDomainIndex))];
        end

        function name=get.RunName(this)

            if isempty(this.internalRunName)
                runID=this.RunID;
                this.internalRunName=cell(length(runID),1);
                for rIndex=1:length(runID)
                    sdiRun=Simulink.sdi.getRun(runID(rIndex));
                    this.internalRunName{rIndex}=sdiRun.Name;
                end
            end
            name=this.internalRunName;

        end

        function isSpecified=get.isFullySpecified(this)


            isSpecified=~isempty(this.definitionDomainIndex)&&all(this.definitionDomainIndex);
        end

        function maxDiff=get.MaxDifference(this)

            maxDiff=max(this.maxDifferences(:));
        end

        function runID=get.RunID(this)
            if isempty(this.internalRunID)||any(arrayfun(@(x)(~Simulink.sdi.isValidRunID(x)),this.internalRunID))
                count=1;
                for sIndex=1:length(this.simOut)

                    if isempty(this.simOut(sIndex).ErrorMessage)&&this.hasRunID(sIndex)
                        this.internalRunID(count)=Simulink.sdi.createRun(this.simOut(sIndex).SimulationMetadata.UserString,'vars',this.simOut(sIndex));
                        sdiRun=Simulink.sdi.getRun(this.internalRunID(count));
                        sdiRun.Name=this.simOut(sIndex).SimulationMetadata.UserString;
                        count=count+1;
                    end
                end
            end
            runID=this.internalRunID;
        end

        function showContents(this,scenarioIndex)






            if nargin<2
                scenarioIndex=1;
            end

            contents(this,scenarioIndex)
        end

        function simOut=getSimulationOutputs(this)




            for sIndex=1:length(this.simOut)
                simOut(sIndex)=this.simOut.simOut;%#ok<AGROW>
            end
        end
    end

    methods(Hidden)

        function contents(this,scenarioIndex)







            if nargin<2
                scenarioIndex=1;
            end

            if~isempty(this.simIn)
                this.simIn(scenarioIndex).showContents();
            end
        end

        function setCost(this,costValue)

            this.Cost=costValue;

        end

        function setPass(this,passValue)

            this.Pass=passValue;

        end

        function valid=isValid(this)



            valid=~all(isinf([this.Cost,this.maxDifferences(:)']));
        end

        function hasRun=hasRunID(this,scenarioIndex)
            hasRun=false;
            if~isempty(this.simOut)
                hasRun=~isempty(this.simOut(scenarioIndex).baselineRunID);
            end
        end

        function hasLogged=hasLoggedSignals(this,scenarioIndex)
            hasLogged=false;
            if~isempty(this.simIn)
                hasLogged=~isempty(this.simIn(scenarioIndex).LoggingSpecification.SignalsToLog);
            end
        end

    end

end

