
%#ok<*AGROW>
classdef LabeledSignalSetParser<Simulink.sdi.internal.import.VariableParser



    properties
SignalIndex
    end


    methods


        function ret=supportsType(this,var)
            ret=false;
            if strcmp(this.TimeSourceRule,'siganalyzer')

                if isa(var,'labeledSignalSet')
                    numMembers=var.NumMembers;
                    for idx=1:numMembers
                        memberData=var.Source{idx};
                        if istimetable(memberData)
                            cols(idx)=size(memberData.Variables,2);
                        elseif iscell(memberData)
                            cols(idx)=numel(memberData);
                        else
                            cols(idx)=size(memberData,2);
                        end
                    end
                    ret=numMembers>0&&...
                    sum(cols)<=8000;
                end
            end
        end


        function ret=getRootSource(this)
            ret=this.VariableName;
        end


        function ret=getTimeSource(this)
            ret=[this.VariableName,'.TimeInformation'];
        end


        function ret=getDataSource(this)
            ret=[this.VariableName,'.Source'];
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


        function ret=getInterpolation(~)
            ret='linear';
        end


        function ret=getUnit(~)
            ret='';
        end


        function ret=getMetaData(~)
            ret=[];
        end


        function ret=getTimeMetadataMode(~)
            ret='inherentLabeledSignalSet';
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
                numMembers=getNumberOfDataValueColumns(this);
                ret={};
                retIdx=0;
                isNonFiniteSupported=isstruct(this.Metadata)&&isfield(this.Metadata,"IsNonFiniteSupported")&&this.Metadata.IsNonFiniteSupported;
                for idx=1:numMembers
                    memberName=getDataValueColumnNameByIndex(this,idx);
                    data=getSignal(this.VariableValue,idx);
                    if(~isnumeric(data)&&~islogical(data)&&~istimetable(data)&&~iscell(data))||...
                        (isnumeric(data)&&~isNonFiniteSupported&&~all(isfinite(data(:))))
                        continue;
                    end
                    retIdx=retIdx+1;
                    if istimetable(data)
                        ret{retIdx}=Simulink.sdi.internal.import.TimetableParser;
                        data.Properties.VariableNames=matlab.lang.makeUniqueStrings(matlab.lang.makeValidName(data.Properties.VariableNames));
                        ret{retIdx}.VariableValue=data;
                        ret{retIdx}.SignalIndex=[];
                        ret{retIdx}.Metadata=this.Metadata;
                    elseif iscell(data)
                        ret{retIdx}=Simulink.sdi.internal.import.LabeledSignalSetCellArrayParser;
                        ret{retIdx}.VariableValue=data;
                        ret{retIdx}.SignalIndex=idx;
                        ret{retIdx}.Metadata=this.Metadata;
                    else
                        ret{retIdx}=Simulink.sdi.internal.import.NumericArrayParser;
                        ret{retIdx}.VariableValue=getTimeValuesForNumericArrayData(this,idx);
                        ret{retIdx}.SignalIndex=[];
                    end
                    ret{retIdx}.Parent=this;
                    ret{retIdx}.VariableName=char(memberName);
                    ret{retIdx}.VariableBlockPath=this.VariableBlockPath;
                    ret{retIdx}.VariableSignalName=this.VariableSignalName;
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


        function ret=getDataValueColumnNameByIndex(this,idx)
            appendLSSNameToMembers=true;
            if isstruct(this.Metadata)&&isfield(this.Metadata,"AppendLSSNameToMembers")
                appendLSSNameToMembers=this.Metadata.AppendLSSNameToMembers;
            end
            names=getMemberNames(this.VariableValue);
            if appendLSSNameToMembers
                ret=strcat(this.VariableName,":",names(idx));
            else
                ret=names(idx);
            end
        end


        function ret=getNumberOfDataValueColumns(this)
            ret=this.VariableValue.NumMembers;
        end


        function ret=getDataValuesColumnNames(this)
            ret=getMemberNames(this.VariableValue);
        end

        function data=getTimeValuesForNumericArrayData(this,midx)
            data=getSignal(this.VariableValue,midx);
            switch this.VariableValue.TimeInformation
            case "sampleRate"
                fs=this.VariableValue.SampleRate;
                if~isscalar(fs)
                    fs=fs(midx);
                end
                time=(0:size(data,1)-1)'/fs;
            case "sampleTime"
                ts=this.VariableValue.SampleTime;
                if~isscalar(ts)
                    ts=ts(midx);
                end
                time=(0:size(data,1)-1)'*ts;
            case "timeValues"
                timeValues=this.VariableValue.TimeValues;
                if iscell(timeValues)
                    if numel(timeValues)>1
                        timeValues=timeValues{midx};
                        time=timeValues(:);
                    else
                        timeValues=timeValues{1};
                        time=timeValues(:);
                    end
                elseif size(timeValues,2)>1
                    time=timeValues(:,midx);
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


