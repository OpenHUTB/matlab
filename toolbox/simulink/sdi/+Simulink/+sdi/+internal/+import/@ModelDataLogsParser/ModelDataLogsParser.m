classdef ModelDataLogsParser<Simulink.sdi.internal.import.VariableParser



    methods


        function ret=supportsType(~,obj)
            ret=isa(obj,'Simulink.ModelDataLogs');
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
            ret=[];
            var.VarName=sprintf('%s.convertToDataset(''%s'')',this.VariableName,this.VariableName);
            var.VarValue=this.VariableValue.convertToDataset(this.VariableName);
            dsParser=parseVariables(this.WorkspaceParser,var);
            if~isempty(dsParser)
                assert(length(dsParser)==1);
                ret=getChildren(dsParser{1});
                numChildren=length(ret);
                for idx=1:numChildren
                    ret{idx}.Parent=this;
                end
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
end
