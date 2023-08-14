classdef CoderExecutionTimeParser<Simulink.sdi.internal.import.VariableParser



    methods


        function ret=supportsType(~,var)
            ret=isa(var,'coder.profile.ExecutionTime')&&...
            isTimeSeriesDataAvailable(var);
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
            ret='zoh';
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
            numSections=numel(this.VariableValue.Sections);
            ret=cell(1,numSections);
            for idx=1:numSections
                ret{idx}=Simulink.sdi.internal.import.CoderExecutionTimeSectionParser;
                ret{idx}.Parent=this;
                ret{idx}.VariableName=sprintf('%s.Sections(%d)',this.VariableName,idx);
                ret{idx}.VariableValue=this.VariableValue.Sections(idx);
                ret{idx}.WorkspaceParser=this.WorkspaceParser;
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
