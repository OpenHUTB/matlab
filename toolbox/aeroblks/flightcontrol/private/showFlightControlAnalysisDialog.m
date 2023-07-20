function[objOut,nameOut,returnFlag,varargout]=...
    showFlightControlAnalysisDialog(modelToAnalyze,menuName)








    inputString=getInputStrings();

    switch menuName
    case 'trim'
        [objOut,nameOut,returnFlag]=getFQdialog(modelToAnalyze,inputString(1),...
        'opcond.OperatingSpec',1,1);
    case 'linearize'
        [objOut,nameOut,returnFlag]=getFQdialog(modelToAnalyze,inputString(2),...
        'opcond',1,1);
    case 'computeLonFQs'
        [objOut,nameOut,returnFlag]=getFQdialog(modelToAnalyze,inputString(3),...
        'ss',0,1);
    case 'computeLatFQs'
        [objOut,nameOut,returnFlag]=getFQdialog(modelToAnalyze,inputString(4),...
        'ss',0,1);
    case 'inputInit'
        [objOut,nameOut,returnFlag,varargout{1}]=getFQdialog(modelToAnalyze,...
        inputString(5),'opcond.OperatingPoint',1,0);
    otherwise
        error(message('aeroblks_flightcontrol:aeroblkflightcontrol:InvalidEntry'));
    end
end




function[varOut,varName,returnFlag,varOutName]=getFQdialog(modelToAnalyze,...
    inputString,classToShow,showTrimButton,showOutVar)
    varOut=[];wkspVarList=[];varName='';returnFlag=0;varOutName='';

    dialogMain=dialog('Visible','off','Units','points','Position',[1,1,300,250],'Name',...
    inputString.Title,'DeleteFcn',@cancel_callback);
    movegui(dialogMain,'center');dialogMain.Visible='on';

    if showTrimButton
        uicontrol('Parent',dialogMain,'Units','points','Position',[18.75,11.25,112.5,22.5],'String',...
        getString(message('aeroblks_flightcontrol:aeroblkflightcontrol:LaunchTrimToolButton')),'Callback',...
        @trim_callback);
    end

    okBtn=uicontrol('Parent',dialogMain,'Units','points','Position',[150.6,11.295,56.475,22.590],...
    'String','Ok','tag','dialogOk','Callback',@ok_callback);

    uicontrol('Parent',dialogMain,'Units','points','Position',[225,11.25,56.25,22.5],'String',...
    'Cancel','tag','dialogCancel','Callback',@cancel_callback);

    uicontrol('Parent',dialogMain,'Style','text','FontWeight','bold','Units','points',...
    'Position',[37.5,165,225,73.75],'HorizontalAlignment','Left','String',...
    inputString.Main,'tag','dialogMainText');

    listBox=uicontrol('Parent',dialogMain,'Style','listbox','Units','points',...
    'Position',[37.5,75,225,93.75],'String',listbox_callback,'HorizontalAlignment','Left',...
    'tag','dialogList');

    if showOutVar

        editBox=uicontrol('Parent',dialogMain,'Style','edit','Units','points',...
        'Position',[150,45,131.25,18.75],'String',inputString.default,'HorizontalAlignment',...
        'Left','tag','dialogVarOut');

        uicontrol('Parent',dialogMain,'Style','text','Units','points','Position',...
        [15,41.25,131.25,18.75],'HorizontalAlignment','Right','String',inputString.varout,...
        'tag','dialogVarOutText');
    end
    uiwait(dialogMain);




    function ok_callback(source,event)%#ok<INUSD>
        varOutName=wkspVarList{get(listBox,'Value')};
        varOut=evalin('base',varOutName);
        if showOutVar
            varName=get(editBox,'String');
        else
            varName=inputString.default;
        end
        delete(dialogMain);
    end

    function cancel_callback(source,event)%#ok<INUSD>
        delete(dialogMain);
        if isempty(varOut)
            returnFlag=1;
        end
        return;
    end

    function trim_callback(source,event)%#ok<INUSD>
        delete(dialogMain);
        returnFlag=1;
        launchTrimTool(modelToAnalyze,0);
    end

    function list=listbox_callback()
        wkspVars=evalin('base','whos');
        wkspVarList={wkspVars.name};
        if strcmp(classToShow,'opCond')
            isWkspVar=(cellfun(@(x)(~isempty(regexpi(x,'opcond.OperatingSpec'))||...
            ~isempty(regexpi(x,'opcond.OperatingPoint'))),{wkspVars.class})');
        else
            isWkspVar=(cellfun(@(x)~isempty(regexpi(x,classToShow)),{wkspVars.class})');
        end
        wkspVarList=wkspVarList(isWkspVar);
        if isempty(wkspVarList)
            list={};
            set(okBtn,'Enable','off');
            warndlg(inputString.novar);
        else
            list=wkspVarList;
        end
    end
end



function inputstring=getInputStrings()
    inputstring(1).Title=getString(message('aeroblks_flightcontrol:aeroblkflightcontrol:TrimTitle'));
    inputstring(2).Title=getString(message('aeroblks_flightcontrol:aeroblkflightcontrol:LinearizeTitle'));
    inputstring(3).Title=getString(message('aeroblks_flightcontrol:aeroblkflightcontrol:FlyingQualitiesTitle'));
    inputstring(4).Title=getString(message('aeroblks_flightcontrol:aeroblkflightcontrol:FlyingQualitiesTitle'));
    inputstring(5).Title=getString(message('aeroblks_flightcontrol:aeroblkflightcontrol:InitializeTitle'));
    inputstring(1).Main=getString(message('aeroblks_flightcontrol:aeroblkflightcontrol:TrimMain'));
    inputstring(2).Main=getString(message('aeroblks_flightcontrol:aeroblkflightcontrol:LinearizeMain'));
    inputstring(3).Main=getString(message('aeroblks_flightcontrol:aeroblkflightcontrol:FlyingQualitiesMain'));
    inputstring(4).Main=getString(message('aeroblks_flightcontrol:aeroblkflightcontrol:FlyingQualitiesMain'));
    inputstring(5).Main=getString(message('aeroblks_flightcontrol:aeroblkflightcontrol:InitializeMain'));
    inputstring(1).novar=getString(message('aeroblks_flightcontrol:aeroblkflightcontrol:TrimNoVarMsg'));
    inputstring(2).novar=getString(message('aeroblks_flightcontrol:aeroblkflightcontrol:LinearizeNoVarMsg'));
    inputstring(3).novar=getString(message('aeroblks_flightcontrol:aeroblkflightcontrol:FlyingQualitiesNoVarMsg'));
    inputstring(4).novar=getString(message('aeroblks_flightcontrol:aeroblkflightcontrol:FlyingQualitiesNoVarMsg'));
    inputstring(5).novar=getString(message('aeroblks_flightcontrol:aeroblkflightcontrol:InitializeNoVarMsg'));
    inputstring(1).varout=getString(message('aeroblks_flightcontrol:aeroblkflightcontrol:TrimVarOut'));
    inputstring(2).varout=getString(message('aeroblks_flightcontrol:aeroblkflightcontrol:LinearizeVarOut'));
    inputstring(3).varout=getString(message('aeroblks_flightcontrol:aeroblkflightcontrol:FlyingQualitiesVarOut'));
    inputstring(4).varout='Not Used';
    inputstring(1).default='opTrim';
    inputstring(2).default='linSys';
    inputstring(3).default='lonFQ';
    inputstring(4).default='latFQ';
    inputstring(5).default='Not Used';
end
