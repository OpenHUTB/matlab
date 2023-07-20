classdef SLDVTestCaseParser<Simulink.sdi.internal.import.DatasetParser





    properties
TestCaseIndex
    end


    methods


        function ret=supportsType(~,~)


            ret=false;
        end


        function ret=getRootSource(this)
            ret=sprintf('%s.TestCases(%d)',this.VariableName,this.TestCaseIndex);
        end


        function ret=getModelSource(this)
            ret=this.VariableValue.ModelInformation.Name;
        end


        function ret=getSignalLabel(this)
            ds=getDataset(this);
            ret=ds.Name;
        end


        function ret=getChildren(this)
            ds=getDataset(this);
            rootSrc=getRootSource(this);
            len=getLength(ds);
            vars=struct('VarName','','VarValue',[]);
            for idx=1:len
                vars(idx).VarName=sprintf('%s.dataValues(%d)',rootSrc,idx);
                vars(idx).VarValue=get(ds,idx);
            end

            ret=parseVariables(this.WorkspaceParser,vars);
            for idx=1:length(ret)
                ret{idx}.Parent=this;
            end
        end


        function ret=allowSelectiveChildImport(~)
            ret=true;
        end


        function ret=isVirtualNode(~)
            ret=false;
        end


        function ret=getRepresentsRun(~)
            ret=true;
        end


        function setRunMetaData(this,repo,runID)
            repo.setRunModel(runID,getModelSource(this));
        end
    end


    methods(Access=private)

        function ds=getDataset(this)
            ds=eval(sprintf('sldvsimdata(this.VariableValue, %d)',this.TestCaseIndex));
        end

    end
end
