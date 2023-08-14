classdef ExternalDataDDG<handle






    properties
        source;
    end

    methods

        function obj=ExternalDataDDG(h)
            if isa(h,'Simulink.BlockDiagram')
                obj.source=h;
            else
                ME=MException('modelPropertiesDDGSource:InvalidSourceType',...
                'The source type is not a Simulink BlockDiagram');
                throw(ME);
            end
        end

        function schema=getDialogSchema(obj)
            rowNum=1;

            dataSourceSelectDesc.Name=DAStudio.message('Simulink:dialog:ModelDataSourceSelectDesc');
            dataSourceSelectDesc.ToolTip=DAStudio.message('Simulink:dialog:ModelDataSourceSelectDesc');
            dataSourceSelectDesc.Type='text';
            dataSourceSelectDesc.WordWrap=true;

            dataSourceSelectDesc.RowSpan=[rowNum,rowNum];
            dataSourceSelectDesc.ColSpan=[1,4];
            dataSourceSelectDesc.PreferredSize=[150,-1];

            if slfeature('SLModelAllowedBaseWorkspaceAccess')>1
                rowNum=rowNum+1;
                dataSourceSelect.Type='text';
                dataSourceSelect.Name=DAStudio.message('Simulink:dialog:ModelDataSourceSelectDD');


                dataSourceSelect.Value=1;
                dataSourceSelect.RowSpan=[rowNum,rowNum];
            else

                dataSourceSelect.Type='radiobutton';
                dataSourceSelect.Name=DAStudio.message('Simulink:dialog:ModelDataSourceSelectLabel');
                dataSourceSelect.ToolTip=DAStudio.message('Simulink:dialog:ModelDataSourceSelectTooltip');
                dataSourceSelect.Entries={...
                DAStudio.message('Simulink:dialog:ModelDataSourceSelectBWS')...
                ,DAStudio.message('Simulink:dialog:ModelDataSourceSelectDD')};
                if isempty(obj.source.DataDictionary)
                    dataSourceSelect.Value=0;
                else
                    dataSourceSelect.Value=1;
                end
                rowNum=rowNum+1;
                dataSourceSelect.ShowBorder=0;
                dataSourceSelect.Tag='DataSourceSelect';
                dataSourceSelect.MatlabMethod='Simulink.DictionarySpecificationCallBack.selectDataSource';
                dataSourceSelect.MatlabArgs={obj,'%dialog'};
                dataSourceSelect.RowSpan=[rowNum,rowNum];
                dataSourceSelect.ColSpan=[1,4];
            end
            dataSourceSelect.Enabled=~obj.source.isHierarchySimulating;


            dataDict.Name='';
            dataDict.Tag='DataDictionary';
            dataDict.Value=obj.source.DataDictionary;
            dataDict.Type='edit';
            dataDict.Editable=true;
            dataDict.Enabled=(dataSourceSelect.Value==1||slfeature('SLModelAllowedBaseWorkspaceAccess')>1)&&...
            ~obj.source.isHierarchySimulating;
            dataDict.ToolTip=DAStudio.message('Simulink:dialog:ModelDataDictTooltip');
            dataDict.MatlabMethod='Simulink.DictionarySpecificationCallBack.updateDictionary';
            dataDict.MatlabArgs={obj,'%dialog','%value'};
            dataDict.ColSpan=[1,4];

            rowNum=rowNum+1;

            pbSelectDD.Name=DAStudio.message('Simulink:dialog:ModelSelectDDBtn');
            pbSelectDD.Type='pushbutton';
            pbSelectDD.ToolTip=DAStudio.message('Simulink:dialog:ModelSelectDDTooltip');
            pbSelectDD.Tag='SelectDD';
            pbSelectDD.Enabled=(dataSourceSelect.Value==1||slfeature('SLModelAllowedBaseWorkspaceAccess')>1)&&...
            ~obj.source.isHierarchySimulating;
            pbSelectDD.MatlabMethod='Simulink.DictionarySpecificationCallBack.selectDD';
            pbSelectDD.MatlabArgs={obj,'%dialog'};
            pbSelectDD.RowSpan=[rowNum,rowNum];
            pbSelectDD.ColSpan=[1,1];


            pbNewDD.Name=DAStudio.message('Simulink:dialog:ModelNewDDBtn');
            pbNewDD.Type='pushbutton';
            pbNewDD.ToolTip=DAStudio.message('Simulink:dialog:ModelNewDDTooltip');
            pbNewDD.Tag='NewDD';
            pbNewDD.Enabled=(dataSourceSelect.Value==1||slfeature('SLModelAllowedBaseWorkspaceAccess')>1)&&...
            ~obj.source.isHierarchySimulating;
            pbNewDD.MatlabMethod='Simulink.DictionarySpecificationCallBack.newDD';
            pbNewDD.MatlabArgs={obj,'%dialog'};
            pbNewDD.RowSpan=[rowNum,rowNum];
            pbNewDD.ColSpan=[2,2];


            pbOpenDD.Name=DAStudio.message('Simulink:dialog:ModelOpenDDBtn');
            pbOpenDD.Type='pushbutton';
            pbOpenDD.ToolTip=DAStudio.message('Simulink:dialog:ModelOpenDDTooltip');
            pbOpenDD.Tag='OpenDD';
            pbOpenDD.Enabled=(dataSourceSelect.Value==1)&&~isempty(dataDict.Value)&&...
            ~obj.source.isHierarchySimulating;
            pbOpenDD.MatlabMethod='Simulink.DictionarySpecificationCallBack.openDD';
            pbOpenDD.MatlabArgs={obj,'%dialog'};
            pbOpenDD.RowSpan=[rowNum,rowNum];
            pbOpenDD.ColSpan=[3,3];


            ddspacer.Type='panel';
            ddspacer.RowSpan=[rowNum,rowNum];
            ddspacer.ColSpan=[4,4];

            rowNum=rowNum+1;
            dataDict.RowSpan=[rowNum,rowNum];

            hasBWSAccess=true;
            ddHasBWSAccess=false;

            if slfeature('SLModelAllowedBaseWorkspaceAccess')>1
                rowNum=rowNum+1;

                enableBWSAccess.Name=DAStudio.message('Simulink:dialog:EnableBaseWorkspaceAccess');
                enableBWSAccess.Tag='EnableAccessToBaseWorkspace';
                enableBWSAccess.ColSpan=[1,5];
                enableBWSAccess.RowSpan=[rowNum,rowNum];
                enableBWSAccess.Type='checkbox';
                enableBWSAccess.Value=strcmp(get_param(obj.source.name,'EnableAccessToBaseWorkspace'),'on');
                enableBWSAccess.ToolTip=DAStudio.message('Simulink:dialog:EnableBaseWorkspaceAccessTooltip');


                enableBWSAccess.MatlabMethod='Simulink.EnableAccessToBWSCallback.doSetEnableBWS';
                enableBWSAccess.MatlabArgs={obj,'%dialog','%value'};

                warnImagePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','search_warning.png');
                warningIcon.Type='image';
                warningIcon.RowSpan=[rowNum,rowNum];
                warningIcon.ColSpan=[1,1];
                warningIcon.FilePath=warnImagePath;
                ddAccessBWSMsg.Name=DAStudio.message('Simulink:dialog:BWSAccessViaDD');
                ddAccessBWSMsg.Type='text';
                ddAccessBWSMsg.WordWrap=true;
                ddAccessBWSMsg.Tag='HasBWSAccessViaDD';
                ddAccessBWSMsg.RowSpan=[rowNum,rowNum];
                ddAccessBWSMsg.ColSpan=[2,10];

                ddAccessBWS.Type='panel';
                ddAccessBWS.Tag='inheritedBWSAccess';
                ddAccessBWS.LayoutGrid=[1,10];
                ddAccessBWS.Items={warningIcon,ddAccessBWSMsg};
                ddAccessBWS.ColSpan=[1,10];
                ddAccessBWS.Visible=false;
                ddProperty=obj.source.DataDictionary;
                if~isempty(ddProperty)
                    try
                        ddTmp=Simulink.dd.open(ddProperty);
                        ddAccessBWS.Visible=ddTmp.HasAccessToBaseWorkspace...
                        &&~enableBWSAccess.Value;
                        ddTmp.close;
                    catch e

                        if~strcmp(e.identifier,'SLDD:sldd:DictionaryNotFound')
                            throw(e);
                        end
                    end
                end
                rowNum=rowNum+1;
                ddAccessBWS.RowSpan=[rowNum,rowNum];

                ddHasBWSAccess=ddAccessBWS.Visible;
                hasBWSAccess=enableBWSAccess.Value;
            end

            if slfeature('SlDataEnableDataConsistencyCheck')>1
                rowNum=rowNum+1;

                enforceDataConsistency.Name=DAStudio.message('Simulink:dialog:EnforceDataConsistency');
                enforceDataConsistency.Tag='EnforceDataConsistency';
                enforceDataConsistency.RowSpan=[rowNum,rowNum];
                enforceDataConsistency.ColSpan=[1,5];
                enforceDataConsistency.Type='checkbox';
                enforceDataConsistency.Value=strcmp(get_param(obj.source.Name,'EnforceDataConsistency'),'on');
                enforceDataConsistency.ToolTip=DAStudio.message('Simulink:dialog:EnforceDataConsistencyTooltip');
                enforceDataConsistency.MatlabMethod='Simulink.enforceDataConsistencyCallback';
                enforceDataConsistency.MatlabArgs={'%dialog',obj.source,'%value'};
            end

            if slfeature('SLDataDictionaryMigrateUI')>0
                rowNum=rowNum+1;

                dataMigrationBtn.Type='pushbutton';
                dataMigrationBtn.Tag='DataMigrationBtn';
                dataMigrationBtn.Name=DAStudio.message('Simulink:dialog:MigrateDataButton');
                dataMigrationBtn.ToolTip=DAStudio.message('Simulink:dialog:MigrateDataButtonTooltip');
                dataMigrationBtn.RowSpan=[rowNum,rowNum];
                dataMigrationBtn.ColSpan=[1,1];
                dataMigrationBtn.Visible=(hasBWSAccess||ddHasBWSAccess);
                dataMigrationBtn.Enabled=~isempty(ddProperty);
                dataMigrationBtn.MatlabMethod='Simulink.DictionarySpecificationCallBack.btnDataMigrate';
                dataMigrationBtn.MatlabArgs={obj,'%dialog'};
            end


            schema.Name=DAStudio.message('Simulink:dialog:ModelExternalDesignDataGroupName');
            schema.LayoutGrid=[3,4];
            schema.ColStretch=[0,0,0,1];
            if slfeature('SLModelAllowedBaseWorkspaceAccess')>1
                schema.LayoutGrid=[5,4];
                schema.Items={dataSourceSelectDesc,dataSourceSelect,...
                dataDict,pbSelectDD,pbNewDD,pbOpenDD,ddspacer,...
                enableBWSAccess,ddAccessBWS};
            else
                schema.Items={dataSourceSelectDesc,dataSourceSelect,dataDict,pbSelectDD,pbNewDD,pbOpenDD,ddspacer};
            end
            if slfeature('SlDataEnableDataConsistencyCheck')>1
                schema.Items{end+1}=enforceDataConsistency;
            end
            if slfeature('SLDataDictionaryMigrateUI')>0
                schema.Items{end+1}=dataMigrationBtn;
            end


            h=obj.source;
            if slfeature('ShowExternalDataNode')>1&&~(bdIsSubsystem(h.Handle))&&~(h.isLibrary)
                rowNum=rowNum+1;
                extdataSourceSelectDesc.Name=DAStudio.message('Simulink:dialog:ModelAdditionalSources');

                extdataSourceSelectDesc.Type='text';
                extdataSourceSelectDesc.WordWrap=true;

                extdataSourceSelectDesc.RowSpan=[rowNum,rowNum];
                extdataSourceSelectDesc.ColSpan=[1,4];
                extdataSourceSelectDesc.PreferredSize=[150,-1];

                rowNum=rowNum+1;

                extSourcesName.Name='';
                extSourcesName.Type='edit';
                extSourcesName.Tag='extSourcesName';
                extSourcesName.RowSpan=[rowNum,rowNum];
                extSourcesName.ColSpan=[1,1];
                extSourcesName.Visible=false;

                extSourcesList.Type='listbox';
                extSourcesList.Tag='extSourcesList';
                extSourcesList.RowSpan=[rowNum,rowNum+4];
                extSourcesList.ColSpan=[1,2];
                sources=get_param(h.name,'ExternalSources');
                ddIdx=find(strcmp(sources,h.DataDictionary));
                if ddIdx>0
                    sources(ddIdx)='';
                end
                extSourcesList.Entries=sources;
                extSourcesList.UserData=extSourcesList.Entries;
                extSourcesList.MatlabMethod='modelddg_cb';
                extSourcesList.MatlabArgs={'%dialog','%tag',h};

                extSourcesBrowse.Name=DAStudio.message('Simulink:dialog:ModelSelectDDBtn');
                extSourcesBrowse.Type='pushbutton';
                extSourcesBrowse.Tag='extSourcesBrowse';
                extSourcesBrowse.RowSpan=[rowNum,rowNum];
                extSourcesBrowse.ColSpan=[3,3];
                extSourcesBrowse.MatlabMethod='modelddg_cb';
                extSourcesBrowse.MatlabArgs={'%dialog','%tag',h,extSourcesList.Tag,extSourcesName.Tag};

                rowNum=rowNum+1;

                extSourcesNew.Name=DAStudio.message('Simulink:dialog:ModelNewDDBtn');
                extSourcesNew.Type='pushbutton';
                extSourcesNew.Tag='extSourcesNew';
                extSourcesNew.RowSpan=[rowNum,rowNum];
                extSourcesNew.ColSpan=[3,3];
                extSourcesNew.MatlabMethod='modelddg_cb';
                extSourcesNew.MatlabArgs={'%dialog','%tag',h,extSourcesList.Tag,extSourcesName.Tag};

                rowNum=rowNum+1;

                extSourcesRemove.MatlabMethod='modelddg_cb';
                extSourcesRemove.MatlabArgs={'%dialog','%tag',h};
                extSourcesRemove.Name=DAStudio.message('Simulink:dialog:RemoveButton');
                extSourcesRemove.Type='pushbutton';
                extSourcesRemove.Tag='extSourcesRemove';
                extSourcesRemove.RowSpan=[rowNum,rowNum];
                extSourcesRemove.ColSpan=[3,3];
                extSourcesRemove.MatlabMethod='modelddg_cb';
                extSourcesRemove.MatlabArgs={'%dialog','%tag',h,extSourcesList.Tag};
                extSourcesRemove.Enabled=false;

                rowNum=rowNum+1;

                extSourcesOpen.Name=DAStudio.message('Simulink:dialog:ModelOpenDDBtn');
                extSourcesOpen.Type='pushbutton';
                extSourcesOpen.Tag='extSourcesOpen';
                extSourcesOpen.RowSpan=[rowNum,rowNum];
                extSourcesOpen.ColSpan=[3,3];
                extSourcesOpen.MatlabMethod='modelddg_cb';
                extSourcesOpen.MatlabArgs={'%dialog','%tag',h,extSourcesList.Tag};
                extSourcesOpen.Enabled=false;

                schema.Items=[schema.Items,{extdataSourceSelectDesc,extSourcesName,extSourcesList,extSourcesBrowse,extSourcesNew,extSourcesRemove,extSourcesOpen}];
            end
        end
    end

    methods(Static)

        function openExternalDataConfig(modelName)




            try
                hObj=Simulink.ExternalDataDDG(get_param(modelName,'Object'));
                slprivate('showDDG',hObj);

            catch exception
                load_system('simulink');
                Simulink.output.error(exception);
            end
        end

    end

end


