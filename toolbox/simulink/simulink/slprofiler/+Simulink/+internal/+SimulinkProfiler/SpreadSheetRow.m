classdef SpreadSheetRow<handle
    properties
        shortLabel;
        totalTime;
        selfTime;
        totalTimeStr;
        selfTimeStr;
        totalSimTime;
        children;
        objectPath;
        numCalls;
        numCallsStr;
        readOnlyProperties={DAStudio.message('Simulink:Profiler:BlockPath'),...
        DAStudio.message('Simulink:Profiler:TotalTime'),...
        DAStudio.message('Simulink:Profiler:SelfTime'),...
        DAStudio.message('Simulink:Profiler:NumCalls'),...
        DAStudio.message('Simulink:Profiler:TimePlot')}
    end
    methods
        function this=SpreadSheetRow(total,self,children,totalSimTime,displayPath,numCalls,objectPath)
            modelPathParts=strsplit(displayPath{end},'/');
            this.shortLabel=modelPathParts{end};
            if isempty(total)
                this.totalTime=0;
                this.totalTimeStr=DAStudio.message('Simulink:Profiler:NoData');
            else
                this.totalTime=total;
                this.totalTimeStr=sprintf('%.3f',total);
            end
            if isempty(self)
                this.selfTime=0;
                this.selfTimeStr=DAStudio.message('Simulink:Profiler:NoData');
            else
                this.selfTime=self;
                this.selfTimeStr=sprintf('%.3f',self);
            end
            this.children=children;
            this.totalSimTime=totalSimTime;
            this.objectPath=objectPath;
            if isempty(numCalls)
                this.numCalls=0;
                this.numCallsStr=DAStudio.message('Simulink:Profiler:NoData');
            else
                this.numCalls=numCalls;
                this.numCallsStr=sprintf('%d',numCalls);
            end
        end

        function propValue=getPropValue(obj,propName)
            switch propName
            case DAStudio.message('Simulink:Profiler:BlockPath')
                propValue=obj.shortLabel;
            case DAStudio.message('Simulink:Profiler:TotalTime')
                propValue=obj.totalTimeStr;
            case DAStudio.message('Simulink:Profiler:SelfTime')
                propValue=obj.selfTimeStr;
            case DAStudio.message('Simulink:Profiler:TimePlot')
                propValue=obj.totalTime;
            case DAStudio.message('Simulink:Profiler:NumCalls')
                propValue=obj.numCallsStr;
            otherwise
                propValue='default';
            end
        end

        function getPropertyStyle(this,propName,propertyStyle)
            if(isequal(propName,DAStudio.message('Simulink:Profiler:TimePlot')))
                propertyStyle.WidgetInfo=struct('Type','progressbar',...
                'Values',...
                round([this.selfTime/this.totalSimTime*100,(this.totalTime-this.selfTime)/this.totalSimTime*100]),...
                'Colors',[[0,0,1,1],[0.4,0.8,1,1]],'Width',round(this.totalTime/this.totalSimTime*250));
                propertyStyle.Tooltip=DAStudio.message('Simulink:Profiler:TimePlotTooltip',this.selfTimeStr,this.totalTimeStr);
            end
        end

        function isValid=isValidProperty(~,propName)
            switch propName
            case DAStudio.message('Simulink:Profiler:TotalTime')
                isValid=true;
            case DAStudio.message('Simulink:Profiler:SelfTime')
                isValid=true;
            case DAStudio.message('Simulink:Profiler:BlockPath')
                isValid=true;
            case DAStudio.message('Simulink:Profiler:TimePlot')
                isValid=true;
            case DAStudio.message('Simulink:Profiler:NumCalls')
                isValid=true;
            otherwise
                isValid=false;
            end
        end

        function selections=resolveComponentSelection(this)
            selections={};
            try

                selections={get_param(this.objectPath{end},'Object')};
            catch

            end
        end


        function tf=isReadonlyProperty(~,~)
            tf=true;
        end

        function ch=getChildren(this,~)
            ch=this.children;
        end

        function ch=getHierarchicalChildren(this)
            ch=this.children;
        end

        function tf=isHierarchical(this)
            tf=~isempty(this.children);
        end

        function isHyperlink=propertyHyperlink(this,aPropName,clicked)
            try
                isHyperlink=false;
                if~strcmp(aPropName,DAStudio.message('Simulink:Profiler:BlockPath'))

                    return;
                end
                isHyperlink=true;
                if clicked
                    lowestModelPathParts=strsplit(this.objectPath{end},'/');
                    if numel(this.objectPath)>1





                        pathToContainingModel=this.objectPath(1:end-1);
                        if numel(lowestModelPathParts)<=2


                            p=Simulink.BlockPath(pathToContainingModel);
                        else


                            pathToContainingSubsys={strjoin(lowestModelPathParts(1:end-1),'/')};
                            p=Simulink.BlockPath([pathToContainingModel,pathToContainingSubsys]);
                        end
                        openFcn=@()p.open('Force','on');
                    else

                        if numel(lowestModelPathParts)==1

                            p=this.objectPath{end};
                            openFcn=@()open_system(p);
                        else



                            p=strjoin(lowestModelPathParts(1:end-1),'/');
                            if numel(lowestModelPathParts)<3



                                openFcn=@()open_system(p);
                            else

                                p=Simulink.BlockPath(p);
                                openFcn=@()p.open('Force','on');
                            end
                        end
                    end


                    openFcn();
                end
            catch me %#ok<NASGU> MATLAB can crash if you don't catch error here
            end
        end

        function yesno=isEditablePropertyInInspector(this,propName)
            yesno=false;
        end





        function name=getObjectType(this)
            name=DAStudio.message('Simulink:Profiler:SimulinkProfiler');
        end

        function out=getPropertySchema(this)
            out=this;
        end

        function tf=supportTabView(this)
            tf=true;
        end

        function mode=rootNodeViewMode(~,rootProp)
            mode='Undefined';
            if strcmp(rootProp,'Simulink:Model:Properties')
                mode='SlimDialogView';
            end
        end

        function subprops=subProperties(~,prop)
            subprops={};
            if isempty(prop)
                subprops{1}='Simulink:Model:Properties';
            end
        end

        function s=getObjectName(obj)%#ok<MANU>
            s='';
        end

        function label=propertyDisplayLabel(obj,prop)
            label=prop;
            if strcmp(prop,'Simulink:Model:Properties')
                label=DAStudio.message('Simulink:Profiler:Detail',obj.shortLabel);
            end
        end

    end
end