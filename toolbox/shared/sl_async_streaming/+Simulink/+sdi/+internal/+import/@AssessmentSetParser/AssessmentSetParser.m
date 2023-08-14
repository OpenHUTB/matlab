classdef AssessmentSetParser<Simulink.sdi.internal.import.VariableParser



    methods


        function ret=supportsType(~,obj)
            ret=isscalar(obj)&&isa(obj,'sltest.AssessmentSet');
        end


        function ret=getRootSource(this)
            ret=this.VariableName;
        end


        function ret=getTimeSource(~)
            ret='';
        end


        function ret=getDataSource(~)
            ret='';
        end


        function ret=getBlockSource(~)
            ret='';
        end


        function ret=getSID(~)
            ret='';
        end


        function ret=getModelSource(~)
            ret='';
        end


        function ret=getSignalLabel(this)
            ret=this.VariableName;
        end


        function ret=getPortIndex(~)
            ret=[];
        end


        function ret=getHierarchyReference(~)
            ret='';
        end


        function ret=getTimeDim(~)
            ret=[];
        end


        function ret=getSampleDims(~)
            ret=[];
        end


        function ret=getInterpolation(~)
            ret='';
        end


        function ret=getUnit(~)
            ret='';
        end


        function ret=getMetaData(~)
            ret=[];
        end


        function ret=getTimeValues(~)
            ret=[];
        end


        function ret=getDataValues(~)
            ret=[];
        end


        function ret=isHierarchical(~)
            ret=true;
        end


        function ret=getChildren(this)
            vars=struct('VarName','','VarValue',[]);
            for idx=1:this.VariableValue.getSummary().Total
                var=this.VariableValue.get(idx);
                vars(idx).VarValue=var;
                vars(idx).VarName=var.Name;
            end

            ret=parseVariables(this.WorkspaceParser,vars);
            for idx=1:numel(ret)
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
            ret=false;
        end


        function setRunMetaData(~,~,~)
        end
    end


    methods(Static)


        function setAssessmentMetaData(sigID,assessment)
            repo=sdi.Repository(1);
            runID=repo.getSignalRunID(sigID);


            repo.setRunMetaData(runID,'ContainsVerify',int32(1));


            repo.setSignalMetaData(sigID,'IsAssessment',int32(1));
            repo.setSignalMetaData(sigID,'AssessmentResult',int32(assessment.Result));
            repo.setSignalMetaData(sigID,'AssessmentId',int32(assessment.AssessmentId));
            if~isempty(assessment.BlockPath.SubPath)
                repo.setSignalMetaData(sigID,'SubPath',assessment.BlockPath.SubPath);
            end
            if~isempty(assessment.SSIdNumber)
                repo.setSignalMetaData(sigID,'SSIDNumber',int32(assessment.SSIdNumber));
            end


            repo.setSignalIsEventBased(sigID,true);
        end

    end
end
