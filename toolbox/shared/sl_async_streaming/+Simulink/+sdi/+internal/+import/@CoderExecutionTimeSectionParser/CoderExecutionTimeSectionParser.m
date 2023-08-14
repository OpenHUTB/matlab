


classdef CoderExecutionTimeSectionParser<Simulink.sdi.internal.import.VariableParser



    methods


        function ret=supportsType(~,var)
            ret=isa(var,'coder.profile.ExecutionTimeSection');
        end


        function ret=getRootSource(this)
            ret=this.VariableName;
        end


        function ret=getTimeSource(this)
            ret=[this.VariableName,'.Time'];
        end


        function ret=getDataSource(this)
            ret='';
            if~isempty(this.VariableValue.Time)
                [~,propName]=getExecTimeDataForSDI(this.VariableValue);
                ret=[this.VariableName,'.',propName];
            end
        end


        function ret=getBlockSource(this)
            sid=getSID(this);
            try
                interface=Simulink.sdi.internal.Framework.getFramework();
                ret=interface.getFullName(sid);
            catch me %#ok
                ret=getModelSource(this);
            end
        end


        function ret=getSID(this)
            section=this.VariableValue;
            lTraceInfo=section.getTraceInfo;
            ret=getPrimaryCallSiteSID(lTraceInfo);
        end


        function ret=getModelSource(this)
            ret=this.VariableValue.getTraceInfo.getOriginalModelRef();
        end


        function ret=getSignalLabel(this)
            ret=this.VariableValue.getSignalNameForSDI();
        end


        function ret=getPortIndex(~)
            ret=[];
        end


        function ret=getHierarchyReference(~)
            ret='';
        end


        function ret=getTimeDim(~)
            ret=1;
        end


        function ret=getSampleDims(~)
            ret=[1,1];
        end


        function ret=getInterpolation(~)
            ret='zoh';
        end


        function ret=getUnit(~)
            ret='';
        end


        function ret=getMetaData(this)
            try
                ret=int2str(this.VariableValue.getIdUint64);
            catch me %#ok
                ret=[];
            end
        end


        function ret=getTimeValues(this)
            ret=this.VariableValue.Time;
        end


        function ret=getDataValues(this)
            ret=[];
            if~isempty(this.VariableValue.Time)
                ret=getExecTimeDataForSDI(this.VariableValue);
            end
        end


        function ret=isHierarchical(~)
            ret=false;
        end


        function ret=getChildren(~)
            ret={};
        end


        function ret=allowSelectiveChildImport(~)
            ret=false;
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
