classdef ExecRow<handle

    properties
        locationName='';
        objectPath;
        uiNode;
        phase='';
        numCalls=0;
        selfTime=0;
        totalSimTime=inf;
        children=Simulink.internal.SimulinkProfiler.ExecRow.empty;
        totalTime=nan;
    end

    properties(Dependent)
        totalTimeStr;
        selfTimeStr;
        shortLabel;
        numCallsStr;
    end

    properties(Transient)
        BlockPathLabel=DAStudio.message('Simulink:Profiler:BlockPath');
        TotalTimeLabel=DAStudio.message('Simulink:Profiler:TotalTime');
        SelfTimeLabel=DAStudio.message('Simulink:Profiler:SelfTime');
        TimePlotLabel=DAStudio.message('Simulink:Profiler:TimePlot');
        NumCallsLabel=DAStudio.message('Simulink:Profiler:NumCalls');
    end

    methods

        function str=get.totalTimeStr(this)
            str=sprintf('%.3f',this.totalTime);
        end

        function str=get.selfTimeStr(this)
            str=sprintf('%.3f',this.selfTime);
        end

        function str=get.shortLabel(this)
            str=this.locationName;
        end

        function str=get.numCallsStr(this)
            str=sprintf('%d',this.numCalls);
        end

        function propValue=getPropValue(obj,propName)
            switch propName
            case obj.BlockPathLabel
                propValue=obj.shortLabel;
            case obj.TotalTimeLabel
                propValue=obj.totalTimeStr;
            case obj.SelfTimeLabel
                propValue=obj.selfTimeStr;
            case obj.TimePlotLabel
                propValue=obj.totalTime;
            case obj.NumCallsLabel
                propValue=obj.numCallsStr;
            otherwise
                propValue='default';
            end
        end

        function getPropertyStyle(this,propName,propertyStyle)
            if(isequal(propName,this.TimePlotLabel))
                propertyStyle.WidgetInfo=struct('Type','progressbar',...
                'Values',...
                round([this.selfTime/this.totalSimTime*100,(this.totalTime-this.selfTime)/this.totalSimTime*100]),...
                'Colors',[[0,0,1,1],[0.4,0.8,1,1]],'Width',round(this.totalTime/this.totalSimTime*250));
                propertyStyle.Tooltip=DAStudio.message('Simulink:Profiler:TimePlotTooltip',this.selfTimeStr,this.totalTimeStr);
            end
        end

        function isValid=isValidProperty(obj,propName)
            switch propName
            case obj.TotalTimeLabel
                isValid=true;
            case obj.SelfTimeLabel
                isValid=true;
            case obj.BlockPathLabel
                isValid=true;
            case obj.TimePlotLabel
                isValid=true;
            case obj.NumCallsLabel
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



                    st=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
                    if~isempty(st)
                        mostActiveStudio=st(1);
                        piCmp=mostActiveStudio.getComponent('GLUE2:PropertyInspector','Property Inspector');
                        piObj=piCmp.getInspector;

                        cleanup=onCleanup(@()piObj.setSticky(false));
                        piObj.setSticky(true);
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


    methods

        function dlgStruct=getDialogSchema(this,dlg)

            spacerWidget.Type='panel';
            spacerWidget.RowSpan=[1,1];
            spacerWidget.ColSpan=[3,3];

            totalTimeDef.Type='text';
            totalTimeDef.Name=DAStudio.message('Simulink:Profiler:TotalTimeDefinition',this.totalTimeStr,this.selfTimeStr,sprintf('%.3f',this.totalTime-this.selfTime));
            totalTimeDef.RowSpan=[2,2];
            totalTimeDef.ColSpan=[1,1];
            totalTimeDef.WordWrap=true;
            totalTimeDef.Tag='simulink_profiler_pi_total_time_definition';








            totalTimeHeader.Type='text';
            totalTimeHeader.Name=DAStudio.message('Simulink:Profiler:TotalTimeBreakdown',this.shortLabel);
            totalTimeHeader.RowSpan=[1,1];
            totalTimeHeader.ColSpan=[1,1];
            totalTimeHeader.WordWrap=true;
            totalTimeHeader.Bold=true;
            totalTimeHeader.Buddy='simulink_profiler_pi_total_time_definition';




            dlgStruct.DialogTitle='';
            dlgStruct.IsScrollable=true;
            dlgStruct.LayoutGrid=[3,1];
            dlgStruct.ColStretch=[1];
            dlgStruct.RowStretch=[1,1,100];
            dlgStruct.Items={totalTimeHeader,totalTimeDef,spacerWidget};
            dlgStruct.DialogTag='simulink_profiler_property_inspector';
            dlgStruct.EmbeddedButtonSet={''};
        end
    end

end
