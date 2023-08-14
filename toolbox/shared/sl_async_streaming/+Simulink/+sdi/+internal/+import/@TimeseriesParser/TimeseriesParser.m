classdef TimeseriesParser<Simulink.sdi.internal.import.VariableParser





    methods


        function ret=supportsType(~,obj)
            ret=isa(obj,'timeseries')&&isscalar(obj);
        end


        function ret=getRootSource(this)
            ret=this.VariableName;
        end


        function ret=getTimeSource(this)
            ret=[this.VariableName,'.Time'];
        end


        function ret=getDataSource(this)
            ret=[this.VariableName,'.Data'];
        end


        function ret=getBlockSource(this)
            if isempty(this.Parent)
                ret='';
            else
                ret=getBlockSource(this.Parent);
            end
        end


        function ret=getFullBlockPath(this)
            if isempty(this.Parent)
                ret=Simulink.SimulationData.BlockPath();
            else
                ret=getFullBlockPath(this.Parent);
            end
        end


        function ret=getSID(this)
            if isempty(this.Parent)
                ret='';
            else
                ret=getSID(this.Parent);
            end
        end


        function ret=getModelSource(this)
            if isempty(this.Parent)
                ret='';
            else
                ret=getModelSource(this.Parent);
            end
        end


        function ret=getSignalLabel(this)
            name='';
            if ischar(this.VariableValue.Name)||isstring(this.VariableValue.Name)
                name=char(this.VariableValue.Name);
            end
            if strcmp(this.TimeSourceRule,'siganalyzer')
                if isempty(name)
                    ret=this.VariableName;
                else
                    ret=[this.VariableName,'.',char(this.VariableValue.Name)];
                end
            else
                ret=name;









                if~isempty(this.Parent)
                    if isempty(ret)||...
                        isa(this.Parent.VariableValue,'Stateflow.SimulationData.State')||...
                        isa(this.Parent.VariableValue,'Stateflow.SimulationData.Data')
                        ret=getSignalLabel(this.Parent);
                    end
                end
            end
        end


        function[logName,sigName,propName]=getCustomExportNames(this)




            logName=char(this.VariableValue.Name);
            sigName=char(this.VariableValue.Name);
            propName='';





            if~isempty(this.Parent)&&~isa(this.Parent,'Simulink.sdi.internal.import.DatasetParser')
                [logName,~,propName]=getCustomExportNames(this.Parent);
                if~isempty(this.LeafBusPath)
                    sigName=logName;
                end
            end
        end


        function ret=getPortIndex(this)
            if isempty(this.Parent)
                ret=[];
            else
                ret=getPortIndex(this.Parent);
            end
        end


        function ret=getHierarchyReference(~)
            ret='';
        end


        function ret=getTimeDim(this)
            if this.VariableValue.IsTimeFirst
                ret=1;
            elseif length(this.VariableValue.Time)==1
                ret=[];
            else
                ret=ndims(this.VariableValue.Data);
            end
        end


        function ret=getSampleDims(this)


            if isempty(this.CachedSampleDims)
                tssize=size(this.VariableValue.Data);
                if this.VariableValue.IsTimeFirst
                    this.CachedSampleDims=tssize(2:end);
                elseif length(this.VariableValue.Time)==1
                    this.CachedSampleDims=tssize;
                else
                    this.CachedSampleDims=tssize(1:end-1);
                end
            end
            ret=this.CachedSampleDims;
        end


        function ret=getInterpolation(this)
            ret=getinterpmethod(this.VariableValue);
        end


        function setSignalCustomMetaData(this,sigID)
            if~isempty(this.Parent)&&isa(this.Parent.VariableValue,'sltest.Assessment')
                Simulink.sdi.internal.import.AssessmentSetParser.setAssessmentMetaData(...
                sigID,this.Parent.VariableValue);
            end
        end


        function ret=getSampleTimeString(this)
            ret='';
            if~strcmpi(getInterpolation(this),'zoh')
                ret=message('simulation_data_repository:sdr:ContinuousSampleTime').getString();
            elseif this.isTimeUniform()
                ret=num2str(this.VariableValue.TimeInfo.Increment);
            end
        end


        function ret=getTimeIncrement(this)
            if this.isTimeUniform()
                ret=this.VariableValue.TimeInfo.Increment;
            else
                ret=0.0;
            end
        end


        function ret=getDomainType(this)
            if isempty(this.Parent)
                ret='';
            else
                ret=getDomainType(this.Parent);
            end
        end


        function ret=getUnit(this)
            ret='';
            if isa(this.VariableValue.DataInfo.Units,'Simulink.SimulationData.Unit')
                ret=this.VariableValue.DataInfo.Units.Name;
            elseif ischar(this.VariableValue.DataInfo.Units)
                ret=this.VariableValue.DataInfo.Units;
            end
        end


        function ret=getMetaData(~)
            ret=[];
        end


        function ret=getTimeValues(this)
            ret=this.VariableValue.Time;
        end


        function ret=getDataValues(this)
            ret=this.VariableValue.Data;
            if strcmp(this.TimeSourceRule,'siganalyzer')
                ret=double(ret);
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


        function ret=getTimeMetadataMode(this)
            if strcmp(this.TimeSourceRule,'siganalyzer')
                ret='inherentTimeseries';
            else
                ret='';
            end
        end


        function[type,writers]=getSharedMemoryInfo(this)
            type=0;
            writers={};
            if~isempty(this.Parent)
                [type,writers]=getSharedMemoryInfo(this.Parent);
            end
        end


        function ret=getTemporalMetaData(this)
            ret=struct.empty();
            if~isempty(this.Parent)
                ret=getTemporalMetaData(this.Parent);
            end
        end


        function ret=getExtendedSDIProperties(this,varargin)
            ret=struct.empty();
            if~isempty(this.Parent)
                ret=getExtendedSDIProperties(this.Parent,this.LeafBusPath);
            end
        end


        function ret=getTimeAndDataForSignalConstruction(this)
            ret.Time=double(getTimeValues(this));
            ret.Data=getDataValues(this);
            ret.CompressedTimeInc=getTimeIncrement(this);
        end

    end

    methods(Hidden)


        function ret=isTimeUniform(this)
            if~isempty(this.VariableValue)&&isa(this.VariableValue,'timeseries')
                ret=ismethod(this.VariableValue.TimeInfo,'isUniform')&&this.VariableValue.TimeInfo.isUniform;
            else
                ret=false;
            end
        end

    end

    properties(Hidden)
CachedSampleDims
    end

end
