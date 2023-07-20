classdef ParameterTuningDialog<handle

    properties
        dialog;
        hModel;
        sourceList={};
        sourceListType='MatlabWorkspace';
        sourceListSource;
        sourceListSelections;
        tunableParametersSource;
        tunableParametersSourceSelections;
    end


    methods(Static,Access=public)
        function r=handleSourceListSelectionChanged(ssTag,selections,dlg)
            dlg.setEnabled('addToTable',~isempty(selections));
            obj=dlg.getDialogSource;
            obj.sourceListSelections=selections;
            r=true;
        end

        function r=handleTunableParametersSelectionChanged(ssTag,selections,dlg)
            dlg.setEnabled('globalParametersRemove',~isempty(selections));
            obj=dlg.getDialogSource;
            obj.tunableParametersSourceSelections=selections;
            r=true;
        end
    end

    methods(Access=public)
        function this=ParameterTuningDialog(hModel)
            this.sourceList=slGetSpecifiedWSData('',1,0,0);
            this.hModel=hModel;
            setappdata(0,get_param(hModel,'Name'),this);
        end

        function dialogStruct=getDialogSchema(obj)

            textDescription.Name=DAStudio.message('Simulink:dialog:StringDescForGlobalTunnableParams2');
            textDescription.Type='text';
            textDescription.WordWrap=true;

            groupDescription.Name=DAStudio.message('Simulink:dialog:SlwsPrmDescription');
            groupDescription.Type='group';
            groupDescription.Items={textDescription};
            groupDescription.RowSpan=[1,1];
            groupDescription.ColSpan=[1,8];



            sourcelist_workspace.Type='combobox';
            sourcelist_workspace.Tag='sourcelist_combobox';
            sourcelist_workspace.ToolTip=DAStudio.message('Simulink:dialog:DispVarsInSelSrc');
            sourcelist_workspace.RowSpan=[2,2];
            sourcelist_workspace.ColSpan=[1,2];
            sourcelist_workspace.ObjectMethod='changeSourceListType';
            sourcelist_workspace.DialogRefresh=true;
            sourcelist_workspace.Entries={DAStudio.message('Simulink:dialog:MATLABWksVars'),DAStudio.message('Simulink:dialog:ReferencedWksVars')};


            sourcelist_spreadsheet.Tag='sourcelist_spreadsheet';
            sourcelist_spreadsheet.Type='spreadsheet';
            sourcelist_spreadsheet.ToolTip=DAStudio.message('Simulink:dialog:SelVarsAddToGlobalTunable');
            sourcelist_spreadsheet.RowSpan=[3,6];
            sourcelist_spreadsheet.ColSpan=[1,2];
            obj.sourceListSource=Simulink.data.ParameterTuningDialog.PTDSSourceListSpreadSheetSource(obj.sourceListType,obj.hModel,obj.tunableParametersSource);
            sourcelist_spreadsheet.Source=obj.sourceListSource;
            sourcelist_spreadsheet.Columns={'Name'};
            sourcelist_spreadsheet.Config='{"enablesort":false}';
            sourcelist_spreadsheet.SelectionChangedCallback=@(tag,sels,obj)Simulink.data.ParameterTuningDialog.ParameterTuningDialog.handleSourceListSelectionChanged(tag,sels,obj);


            sourcelist_pushbutton1.Name=DAStudio.message('Simulink:dialog:SlwsPrmRefreshList');
            sourcelist_pushbutton1.FilePath='';
            sourcelist_pushbutton1.Tag='sourcelist_refresh_button';
            sourcelist_pushbutton1.Type='pushbutton';
            sourcelist_pushbutton1.ToolTip=DAStudio.message('Simulink:dialog:RefreshSourceList');
            sourcelist_pushbutton1.RowSpan=[7,7];
            sourcelist_pushbutton1.ColSpan=[1,1];
            sourcelist_pushbutton1.Alignment=1;
            sourcelist_pushbutton1.DialogRefresh=true;

            sourcelist_pushbutton2.Name=DAStudio.message('Simulink:dialog:SlwsPrmAddToTable');
            sourcelist_pushbutton2.Tag='addToTable';
            sourcelist_pushbutton2.FilePath='';
            sourcelist_pushbutton2.Type='pushbutton';
            sourcelist_pushbutton2.ToolTip=DAStudio.message('Simulink:dialog:AddSelectVarsToGlobalTunable');
            sourcelist_pushbutton2.RowSpan=[7,7];
            sourcelist_pushbutton2.ColSpan=[2,2];
            sourcelist_pushbutton2.Alignment=7;
            sourcelist_pushbutton2.Enabled=false;
            sourcelist_pushbutton2.ObjectMethod='addToTable';
            sourcelist_pushbutton2.MethodArgs={'%dialog'};
            sourcelist_pushbutton2.ArgDataTypes={'handle'};
            sourcelist_pushbutton2.DialogRefresh=true;

            sourcelist_panel.Type='panel';
            sourcelist_panel.Items={sourcelist_pushbutton1,sourcelist_pushbutton2};
            sourcelist_panel.RowSpan=[7,7];
            sourcelist_panel.ColSpan=[1,2];
            sourcelist_panel.LayoutGrid=[1,2];

            groupSourceList.Name=DAStudio.message('Simulink:dialog:SlwsPrmSourceList');
            groupSourceList.Type='group';
            groupSourceList.Items={sourcelist_workspace,sourcelist_spreadsheet,sourcelist_panel};
            groupSourceList.RowSpan=[2,7];
            groupSourceList.ColSpan=[1,2];



            groupGlobalParameters_spreadsheet.Tag='groupGlobalParameters_spreadsheet';
            groupGlobalParameters_spreadsheet.Type='spreadsheet';
            groupGlobalParameters_spreadsheet.RowSpan=[2,6];
            groupGlobalParameters_spreadsheet.ColSpan=[3,8];
            if isempty(obj.tunableParametersSource)
                obj.tunableParametersSource=Simulink.data.ParameterTuningDialog.PTDSTunableParametersSpreadSheetSource(obj.hModel);
            end
            groupGlobalParameters_spreadsheet.Source=obj.tunableParametersSource;
            groupGlobalParameters_spreadsheet.SelectionChangedCallback=@(tag,sels,obj)Simulink.data.ParameterTuningDialog.ParameterTuningDialog.handleTunableParametersSelectionChanged(tag,sels,obj);
            groupGlobalParameters_spreadsheet.Columns={'Name','Storage class','Storage type qualifier'};

            globalParameters_placeholder.Type='panel';
            globalParameters_placeholder.RowSpan=[1,1];
            globalParameters_placeholder.ColSpan=[1,8];
            globalParameters_placeholder.LayoutGrid=[1,8];

            globalParameters_pushbutton1.Name=DAStudio.message('Simulink:dialog:SlwsPrmNew');
            globalParameters_pushbutton1.FilePath='';
            globalParameters_pushbutton1.Tag='globalParametersNew';
            globalParameters_pushbutton1.ObjectMethod='addNewTunableParameter';
            globalParameters_pushbutton1.MethodArgs={'%dialog'};
            globalParameters_pushbutton1.ArgDataTypes={'handle'};
            globalParameters_pushbutton1.ToolTip=DAStudio.message('Simulink:dialog:AddingNewParamToGlobalTunable');
            globalParameters_pushbutton1.Type='pushbutton';
            globalParameters_pushbutton1.RowSpan=[1,1];
            globalParameters_pushbutton1.ColSpan=[9,9];
            globalParameters_pushbutton1.Alignment=4;
            globalParameters_pushbutton1.DialogRefresh=true;

            globalParameters_pushbutton2.Name=DAStudio.message('Simulink:dialog:SlwsPrmRemove');
            globalParameters_pushbutton2.Tag='globalParametersRemove';
            globalParameters_pushbutton2.FilePath='';
            globalParameters_pushbutton2.Type='pushbutton';
            globalParameters_pushbutton2.ToolTip=DAStudio.message('Simulink:dialog:RemoveSelectParamsFromGlobalTunable');
            globalParameters_pushbutton2.ObjectMethod='removeSelectedTunableParameters';
            globalParameters_pushbutton2.MethodArgs={'%dialog'};
            globalParameters_pushbutton2.ArgDataTypes={'handle'};
            globalParameters_pushbutton2.RowSpan=[1,1];
            globalParameters_pushbutton2.ColSpan=[10,10];
            if isempty(obj.tunableParametersSourceSelections)
                globalParameters_pushbutton2.Enabled=false;
            else
                globalParameters_pushbutton2.Enabled=true;
            end
            globalParameters_pushbutton2.Alignment=4;
            globalParameters_pushbutton2.DialogRefresh=true;

            globalParameters_buttonGroup.Type='panel';
            globalParameters_buttonGroup.Items={globalParameters_placeholder,globalParameters_pushbutton1,globalParameters_pushbutton2};
            globalParameters_buttonGroup.RowSpan=[7,7];
            globalParameters_buttonGroup.ColSpan=[3,8];
            globalParameters_buttonGroup.LayoutGrid=[1,10];

            groupGlobalParameters.Name=DAStudio.message('Simulink:dialog:SlwsPrmGlobalTunableParameters');
            groupGlobalParameters.Type='group';
            groupGlobalParameters.Items={groupGlobalParameters_spreadsheet,globalParameters_buttonGroup};
            groupGlobalParameters.RowSpan=[2,7];
            groupGlobalParameters.ColSpan=[3,8];

            modelName=get_param(obj.hModel,'name');
            name=DAStudio.message('Simulink:dialog:ModelParamConfigName',modelName);
            dialogStruct.DialogTag='parameterTuningDialog';
            dialogStruct.DialogTitle=name;
            dialogStruct.LayoutGrid=[8,8];
            dialogStruct.RowStretch=[0,0,1,1,1,1,0,0];
            dialogStruct.ColStretch=[1,1,1,1,1,1,1,1];
            dialogStruct.EmbeddedButtonSet={''};

            dialogStruct.PostApplyMethod='doApply';
            dialogStruct.PostApplyArgs={'%dialog'};
            dialogStruct.PostApplyArgsDT={'handle'};

            dialogStruct.HelpMethod='onHelp';
            dialogStruct.HelpArgs={'%dialog'};
            dialogStruct.HelpArgsDT={'handle'};
            dialogStruct.Items={groupDescription,groupSourceList,groupGlobalParameters};
        end


        function changeSourceListType(obj)
            comboboxText=obj.dialog.getComboBoxText('sourcelist_combobox');
            if isequal(comboboxText,DAStudio.message('Simulink:dialog:MATLABWksVars'))
                obj.sourceListType='MatlabWorkspace';
            elseif isequal(comboboxText,DAStudio.message('Simulink:dialog:ReferencedWksVars'))
                obj.sourceListType='ReferencedWorkspaceVariable';
            end
        end


        function addNewTunableParameter(obj,dlg)
            dlg.enableApplyButton(true);
            tunableParametersSourceObj=obj.tunableParametersSource;
            tunableParametersSourceObj.addNewRow('','Model default','');
            newRowObj=tunableParametersSourceObj.mData(numel(tunableParametersSourceObj.mData));
            ssComp=dlg.getWidgetInterface('groupGlobalParameters_spreadsheet');
            ssComp.select(newRowObj);
        end


        function removeSelectedTunableParameters(obj,dlg)
            dlg.enableApplyButton(true);
            tunableParametersSourceObj=obj.tunableParametersSource;
            tunableParametersSourceObj.removeselectedRows(obj.tunableParametersSourceSelections);

            obj.tunableParametersSourceSelections={};
        end


        function addToTable(obj,dlg)
            dlg.enableApplyButton(true);
            tunableParametersSourceObj=obj.tunableParametersSource;
            for i=1:numel(obj.sourceListSelections)
                tunableParametersSourceObj.addNewRow(obj.sourceListSelections{i}.name,'Model default','');
            end
        end


        function onHelp(obj,~)
            try
                helpview([docroot,'/toolbox/simulink/helptargets.map'],'model_param_cfg_dlg');
            catch



                doc;
            end
        end


        function doApply(obj,dlg)
            dlg.enableApplyButton(false);
            tunableParametersSourceObj=obj.tunableParametersSource;
            tunableParametersRows=tunableParametersSourceObj.getAllRows;
            tunableVarsName=[];
            tunableVarsStorageClass=[];
            tunableVarsTypeQualifier=[];

            set=containers.Map;
            if numel(tunableParametersRows)>0

                for i=1:numel(tunableParametersRows)
                    if i==numel(tunableParametersRows)
                        sep='';
                    else
                        sep=',';
                    end
                    if isequal(tunableParametersRows(i).name,'')
                        continue;
                    end
                    if~set.isKey(tunableParametersRows(i).name)
                        set(tunableParametersRows(i).name)=1;
                        tunableVarsName=[tunableVarsName,tunableParametersRows(i).name,sep];
                        tunableVarsStorageClass=[tunableVarsStorageClass,tunableParametersRows(i).storageClass,sep];
                        if isequal(tunableParametersRows(i).storageTypeQualifier,' ')
                            tunableVarsTypeQualifier=[tunableVarsTypeQualifier,'',sep];
                        else
                            tunableVarsTypeQualifier=[tunableVarsTypeQualifier,tunableParametersRows(i).storageTypeQualifier,sep];
                        end
                    end
                end


                if~isequal(numel(tunableVarsName),0)&&isequal(tunableVarsName(numel(tunableVarsName)),',')
                    tunableVarsName=tunableVarsName(1:numel(tunableVarsName)-1);
                    tunableVarsStorageClass=tunableVarsStorageClass(1:numel(tunableVarsStorageClass)-1);
                    tunableVarsTypeQualifier=tunableVarsTypeQualifier(1:numel(tunableVarsTypeQualifier)-1);
                end
            end


            if~isequal(numel(tunableVarsName),0)&&numel(tunableParametersRows)>0
                set_param(obj.hModel,...
                'TunableVars',tunableVarsName,...
                'TunableVarsStorageClass',tunableVarsStorageClass,...
                'TunableVarsTypeQualifier',tunableVarsTypeQualifier...
                );
            else

                set_param(obj.hModel,...
                'TunableVars','',...
                'TunableVarsStorageClass','',...
                'TunableVarsTypeQualifier',''...
                );
            end


            if strcmp(obj.sourceListType,'MatlabWorkspace')
                set_param(obj.hModel,'ParamWorkspaceSource','MATLABWorkspace');
            elseif strcmp(obj.sourceListType,'ReferencedWorkspaceVariable')
                set_param(obj.hModel,'ParamWorkspaceSource','ReferencedWorkspace');
            else
                error=MSLException([],message('Simulink:dialog:ErrorSetParamWksSrc'));
                sldiagviewer.reportError(error);
            end
        end

        function setDialogObj(obj,dlg)
            obj.dialog=dlg;
        end

        function dlg=getDialogObj(obj)
            dlg=obj.dialog;
        end
    end
end
