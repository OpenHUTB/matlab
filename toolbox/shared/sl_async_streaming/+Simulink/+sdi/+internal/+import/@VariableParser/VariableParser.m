classdef VariableParser<handle




    properties
Parent

        VariableName=''
VariableValue
        LeafBusPath=''
        ForEachIter=[]
        Metadata=[];



        VariableBlockPath=''
        VariableSignalName=''














        TimeSourceRule='block based'
        UniqueKeyStr=''
WorkspaceParser
    end


    methods(Abstract)


        ret=supportsType(this,obj);


        ret=getRootSource(this);
        ret=getTimeSource(this);
        ret=getDataSource(this);

        ret=getBlockSource(this);
        ret=getSID(this);
        ret=getModelSource(this);
        ret=getSignalLabel(this);
        ret=getPortIndex(this);
        ret=getHierarchyReference(this);

        ret=getTimeDim(this);
        ret=getSampleDims(this);

        ret=getInterpolation(this);
        ret=getUnit(this);
        ret=getMetaData(this);


        ret=getTimeValues(this);
        ret=getDataValues(this);


        ret=isHierarchical(this);
        ret=getChildren(this);



        ret=allowSelectiveChildImport(this);




        ret=isVirtualNode(this)


        ret=getRepresentsRun(this);
        setRunMetaData(this,repo,runID);
    end


    methods
        function setSignalCustomMetaData(~,~)




        end

        function ret=getSampleTimeString(~)
            ret='';
        end

        function ret=getTimeIncrement(~)
            ret=0.0;
        end

        function ret=getDomainType(~)
            ret='';
        end

        function ret=getForEachParentDims(~)
            ret=[];
        end

        function ret=getTimeMetadataMode(~)
            ret='';
        end

        function ret=isEventBasedSignal(~)
            ret=false;
        end

        function setVariableChecked(this,val)
            setVariableChecked(this.WorkspaceParser,this,val);
        end

        function ret=isVariableChecked(this)
            ret=isVariableChecked(this.WorkspaceParser,this);
        end

        function ret=getTimeAndDataForSignalConstruction(this)



            ret.Time=double(getTimeValues(this));
            ret.Data=getDataValues(this);
        end

        function ret=useLazyConstruction(~)



            ret=false;
        end

        function[logName,sigName,propName]=getCustomExportNames(~)




            logName='';
            sigName='';
            propName='';
        end

        function ret=getFullBlockPath(this)
            bpath=getBlockSource(this);
            if isempty(bpath)
                ret=Simulink.SimulationData.BlockPath;
            else
                ret=Simulink.SimulationData.BlockPath(bpath);
            end
        end

        function ret=alwaysShowInImportUI(~)
            ret=false;
        end

        function ret=getDescription(~)
            ret='';
        end

        function[type,writers]=getSharedMemoryInfo(~)
            type=0;
            writers={};
        end

        function ret=getTemporalMetaData(~)
            ret=struct.empty();
        end

        function ret=getExtendedSDIProperties(~,varargin)
            ret=struct();
        end

        function ret=getLeafPaths(this)
            if isempty(this.CachedLeafPaths)
                this.CachedLeafPaths={};
                if~isHierarchical(this)
                    this.CachedLeafPaths{end+1}=this.LeafBusPath;
                else
                    c=getChildren(this);
                    for idx=1:numel(c)
                        this.CachedLeafPaths=[this.CachedLeafPaths,c{idx}.getLeafPaths()];
                    end
                end
            end
            ret=this.CachedLeafPaths;
        end

        function ret=isTopLevelDatasetElement(this)




            ret=false;
            if~isempty(this.Parent)&&isVirtualNode(this.Parent)
                ret=isTopLevelDatasetElement(this.Parent);
            end
        end


        function setUniqueKeyStr(this,keyStr)
            this.UniqueKeyStr=keyStr;
        end


        function ret=getUniqueKeyStr(this)
            ret=this.UniqueKeyStr;
            if isempty(ret)
                ret=getRootSource(this);
            end
        end
    end


    properties(Access=private)
        CachedLeafPaths={}
    end
end
