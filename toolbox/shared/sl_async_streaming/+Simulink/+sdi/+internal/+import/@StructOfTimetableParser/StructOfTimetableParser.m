

classdef StructOfTimetableParser<Simulink.sdi.internal.import.TimetableParser



    properties
        BusName=''
    end


    methods


        function ret=supportsType(this,obj)
            ret=isstruct(obj);
            if ret
                len=numel(obj);
                fnames=fieldnames(obj(1));
                numFields=length(fnames);
                for idx=1:len
                    for fIdx=1:numFields
                        curField=fnames{fIdx};
                        curVal=obj(idx).(curField);
                        if~isa(curVal,'timetable')&&~isempty(curVal)&&~supportsType(this,curVal)
                            ret=false;
                            return
                        end
                    end
                end
            end
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


        function ret=getSignalLabel(this)
            ret=this.BusName;
            if~isempty(this.VariableSignalName)
                ret=this.VariableSignalName;
            elseif~isempty(this.Parent)&&~isa(this.Parent,'Simulink.sdi.internal.import.StructOfTimetableParser')
                ret=getSignalLabel(this.Parent);
            end




            if isempty(ret)&&isempty(this.Parent)
                ret=this.VariableName;
            end
        end


        function ret=getTimeDim(~)
            ret=[];
        end


        function ret=getSampleDims(this)
            ret=size(this.VariableValue);
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

            if isempty(this.LeafBusPath)
                busPrefix=getSignalLabel(this);
            else
                busPrefix=this.LeafBusPath;
            end
            if isempty(busPrefix)
                bpath=getBlockSource(this);
                bpath=Simulink.SimulationData.BlockPath.manglePath(bpath);
                pos=strfind(bpath,'/');
                if~isempty(pos)
                    bpath=bpath(pos+1:end);
                end
                portIdx=getPortIndex(this);
                if~isempty(bpath)&&portIdx>0
                    busPrefix=sprintf('%s:%d',bpath,portIdx);
                else
                    busPrefix=bpath;
                end
            end


            numChannels=numel(this.VariableValue);
            if numChannels>1
                ret=cell(1,numChannels);
                dims=size(this.VariableValue);
                dimIdx=cell(size(dims));
                for idx=1:numChannels
                    ret{idx}=Simulink.sdi.internal.import.StructOfTimetableParser;
                    ret{idx}.Parent=this;
                    ret{idx}.WorkspaceParser=this.WorkspaceParser;

                    [dimIdx{:}]=ind2sub(dims,idx);
                    channelVal=cell2mat(dimIdx);
                    idxStr=sprintf('%d,',channelVal);
                    idxStr=['(',idxStr(1:end-1),')'];

                    ret{idx}.VariableValue=eval(sprintf('this.VariableValue%s',idxStr));
                    ret{idx}.VariableName=[this.VariableName,idxStr];
                    ret{idx}.VariableBlockPath=this.VariableBlockPath;
                    ret{idx}.LeafBusPath=[busPrefix,idxStr];
                    ret{idx}.VariableSignalName=ret{idx}.LeafBusPath;
                    ret{idx}.BusName=this.BusName;
                end


            else
                fnames=fieldnames(this.VariableValue);
                numFields=length(fnames);
                ret=cell(1,numFields);
                for idx=1:numFields
                    curField=fnames{idx};
                    curVar.VarName=[this.VariableName,'.',curField];
                    curVar.VarBlockPath=this.VariableBlockPath;
                    curVar.VarValue=this.VariableValue.(curField);
                    if isempty(curVar.VarValue)
                        curVar.VarValue=timetable();
                    end
                    curParsers=parseVariables(this.WorkspaceParser,curVar);
                    assert(length(curParsers)==1);

                    ret{idx}=curParsers{1};
                    ret{idx}.Parent=this;
                    ret{idx}.LeafBusPath=[busPrefix,'.',curField];
                    ret{idx}.VariableSignalName=curField;
                    if isa(ret{idx},'Simulink.sdi.internal.import.StructOfTimetableParser')
                        ret{idx}.BusName=curField;
                    end
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
