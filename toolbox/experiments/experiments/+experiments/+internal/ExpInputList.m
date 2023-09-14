classdef ExpInputList<handle

    properties(Access=private)
        InputList={};
        ExecMode='Sequential';
curTrial
total
curTrialIndex
valsPerInput
    end

    methods
        function this=ExpInputList()
            this.InputList={};
            this.ExecMode='Sequential';
        end

        function addInput(this,inp)
            this.InputList{end+1}=inp;
        end

        function setExecMode(this,mode)
            this.ExecMode=mode;
        end

        function n=getNumTrials(this)
            if isempty(this.InputList)
                n=1;
                return;
            end
            if strcmp(this.ExecMode,'Sequential')
                n=min(cellfun(@(inp)inp.getNumValues(),this.InputList));
            else
                n=prod(cellfun(@(inp)inp.getNumValues(),this.InputList));
            end
        end

        function initExecution(this)
            this.curTrial=0;
            this.total=this.getNumTrials();
            if isempty(this.InputList)
                return;
            end

            this.valsPerInput=cellfun(@(inp)inp.getNumValues(),this.InputList);
            if strcmp(this.ExecMode,'Sequential')
                this.curTrialIndex=zeros(1,length(this.InputList));
            else
                this.curTrialIndex=this.valsPerInput-1;
            end
        end

        function hyPrValues=getFirstBayesoptTrial(this)
            hyPrValues={};
            for i=1:length(this.InputList)
                hyPrValues{1,i}=this.InputList{i}.getMinValue();
            end
        end


        function hyPrValues=getNextTrial(this)
            hyPrValues={};
            if isempty(this.InputList)
                return;
            end

            if this.curTrial==this.total
                return;
            end

            this.curTrial=this.curTrial+1;
            hyPrValues=cell(1,length(this.curTrialIndex));
            if strcmp(this.ExecMode,'Sequential')
                this.curTrialIndex=this.curTrialIndex+1;
            else
                sub=cell(1,length(this.valsPerInput));
                [sub{:}]=ind2sub(this.valsPerInput,this.curTrial);
                this.curTrialIndex=cell2mat(sub);
            end
            arrayfun(@(i)addParam(i),...
            1:length(this.curTrialIndex),...
            'UniformOutput',false);

            function addParam(i)
                hyPrValues{i}=this.InputList{i}.getValueAt(this.curTrialIndex(i));
            end

        end
    end
end

