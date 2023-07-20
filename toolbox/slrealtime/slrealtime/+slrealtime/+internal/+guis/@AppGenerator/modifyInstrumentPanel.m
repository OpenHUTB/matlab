function modifyInstrumentPanel(this)





    onCleanups=onCleanup.empty;

    try

        [filename,pathname]=uigetfile(...
        {'*.mlapp','MATLAB App (*.mlapp)'},...
        this.SelectMLAPPFile_msg);


        this.bringToFront();


        if~isequal(filename,0)&&~isequal(pathname,0)
            instPanelFile=fullfile(pathname,filename);
        else

            this.infoDlg('slrealtime:appdesigner:NoMLAPPFileModified');
            return;
        end



        dlg=uiprogressdlg(...
        this.getUIFigure(),...
        'Indeterminate','on',...
        'Message',this.GenerateDlgMsg_msg,...
        'Title',this.GenerateDlgTitle_msg);
        onCleanups(end+1)=onCleanup(@()delete(dlg));



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



        if~isfield(code,'StartupCallback')
            slrealtime.internal.throw.Error('slrealtime:appdesigner:MLAPPNoStartupFcn');
        end




        uifigureName='UIFigure';
        appArgName='app';
        compAllAddedUIComponentsGrid=components.(uifigureName);
        gridComp=components.(uifigureName);
        targetSelectorVarName='targetSelector';

        slrtTokenCode={};







        bindingData=this.BindingData(this.BindingTable.Selection);
        compMap=containers.Map('KeyType','char','ValueType','any');

        [controlNames,controlTypes]=this.getControlNamesAndTypes(bindingData);
        this.checkControlNames(controlNames,components);

        for nControl=1:length(controlNames)
            switch controlTypes{nControl}
            case 'Edit Field (numeric)'
                comp=uieditfield(compAllAddedUIComponentsGrid,'numeric');
            case 'Edit Field (text)'
                comp=uieditfield(compAllAddedUIComponentsGrid,'text');
            case 'Gauge'
                comp=uigauge(compAllAddedUIComponentsGrid,'circular');
            case '90 Degree Gauge'
                comp=uigauge(compAllAddedUIComponentsGrid,'ninetydegree');
            case 'Linear Gauge'
                comp=uigauge(compAllAddedUIComponentsGrid,'linear');
            case 'Semicircular Gauge'
                comp=uigauge(compAllAddedUIComponentsGrid,'semicircular');
            case 'Lamp'
                comp=uilamp(compAllAddedUIComponentsGrid);
            case 'Axes'
                comp=uiaxes(compAllAddedUIComponentsGrid);
            case 'Knob'
                comp=uiknob(compAllAddedUIComponentsGrid);
            case 'Slider'
                comp=uislider(compAllAddedUIComponentsGrid);
            case 'Parameter Table'
                comp=slrealtime.ui.control.ParameterTable(gridComp);
                slrtTokenCode{end+1}=['            ',appArgName,'.',controlNames{nControl},'.TargetSource = ',targetSelectorVarName,';'];%#ok
            case 'Signal Table'
                comp=slrealtime.ui.control.SignalTable(gridComp);
                slrtTokenCode{end+1}=['            ',appArgName,'.',controlNames{nControl},'.TargetSource = ',targetSelectorVarName,';'];%#ok
            otherwise
                continue;
            end
            if this.PropsMap.isKey(controlNames{nControl})
                this.copyPropValues(this.PropsMap(controlNames{nControl}),comp);
            end

            comp.Position(1)=comp.Position(1)+(10*nControl);
            comp.Position(2)=comp.Position(2)+(10*nControl);

            this.addDesignTimeProperties(comp,controlNames(nControl));
            compMap(controlNames{nControl})=comp;
            comp=[];%#ok
        end
        slrtTokenCode{end+1}='';



        [guiInstrument,nSignals,tooltipCode,~]=this.createInstrument(bindingData,compMap,appArgName);
        slrtTokenCode{end+1}='            hInst = slrealtime.Instrument();';
        slrtTokenCode{end+1}='';
        slrtTokenCode=[slrtTokenCode,tooltipCode];
        slrtTokenCode{end+1}='';



        bindingCode=this.createBindingCode(guiInstrument,bindingData,nSignals,uifigureName,appArgName,targetSelectorVarName);
        slrtTokenCode=[slrtTokenCode,bindingCode];

        slrtTokenCode{end+1}=['            slrtInstrumentsComponent = slrealtime.ui.tool.InstrumentManager(',appArgName,'.',uifigureName,', ''TargetSource'', ',targetSelectorVarName,');'];
        slrtTokenCode{end+1}='            slrtInstrumentsComponent.Instruments = hInst;';



        matlabCodeText='error(''slrealtime:appdesigner:OpenBeforeRun'', getString(message(''slrealtime:appdesigner:OpenBeforeRun'')));';



        code.StartupCallback.Code=...
        {...
        code.StartupCallback.Code{:},...
        slrtTokenCode{:}
        }';%#ok



        appdata.code=code;
        appdata.components=components;
        appMetadata=fileReader.readAppMetadata();
        fileWriter=appdesigner.internal.serialization.FileWriter(instPanelFile);
        fileWriter.writeMLAPPFile(matlabCodeText,appdata,appMetadata);

    catch ME
        this.errorDlg(...
        'slrealtime:appdesigner:NewInstrumentError',...
        ME.message);
        return;
    end

    delete(dlg);



    msg=getString(message('slrealtime:appdesigner:FilesModified',instPanelFile));
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
