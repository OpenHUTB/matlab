
%#ok<*AGROW>

classdef LabeledSignalSetCellArrayParser<Simulink.sdi.internal.import.VariableParser





    properties
SignalIndex
    end


    methods


        function ret=supportsType(~,~)
            ret=false;
        end




        function ret=getRootSource(this)
            ret=this.VariableName;
        end


        function ret=getTimeSource(~)
            ret='';
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
            ret=this.VariableName;
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


        function ret=getInterpolation(this)
            if strcmp(this.TimeSourceRule,'siganalyzer')
                ret='linear';
            else
                ret='zoh';
            end
        end


        function ret=getUnit(~)
            ret='';
        end


        function ret=getMetaData(~)
            ret=[];
        end


        function ret=getTimeMetadataMode(this)
            if strcmp(this.TimeSourceRule,'siganalyzer')
                ret='inherentLabeledSignalSet';
            else
                ret='';
            end
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
            ret={};
            if isHierarchical(this)
                numElements=length(this.VariableValue);
                ret={};
                retIdx=0;
                isNonFiniteSupported=isstruct(this.Metadata)&&isfield(this.Metadata,"IsNonFiniteSupported")&&this.Metadata.IsNonFiniteSupported;
                for idx=1:numElements
                    data=this.VariableValue{idx};
                    if(~isnumeric(data)&&~islogical(data)&&~istimetable(data))||...
                        (~istimetable(data)&&~isNonFiniteSupported&&~all(isfinite(data(:))))
                        continue;
                    end
                    retIdx=retIdx+1;
                    if istimetable(data)
                        ret{retIdx}=Simulink.sdi.internal.import.TimetableParser;
                        data.Properties.VariableNames=matlab.lang.makeUniqueStrings(matlab.lang.makeValidName(data.Properties.VariableNames));
                        ret{retIdx}.VariableValue=data;
                        ret{retIdx}.Metadata=this.Metadata;
                    else
                        ret{retIdx}=Simulink.sdi.internal.import.NumericArrayParser;
                        ret{retIdx}.VariableValue=getTimeValuesForNumericArrayData(this,idx);
                    end
                    ret{retIdx}.Parent=this;
                    ret{retIdx}.VariableName=[this.VariableName,'{',num2str(idx),'}'];
                    ret{retIdx}.VariableBlockPath=this.VariableBlockPath;
                    ret{retIdx}.VariableSignalName=this.VariableSignalName;
                    ret{retIdx}.SignalIndex=[];
                    ret{retIdx}.TimeSourceRule=this.TimeSourceRule;
                    ret{retIdx}.WorkspaceParser=this.WorkspaceParser;
                end
            end
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

        function data=getTimeValuesForNumericArrayData(this,idx)
            data=this.VariableValue{idx};
            switch this.Parent.VariableValue.TimeInformation
            case "sampleRate"
                fs=this.Parent.VariableValue.SampleRate;
                if~isscalar(fs)
                    fs=fs(this.SignalIndex);
                end
                time=(0:size(data,1)-1)'/fs;
            case "sampleTime"
                ts=this.Parent.VariableValue.SampleTime;
                if~isscalar(ts)
                    ts=ts(this.SignalIndex);
                end
                time=(0:size(data,1)-1)'*ts;
            case "timeValues"
                timeValues=this.Parent.VariableValue.TimeValues;
                if iscell(timeValues)
                    if numel(timeValues)>1
                        timeValues=timeValues{this.SignalIndex};
                        time=timeValues(:);
                    else
                        timeValues=timeValues{1};
                        time=timeValues(:);
                    end
                elseif size(timeValues,2)>1
                    time=timeValues(:,this.SignalIndex);
                end
            case "none"
                time=(0:size(data,1)-1)';
            end
            if isduration(time)
                time=seconds(time);
            end
            data=[time,data];
        end
    end
end
