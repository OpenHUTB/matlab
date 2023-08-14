classdef SLDVStructParser<Simulink.sdi.internal.import.VariableParser




    methods


        function ret=supportsType(~,obj)
            fwk=Simulink.sdi.internal.SLFramework;
            ret=fwk.isSLDVData(obj);
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
            if isfield(this.VariableValue,'TestCases')
                numTestCases=length(this.VariableValue.TestCases);
            else
                numTestCases=length(this.VariableValue.CounterExamples);
            end
            ret=cell(1,numTestCases);
            for idx=1:numTestCases
                ret{idx}=Simulink.sdi.internal.import.SLDVTestCaseParser;
                ret{idx}.Parent=this;
                ret{idx}.VariableName=this.VariableName;
                ret{idx}.VariableValue=this.VariableValue;
                ret{idx}.WorkspaceParser=this.WorkspaceParser;
                ret{idx}.TestCaseIndex=idx;
            end
        end


        function ret=allowSelectiveChildImport(~)
            ret=true;
        end


        function ret=isVirtualNode(~)
            ret=true;
        end


        function ret=getRepresentsRun(~)
            ret=false;
        end


        function setRunMetaData(~,~,~)
        end
    end
end
