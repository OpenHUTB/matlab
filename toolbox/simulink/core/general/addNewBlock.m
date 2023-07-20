classdef addNewBlock<handle




    properties
        mVarName='';
        mMdlName='';
        mBlkFullName='';
        mPropName='';
        mValue='';
        mLocation='';
        mGlobalWS=true;
        mSrcHandle='';
mDlgSrc
mTypesList
mClassSuggestion
mDialogTag
mResult
    end

    properties(Access=public)
        m_modelCloseListener=[];
    end

    events
        CloseEvent;
    end


    methods
        function schema=getDialogSchema(obj)

            blockParamName.Name=DAStudio.message('Simulink:dialog:CreateNewDataDlg_Name');
            blockParamName.RowSpan=[2,2];
            blockParamName.ColSpan=[1,1];
            blockParamName.Type='text';

            blockParamValue.RowSpan=[2,2];
            blockParamValue.ColSpan=[2,2];
            blockParamValue.Type='text';
            blockParamValue.Tag='paramValue_tag';
            blockParamValue.Name=obj.mVarName;

            [parent,blockFullName]=getBlockInformationFromSource(obj.mDlgSrc,obj.mPropName);
            locations={};
            if isempty(blockFullName)
                return;
            else
                bdRoot=parent;
                while~isa(bdRoot,'Simulink.BlockDiagram')
                    locations{end+1}=bdRoot.getFullName;
                    bdRoot=bdRoot.getParent;
                end
                mdl_name=bdRoot.getFullName;
                locations{end+1}=mdl_name;
            end
            obj.mBlkFullName=blockFullName;
            locations=flip(locations);
            locations{end+1}='Global Data Store';

            dataStoreLocationText.Name=DAStudio.message('Simulink:dialog:CreateNewDataDlg_Visibility');
            dataStoreLocationText.Type='text';
            dataStoreLocationText.RowSpan=[3,3];
            dataStoreLocationText.ColSpan=[1,1];

            dataStoreLocation.Mode=1;
            dataStoreLocation.Tag='systemSelection_tag';
            dataStoreLocation.RowSpan=[3,3];
            dataStoreLocation.ColSpan=[2,3];
            dataStoreLocation.Type='combobox';
            dataStoreLocation.Editable=true;


            dataStoreLocation.MatlabMethod='addNewBlock.cmbBoxCB';
            dataStoreLocation.MatlabArgs={'%dialog',dataStoreLocation.Tag};
            dataStoreLocation.Entries=locations;







            dataLocationText.Name=DAStudio.message('Simulink:dialog:CreateNewDataDlg_Location');
            dataLocationText.Tag='dataLocationText_tag';
            dataLocationText.Type='text';
            dataLocationText.RowSpan=[4,4];
            dataLocationText.ColSpan=[1,1];
            dataLocationText.Visible=false;

            dataLocation.Mode=1;
            dataLocation.RowSpan=[4,4];
            dataLocation.ColSpan=[2,3];
            dataLocation.Type='combobox';
            dataLocation.Tag='dataLocation_tag';
            dataLocation.Editable=false;
            dataLocation.Visible=false;
            ddName=get_param(mdl_name,'DataDictionary');
            ddRefList={};
            wsLocation={};
            defLoc=1;
            obj.mClassSuggestion='Signal';
            if isempty(ddName)
                wsLocation=[wsLocation,DAStudio.message('Simulink:dialog:WorkspaceLocation_Base')];
            else
                ddConn=Simulink.dd.open(ddName);
                if slfeature('SLModelAllowedBaseWorkspaceAccess')>0
                    hasBWS=strcmp(get_param(mdl_name,'HasAccessToBaseWorkspace'),'on');
                else
                    hasBWS=ddConn.HasAccessToBaseWorkspace;
                end
                if(~isempty(ddConn.Dependencies))

                    dependencies=ddConn.DependencyClosure;
                    for idx=2:length(dependencies)


                        [~,ddRefName,fileExt]=fileparts(dependencies{idx});
                        ddRefList=[ddRefList,{[ddRefName,fileExt]}];%#ok
                    end
                end
                wsLocation=[wsLocation,[DAStudio.message('Simulink:dialog:WorkspaceLocation_Dictionary'),' (',ddName,')']];
                if hasBWS
                    wsLocation=[wsLocation,DAStudio.message('Simulink:dialog:WorkspaceLocation_Base')];
                end
            end
            ddRefList=sort(ddRefList);
            if~isempty(ddRefList)
                wsLocation=[wsLocation,ddRefList{:}];
            end
            dataLocation.Entries=wsLocation;
            if isempty(obj.mLocation)
                obj.mLocation=wsLocation{defLoc};
            else
                desiredLoc=wsLocation(contains(wsLocation,obj.mLocation));
                obj.mLocation=desiredLoc{1};
            end
            dataLocation.Value=obj.mLocation;
            useGlobalWS=true;

            dataType.Tag='dataType_tag';
            dataLocation.MatlabArgs={'%dialog','%tag',dataType.Tag};


            dataTypeText.Name=DAStudio.message('Simulink:dialog:CreateNewDataDlg_Value');
            dataTypeText.Tag='dataTypeText_tag';
            dataTypeText.Type='text';
            dataTypeText.RowSpan=[5,5];
            dataTypeText.ColSpan=[1,1];
            dataTypeText.Visible=false;

            dataType.Mode=1;
            dataType.Tag='dataType_tag';
            dataType.RowSpan=[5,5];
            dataType.ColSpan=[2,3];
            dataType.Type='combobox';
            dataType.Editable=true;
            dataType.Value=obj.mValue;
            dataType.Visible=false;
            listOfClasses={};

            if isequal(1,slfeature('CustomizeClassLists'))
                if~isequal(obj.mClassSuggestion,'Default')
                    listOfClasses=Simulink.data.findValidClasses(obj.mClassSuggestion);
                    dataType.Value=listOfClasses{1};
                end

                listOfClasses{end+1}=DAStudio.message('modelexplorer:DAS:ME_SIMULINK_OBJECT_LIST_CUSTOMIZE_MENU_ITEM');
            else
                if isempty(obj.mTypesList)
                    obj.mTypesList=find_valid_user_classes(true,useGlobalWS);
                end
                listOfClasses=obj.mTypesList;
            end

            dataType.MatlabMethod='createDataDDG.cmbBoxCB';
            dataType.MatlabArgs={'%dialog',dataType.Tag};
            dataType.Entries=listOfClasses;

            spacer.Type='panel';
            spacer.RowSpan=[6,6];
            spacer.ColSpan=[1,2];

            schema.StandaloneButtonSet={''};

            button1.Type='pushbutton';
            button1.Name=DAStudio.message('Simulink:editor:DialogCreate');
            button1.Tag='CreateDataDlg_Create';
            button1.MatlabMethod='addNewBlock.buttonCB';
            button1.MatlabArgs={'%dialog',button1.Tag,obj};
            button1.RowSpan=[1,1];
            button1.ColSpan=[1,1];

            button2.Type='pushbutton';
            button2.Name=DAStudio.message('Simulink:editor:DialogCancel');
            button2.Tag='CreateDataDlg_Cancel';
            button2.MatlabMethod='addNewBlock.buttonCB';
            button2.MatlabArgs={'%dialog',button2.Tag,obj};
            button2.RowSpan=[1,1];
            button2.ColSpan=[2,2];

            buttonGroup.Type='panel';
            buttonGroup.LayoutGrid=[1,2];
            buttonGroup.Items={button1,button2};
            buttonGroup.RowSpan=[7,7];
            buttonGroup.ColSpan=[3,3];




            schema.DialogTag=obj.mDialogTag;
            schema.DialogTitle='Create Data Store';
            schema.LayoutGrid=[7,3];
            schema.ColStretch=[0,1,0];
            schema.Items={spacer,...
            blockParamName,blockParamValue,...
            dataStoreLocationText,dataStoreLocation,...
            dataTypeText,dataType,...
            dataLocationText,dataLocation,...
            spacer,...
            buttonGroup};
            schema.CloseArgs={'%dialog','%closeaction'};
            schema.CloseCallback='addNewBlock.buttonCB';

        end
    end

    methods(Static,Access=public)

        function modelCloseListener(~,~,obj)
            dialog=DAStudio.ToolRoot.getOpenDialogs.find('dialogTag',obj.mDialogTag);
            if~isempty(dialog)
                dialog.delete;
            end
        end

        function obj=addNewBlock(varName,propName,mdlName,dlgSrc,blkHandle)
            if(isempty(mdlName))
                [parent,~]=getBlockInformationFromSource(dlgSrc,propName);
                bdRoot=parent;
                while~isa(bdRoot,'Simulink.BlockDiagram')
                    bdRoot=bdRoot.getParent;
                end
                mdlName=bdRoot.getFullName;
            end
            tag=['addNewBlock_',mdlName,'_',varName];
            obj.mVarName=varName;
            obj.mPropName=propName;
            obj.mMdlName=mdlName;
            obj.mDlgSrc=dlgSrc;
            obj.mSrcHandle=blkHandle;
            obj.mDialogTag=tag;
            oModel=get_param(mdlName,'Object');
            obj.m_modelCloseListener=Simulink.listener(oModel,'CloseEvent',...
            @(src,eventData)obj.modelCloseListener(src,eventData,obj));
        end

        function cmbBoxCB(dlg,dataTypesTag)
            itemIndex=dlg.getWidgetValue(dataTypesTag);
            boolVal=isequal(itemIndex,'Global Data Store');
            dlg.setVisible('dataLocation_tag',boolVal);
            dlg.setVisible('dataLocationText_tag',boolVal);
            dlg.setVisible('dataType_tag',boolVal);
            dlg.setVisible('dataTypeText_tag',boolVal);
            dlg.resetSize(true);
        end


        function buttonCB(dlg,closeaction,obj)
            bClose=false;

            try
                if isequal(closeaction,'cancel')
                    dlg.hide;
                    return;
                elseif strcmpi(closeaction,'CreateDataDlg_Create')
                    dlg.setVisible(closeaction,0);
                    locationTxt=dlg.getWidgetValue('systemSelection_tag');
                    name=dlg.getWidgetValue('paramValue_tag');
                    dataLocation=dlg.getComboBoxText('dataLocation_tag');
                    expr=dlg.getWidgetValue('dataType_tag');
                    if isequal(locationTxt,'Global Data Store')
                        obj.mResult=DAStudio.message('SLDD:sldd:VariableCreated',obj.mVarName);
                        dlgSrc=dlg.getDialogSource;
                        bClose=createDataDDG.createVarWSHelper(dlg,expr,dataLocation,closeaction,dlgSrc);
                    else
                        h=add_block('simulink/Signal Routing/Data Store Memory',...
                        [locationTxt,'/Data Store Memory'],'MakeNameUnique','on');
                        set_param(h,obj.mPropName,name);
                        bClose=true;
                        obj.mResult=DAStudio.message('Simulink:dialog:BlockEditTimeNotification_NewDSMBlockAdded');
                    end
                else
                    bClose=true;
                end
            catch
                bClose=false;
            end
            if bClose
                delete(dlg);
            end

            if~isempty(obj.mDlgSrc)
                blkEditTimeCheck.openDialogsRefresh(obj.mBlkFullName);
                blkEditTimeCheck.openCanvasRefresh(obj.mMdlName);
            end
        end
    end
end
