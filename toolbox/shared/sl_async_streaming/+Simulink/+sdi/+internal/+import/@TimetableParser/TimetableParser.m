

%#ok<*AGROW>
classdef TimetableParser<Simulink.sdi.internal.import.VariableParser



    properties
SignalIndex
        UseColumnNames=false
    end


    methods


        function ret=supportsType(~,var)


            if iscell(var)
                var=var{1};
            end
            ret=false;
            if istimetable(var)
                [~,cols]=size(var.Variables);
                ret=numel(var.Properties.VariableNames)>0&&...
                cols<=8000&&...
                isduration(var.Properties.RowTimes);
            end
        end


        function ret=getRootSource(this)
            ret=this.VariableName;
        end


        function ret=getTimeSource(this)
            name=this.VariableValue.Properties.DimensionNames{1};
            ret=[this.VariableName,'.',name];
        end


        function ret=getDataSource(this)
            if isempty(this.SignalIndex)
                ret=[this.VariableName,'.Properties.VariableNames'];
            else
                dataVarName=this.getDataValueColumnNameByIndex(this.SignalIndex);
                ret=[this.VariableName,'.',dataVarName];
            end
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
            if isempty(this.SignalIndex)
                if~isempty(this.Parent)&&isa(this.Parent,'Simulink.sdi.internal.import.DatasetElementParser')
                    ret=getSignalLabel(this.Parent);
                else
                    str=strsplit(this.VariableName,'.');
                    ret=str{end};
                end
            else
                ret=getDataSource(this);
            end
        end


        function[logName,sigName,propName]=getCustomExportNames(this)




            logName=getSignalLabel(this);
            sigName=logName;
            propName='';





            if~isempty(this.Parent)&&~isa(this.Parent,'Simulink.sdi.internal.import.DatasetParser')
                [logName,~,propName]=getCustomExportNames(this.Parent);
                if~isempty(this.LeafBusPath)
                    sigName=logName;
                end
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


        function ret=getInterpolation(this)
            if strcmp(this.TimeSourceRule,'siganalyzer')
                ret='linear';
            else
                ret='zoh';
                interp=this.VariableValue.Properties.VariableContinuity;
                if isequal(interp,matlab.tabular.Continuity.continuous)
                    ret='linear';
                end
            end
        end


        function ret=isEventBasedSignal(this)
            interp=this.VariableValue.Properties.VariableContinuity;
            ret=isequal(interp,matlab.tabular.Continuity.event);
        end


        function ret=getUnit(~)
            ret='';
        end


        function ret=getMetaData(~)
            ret=[];
        end


        function ret=getTimeMetadataMode(this)
            if strcmp(this.TimeSourceRule,'siganalyzer')
                ret='inherentTimetable';
            else
                ret='';
            end
        end


        function ret=getTimeValues(this)

            ret=seconds(this.VariableValue.Properties.RowTimes);
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
                time=getTimeValues(this);
                if~all(isfinite(time(:)))||(length(time)~=length(unique(time)))
                    return;
                end
                numChannels=getNumberOfDataValueColumns(this);
                ret={};
                retIdx=0;
                bUseColNames=this.UseColumnNames||numChannels>1;
                isNonFiniteSupported=isstruct(this.Metadata)&&isfield(this.Metadata,"IsNonFiniteSupported")&&this.Metadata.IsNonFiniteSupported;
                for idx=1:numChannels
                    colName=getDataValueColumnNameByIndex(this,idx);
                    data=this.VariableValue.(colName);
                    if iscell(data)
                        if~locIsValidVarDimsData(this,data)
                            continue
                        end
                    elseif(~isnumeric(data)&&~islogical(data))||(~isNonFiniteSupported&&~all(isfinite(data(:))))
                        continue;
                    end
                    if strcmp(this.TimeSourceRule,'siganalyzer')&&...
                        ~ismatrix(data)
                        continue;
                    end
                    retIdx=retIdx+1;
                    ret{retIdx}=Simulink.sdi.internal.import.TimetableLeafParser;
                    ret{retIdx}.Parent=this;
                    ret{retIdx}.VariableName=[this.VariableName,'.',colName];
                    ret{retIdx}.VariableBlockPath=this.VariableBlockPath;
                    ret{retIdx}.VariableSignalName=this.VariableSignalName;
                    ret{retIdx}.VariableValue=this.VariableValue(:,colName);
                    ret{retIdx}.SignalIndex=[];
                    ret{retIdx}.TimeSourceRule=this.TimeSourceRule;
                    ret{retIdx}.WorkspaceParser=this.WorkspaceParser;
                    ret{retIdx}.LeafBusPath=this.LeafBusPath;







                    if bUseColNames||~strcmpi(colName,'Data')
                        ret{retIdx}.ColName=colName;
                    end
                end
            end
        end


        function ret=allowSelectiveChildImport(this)
            ret=false;
            if this.getNumberOfVisibleColumns()>1&&~strcmp(this.TimeSourceRule,'siganalyzer')
                ret=true;
            end
        end


        function ret=isVirtualNode(this)
            ret=false;
            if this.getNumberOfVisibleColumns()<2&&~strcmp(this.TimeSourceRule,'siganalyzer')

                ret=true;
            end
        end


        function ret=getRepresentsRun(~)
            ret=false;
        end


        function setRunMetaData(~,~,~)
        end


        function ret=getDataValueColumnNameByIndex(this,idx)
            ret=this.VariableValue.Properties.VariableNames{idx};
        end


        function ret=getNumberOfDataValueColumns(this)
            ret=numel(getDataValuesColumnNames(this));
        end


        function ret=getNumberOfVisibleColumns(this)
            ret=0;
            totalCols=this.getNumberOfDataValueColumns();
            for idx=1:totalCols
                colName=getDataValueColumnNameByIndex(this,idx);
                data=this.VariableValue.(colName);
                if iscell(data)
                    if~locIsValidVarDimsData(this,data)
                        continue
                    end
                elseif(~isnumeric(data)&&~islogical(data))||~all(isfinite(data(:)))
                    continue;
                end
                if strcmp(this.TimeSourceRule,'siganalyzer')&&...
                    ~ismatrix(data)
                    continue;
                end
                ret=ret+1;
            end
        end


        function ret=getDataValuesColumnNames(this)
            ret=this.VariableValue.Properties.VariableNames;
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
    end
end


function ret=locIsValidVarDimsData(this,data)
    numPts=numel(data);
    ret=numPts>0;
    if ret

        if~isnumeric(data{1})&&~islogical(data{1})
            ret=false;
            return
        end
        dt=class(data{1});
        nd=numel(size(data{1}));
        isReal=isreal(data{1});



        isNonFiniteSupported=isstruct(this.Metadata)&&isfield(this.Metadata,"IsNonFiniteSupported")&&this.Metadata.IsNonFiniteSupported;
        for idx=1:numPts
            if numel(size(data{idx}))~=nd||isreal(data{idx})~=isReal||~isa(data{idx},dt)||...
                (~isNonFiniteSupported&&~all(isfinite(data{idx}(:))))
                ret=false;
                return
            end
        end
    end
end


