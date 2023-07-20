

classdef TimetableLeafParser<Simulink.sdi.internal.import.VariableParser



    properties
SignalIndex
ColName
    end


    methods


        function ret=supportsType(~,~)


            ret=false;
        end


        function ret=getRootSource(this)
            ret=getRootSource(this.Parent);
            if~isempty(this.ColName)
                ret=sprintf('%s.%s',ret,this.ColName);
            end
        end


        function ret=getTimeSource(this)
            ret=getTimeSource(this.Parent);
        end


        function ret=getDataSource(this)
            ret=this.VariableName;
            if~isempty(this.ColName)
                ret=sprintf('%s{:,"%s"}',ret,this.ColName);
            end
        end


        function ret=getBlockSource(this)
            if strcmp(this.TimeSourceRule,'siganalyzer')
                ret=getBlockSource(this.Parent);
            else
                ret='';
                parent=this.Parent;
                if~isempty(parent.Parent)
                    ret=getBlockSource(parent.Parent);
                end
            end
        end


        function ret=getFullBlockPath(this)
            if strcmp(this.TimeSourceRule,'siganalyzer')
                ret=getFullBlockPath(this.Parent);
            else
                ret=Simulink.SimulationData.BlockPath();
                parent=this.Parent;
                if~isempty(parent.Parent)
                    ret=getFullBlockPath(parent.Parent);
                end
            end
        end


        function ret=getSID(this)
            ret=getSID(this.Parent);
        end


        function ret=getModelSource(this)
            ret=getModelSource(this.Parent);
        end


        function ret=getSignalLabel(this)
            if~isempty(this.ColName)
                ret=this.ColName;
            else
                ret=getSignalLabel(this.Parent);
            end
        end


        function[logName,sigName,propName]=getCustomExportNames(this)




            logName='';
            sigName='';
            propName='';

            if~isempty(this.Parent)
                [logName,~,propName]=getCustomExportNames(this.Parent);
                if~isempty(this.LeafBusPath)
                    sigName=logName;
                end
            end
        end


        function ret=getPortIndex(this)
            ret=[];
            if~strcmp(this.TimeSourceRule,'siganalyzer')
                parent=this.Parent;
                if~isempty(parent.Parent)
                    ret=getPortIndex(parent.Parent);
                end
            end
        end


        function ret=getHierarchyReference(~)
            ret='';
        end


        function ret=getTimeDim(~)
            ret=1;
        end


        function ret=getSampleDims(this)
            if strcmp(this.TimeSourceRule,'siganalyzer')
                ret=1;
            else
                ttsize=size(this.VariableValue{1,1});
                ret=ttsize(2:end);

                if(isequal(numel(ret),1)&&ret>1)
                    isWide=false;
                    userData=this.VariableValue.Properties.UserData;
                    if~isempty(userData)&&...
                        isfield(userData,'AppData')&&...
                        isfield(userData.AppData,'IsSimulinkWideSignal')
                        isWide=userData.AppData.IsSimulinkWideSignal;
                    end
                    if~isWide
                        ret=[ret,1];
                    end
                end
            end
        end


        function ret=getInterpolation(this)
            ret=getInterpolation(this.Parent);
        end


        function ret=isEventBasedSignal(this)
            ret=isEventBasedSignal(this.Parent);
        end


        function ret=getUnit(~)
            ret='';
        end


        function ret=getMetaData(~)
            ret=[];
        end


        function ret=getTimeMetadataMode(this)
            ret=getTimeMetadataMode(this.Parent);
        end


        function ret=getTimeValues(this)
            ret=getTimeValues(this.Parent);
        end


        function ret=getDataValues(this)
            if(strcmp(this.TimeSourceRule,'siganalyzer'))
                ret=[];
            else




                sampleSz=size(this.VariableValue{1,1});
                if numel(sampleSz)<3




                    ret=this.VariableValue{:,1};





                    if sampleSz(2)>1
                        isWide=false;
                        userData=this.VariableValue.Properties.UserData;
                        if~isempty(userData)&&...
                            isfield(userData,'AppData')&&...
                            isfield(UserData.AppData,'IsSimulinkWideSignal')
                            isWide=userData.AppData.IsSimulinkWideSignal;
                        end
                        if~isWide

                            totalDataSize=size(this.VariableValue{:,1});
                            ret=reshape(this.VariableValue{:,1}',...
                            sampleSz(2),sampleSz(1),totalDataSize(1));
                        end
                    end
                else




                    ret=shiftdim(this.VariableValue{:,1},1);
                end
            end
        end


        function ret=isHierarchical(this)
            if strcmp(this.TimeSourceRule,'siganalyzer')
                ret=true;
            else
                ret=false;
            end
        end


        function ret=getChildren(this)
            ret=[];
            if isHierarchical(this)
                time=getTimeValues(this);
                data=this.VariableValue.Variables;
                if strcmp(this.TimeSourceRule,'siganalyzer')&&...
                    ~ismatrix(data)
                    return;
                end
                data=[time,data];
                ret={};
                ret{1}=Simulink.sdi.internal.import.NumericArrayParser;
                ret{1}.Parent=this;
                ret{1}.VariableName=this.VariableName;
                ret{1}.VariableBlockPath=this.VariableBlockPath;
                ret{1}.VariableSignalName=this.VariableSignalName;
                ret{1}.VariableValue=data;
                ret{1}.SignalIndex=[];
                ret{1}.TimeSourceRule=this.TimeSourceRule;
                ret{1}.WorkspaceParser=this.WorkspaceParser;
            end
        end


        function ret=allowSelectiveChildImport(~)
            ret=true;
        end


        function ret=isVirtualNode(this)
            if strcmp(this.TimeSourceRule,'siganalyzer')
                ret=true;
            else
                ret=false;
            end
        end


        function ret=getRepresentsRun(~)
            ret=false;
        end


        function setRunMetaData(~,~,~)
        end


        function[type,writers]=getSharedMemoryInfo(this)
            type=0;
            writers={};
            if~isempty(this.Parent)
                [type,writers]=getSharedMemoryInfo(this.Parent);
            end
        end
    end
end
