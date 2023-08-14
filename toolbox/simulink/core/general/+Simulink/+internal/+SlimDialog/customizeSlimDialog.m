function dlg=customizeSlimDialog(blockPath,origDlg)





    dlg=origDlg;




    if blockisa(blockPath,{'Delay','UnitDelay','Memory'...
        ,'DiscreteZeroPole'...
        ,'DiscreteStateSpace'})


        sectionIndex=2;


        doCustomization=true;
        try
            sectionName=dlg.Items{1}.Items{sectionIndex}.Name;
        catch ex %#ok

            doCustomization=false;
        end
        if doCustomization

            doCustomization=strcmp(sectionName,DAStudio.message('Simulink:dialog:StateAttributes'));
        end


        if doCustomization

            widgetStartIdx=7;
            if(slfeature('DeprecateEmbeddedSignalAPI')>0)
                widgetStartIdx=widgetStartIdx-2;
            end
            for i=widgetStartIdx:-1:4
                dlg.Items{1}.Items{sectionIndex}.Items(i)=[];
            end


            dlg.Items{1}.Items{sectionIndex}.LayoutGrid=[2,2];
            dlg.Items{1}.Items{sectionIndex}.RowStretch=[0,1];
        end
    elseif blockisa(blockPath,'ModelReference')


        if numel(dlg.Items)==1

            dlg.Items{1}.Items{1}.Items{1}.Name=sprintf(strcat('\n',DAStudio.message('dastudio:propertyinspector:OpenModelBlockDialog'),'\n'));

            dlg.Items{1}.Items{1}.Items{2}.Items{2}.MatlabArgs={blockPath,'Param'};
        end
    elseif blockisa(blockPath,{'PID 1dof','PID 2dof'})


        try

            imageWidget=dlg.Items{1}.Items{7}.Items{1};
            alignImage=strcmp(imageWidget.Type,'image');
        catch ex %#ok

            alignImage=false;
        end
        if alignImage
            dlg.Items{1}.Items{7}.Items{1}.Alignment=6;
        end


        try
            dataTypePanel=dlg.Items{1}.Items{8}.Items{4};
            replaceDataType=strcmp(dataTypePanel.Name,DAStudio.message('Simulink:dialog:DataTypesTab'));
        catch ex %#ok

            replaceDataType=false;
        end
        if replaceDataType
            viewPnl=Simulink.internal.SlimDialog.createOpenButton(blockPath,...
            'dastudio:propertyinspector:AllParameters','mask');
            viewPnl.RowSpan=[1,1];
            viewPnl.ColSpan=[1,2];

            dlg.Items{1}.Items{8}.Items{4}.Items={viewPnl};


            dlg.Items{1}.Items{8}.Items{4}.LayoutGrid=[1,2];
        end
    else


        dlg=Simulink.internal.SlimDialog.transformDataTypeGroup(dlg);
    end

    if slfeature('SlimDialogShowScriptReference')>0

        blkObj=get_param(blockPath,'Object');
        blkDlgSrc=blkObj.getDialogSource;


        if strcmp(class(blkDlgSrc),'Simulink.SLDialogSource')%#ok This is faster than isa(_, _)


            if all(ismember(fieldnames(dlg.Items{end}),{'Type','RowSpan','ColSpan','Enabled'}))

                dlg.RowStretch(end)=true;
            else

                spacerPanel.Type='panel';
                spacerPanel.RowSpan=[dlg.LayoutGrid(1)+1,dlg.LayoutGrid(1)+1];
                spacerPanel.ColSpan=[1,dlg.LayoutGrid(2)];
                spacerPanel.Enabled=false;

                dlg.Items{end+1}=spacerPanel;
                dlg.LayoutGrid=dlg.LayoutGrid+[1,0];
                dlg.RowStretch=[dlg.RowStretch,1];
            end


            scriptEditor.Type='matlabeditor';
            scriptEditor.Name='';
            scriptEditor.Tag='ScriptReference_matlabeditor';
            scriptEditor.RowSpan=[1,1];
            scriptEditor.Enabled=false;
            scriptEditor.Visible=true;

            scriptPanel.Type='togglepanel';
            scriptPanel.Name=DAStudio.message('Simulink:dialog:ScriptReference');
            scriptPanel.Tag='ScriptReference_togglepanel';
            scriptPanel.RowSpan=[1,1];
            scriptPanel.LayoutGrid=[1,1];
            scriptPanel.RowStretch=1;
















            if isNewBlockClicked(blockPath)
                scriptPanel.Expand=false;
            else
                blkObj=get_param(blockPath,'Object');
                scriptPanelState=DAStudio.getDialogTogglePanelState(blkObj.getDialogSource.getFullName,scriptPanel.Tag);
                scriptPanel.Expand=scriptPanelState>0;
            end


            if scriptPanel.Expand
                scriptEditor.Value=Simulink.internal.SlimDialog.generateScriptReference(blockPath);
            else
                scriptEditor.Value='';
            end

            scriptPanel.Items={scriptEditor};
            scriptPanel.ExpandCallback=@Simulink.internal.SlimDialog.expandScriptPanelCallBack;

            scriptGroup.Type='group';
            scriptGroup.Name='';
            scriptGroup.Tag='ScriptReference_group';
            scriptGroup.RowSpan=[dlg.LayoutGrid(1)+1,dlg.LayoutGrid(1)+1];
            scriptGroup.ColSpan=[1,dlg.LayoutGrid(2)];
            scriptGroup.LayoutGrid=[1,1];
            scriptGroup.RowStretch=1;
            scriptGroup.Items={scriptPanel};


            dlg.Items{end+1}=scriptGroup;
            dlg.LayoutGrid=dlg.LayoutGrid+[1,0];
            dlg.RowStretch=[dlg.RowStretch,0];

        end

    end

    function newBlockClicked=isNewBlockClicked(blockPath)




        persistent cachedSID

        blockSID=get_param(blockPath,'SID');
        newBlockClicked=~isequal(blockSID,cachedSID);
        cachedSID=blockSID;
