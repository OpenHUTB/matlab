classdef DomainSpecPropertyDDG<handle




    properties
        isAtRoot=true;
        modelH=0;
        graphH=0;

        hasDomainSpec=0;
        domainType='';
        parameterizeDiscreteRates=false;
        baseStepSize='';
        usingTimingServices=false;

        domainConstraint='None';

        dataflowEnabled=false;
        dataflowLatency=0;
        dataflowMultirateEnabled=false;
        dataflowMultirate=false;
    end

    properties(SetAccess=private)
        activeDomainTypes cell...
        {mustBeMember(activeDomainTypes,{'Deduce','Discrete','Continuous','Dataflow','ExportFunction'})}...
        ={'Deduce'};
    end

    methods
        function schema=getDialogSchema(obj)




            model=get_param(obj.modelH,'Object');
            isEnabled=~model.isHierarchySimulating&&...
            ~strcmpi(obj.domainConstraint,'DisallowAll');

            rowIdx=1;
            descTxt.Name=DAStudio.message('Simulink:dialog:SL_DSCPT_DOMAINCONFIG_V2');
            descTxt.Type='text';
            descTxt.WordWrap=true;
            descTxt.RowSpan=[1,1];
            descTxt.ColSpan=[1,1];
            descTxt.PreferredSize=[150,-1];

            rowIdx=rowIdx+1;
            SetDomainSpecWidget.Name=DAStudio.message('Simulink:dialog:SetDomainSpec');
            SetDomainSpecWidget.Type='checkbox';
            SetDomainSpecWidget.Tag='SetExecutionDomain';
            SetDomainSpecWidget.ObjectMethod='setHasDomainSpec';
            SetDomainSpecWidget.MethodArgs={'%dialog','%tag','%value'};
            SetDomainSpecWidget.ArgDataTypes={'handle','string','mxArray'};
            SetDomainSpecWidget.RowSpan=[rowIdx,rowIdx];
            SetDomainSpecWidget.ColSpan=[1,1];
            SetDomainSpecWidget.Source=obj;
            SetDomainSpecWidget.Visible=1;
            SetDomainSpecWidget.Enabled=isEnabled;
            SetDomainSpecWidget.DialogRefresh=1;
            SetDomainSpecWidget.Value=obj.hasDomainSpec;
            SetDomainSpecWidget.PreferredSize=[150,-1];

            items={descTxt,SetDomainSpecWidget};
            if obj.hasDomainSpec
                rowIdx=rowIdx+1;
                DomainTypeWidget.Name=DAStudio.message('Simulink:dialog:SubsystemDomain');
                DomainTypeWidget.Type='combobox';


                DomainTypeWidget.Entries={DAStudio.message('Simulink:dialog:DeduceFromContents_Exec_CB')};
                obj.activeDomainTypes={'Deduce'};
                if~strcmp(obj.domainConstraint,'OnlyAllowDataflow')
                    DomainTypeWidget.Entries{end+1}=DAStudio.message('Simulink:dialog:Discrete_Exec_CB');
                    obj.activeDomainTypes{end+1}='Discrete';
                    if(slfeature('ExecutionDomainAwareSampleTimePropagation')>1)
                        DomainTypeWidget.Entries{end+1}=DAStudio.message('Simulink:dialog:Continuous_Exec_CB');
                        obj.activeDomainTypes{end+1}='Continuous';
                    end
                end
                if(obj.dataflowEnabled)
                    DomainTypeWidget.Entries{end+1}=DAStudio.message('Simulink:dialog:Dataflow_Exec_CB');
                    obj.activeDomainTypes{end+1}='Dataflow';
                end
                if obj.isAtRoot&&...
                    slfeature('ExecutionDomainExportFunction')>0
                    DomainTypeWidget.Entries{end+1}=DAStudio.message('Simulink:dialog:ExportFunction_Exec_CB');
                    obj.activeDomainTypes{end+1}='ExportFunction';
                end

                DomainTypeWidget.Tag='ExecutionDomainType';
                DomainTypeWidget.RowSpan=[rowIdx,rowIdx];
                DomainTypeWidget.ColSpan=[1,1];
                DomainTypeWidget.Visible=1;
                DomainTypeWidget.Enabled=isEnabled;
                DomainTypeWidget.Value=obj.getDomainType();
                DomainTypeWidget.Source=obj;
                DomainTypeWidget.ObjectMethod='setExecutionDomainType';
                DomainTypeWidget.MethodArgs={'%dialog','%tag','%value'};
                DomainTypeWidget.ArgDataTypes={'handle','string','mxArray'};
                DomainTypeWidget.DialogRefresh=1;
                DomainTypeWidget.Mode=true;
                DomainTypeWidget.Tunable=false;
                DomainTypeWidget.PreferredSize=[150,-1];

                items=[items,{DomainTypeWidget}];
            end

            generalGrp.Name=DAStudio.message('Simulink:dialog:DomainType');
            generalGrp.Type='togglepanel';
            generalGrp.Tag='GeneralTag';
            generalGrp.Items=items;
            generalGrp.Expand=true;
            generalGrp.LayoutGrid=[rowIdx,1];
            generalGrp.RowSpan=[1,1];
            generalGrp.ColSpan=[1,1];
            generalGrp.Source=obj;

            hasDomainAttributes=false;
            if obj.hasDomainSpec
                if slfeature('SampleTimeParameterization')&&...
                    obj.isAtRoot&&strcmpi(obj.domainType,'discrete')
                    parameterizeDiscreteRatesWidget.Name=DAStudio.message('Simulink:dialog:ParameterizeDiscreteRates');
                    parameterizeDiscreteRatesWidget.Type='checkbox';
                    parameterizeDiscreteRatesWidget.Tag='ParameterizeDiscreteRates';
                    parameterizeDiscreteRatesWidget.ObjectMethod='setParameterizeDiscreteRates';
                    parameterizeDiscreteRatesWidget.MethodArgs={'%dialog','%tag','%value'};
                    parameterizeDiscreteRatesWidget.ArgDataTypes={'handle','string','mxArray'};
                    parameterizeDiscreteRatesWidget.RowSpan=[rowIdx,rowIdx];
                    parameterizeDiscreteRatesWidget.ColSpan=[1,1];
                    parameterizeDiscreteRatesWidget.Mode=1;
                    parameterizeDiscreteRatesWidget.Visible=1;
                    parameterizeDiscreteRatesWidget.Enabled=isEnabled;
                    parameterizeDiscreteRatesWidget.Value=obj.parameterizeDiscreteRates;
                    parameterizeDiscreteRatesWidget.PreferredSize=[150,-1];
                    items={parameterizeDiscreteRatesWidget};

                    if obj.parameterizeDiscreteRates
                        rowIdx=rowIdx+1;
                        baseStepSizeWidget.Name=DAStudio.message('Simulink:dialog:BaseStepSize');
                        baseStepSizeWidget.Type='edit';
                        baseStepSizeWidget.Tag='BaseStepSize';
                        baseStepSizeWidget.Value=obj.baseStepSize;
                        baseStepSizeWidget.ObjectMethod='setBaseStepSize';
                        baseStepSizeWidget.MethodArgs={'%dialog','%tag','%value'};
                        baseStepSizeWidget.ArgDataTypes={'handle','string','mxArray'};
                        baseStepSizeWidget.RowSpan=[rowIdx,rowIdx];
                        baseStepSizeWidget.ColSpan=[1,2];
                        baseStepSizeWidget.Mode=1;
                        baseStepSizeWidget.DialogRefresh=1;
                        baseStepSizeWidget.Enabled=obj.parameterizeDiscreteRates;
                        baseStepSizeWidget.Visible=1;
                        baseStepSizeWidget.PreferredSize=[150,-1];
                        items=[items,{baseStepSizeWidget}];
                    end

                    hasDomainAttributes=true;
                elseif obj.dataflowEnabled&&strcmpi(obj.domainType,'dataflow')&&~strcmp(get_param(obj.modelH,'BlockDiagramType'),'subsystem')
                    dataflowPanel=getDataflowPanel(obj);
                    dataflowPanel.RowSpan=[rowIdx,rowIdx];
                    dataflowPanel.ColSpan=[1,1];
                    items={dataflowPanel};
                    hasDomainAttributes=true;
                end
                if hasDomainAttributes
                    attrGrp.Name=DAStudio.message('Simulink:dialog:DomainAttributes');
                    attrGrp.Type='togglepanel';
                    attrGrp.Tag='AttributesTag';
                    attrGrp.Expand=true;
                    attrGrp.LayoutGrid=[1,1];
                    attrGrp.Items=items;
                    attrGrp.RowSpan=[2,2];
                    attrGrp.ColSpan=[1,1];
                    attrGrp.Source=obj;
                end
            end

            hasCodegenAttributes=false;
            if slfeature('TimingServicesInCodeGen')>1&&...
                obj.isAtRoot&&strcmpi(obj.domainType,'discrete')
                rowIdx=rowIdx+1;
                usingTimingServicesWidget.Name=DAStudio.message('Simulink:dialog:TimingServicesInCodeGen');
                usingTimingServicesWidget.Type='checkbox';
                usingTimingServicesWidget.Tag='UsingTimingServicesInCodeGeneration';
                usingTimingServicesWidget.ObjectMethod='setUsingTimingServices';
                usingTimingServicesWidget.MethodArgs={'%dialog','%tag','%value'};
                usingTimingServicesWidget.ArgDataTypes={'handle','string','mxArray'};
                usingTimingServicesWidget.RowSpan=[rowIdx,rowIdx];
                usingTimingServicesWidget.ColSpan=[1,1];
                usingTimingServicesWidget.Mode=1;
                usingTimingServicesWidget.Visible=1;
                usingTimingServicesWidget.Enabled=isEnabled;
                usingTimingServicesWidget.Value=obj.usingTimingServices;
                usingTimingServicesWidget.PreferredSize=[150,-1];
                items={usingTimingServicesWidget};

                codeGenGrp.Name=DAStudio.message('Simulink:dialog:CodeGeneration');
                codeGenGrp.Type='togglepanel';
                codeGenGrp.Tag='CodegenTag';
                codeGenGrp.Expand=true;
                codeGenGrp.LayoutGrid=[1,1];
                codeGenGrp.Items=items;
                codeGenGrp.RowSpan=[2,2];
                codeGenGrp.ColSpan=[1,1];
                codeGenGrp.Source=obj;

                hasCodegenAttributes=true;
            end

            spacer.Type='panel';
            NumRow=2;
            if hasDomainAttributes
                NumRow=NumRow+1;
            end
            if hasCodegenAttributes
                NumRow=NumRow+1;
            end

            spacer.RowSpan=[NumRow,NumRow];
            spacer.ColSpan=[1,1];




            schema.DialogTitle='';
            schema.DialogTag='DomainSpecificationWidget';
            schema.DialogMode='Slim';
            schema.Items={generalGrp};

            if hasDomainAttributes
                schema.Items=[schema.Items,{attrGrp}];
            end
            if hasCodegenAttributes
                schema.Items=[schema.Items,{codeGenGrp}];
            end
            schema.Items=[schema.Items,{spacer}];

            schema.LayoutGrid=[NumRow,1];
            schema.RowStretch=[zeros(1,NumRow-1),1];


            schema.StandaloneButtonSet={''};
            schema.EmbeddedButtonSet={''};
        end

        function obj=DomainSpecPropertyDDG(graphH)
            obj.graphH=graphH;
            obj.isAtRoot=strcmp(get_param(graphH,'Type'),'block_diagram');
            if obj.isAtRoot
                obj.modelH=obj.graphH;
            else
                obj.modelH=bdroot(graphH);
            end

            obj.domainType=get_param(obj.graphH,'ExecutionDomainType');
            obj.hasDomainSpec=strcmp(get_param(obj.graphH,'SetExecutionDomain'),'on');

            obj.domainConstraint=get_param(obj.graphH,'ExecutionDomainConstraint');

            if obj.isAtRoot
                if slfeature('SampleTimeParameterization')&&strcmpi(obj.domainType,'Discrete')
                    obj.parameterizeDiscreteRates=...
                    strcmpi(get_param(obj.modelH,'ParameterizeDiscreteRates'),'on');
                    if obj.parameterizeDiscreteRates
                        obj.baseStepSize=get_param(obj.modelH,'BaseStepSize');
                    end
                end
                if slfeature('TimingServicesInCodeGen')>1&&strcmpi(obj.domainType,'Discrete')
                    mdl=get_param(obj.modelH,'Name');
                    sdpTypes=coder.internal.rte.SDPTypes(mdl);
                    obj.usingTimingServices=coder.internal.rte.util.getUsingTimerService(sdpTypes,mdl);
                end

                if(strcmp(get_param(obj.modelH,'BlockDiagramType'),'subsystem'))
                    obj.dataflowEnabled=obj.dataflowEnabled|((license('test','signal_blocks')>0)||...
                    strcmpi(get_param(obj.modelH,'ExecutionDomainType'),'Dataflow'));
                end

            else
                obj.dataflowEnabled=obj.dataflowEnabled|((license('test','signal_blocks')>0)||...
                strcmpi(get_param(graphH,'ExecutionDomainType'),'Dataflow'));
                obj.dataflowMultirateEnabled=obj.dataflowEnabled;

                if(obj.dataflowEnabled)
                    obj.dataflowLatency=get_param(graphH,'Latency');
                    if obj.dataflowMultirateEnabled
                        obj.dataflowMultirate=get_param(graphH,'AutoFrameSizeCalculation')=="on";
                    end
                end
            end
        end

        function dataflowPanel=getDataflowPanel(obj)


            dataflowPanelItems={};
            dataflowPanelRowIdx=1;


            dfParamsEnabled=true;
            topMostDataflowSubsystem=[];
            showThreads=false;
            threads=1;


            ui=get_param(obj.modelH,'DataflowUI');
            if(~isempty(ui))
                topMostDataflowSubsystem=ui.getTopMostDataflowSubsystem(obj.graphH);
                if(~isempty(topMostDataflowSubsystem))
                    dfParamsEnabled=(topMostDataflowSubsystem==obj.graphH);
                end

                if(numel(ui.MappingData)>0)
                    mappingData=ui.getBlkMappingData(obj.graphH);
                    if(~isempty(mappingData))&&(bitget(mappingData.Attributes,6))
                        threads=mappingData.NumberOfThreads;
                        showThreads=true;
                    end
                end

            else


                topMostDataflowSubsystem=getTopMostDataflowSubsystem(obj,obj.graphH);
                if(~isempty(topMostDataflowSubsystem))
                    dfParamsEnabled=(topMostDataflowSubsystem==obj.graphH);
                end
            end

            latencyEdit.Name=DAStudio.message('Simulink:dialog:DataflowLatencyEditLabel');
            latencyEdit.Tag='Latency';
            latencyEdit.ToolTip=DAStudio.message('Simulink:dialog:DataflowLatencyEditTooTip');
            latencyEdit.Type='edit';
            latencyEdit.RowSpan=[dataflowPanelRowIdx,dataflowPanelRowIdx];
            latencyEdit.ColSpan=[1,1];
            latencyEdit.Enabled=dfParamsEnabled;
            latencyEdit.Visible=true;
            latencyEdit.Value=obj.dataflowLatency;
            latencyEdit.ObjectMethod='setDataflowLatency';
            latencyEdit.MethodArgs={'%dialog','%tag','%value'};
            latencyEdit.ArgDataTypes={'handle','string','mxArray'};
            latencyEdit.Tunable=false;

            dataflowPanelItems{end+1}=latencyEdit;

            threadsLabel.Name=DAStudio.message('Simulink:dialog:DataflowThreadsNumLabel',threads);
            threadsLabel.Type='text';
            threadsLabel.Tag='ThreadsLabel';
            threadsLabel.RowSpan=[dataflowPanelRowIdx,dataflowPanelRowIdx];
            threadsLabel.ColSpan=[3,4];
            threadsLabel.Visible=showThreads;

            dataflowPanelItems{end+1}=threadsLabel;

            if obj.dataflowMultirateEnabled
                dataflowPanelRowIdx=dataflowPanelRowIdx+1;

                multirateCheckbox.Name=DAStudio.message('Simulink:dialog:DataflowMultirateCheckbox');
                multirateCheckbox.Type='checkbox';
                multirateCheckbox.Tag='AutoFrameSizeCalculation';
                multirateCheckbox.ToolTip=DAStudio.message('Simulink:dialog:DataflowMultirateToolTip');
                multirateCheckbox.RowSpan=[dataflowPanelRowIdx,dataflowPanelRowIdx];
                multirateCheckbox.ColSpan=[1,2];
                multirateCheckbox.Visible=true;
                multirateCheckbox.Enabled=dfParamsEnabled;
                multirateCheckbox.Value=obj.dataflowMultirate;
                multirateCheckbox.ObjectMethod='setDataflowMultirate';
                multirateCheckbox.MethodArgs={'%dialog','%tag','%value'};
                multirateCheckbox.ArgDataTypes={'handle','string','mxArray'};

                dataflowPanelItems{end+1}=multirateCheckbox;
            end


            if(~dfParamsEnabled)
                dataflowPanelRowIdx=dataflowPanelRowIdx+1;

                nestedLabel.Name=['<p>',...
                DAStudio.message('Simulink:dialog:DataflowNestedLabel'),...
                ' <a href="matlab:Simulink.openDataflowSubsystem(''',...
                getfullname(topMostDataflowSubsystem),''')">',...
                getfullname(topMostDataflowSubsystem),'</a></p>'];
                nestedLabel.Type='text';
                nestedLabel.ToolTip=getString(message('Simulink:dialog:DataflowNestedHyperlinkToolTip'));
                nestedLabel.WordWrap=true;
                nestedLabel.Tag='NestedLabel';
                nestedLabel.RowSpan=[dataflowPanelRowIdx,dataflowPanelRowIdx];
                nestedLabel.ColSpan=[1,4];
                nestedLabel.Visible=(~dfParamsEnabled);

                dataflowPanelItems{end+1}=nestedLabel;
            end


            dataflowPanel.Type='panel';
            dataflowPanel.Tag='DataflowPanel';
            dataflowPanel.Flat=false;
            dataflowPanel.LayoutGrid=[dataflowPanelRowIdx,4];
            dataflowPanel.ColStretch=[1,0,1,0];
            dataflowPanel.Visible=strcmpi(obj.domainType,'Dataflow');
            dataflowPanel.Items=dataflowPanelItems;
        end
    end

    methods(Static)
        function dlg=getDomainSpecDialogSchema(graphH)
            obj=Simulink.DomainSpecPropertyDDG(graphH);
            dlg=obj.getDialogSchema();
        end

        function openDomainPropertyInspector(graphType)
            studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            studio=studios(1);
            editor=studio.App.getActiveEditor;
            editor.clearSelection;

            pi=studio.getComponent('GLUE2:PropertyInspector','Property Inspector');
            studio.showComponent(pi);
            inspector=pi.getInspector();
            if strcmp(graphType,'Subsystem')
                pos=3;
            else
                assert(strcmp(graphType,'Model'));
                pos=2;
            end
            inspector.setActiveTab(pos);
        end
    end

    methods(Access=public,Hidden=true)

        function defaultDomainSpecCB_ddg(this,dialog,tag,value)
            if this.isAtRoot
                ed=DAStudio.EventDispatcher;
                ed.broadcastEvent('PropertyUpdateRequestEvent',dialog,{tag,value});
            else
                set_param(this.graphH,tag,value);
            end
            if~dialog.isWidgetWithError(tag)
                dialog.clearWidgetDirtyFlag(tag);
            end
        end

        function refreshDomain(this)
            graphHandle=get_param(this.graphH,'Handle');
            obj=diagram.resolver.resolve(graphHandle,'diagram');
            badgeObj=diagram.badges.get('ExecutionDomainConfiguration','Graph');
            badgeObj.update(obj);
        end

        function setHasDomainSpec(this,dialog,tag,value)
            this.hasDomainSpec=value;


            oldHasDomainSpec=strcmp(get_param(this.graphH,'SetExecutionDomain'),'on');


            if value
                propValue='on';
            else
                propValue='off';
            end
            this.defaultDomainSpecCB_ddg(dialog,tag,propValue);


            if oldHasDomainSpec~=value
                this.refreshDomain();
            end
        end

        function retValue=getDomainType(this)
            if isempty(this.domainType)
                retValue=0;
            else
                for idxDomainType=1:length(this.activeDomainTypes)
                    if strcmpi(this.domainType,this.activeDomainTypes{idxDomainType})
                        retValue=idxDomainType-1;
                        break;
                    end
                end
            end
        end

        function setExecutionDomainType(this,dialog,tag,value)
            assert(value<length(this.activeDomainTypes));
            for idxDomainType=1:length(this.activeDomainTypes)
                if(value+1)==idxDomainType
                    this.domainType=this.activeDomainTypes{idxDomainType};
                    break;
                end
            end


            if this.hasDomainSpec
                oldType=get_param(this.graphH,'ExecutionDomainType');
            end

            this.defaultDomainSpecCB_ddg(dialog,tag,this.domainType);

            if this.hasDomainSpec
                if~strcmpi(oldType,this.domainType)
                    this.refreshDomain();
                end
            end
        end

        function setParameterizeDiscreteRates(this,dialog,tag,value)
            this.parameterizeDiscreteRates=value;


            if value
                propValue='on';
            else
                propValue='off';
            end
            this.defaultDomainSpecCB_ddg(dialog,tag,propValue);
        end

        function setUsingTimingServices(this,dialog,tag,value)
            this.usingTimingServices=value;


            if value
                propValue='on';
            else
                propValue='off';
            end
            this.defaultDomainSpecCB_ddg(dialog,tag,propValue);
        end

        function setBaseStepSize(this,dialog,tag,value)
            this.baseStepSize=value;
            this.defaultDomainSpecCB_ddg(dialog,tag,this.baseStepSize);
        end

        function setDataflowLatency(this,dialog,tag,value)
            this.dataflowLatency=value;
            this.defaultDomainSpecCB_ddg(dialog,tag,this.dataflowLatency);
        end

        function setDataflowMultirate(this,dialog,tag,value)
            this.dataflowMultirate=value;
            if this.dataflowMultirate
                propValue='on';
            else
                propValue='off';
            end
            if this.dataflowMultirateEnabled
                this.defaultDomainSpecCB_ddg(dialog,tag,propValue);
            end
        end

        function topMost=getTopMostDataflowSubsystem(this,subsystem)
            topMost=[];
            if strcmpi(this.domainType,'dataflow')
                topMost=get_param(subsystem,'Handle');
            end
            parent=get_param(subsystem,'parent');
            while(~isempty(parent))
                if(strcmpi(get_param(parent,'SetExecutionDomain'),'on')...
                    &&strcmpi(get_param(parent,'ExecutionDomainType'),'dataflow'))
                    topMost=get_param(parent,'Handle');
                end
                parent=get_param(parent,'parent');
            end
        end

        function openDataflowAssistant(this)
            dfs.analysis.openMultithreadingAnalysis(this.graphH);
        end
    end
end

