function newInstrumentPanel(this)





    function confirmExistingFilesCB(e)
        confirmExistingFilesSelectedOption=e.SelectedOptionIndex;
    end

    onCleanups=onCleanup.empty;

    instPanelTemplateName='slrtInstrumentPanelTemplate';
    instPanelTemplateDir=fullfile(matlabroot,'toolbox','slrealtime','slrealtime','+slrealtime','+internal');
    instPanelTemplateFile=strcat(fullfile(instPanelTemplateDir,instPanelTemplateName),'.mlapp');
    callbackTemplateName='slrtCallbackTemplate';
    callbackTemplateDir=fullfile(matlabroot,'toolbox','slrealtime','slrealtime','+slrealtime','+internal');
    callbackTemplateFile=strcat(fullfile(callbackTemplateDir,callbackTemplateName),'.m');

    try

        if~isempty(this.GenerateLastFolder)&&~isempty(this.GenerateLastName)
            [filename,pathname]=uiputfile(...
            fullfile(this.GenerateLastFolder,this.GenerateLastName),...
            this.SelectMLAPPFile_msg);
        else
            [filename,pathname]=uiputfile(...
            {'*.mlapp','MATLAB App (*.mlapp)'},...
            this.SelectMLAPPFile_msg);
        end


        this.bringToFront();


        if~isequal(filename,0)&&~isequal(pathname,0)

            outputDir=fileparts(pathname);
            [~,instPanelName]=fileparts(filename);
            callbackName=[instPanelName,'_SLRTCallback'];

            this.GenerateLastFolder=outputDir;
            this.GenerateLastName=[instPanelName,'.mlapp'];
        else

            this.infoDlg('slrealtime:appdesigner:NoMLAPPFileCreated');
            return;
        end

        instPanelOutputDir=outputDir;
        instPanelNameWithExt=[instPanelName,'.mlapp'];
        instPanelFile=strcat(fullfile(instPanelOutputDir,instPanelName),'.mlapp');
        callbackOutputDir=outputDir;
        callbackNameWithExt=[callbackName,'.m'];
        callbackFile=strcat(fullfile(callbackOutputDir,callbackName),'.m');



        filesToCreate={};
        filesExist={};
        filesToRestoreOnError=struct('origFile',{},'tempFile',{});

        filesToCreate{end+1}=instPanelNameWithExt;
        if this.OptionsCallbackItem.Value
            filesToCreate{end+1}=callbackNameWithExt;
            if exist(callbackFile,'file')




                filesExist{end+1}=callbackNameWithExt;
            end
        end

        if~isempty(filesExist)
            msg=getString(message('slrealtime:appdesigner:ReplaceExistingFiles',...
            outputDir,char(join(cellfun(@(x)[char(9),x],filesExist,'UniformOutput',false),newline))));

            confirmExistingFilesSelectedOption=[];
            if isempty(this.ReplaceExistingFilesSelection)



                uiconfirm(this.getUIFigure(),...
                msg,this.Confirm_msg,...
                'Options',{this.Yes_msg,this.No_msg},...
                'DefaultOption',this.No_msg,...
                'CloseFcn',@(o,e)confirmExistingFilesCB(e));
            else



                confirmExistingFilesSelectedOption=this.ReplaceExistingFilesSelection;
            end
            while isempty(confirmExistingFilesSelectedOption)
                pause(0.01);
            end

            if confirmExistingFilesSelectedOption==2

                this.infoDlg('slrealtime:appdesigner:MLAPPFileNotCreated',instPanelFile);
                return;
            else

                for i=1:numel(filesExist)
                    filesToRestoreOnError{i}.origFile=filesExist{i};
                    filesToRestoreOnError{i}.tempFile=tempname(outputDir);
                    movefile(filesToRestoreOnError{i}.origFile,filesToRestoreOnError{i}.tempFile);
                end
            end
        end



        dlg=uiprogressdlg(...
        this.getUIFigure(),...
        'Indeterminate','on',...
        'Message',this.GenerateDlgMsg_msg,...
        'Title',this.GenerateDlgTitle_msg);
        onCleanups(end+1)=onCleanup(@()delete(dlg));



        [success,msg,msgId]=copyfile(instPanelTemplateFile,instPanelFile);
        if success~=1,error(msgId,msg);end



        [success,msg,msgId]=fileattrib(instPanelFile,'+w');
        if success~=1,error(msg,msgId);end



        fileReader=appdesigner.internal.serialization.FileReader(instPanelFile);
        appdata=fileReader.readAppDesignerData();
        code=appdata.code;
        components=appdata.components;
        if~isempty(components)&&...
            isfield(components,'UIFigure')&&ishandle(components.UIFigure)


            onCleanups(end+1)=onCleanup(@()delete(components.UIFigure));
        end
        code.ClassName=instPanelName;




        uifigureName='UIFigure';
        appArgName='app';
        compToolstripPanel=components.(uifigureName).Children(1).Children(1);
        compTabGroup=components.(uifigureName).Children(1).Children(2);
        compStatusBarPanel=components.(uifigureName).Children(1).Children(3);
        compAllComponentsGrid=compTabGroup.Children(1).Children(1);
        compAllAddedComponentsGrid=compAllComponentsGrid.Children(1);
        compAllAddedUIComponentsGrid=compAllAddedComponentsGrid.Children(1);




        if~this.OptionsUseGridItem.Value
            delete(compAllComponentsGrid);
            delete(compAllAddedComponentsGrid);
            delete(compAllAddedUIComponentsGrid);
            compAllComponentsGrid=compTabGroup.Children(1);
            compAllAddedComponentsGrid=compTabGroup.Children(1);
            compAllAddedUIComponentsGrid=compTabGroup.Children(1);




            compTabGroup.Children(1).AutoResizeChildren='off';
        end

        compDashboardTab=compTabGroup.Children(2);
        compTETMonitorTab=compTabGroup.Children(3);

        slrtTokenCode={};



        targetSelectorVarName='targetSelector';
        if this.OptionsToolstripItem.Value



            comp=slrealtime.ui.control.TargetSelector(compToolstripPanel.Children(4).Children(1));
            this.copyPropValues(this.PropsTargetSelector,comp);
            this.addDesignTimeProperties(comp,'TargetSelector');
            slrtTokenCode{end+1}=['            ',targetSelectorVarName,' = ',appArgName,'.TargetSelector;'];
            slrtTokenCode{end+1}='';

            comp=slrealtime.ui.control.ConnectButton(compToolstripPanel.Children(4).Children(1));
            this.copyPropValues(this.PropsConnectButton,comp);
            this.addDesignTimeProperties(comp,'ConnectButton');
            slrtTokenCode{end+1}=['            ',appArgName,'.ConnectButton.TargetSource = ',targetSelectorVarName,';'];

            comp=slrealtime.ui.control.LoadButton(compToolstripPanel.Children(3).Children(1));
            this.copyPropValues(this.PropsLoadButton,comp);
            this.addDesignTimeProperties(comp,'LoadButton');
            slrtTokenCode{end+1}=['            ',appArgName,'.LoadButton.TargetSource = ',targetSelectorVarName,';'];

            comp=slrealtime.ui.control.StartStopButton(compToolstripPanel.Children(2).Children(1));
            comp.Layout.Row=[1,3];
            comp.Layout.Column=1;
            this.copyPropValues(this.PropsStartStopButton,comp);
            this.addDesignTimeProperties(comp,'StartStopButton');
            slrtTokenCode{end+1}=['            ',appArgName,'.StartStopButton.TargetSource = ',targetSelectorVarName,';'];

            comp=slrealtime.ui.control.StopTimeEditField(compToolstripPanel.Children(2).Children(1));
            comp.Layout.Row=2;
            comp.Layout.Column=2;
            this.copyPropValues(this.PropsStopTime,comp);
            this.addDesignTimeProperties(comp,'StopTimeEditField');
            slrtTokenCode{end+1}=['            ',appArgName,'.StopTimeEditField.TargetSource = ',targetSelectorVarName,';'];

            comp=slrealtime.ui.control.SystemLog(compToolstripPanel.Children(1).Children(1));
            this.copyPropValues(this.PropsSystemLog,comp);
            this.addDesignTimeProperties(comp,'SystemLog');
            slrtTokenCode{end+1}=['            ',appArgName,'.SystemLog.TargetSource = ',targetSelectorVarName,';'];

        else



            parent=compToolstripPanel.Parent;
            compToolstripPanel.Parent=[];
            delete(compToolstripPanel);
            clear compToolstripPanel;
            compTabGroup.Layout.Row=1;
            compStatusBarPanel.Layout.Row=2;
            parent.RowHeight=parent.RowHeight(2:3);
            slrtTokenCode{end+1}=['            menu = slrealtime.ui.container.Menu(',appArgName,'.',uifigureName,');'];
            slrtTokenCode{end+1}=['            ',targetSelectorVarName,' = menu.TargetSelector;'];
            slrtTokenCode{end+1}=['            menu.SkipInstall = ',num2str(this.PropsMenu.SkipInstall),';'];
            slrtTokenCode{end+1}=['            menu.AsyncLoad = ',num2str(this.PropsMenu.AsyncLoad),';'];
            if~isempty(this.PropsMenu.Application)
                slrtTokenCode{end+1}=['            menu.Application = ''',this.PropsMenu.Application,''';'];
            end
            slrtTokenCode{end+1}=['            menu.ReloadOnStop = ',num2str(this.PropsMenu.ReloadOnStop),';'];
            slrtTokenCode{end+1}=['            menu.AutoImportFileLog = ',num2str(this.PropsMenu.AutoImportFileLog),';'];
            slrtTokenCode{end+1}=['            menu.ExportToBaseWorkspace = ',num2str(this.PropsMenu.ExportToBaseWorkspace),';'];
            slrtTokenCode{end+1}='';
        end



        if this.OptionsStatusBarItem.Value



            comp=slrealtime.ui.control.StatusBar(compStatusBarPanel.Children(1));
            this.copyPropValues(this.PropsStatusBar,comp);
            this.addDesignTimeProperties(comp,'StatusBar');
            slrtTokenCode{end+1}=['            ',appArgName,'.StatusBar.TargetSource = ',targetSelectorVarName,';'];
        else



            parent=compStatusBarPanel.Parent;
            compStatusBarPanel.Parent=[];
            delete(compStatusBarPanel);
            clear compStatusBarPanel;
            parent.RowHeight=parent.RowHeight(1:end-1);
        end



        if this.OptionsTETMonitorItem.Value



            comp=slrealtime.ui.control.TETMonitor(compTETMonitorTab.Children(1));
            this.addDesignTimeProperties(comp,'TETMonitor');
            slrtTokenCode{end+1}=['            ',appArgName,'.TETMonitor.TargetSource = ',targetSelectorVarName,';'];
        else



            compTETMonitorTab.Parent=[];
            delete(compTETMonitorTab);
            clear compTETMonitorTab;
        end
        slrtTokenCode{end+1}='';



        slrtTokenCode{end+1}='            hInst = slrealtime.Instrument();';
        if this.OptionsInstrumentedSignalsItem.Value



            uiaxesName='InstrumentedSignalsAxes';
            try
                instCode=this.getInstrumentedSignalsCode(...
                this.SessionSource.SourceFile,this.SessionSource.ModelName,...
                uiaxesName,appArgName);
            catch ME
                uialert(this.getUIFigure(),slrealtime.internal.replaceHyperlinks(ME.message),this.Error_msg);
                return;
            end
            slrtTokenCode=[slrtTokenCode,instCode];

            comp=uiaxes(compAllComponentsGrid);
            if this.OptionsUseGridItem.Value
                comp.Layout.Row=1;
                comp.Layout.Column=2;
            end
            comp.Title.String='Instrumented Signals';
            comp.XLabel.String='time (seconds)';
            this.addDesignTimeProperties(comp,uiaxesName);
            slrtTokenCode{end+1}=['            legend(',appArgName,'.',uiaxesName,', ''Interpreter'', ''none'');'];
        else



            if this.OptionsUseGridItem.Value
                compAllComponentsGrid.ColumnWidth={'1x'};
            end
        end
        slrtTokenCode{end+1}='';







        tableComp=[];
        bindingData=this.BindingData;
        compMap=containers.Map('KeyType','char','ValueType','any');

        [controlNames,controlTypes]=this.getControlNamesAndTypes(bindingData);
        this.checkControlNames(controlNames,components);

        addedComponentsTabNum=0;
        addedComponents=0;
        addUIComponentsParent=compAllAddedUIComponentsGrid;

        for nControl=1:length(controlNames)
            switch controlTypes{nControl}
            case{'Parameter Table','Signal Table'}
                if this.OptionsUseGridItem.Value


                    if isempty(tableComp)
                        tableComp=uitabgroup(compAllAddedComponentsGrid);
                        tableComp.Layout.Row=2;
                        tableComp.Layout.Column=1;
                        this.addDesignTimeProperties(tableComp,'SignalAndParameterTables');
                    end


                    tabComp=uitab(tableComp);
                    tabComp.Title=controlNames{nControl};
                    this.addDesignTimeProperties(tabComp,[controlNames{nControl},'Tab']);


                    gridComp=uigridlayout(tabComp,[1,1],...
                    'Padding',0,'RowSpacing',0,'ColumnSpacing',0);
                    gridComp.RowHeight={'1x'};
                    gridComp.ColumnWidth={'1x'};
                    this.addDesignTimeProperties(gridComp,[controlNames{nControl},'Grid']);
                else
                    gridComp=compTabGroup.Children(1);
                end


                switch controlTypes{nControl}
                case 'Parameter Table'
                    comp=slrealtime.ui.control.ParameterTable(gridComp);
                case 'Signal Table'
                    comp=slrealtime.ui.control.SignalTable(gridComp);
                end
                slrtTokenCode{end+1}=['            ',appArgName,'.',controlNames{nControl},'.TargetSource = ',targetSelectorVarName,';'];%#ok

            otherwise
                if this.OptionsUseGridItem.Value




                    addedComponents=addedComponents+1;
                    if addedComponents>16
                        addedComponents=1;
                        addedComponentsTabNum=addedComponentsTabNum+1;

                        overflowTabComp=uitab(compTabGroup);
                        overflowTabComp.Title=['Signals and Parameters',num2str(addedComponentsTabNum)];
                        this.addDesignTimeProperties(overflowTabComp,['SignalsAndParameters',num2str(addedComponentsTabNum),'Tab']);


                        overflowGridComp=uigridlayout(overflowTabComp,[1,1],...
                        'Padding',0,'RowSpacing',0,'ColumnSpacing',0);
                        overflowGridComp.RowHeight={'1x','1x'};
                        overflowGridComp.ColumnWidth={'1x','1x'};
                        this.addDesignTimeProperties(overflowGridComp,['SignalsAndParameters',num2str(addedComponentsTabNum),'Grid']);

                        addUIComponentsParent=overflowGridComp;
                    end
                end

                switch controlTypes{nControl}
                case 'Edit Field (numeric)'
                    comp=uieditfield(addUIComponentsParent,'numeric');
                case 'Edit Field (text)'
                    comp=uieditfield(addUIComponentsParent,'text');
                case 'Gauge'
                    comp=uigauge(addUIComponentsParent,'circular');
                case '90 Degree Gauge'
                    comp=uigauge(addUIComponentsParent,'ninetydegree');
                case 'Linear Gauge'
                    comp=uigauge(addUIComponentsParent,'linear');
                case 'Semicircular Gauge'
                    comp=uigauge(addUIComponentsParent,'semicircular');
                case 'Lamp'
                    comp=uilamp(addUIComponentsParent);
                case 'Axes'
                    comp=uiaxes(addUIComponentsParent);
                case 'Knob'
                    comp=uiknob(addUIComponentsParent);
                case 'Slider'
                    comp=uislider(addUIComponentsParent);
                otherwise
                    continue;
                end
            end

            if this.PropsMap.isKey(controlNames{nControl})
                this.copyPropValues(this.PropsMap(controlNames{nControl}),comp);
            end

            if~this.OptionsUseGridItem.Value
                comp.Position(1)=comp.Position(1)+(10*nControl);
                comp.Position(2)=comp.Position(2)+(10*nControl);
            end

            this.addDesignTimeProperties(comp,controlNames(nControl));
            compMap(controlNames{nControl})=comp;
            comp=[];
        end

        if isempty(tableComp)



            if this.OptionsUseGridItem.Value
                compAllAddedComponentsGrid.RowHeight={'1x'};
            end
        end



        [guiInstrument,nSignals,tooltipCode,callbackCode]=this.createInstrument(bindingData,compMap,appArgName);
        slrtTokenCode=[slrtTokenCode,tooltipCode];
        slrtTokenCode{end+1}='';

        if this.OptionsCallbackItem.Value


            fcnH=['@(o,e)',callbackName,'(o,e,app)'];
            guiInstrument.connectCallback(eval(fcnH));



            [success,msg,msgId]=copyfile(callbackTemplateFile,callbackFile);
            if success~=1,error(msgId,msg);end
            [success,msg,msgId]=fileattrib(callbackFile,'+w');
            if success~=1,error(msg,msgId);end



            [fid,errmsg]=fopen(callbackFile);
            if fid<0,error(errmsg);end
            callbackFileContents=fread(fid,'*char')';
            status=fclose(fid);
            if status~=0
                slrealtime.internal.throw.Error(...
                'slrealtime:appdesigner:MLAPPFileCloseError',callbackFile);
            end



            callbackFileContents=strrep(callbackFileContents,'slrtCallbackTemplate',callbackName);
            callbackCode=join(callbackCode,newline);
            if isempty(callbackCode),callbackCode={''};end
            callbackFileContents=strrep(callbackFileContents,'    %<SLRT_TOKEN>',callbackCode{:});



            [fid,errmsg]=fopen(callbackFile,'wt');
            if fid<0,error(errmsg);end
            fprintf(fid,'%s',callbackFileContents);
            status=fclose(fid);
            if status~=0
                slrealtime.internal.throw.Error(...
                'slrealtime:appdesigner:MLAPPFileCloseError',callbackFile);
            end
        end



        bindingCode=this.createBindingCode(guiInstrument,bindingData,nSignals,uifigureName,appArgName,targetSelectorVarName);
        slrtTokenCode=[slrtTokenCode,bindingCode];



        if this.OptionsDashboardItem.Value



            try
                find_system(this.SessionSource.ModelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices);
            catch
                try
                    load_system(this.SessionSource.ModelName);
                    onCleanups(end+1)=onCleanup(@()close_system(this.SessionSource.ModelName,false));
                catch
                    this.errorDlg(...
                    'slrealtime:appdesigner:ModelNotFound',...
                    this.SessionSource.ModelName);
                    return;
                end
            end

            blks=Simulink.HMI.getDashboardBlocksInModel(this.SessionSource.ModelName);
            blks=blks(strcmp(get_param(blks,'Commented'),'off'));

            compDashboardGrid=compDashboardTab.Children(1);
            str=cell(1,ceil(sqrt(length(blks))));
            str(:)={'1x'};
            compDashboardGrid.RowHeight=str;
            compDashboardGrid.ColumnWidth=str;

            comp=[];

            for nBlk=1:length(blks)
                blockType=get_param(blks{nBlk},'BlockType');

                dashboardCompName=this.getUniqueControlName();

                switch(blockType)
                case 'CustomWebBlock'
                    customType=get_param(blks{nBlk},'CustomType');
                    switch customType
                    case{'Vertical Gauge','Horizontal Gauge'}
                        blockType='LinearGaugeBlock';
                    case 'Circular Gauge'
                        blockType='CircularGaugeBlock';
                    otherwise
                        continue;
                    end

                case 'CustomTuningWebBlock'
                    customType=get_param(blks{nBlk},'CustomType');
                    switch customType
                    case{'Knob'}
                        blockType='KnobBlock';
                    case{'Vertical Slider','Horizontal Slider'}
                        blockType='SliderBlock';
                    otherwise
                        continue;
                    end
                end

                switch blockType
                case{'KnobBlock','SliderBlock'}
                    switch blockType
                    case 'KnobBlock'
                        comp=uiknob(compDashboardGrid);
                    case 'SliderBlock'
                        comp=uislider(compDashboardGrid);
                    end

                    binding=get_param(blks{nBlk},'Binding');
                    if isempty(binding),continue;end

                    limits=get_param(blks{nBlk},'Limits');
                    comp.Limits=[limits(1),limits(3)];
                    value=get_param(blks{nBlk},'Value');
                    comp.Value=str2double(value);

                    if~isempty(binding.VarName)
                        blockpath='';
                        paramname=binding.VarName;
                    else
                        blockpath=binding.BlockPath.getBlock(1);
                        paramname=binding.ParamName;
                    end

                    slrtTokenCode{end+1}=['            slrtcomp = slrealtime.ui.tool.ParameterTuner(',appArgName,'.',uifigureName,', ''TargetSource'', ',targetSelectorVarName,');'];%#ok
                    slrtTokenCode{end+1}=['            slrtcomp.Component = ',appArgName,'.',dashboardCompName,';'];%#ok
                    slrtTokenCode{end+1}=['            slrtcomp.BlockPath = ''',blockpath,''';'];%#ok
                    slrtTokenCode{end+1}=['            slrtcomp.ParameterName = ''',paramname,''';'];%#ok
                    slrtTokenCode{end+1}=['            slrtcomp.ConvertToComponent = @',appArgName,'.convToDouble;'];%#ok
                    slrtTokenCode{end+1}='';%#ok

                case 'EditField'
                    comp=uieditfield(compDashboardGrid,'numeric');

                    binding=get_param(blks{nBlk},'Binding');
                    if isempty(binding),continue;end

                    value=get_param(blks{nBlk},'Value');
                    comp.Value=str2double(value);

                    if~isempty(binding.VarName)
                        blockpath='';
                        paramname=binding.VarName;
                    else
                        blockpath=binding.BlockPath.getBlock(1);
                        paramname=binding.ParamName;
                    end

                    slrtTokenCode{end+1}=['            slrtcomp = slrealtime.ui.tool.ParameterTuner(',appArgName,'.',uifigureName,', ''TargetSource'', ',targetSelectorVarName,');'];%#ok
                    slrtTokenCode{end+1}=['            slrtcomp.Component = ',appArgName,'.',dashboardCompName,';'];%#ok
                    slrtTokenCode{end+1}=['            slrtcomp.BlockPath = ''',blockpath,''';'];%#ok
                    slrtTokenCode{end+1}=['            slrtcomp.ParameterName = ''',paramname,''';'];%#ok
                    slrtTokenCode{end+1}=['            slrtcomp.ConvertToComponent = @',appArgName,'.convToDouble;'];%#ok
                    slrtTokenCode{end+1}='';%#ok

                case 'Checkbox'
                    comp=uicheckbox(compDashboardGrid);

                    binding=get_param(blks{nBlk},'Binding');
                    if isempty(binding),continue;end

                    label=get_param(blks{nBlk},'Label');
                    comp.Text=label;

                    if~isempty(binding.VarName)
                        blockpath='';
                        paramname=binding.VarName;
                    else
                        blockpath=binding.BlockPath.getBlock(1);
                        paramname=binding.ParamName;
                    end

                    slrtTokenCode{end+1}=['            slrtcomp = slrealtime.ui.tool.ParameterTuner(',appArgName,'.',uifigureName,', ''TargetSource'', ',targetSelectorVarName,');'];%#ok
                    slrtTokenCode{end+1}=['            slrtcomp.Component = ',appArgName,'.',dashboardCompName,';'];%#ok
                    slrtTokenCode{end+1}=['            slrtcomp.BlockPath = ''',blockpath,''';'];%#ok
                    slrtTokenCode{end+1}=['            slrtcomp.ParameterName = ''',paramname,''';'];%#ok
                    slrtTokenCode{end+1}=['            slrtcomp.ConvertToComponent = @',appArgName,'.convToScalarLogical;'];%#ok
                    slrtTokenCode{end+1}='';%#ok

                case{'ComboBox','RotarySwitchBlock','ToggleSwitchBlock','RockerSwitchBlock','SliderSwitchBlock'}
                    switch blockType
                    case 'ComboBox'
                        comp=uidropdown(compDashboardGrid);
                    case 'RotarySwitchBlock'
                        comp=uiknob(compDashboardGrid,'discrete');
                    case 'ToggleSwitchBlock'
                        comp=uiswitch(compDashboardGrid,'toggle');
                    case 'RockerSwitchBlock'
                        comp=uiswitch(compDashboardGrid,'rocker');
                    case 'SliderSwitchBlock'
                        comp=uiswitch(compDashboardGrid,'slider');
                    end

                    binding=get_param(blks{nBlk},'Binding');
                    if isempty(binding),continue;end

                    if~isempty(binding.VarName)
                        blockpath='';
                        paramname=binding.VarName;
                    else
                        blockpath=binding.BlockPath.getBlock(1);
                        paramname=binding.ParamName;
                    end

                    states=get_param(blks{nBlk},'States');
                    comp.Items={states.Label};
                    valuesVar=[dashboardCompName,'_values'];
                    labelsVar=[dashboardCompName,'_labels'];
                    slrtTokenCode{end+1}=['            ',valuesVar,' = ',mat2str([states.Value]),';'];%#ok
                    slrtTokenCode{end+1}=['            ',labelsVar,' = ',this.convertToStrForMLAPPCode(comp.Items),';'];%#ok

                    slrtTokenCode{end+1}=['            slrtcomp = slrealtime.ui.tool.ParameterTuner(',appArgName,'.',uifigureName,', ''TargetSource'', ',targetSelectorVarName,');'];%#ok
                    slrtTokenCode{end+1}=['            slrtcomp.Component = ',appArgName,'.',dashboardCompName,';'];%#ok
                    slrtTokenCode{end+1}=['            slrtcomp.BlockPath = ''',blockpath,''';'];%#ok
                    slrtTokenCode{end+1}=['            slrtcomp.ParameterName = ''',paramname,''';'];%#ok
                    slrtTokenCode{end+1}=['            slrtcomp.ConvertToComponent = @(val)',appArgName,'.convertValueToLabel(val, ',valuesVar,', ',labelsVar,');'];%#ok
                    slrtTokenCode{end+1}=['            slrtcomp.ConvertToTarget = @(val)',appArgName,'.convertLabelToValue(val, ',valuesVar,', ',labelsVar,');'];%#ok
                    slrtTokenCode{end+1}='';%#ok




















                case 'DashboardScope'
                    comp=uiaxes(compDashboardGrid);

                    binding=get_param(blks{nBlk},'Binding');
                    if isempty(binding),continue;end

                    for nBinding=1:length(binding)
                        if~isempty(binding{nBinding}.SignalName_)
                            slrtTokenCode{end+1}=['            hInst.connectLine(',appArgName,'.',dashboardCompName,', ''',binding{nBinding}.SignalName_,''');'];%#ok
                        else
                            slrtTokenCode{end+1}=['            hInst.connectLine(',appArgName,'.',dashboardCompName,', ''',binding{nBinding}.BlockPath.getBlock(1),''', ',num2str(binding{nBinding}.OutputPortIndex),');'];%#ok
                        end
                    end
                    slrtTokenCode{end+1}='';%#ok

                case 'DisplayBlock'
                    comp=uieditfield(compDashboardGrid,'text');
                    comp.Editable=false;

                    binding=get_param(blks{nBlk},'Binding');
                    if isempty(binding),continue;end

                    if~isempty(binding.SignalName_)
                        slrtTokenCode{end+1}=['            hInst.connectScalar(',appArgName,'.',dashboardCompName,', ''',binding.SignalName_,''', ''Callback'', @(t,d)',appArgName,'.displayBlockCB(d));'];%#ok
                    else
                        slrtTokenCode{end+1}=['            hInst.connectScalar(',appArgName,'.',dashboardCompName,', ''',binding.BlockPath.getBlock(1),''', ',num2str(binding.OutputPortIndex),', ''Callback'', @(t,d)',appArgName,'.displayBlockCB(d));'];%#ok
                    end
                    slrtTokenCode{end+1}='';%#ok

                case 'LampBlock'
                    comp=uilamp(compDashboardGrid);

                    binding=get_param(blks{nBlk},'Binding');
                    if isempty(binding),continue;end

                    states=get_param(blks{nBlk},'States');
                    default=get_param(blks{nBlk},'ColorDefault');
                    statesVar=[dashboardCompName,'_states'];
                    defaultVar=[dashboardCompName,'_default'];
                    slrtTokenCode{end+1}=['            ',statesVar,'{1} = ',mat2str(states{1}),';'];%#ok
                    slrtTokenCode{end+1}=['            ',statesVar,'{2} = ',mat2str(states{2}/255),';'];%#ok
                    slrtTokenCode{end+1}=['            ',defaultVar,' = ',mat2str(default),';'];%#ok
                    if~isempty(binding.SignalName_)
                        slrtTokenCode{end+1}=['            hInst.connectScalar(',appArgName,'.',dashboardCompName,', ''',binding.SignalName_,''', ''Property'', ''Color'', ''Callback'', @(t,d)',appArgName,'.lampBlockCB(d, ',statesVar,', ',defaultVar,'));'];%#ok
                    else
                        slrtTokenCode{end+1}=['            hInst.connectScalar(',appArgName,'.',dashboardCompName,', ''',binding.BlockPath.getBlock(1),''', ',num2str(binding.OutputPortIndex),', ''Property'', ''Color'', ''Callback'', @(t,d)',appArgName,'.lampBlockCB(d, ',statesVar,', ',defaultVar,'));'];%#ok
                    end
                    slrtTokenCode{end+1}='';%#ok

                case{'CircularGaugeBlock','SemiCircularGaugeBlock','QuarterGaugeBlock','LinearGaugeBlock'}
                    switch(blockType)
                    case 'CircularGaugeBlock'
                        comp=uigauge(compDashboardGrid,'circular');
                    case 'SemiCircularGaugeBlock'
                        comp=uigauge(compDashboardGrid,'semicircular');
                    case 'QuarterGaugeBlock'
                        comp=uigauge(compDashboardGrid,'ninetydegree');
                    case 'LinearGaugeBlock'
                        comp=uigauge(compDashboardGrid,'linear');
                    end

                    binding=get_param(blks{nBlk},'Binding');
                    if isempty(binding),continue;end

                    limits=get_param(blks{nBlk},'Limits');
                    if~isempty(limits)
                        comp.Limits=[limits(1),limits(3)];
                    end

                    ranges=get_param(blks{nBlk},'ScaleColors');
                    if~isempty(ranges)
                        colors=[];
                        limits=[];
                        for i=1:numel(ranges)
                            colors=[colors;ranges(i).Color];%#ok
                            limits=[limits;[ranges(i).Min,ranges(i).Max]];%#ok
                        end
                        comp.ScaleColors=colors;
                        comp.ScaleColorLimits=limits;
                    end

                    if~isempty(binding.SignalName_)
                        slrtTokenCode{end+1}=['            hInst.connectScalar(',appArgName,'.',dashboardCompName,', ''',binding.SignalName_,''');'];%#ok
                    else
                        slrtTokenCode{end+1}=['            hInst.connectScalar(',appArgName,'.',dashboardCompName,', ''',binding.BlockPath.getBlock(1),''', ',num2str(binding.OutputPortIndex),');'];%#ok
                    end
                    slrtTokenCode{end+1}='';%#ok
                end

                if~isempty(comp)
                    this.addDesignTimeProperties(comp,dashboardCompName);
                    comp=[];
                end
            end

        else



            compDashboardTab.Parent=[];
            delete(compDashboardTab);
            clear compDashboardTab;
        end

        slrtTokenCode{end+1}=['            slrtInstrumentsComponent = slrealtime.ui.tool.InstrumentManager(',appArgName,'.',uifigureName,', ''TargetSource'', ',targetSelectorVarName,');'];
        slrtTokenCode{end+1}='            slrtInstrumentsComponent.Instruments = hInst;';



        matlabCodeText='error(''slrealtime:appdesigner:OpenBeforeRun'', getString(message(''slrealtime:appdesigner:OpenBeforeRun'')));';



        idx=find(contains(code.StartupCallback.Code,'%<SLRT_TOKEN>'));
        code.StartupCallback.Code=...
        {...
        code.StartupCallback.Code{1:idx-1},...
        slrtTokenCode{:},...
        code.StartupCallback.Code{idx+1:end}...
        }';%#ok



        appdata.code=code;
        appdata.components=components;
        appMetadata=fileReader.readAppMetadata();
        fileWriter=appdesigner.internal.serialization.FileWriter(instPanelFile);
        fileWriter.writeMLAPPFile(matlabCodeText,appdata,appMetadata);

    catch ME




        for i=1:numel(filesToCreate)
            delete(filesToCreate{i});
        end
        for i=1:numel(filesToRestoreOnError)
            movefile(filesToRestoreOnError{i}.tempFile,filesToRestoreOnError{i}.origFile);
        end

        this.errorDlg(...
        'slrealtime:appdesigner:NewInstrumentError',...
        ME.message);
        return;
    end

    delete(dlg);



    for i=1:numel(filesToRestoreOnError)
        delete(filesToRestoreOnError{i}.tempFile);
    end



    files='';
    for i=1:numel(filesToCreate)
        files=[files,sprintf('\t%s',filesToCreate{i}),newline];%#ok
    end
    msg=getString(message('slrealtime:appdesigner:FilesCreated',outputDir,files));
    function closeCB(e)
        if e.SelectedOptionIndex==2
            open(instPanelFile);
        end
    end
    uiconfirm(this.getUIFigure(),...
    msg,this.Success_msg,...
    'Options',{this.OK_msg,this.OpenInAppDes_msg},...
    'DefaultOption',this.OK_msg,...
    'Icon','success',...
    'CloseFcn',@(o,e)closeCB(e));
end
