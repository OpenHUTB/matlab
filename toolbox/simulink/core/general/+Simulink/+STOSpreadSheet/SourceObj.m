classdef SourceObj<handle




    properties
        mRateData;
        mTypeData;
        mSTLObj;
        mModelName;
        mTopModelName;
        mTabs;

        mComponentName;
        mComponent;

        isHierarchy;
        mInvertPeriod=false;
        mPropertyList;
        type='sourceObj';
        highlightMode='none';
        highlightOption=false;
        hiliteHelp=false;
        hiliteHelpText='';
        comboBoxValue=0;
        baseRate='-1';
        isFixedStepDiscrete=false;
    end

    methods
        function this=SourceObj(currentModelName,topMdlName,STLObj,tabIdx,ssComp)

            this.mComponent=ssComp;
            this.mPropertyList={'Type',DAStudio.message('Simulink:utility:ValueWithoutColon')};

            ssComp.setColumns(this.mPropertyList,'','',false);
            this.mComponent.setConfig('{"columns": {"name": "Type", "minsize": 125, "maxsize": 125}}');

            this.mModelName=currentModelName;
            this.mTopModelName=topMdlName;
            this.mSTLObj=STLObj;
            this.mComponentName=sprintf('GLUE2:SpreadSheet/%s',ssComp.getName);
            this.mTabs=tabIdx;
            this.mComponent.setTitleViewSource(this);
            this.mComponent.onHelpClicked=@(ss_src)Simulink.STOSpreadSheet.SourceObj.handleHelpClicked(ss_src,this);
            this.mComponent.addEventListener('click',@Simulink.STOSpreadSheet.SourceObj.handleClick);
            this.mComponent.onCloseClicked=@(comp)Simulink.STOSpreadSheet.SourceObj.onCloseClicked(comp);
            ssComp.setComponentUserData(this);

            this.updateViewData(currentModelName,topMdlName);
        end


        function updateViewData(this,currentModelName,topMdlName)

            this.isHierarchy=true;
            this.mComponent.enableHierarchicalView(true);
            this.mModelName=currentModelName;
            this.mTopModelName=topMdlName;
            this.mInvertPeriod=strcmp(get_param(currentModelName,'ShowInverseOfPeriodInSampleTimeLegend'),'on');
            legendData=getLegendData(this,this.mModelName);
            len=length(legendData);

            tmpRateData=cell(len,1);
            for count=1:len

                rowData=legendData(count);
                tmpRateData{count}=Simulink.STOSpreadSheet.rateNode(this,rowData,this.mSTLObj,count,this.mModelName,this.baseRate);
            end
            this.mRateData=repmat(tmpRateData{1},len,1);
            for count=1:len
                this.mRateData(count)=tmpRateData{count};
            end


            this.mTypeData=Simulink.STOSpreadSheet.constructTypeGroups(this,this.mRateData);

            this.mComponent.updateTitleView;
            this.mComponent.update();
        end


        function b=isHierarchical(this)
            b=this.isHierarchy;
        end

        function children=getChildren(this,component)
            children=[];
            if strcmp(component,this.mComponentName)
                children=this.mTypeData;
            end
        end



        function dlgStruct=getDialogSchema(obj,~)

            maxItemsInPanel=12;

            perspectiveChoice.Type='combobox';
            perspectiveChoice.Name=DAStudio.message('Simulink:utility:Highlight');
            perspectiveChoice.Tag=[obj.mComponentName,'legendHighlightMode'];
            perspectiveChoice.ToolTip=DAStudio.message('Simulink:utility:HighlightOptionToolTips');
            perspectiveChoice.RowSpan=[1,1];
            perspectiveChoice.ColSpan=[2,2];
            perspectiveChoice.Entries={DAStudio.message('Simulink:utility:HighlightNone'),...
            DAStudio.message('Simulink:utility:HighlightSourceOption'),...
            DAStudio.message('Simulink:utility:HighlightAllOption')};
            perspectiveChoice.ObjectMethod='switchHighlightMode';
            perspectiveChoice.MethodArgs={'%dialog','%value'};
            perspectiveChoice.ArgDataTypes={'handle','mxArray'};
            perspectiveChoice.Graphical=true;
            perspectiveChoice.Enabled=true;
            perspectiveChoice.DialogRefresh=1;
            perspectiveChoice.Value=obj.comboBoxValue;


            scopeButton.Type='togglebutton';
            scopeButton.Tag=[obj.mComponentName,'legend_showInversePeriod'];
            scopeButton.ToolTip=DAStudio.message('Simulink:utility:showFrequencyInSampleTimeLegendToolTip');
            if(ismac||ispc)
                scopeButton.FilePath=fullfile(matlabroot,'toolbox',...
                'simulink','core','general','+Simulink','+STOSpreadSheet','icon','OneOverPeriod_16.png');
            else
                scopeButton.FilePath=fullfile(matlabroot,'toolbox',...
                'simulink','core','general','+Simulink','+STOSpreadSheet','icon','OneOverPeriod_16.ico');
            end
            scopeButton.RowSpan=[1,1];
            scopeButton.ColSpan=[3,3];
            scopeButton.ObjectMethod='inversePeriod';
            scopeButton.MethodArgs={'%dialog','%value'};
            scopeButton.ArgDataTypes={'handle','mxArray'};
            scopeButton.Graphical=true;
            scopeButton.Enabled=true;
            scopeButton.Value=obj.mInvertPeriod;



            scheduleButton.Type='pushbutton';
            scheduleButton.Tag=[obj.mComponentName,'legend_openScheduleEditor'];
            scheduleButton.ToolTip=DAStudio.message('Simulink:utility:scheduleEditorToolTip');
            if(ismac||ispc)
                scheduleButton.FilePath=fullfile(matlabroot,'toolbox',...
                'simulink','core','general','+Simulink','+STOSpreadSheet','icon','SchedulingEditor_16.png');
            else
                scheduleButton.FilePath=fullfile(matlabroot,'toolbox',...
                'simulink','core','general','+Simulink','+STOSpreadSheet','icon','SchedulingEditor_16.ico');
            end
            scheduleButton.RowSpan=[1,1];
            scheduleButton.ColSpan=[maxItemsInPanel,maxItemsInPanel];
            scheduleButton.ObjectMethod='openScheduleEditor';
            scheduleButton.MethodArgs={'%dialog'};
            scheduleButton.ArgDataTypes={'handle'};
            scheduleButton.Graphical=true;
            scheduleButton.Value=obj.mInvertPeriod;
            scheduleButtonEnabled=...
            strcmp(get_param(obj.mModelName,"isExportFunctionModel"),"on")||...
            sltp.internal.hasExplicitPartitions(obj.mModelName);
            scheduleButton.Enabled=scheduleButtonEnabled;
            scheduleButton.Visible=scheduleButtonEnabled;

            helpText.Name=obj.hiliteHelpText;
            helpText.Bold=false;
            helpText.Type='text';
            helpText.RowSpan=[2,2];
            helpText.WordWrap=true;
            helpText.ColSpan=[1,maxItemsInPanel];
            if slfeature('DisplayBaseRate')


                if(strcmpi(obj.baseRate,'-1'))
                    getLegendData(obj,obj.mModelName);
                end

                testTextBox.Type='edit';
                testTextBox.Name="H = ";
                testTextBox.Enabled=true;
                testTextBox.Value=obj.baseRate;
                testTextBox.ToolTip=DAStudio.message('Simulink:utility:HFixedStepSizeIndicator');
                testTextBox.RowSpan=[3,3];
                testTextBox.ColSpan=[2,1];
            end


            hiliteInfo.Type='panel';
            hiliteInfo.Tag='hiliteInfo';
            hiliteInfo.Items={helpText};

            hiliteInfo.ColSpan=[1,maxItemsInPanel];
            hiliteInfo.RowSpan=[2,2];
            hiliteInfo.Visible=obj.hiliteHelp;

            titlePanel.Type='panel';
            if slfeature('DisplayBaseRate')
                titlePanel.Items={perspectiveChoice,...
                testTextBox,scheduleButton,hiliteInfo};
            else
                titlePanel.Items={perspectiveChoice,...
                scopeButton,scheduleButton,hiliteInfo};
            end
            titlePanel.LayoutGrid=[2,maxItemsInPanel];
            titlePanel.ColStretch=[0,0,0,1,0,0,0,0,0,1,0,0];

            titlePanel.RowSpan=[1,1];
            titlePanel.ColSpan=[1,1];

            dlgStruct.LayoutGrid=[1,1];
            dlgStruct.DialogTitle='';
            dlgStruct.IsScrollable=false;
            dlgStruct.Items={titlePanel};
            dlgStruct.StandaloneButtonSet={''};
            dlgStruct.EmbeddedButtonSet={''};

        end


    end

    methods(Static)



        function out=getPropertySchema(this)
            out=this;
        end


        function handleHelpClicked(~,obj)
            helpview(strcat(docroot,'/toolbox/simulink/helptargets.map'),'Sample_Time_Legend');
        end
        function handleClick(comp,sel,~)
            Simulink.STOSpreadSheet.SourceObj.handleSelectionChange(comp,sel);
        end


        function onCloseClicked(comp)
            sel=comp.getComponentUserData;
            legendObj=sel.mSTLObj;
            legendObj.clearHilite(sel.mModelName);

            if(isequal(sel.type,'rate')||isequal(sel.type,'type'))
                topModelName=sel.sourceObj.mTopModelName;
            else
                topModelName=sel.mTopModelName;
            end

            studioTab_cont=find(strcmp(topModelName,sel.mSTLObj.modelList),1);
            sel.mSTLObj.modelLegendState{studioTab_cont}='off';
            if(isKey(legendObj.studioDiagramMap,num2str(get_param(sel.mTopModelName,'handle'))))
                legendObj.studioDiagramMap(num2str(get_param(sel.mTopModelName,'handle')))=[];
            end
            sel.highlightOption=false;
        end

        function result=handleSelectionChange(comp,sel)
            if(iscell(sel))
                sel=sel{1};
            end
            comp.setComponentUserData(sel);

            if(~sel.sourceObj.highlightOption)
                return;
            end
            sel.mSTLObj.clearHilite(sel.mModelName);
            sel.mSTLObj.clearHilite(sel.mModelName,'task');
            sel.sourceObj.hiliteHelp=true;

            highlightMode=sel.sourceObj.highlightMode;
            sel.sourceObj.hiliteHelpText=DAStudio.message(Simulink.STOSpreadSheet.internal.updateHighlightHelpTextCatelog(sel));

            if(strcmp(sel.type,'rate'))

                legendObj=sel.mSTLObj;
                if(~isempty(sel.TID))
                    hilite_data=legendObj.rateHighlight({'rate',num2str(sel.TID),sel.mModelName,highlightMode});
                else
                    hilite_data=legendObj.rateHighlight({'rate','M',sel.mModelName,highlightMode});
                end

                featSampleTimeStyling=slfeature('SampleTimeStyling');
                if((~featSampleTimeStyling&&...
                    strcmp(get_param(sel.mModelName,'SampleTimeColors'),'off'))||...
                    (featSampleTimeStyling&&...
                    strcmp(get_param(sel.sourceObj.mTopModelName,'SampleTimeColors'),'off')))
                    hilite_data.colorRGB=[-1,-1,-1];
                end
                legendObj.hilite_system_legend(hilite_data);
            elseif(strcmp(sel.type,'type'))

                legendObj=sel.mSTLObj;
                typeHiliteInfo=Simulink.STOSpreadSheet.internal.getTypeHiliteInfo(sel,sel.mSTLObj,highlightMode);
                legendObj.hilite_system_legend(typeHiliteInfo);
            end
            comp.updateTitleView;
            result=1;
        end
    end

    methods

        function handleRefresh(obj)
            st=obj.mComponent;
            st.update();
        end



        function openPropertyInspector(obj)
            mdlName=obj.mModelName;
            editor=GLUE2.Util.findAllEditors(mdlName);
            studio=editor.getStudio;
            PI=studio.getComponent('GLUE2:PropertyInspector','Property Inspector');
            if(~PI.isVisible)
                studio.showComponent(PI);
            end
        end


        function switchHighlightMode(obj,diag,value)
            st=obj.mComponent;
            obj.comboBoxValue=value;

            currentMode=value;
            if(isequal(currentMode,2))
                obj.highlightMode='all';
                obj.highlightOption=true;
                sel=obj.mComponent.getComponentUserData;
                obj.hiliteHelp=true;
                obj.hiliteHelpText=DAStudio.message('Simulink:utility:HighlightAllHelpText');
                if(strcmp(sel.type,'type')||strcmp(sel.type,'rate'))
                    sel.sourceObj=obj;
                    obj.handleSelectionChange(obj.mComponent,sel);
                end
            elseif(isequal(currentMode,1))
                obj.highlightMode='source';
                obj.highlightOption=true;
                sel=obj.mComponent.getComponentUserData;
                obj.hiliteHelp=true;
                obj.hiliteHelpText=DAStudio.message('Simulink:utility:HighlightOrigHelpText');
                if(strcmp(sel.type,'type')||strcmp(sel.type,'rate'))
                    sel.sourceObj=obj;
                    obj.handleSelectionChange(obj.mComponent,sel);
                end
            else
                obj.hiliteHelp=false;
                obj.highlightOption=false;
                obj.highlightMode='none';
                obj.mSTLObj.clearHilite(obj.mModelName);
                obj.mSTLObj.clearHilite(obj.mModelName,'task');
            end
            st.update();
            st.updateTitleView;
        end


        function clearHighlight(obj,~)
            obj.mSTLObj.clearHilite(obj.mModelName);
        end



        function inversePeriod(obj,diag,value)
            st=obj.mComponent;

            if(value)
                set_param(obj.mModelName,'ShowInverseOfPeriodInSampleTimeLegend','on');
                obj.mInvertPeriod=true;
            else
                set_param(obj.mModelName,'ShowInverseOfPeriodInSampleTimeLegend','off');
                obj.mInvertPeriod=false;
            end

            st.update();
        end


        function openScheduleEditor(obj,~)
            modelHandle=get_param(obj.mModelName,'Handle');
            editor=sltp.internal.ScheduleEditorManager.getEditor(modelHandle);
            editor.show();
        end

    end
    methods(Access=protected)

        function baseRate=GetBaseRate(this,r1,r2)
            if r1>r2
                tmp=r1;
                r1=r2;
                r2=tmp;
            end

            r=r2/r1;
            [~,den]=rat(r);

            baseRate=r1/den;
        end

        function totalBaseRate=ComputeBaseRate(this,nRates,rates)



            if(isequal(nRates,0))
                totalBaseRate='N/A';
                return;
            end

            rates=sort(rates);

            totalBaseRate=rates(1);
            for i=2:nRates
                totalBaseRate=this.GetBaseRate(totalBaseRate,rates(i));
            end
        end

        function legendData=getLegendData(this,modelName)

            stoStr=get_param(modelName,'SerializedTTRInfo');
            ser=mf.zero.io.XmlParser;
            ser.documentTagName='slexec_sto';
            registry=ser.parseString(stoStr.SerializedTimingAndTaskingRegistry);
            useDisplayBaseRateFeature=slfeature('DisplayBaseRate');
            if useDisplayBaseRateFeature
                this.baseRate=num2str(registry.clockRegistry.clocks(1).resolution);
                this.isFixedStepDiscrete=~strcmpi(this.baseRate,'0');
            end

            Map=containers.Map('KeyType','int32','ValueType','any');
            Map2=containers.Map('KeyType','char','ValueType','any');
            for clockIte=1:registry.clockRegistry.clocks.Size

                clock=registry.clockRegistry.clocks(clockIte);
                rateVec=clock.rates;
                for rateIte=1:rateVec.Size
                    Map(rateVec(rateIte).rateIdx)=rateVec(rateIte);
                    Map2(rateVec(rateIte).annotation)=rateVec(rateIte);
                end
            end

            tLegendData=get_param(modelName,'SampleTimes');
            rateTaskMap=get_param(modelName,'rateIndexTaskIdxMap');

            len=length(tLegendData);
            tabIdx=find(strcmp(modelName,this.mSTLObj.modelList),1);

            valueDataGroup=this.mSTLObj.getValueDataGroup(this.mSTLObj,tLegendData,tabIdx,true);

            indexOfEmpty=-1;
            discreteRates=[];
            if(~isempty(tabIdx))
                for count=1:len
                    tLegendData(count).ValueDetails=valueDataGroup{count};
                    tLegendData(count).taskId=rateTaskMap(count).taskIdx;
                    tLegendData(count).SourceBlocks=rateTaskMap(count).SourceBlocks;
                    tLegendData(count).AllBlocks=rateTaskMap(count).AllBlocks;
                    rate=[];
                    if(isKey(Map2,tLegendData(count).Annotation))
                        rate=Map2(tLegendData(count).Annotation);
                    elseif(isKey(Map,tLegendData(count).TID))
                        rate=Map(tLegendData(count).TID);
                    end

                    if(~isempty(rate))
                        tLegendData(count).STOObj=struct('TaskID',rate.taskId,...
                        'RateType',rate.rateSpec.rateType,...
                        'ClockID',rate.clockId);

                        for clockIte=1:registry.clockRegistry.clocks.Size
                            clock=registry.clockRegistry.clocks(clockIte);
                            if(~strcmpi(clock.identifier,tLegendData(count).STOObj.ClockID))
                                continue;
                            end

                            if(isprop(clock,'eventType'))
                                tLegendData(count).STOObj.clockEventType=string(clock.eventType);
                                break;
                            end
                        end

                        if useDisplayBaseRateFeature
                            if(strcmpi(tLegendData(count).STOObj.RateType,'ClassicPeriodicDiscrete')&&...
                                ~isempty(tLegendData(count).AllBlocks)&&tLegendData(count).Value(1)~=0)
                                discreteRates=[discreteRates,tLegendData(count).Value(1)];
                            end
                        end
                    else
                        tLegendData(count).STOObj=struct.empty;
                    end

                    if(useDisplayBaseRateFeature&&isempty(tLegendData(count).AllBlocks)&&...
                        strcmpi(tLegendData(count).STOObj.RateType,'ClassicPeriodicDiscrete'))
                        indexOfEmpty=count;
                    end
                end
            end

            legendData=tLegendData;

            if(useDisplayBaseRateFeature&&...
                (~this.isFixedStepDiscrete||slfeature('SampleTimeParameterization')))


                this.baseRate=num2str(this.ComputeBaseRate(length(discreteRates),discreteRates));
            end
            if(useDisplayBaseRateFeature&&indexOfEmpty~=-1)
                legendData(indexOfEmpty)=[];
            end

        end
    end
end
