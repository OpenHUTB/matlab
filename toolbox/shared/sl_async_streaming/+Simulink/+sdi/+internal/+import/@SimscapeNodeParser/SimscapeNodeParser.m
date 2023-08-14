classdef SimscapeNodeParser<Simulink.sdi.internal.import.VariableParser



    methods


        function ret=supportsType(~,obj)
            ret=...
            isa(obj,'simscape.logging.Node')&&...
            (numChildren(obj)>0);
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


        function ret=getBlockSource(this)
            if isempty(this.CachedBlockPath)
                bIsChild=...
                ~isempty(this.Parent)&&...
                isa(this.Parent,'Simulink.sdi.internal.import.SimscapeNodeParser');



                if~bIsChild&&isempty(this.Parent)
                    if~strcmp(getName(this.VariableValue),getSource(this.VariableValue))
                        bIsChild=true;
                    end
                end


                if bIsChild
                    sid=getSID(this);%#ok<NASGU>
                    try
                        bpath=eval('Simulink.ID.getFullName(sid)');
                    catch me %#ok<NASGU>
                        bpath='';
                    end
                    if isempty(bpath)
                        if isempty(this.Parent)
                            bpath=getSignalLabel(this);
                        else
                            bpath=[getBlockSource(this.Parent),'/',getSignalLabel(this)];
                        end
                    end
                else
                    bpath=getSignalLabel(this);
                end


                this.CachedBlockPath=Simulink.SimulationData.BlockPath.manglePath(bpath);
            end

            ret=this.CachedBlockPath;
        end


        function ret=getSID(this)
            ret='';
            if hasSource(this.VariableValue)
                ret=getSource(this.VariableValue);
            end
        end


        function ret=getModelSource(this)
            ret='';
            bpath=getBlockSource(this);
            if~isempty(bpath)
                ret=Simulink.SimulationData.BlockPath.getModelNameForPath(bpath);
            end
        end


        function ret=getSignalLabel(this)
            ret=getName(this.VariableValue);
        end


        function ret=getPortIndex(~)
            ret=[];
        end


        function ret=getHierarchyReference(this)
            if isempty(this.CachedHierRef)
                bIsChild=...
                ~isempty(this.Parent)&&...
                isa(this.Parent,'Simulink.sdi.internal.import.SimscapeNodeParser');


                if bIsChild
                    bpath=[getHierarchyReference(this.Parent),'/',getSignalLabel(this)];
                else
                    bpath=getSignalLabel(this);
                end


                this.CachedHierRef=Simulink.SimulationData.BlockPath.manglePath(bpath);
            end

            ret=this.CachedHierRef;
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

            if isempty(this.LeafBusPath)
                busPrefix=getSignalLabel(this);
            else
                busPrefix=this.LeafBusPath;
            end

            numFields=this.VariableValue.numChildren();
            fnames=this.VariableValue.childIds();



            ret={};
            iRet=1;
            for idx=1:numFields
                curField=fnames{idx};
                curVal=this.VariableValue.(curField);
                numVals=numel(curVal);
                for iVal=1:numVals


                    if numVals>1
                        curField=curVal(iVal).getName;
                    end
                    if isempty(curVal(iVal))
                        ret{iRet}=Simulink.sdi.internal.import.TimeseriesParser;%#ok<*AGROW>
                        curVal(iVal)=timeseries([],[],'Name','');
                    elseif numChildren(curVal(iVal))>0
                        ret{iRet}=Simulink.sdi.internal.import.SimscapeNodeParser;
                    else
                        ret{iRet}=Simulink.sdi.internal.import.SimscapeSeriesParser;
                    end

                    ret{iRet}.VariableName=[this.VariableName,'.',curField];
                    ret{iRet}.VariableValue=curVal(iVal);
                    ret{iRet}.WorkspaceParser=this.WorkspaceParser;
                    ret{iRet}.Parent=this;
                    ret{iRet}.LeafBusPath=[busPrefix,'.',curField];
                    ret{iRet}.VariableSignalName=[busPrefix,'.',curField];
                    iRet=iRet+1;
                end
            end
        end


        function ret=allowSelectiveChildImport(~)
            ret=true;
        end


        function ret=isVirtualNode(this)
            bIsChild=...
            ~isempty(this.Parent)&&...
            isa(this.Parent,'Simulink.sdi.internal.import.SimscapeNodeParser');
            ret=bIsChild;
        end


        function ret=getRepresentsRun(~)
            ret=false;
        end


        function setRunMetaData(~,~,~)
        end


        function ret=getDomainType(~)
            ret='ssc_var';
        end


        function ret=alwaysShowInImportUI(~)
            ret=true;
        end
    end


    properties(Access=private)
CachedBlockPath
CachedHierRef
    end
end
