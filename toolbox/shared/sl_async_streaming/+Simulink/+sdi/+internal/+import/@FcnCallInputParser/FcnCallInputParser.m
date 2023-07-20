classdef FcnCallInputParser<Simulink.sdi.internal.import.VariableParser



    properties
    end


    methods


        function ret=supportsType(this,var)
            ret=false;


            return


            if~isa(var,'double')||~iscolumn(var)||isempty(var)||isscalar(var)||~issorted(var)
                return
            end




            switch lower(this.TimeSourceRule)
            case{'model based','scope','siganalyzer'}
                return
            otherwise
                ret=true;
            end
        end


        function ret=getRootSource(this)
            ret=this.VariableName;
        end


        function ret=getTimeSource(this)
            ret=this.VariableName;
        end


        function ret=getDataSource(this)
            ret=this.VariableName;
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
            if~isempty(this.Parent)
                ret=getSignalLabel(this.Parent);
            else
                ret=this.VariableName;
            end
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
            ret=1;
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


        function ret=getTimeMetadataMode(~)
            ret='';
        end


        function ret=getTimeValues(this)
            ret=this.VariableValue;
        end


        function ret=getDataValues(this)
            ret=ones(size(this.VariableValue));
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


        function ret=isEventBasedSignal(~)
            ret=true;
        end


        function ret=getDomainType(~)
            ret='fcncall_input';
        end
    end

end
