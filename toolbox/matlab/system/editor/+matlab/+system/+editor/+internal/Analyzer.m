classdef Analyzer




    properties(Constant)
        DefaultWidth=250;
        MinDefaultHeight=250;
        MaxDefaultHeight=700;
        MinWidth=200;
        MinHeight=150;
    end

    methods(Static)
        function[analyzer,URL]=launch(analyzer,document,varargin)

            import matlab.internal.lang.capability.Capability;
            p=inputParser;
            p.addParameter('LaunchWebWindow',true);
            p.addParameter('UseDebug',false);
            p.parse(varargin{:});
            results=p.Results;

            filePath=document.Filename;

            if isfield(analyzer,'Window')
                window=analyzer.Window;
                channel=analyzer.Channel;
            else
                window=[];
                channel=[];
            end



            connector.ensureServiceOn;

            if isValidAnalyzerHandle(window)
                id=channel.clientId;
                if~window.isVisible


                    matlab.system.editor.internal.DocumentAction.updateAnalyzer(filePath,false);
                end
                window.bringToFront;
                URL=getAnalyzerURL(id,results.UseDebug);
            else
                [~,id]=fileparts(tempname);


                channel.clientId=id;
                launchWindow=results.LaunchWebWindow;
                channel.subscription=message.subscribe(['/matlab/system/editor/analyzer/',id,'/ready'],...
                @(msg)onAnalyzerReady(msg,document,launchWindow));


                URL=getAnalyzerURL(id,results.UseDebug);
                if launchWindow



                    defaultPosition=[0,0,...
                    matlab.system.editor.internal.Analyzer.DefaultWidth,...
                    matlab.system.editor.internal.Analyzer.MinDefaultHeight];
                    remoteDebuggingPort=matlab.internal.getDebugPort;

                    if Capability.isSupported(Capability.LocalClient)
                        window=matlab.internal.webwindow(URL,remoteDebuggingPort,defaultPosition);
                    else

                        window=matlab.internal.webwindow(URL);
                        window.Position=defaultPosition;
                        window.show();
                    end
                else
                    window=getAnalyzerTestVersionKey;
                end

                analyzer.Channel=channel;
                analyzer.Window=window;
            end
        end

        function viewHelp
            helpview([docroot,'/matlab/helptargets.map'],'sysobj_analyzer','CSHelpWindow');
        end

        function publishSysObjUpdateStatus(clientId,info)

            if(~isempty(clientId))
                message.publish(['/matlab/system/editor/analyzer/',clientId,'/update'],info);
            end
        end


        function analyzer=refresh(analyzer,filePath,mt,sysobjMethodInfo,customMethodInfo)


            if~isfield(analyzer,'Window')
                return
            end

            window=analyzer.Window;
            if(isValidAnalyzerHandle(window)&&window.isVisible)||isTestVersion(window)
                id=analyzer.Channel.clientId;
                publishUpdate(filePath,id,mt,sysobjMethodInfo,customMethodInfo,false);
            end
        end

        function analyzer=analyzerError(analyzer)
            if~isfield(analyzer,'Window')
                return
            end

            window=analyzer.Window;
            if(isValidAnalyzerHandle(window)&&window.isVisible)||isTestVersion(window)
                id=analyzer.Channel.clientId;
                publishError(id);
            end
        end

        function update(filePath,analyzer,mt,sysobjMethodInfo,customMethodInfo,isLaunch)
            publishUpdate(filePath,analyzer.Channel.clientId,mt,sysobjMethodInfo,customMethodInfo,isLaunch);
        end

        function updateStatus(analyzer)
            if~isempty(analyzer)
                publishUpdateStatus(analyzer.Channel.clientId);
            end
        end

        function analyzer=show(analyzer,document,height)
            if isfield(analyzer,'Window')&&isValidAnalyzerHandle(analyzer.Window)
                window=analyzer.Window;

                window.setMinSize([matlab.system.editor.internal.Analyzer.MinWidth,...
                matlab.system.editor.internal.Analyzer.MinHeight]);

                updateTitle(window,document.Filename);

                window.CustomWindowClosingCallback=@(evt,src)hide(window);

                if isa(document.Editor,'matlab.desktop.editor.RtcEditorDocument')
                    window.Position=getAnalyzerPositionForLiveEditorClient(document,height);
                elseif isa(document.Editor,'matlab.desktop.editor.MotwEditorDocument')
                    window.Position=getAnalyzerPositionForMotw(height);
                else
                    window.Position=getAnalyzerPosition(document,height);
                end

                window.bringToFront;
            end
        end

        function analyzer=onFilePathChanged(analyzer,newFilePath,mt,sysobjMethodInfo,customMethodInfo)
            if~(isfield(analyzer,'Window')&&isValidAnalyzerHandle(analyzer.Window))
                return
            end
            updateTitle(analyzer.Window,newFilePath);
            matlab.system.editor.internal.Analyzer.refresh(analyzer,newFilePath,mt,sysobjMethodInfo,customMethodInfo);
        end

        function info=getAnalysisInfo(filePath,mt,sysobjMethodInfo,customMethodInfo)


            infoGroups=struct('Title',{},'Rows',{});

            escapedFilePath=mat2str(filePath);
            [superClassInfo]=matlab.system.editor.internal.SuperClassAction.getAnalysisInfo(mt);

            infoGroups=[infoGroups,createInfoGroup(superClassInfo,escapedFilePath,'MATLAB:system:Editor:AnalyzerSuperClassTitle')];

            [inputInfo,outputInfo]=matlab.system.editor.internal.IOAction.getAnalysisInfo(mt);
            infoGroups=[infoGroups,createInfoGroup(inputInfo,escapedFilePath,'MATLAB:system:Editor:AnalyzerInputsTitle'),...
            createInfoGroup(outputInfo,escapedFilePath,'MATLAB:system:Editor:AnalyzerOutputsTitle')];

            [publicPropertiesInfo,restrictedPropertiesInfo,stateInfo]=matlab.system.editor.internal.PropertyAction.getAnalysisInfo(mt);
            infoGroups=[infoGroups,createInfoGroup(publicPropertiesInfo,escapedFilePath,'MATLAB:system:Editor:AnalyzerPublicProperties'),...
            createInfoGroup(restrictedPropertiesInfo,escapedFilePath,'MATLAB:system:Editor:AnalyzerRestrictedProperties'),...
            createInfoGroup(stateInfo,escapedFilePath,'MATLAB:system:Editor:AnalyzerStatesTitle')];



            sysobjMethodInfo=matlab.system.editor.internal.MethodAction.addLegacyInfo(mt,sysobjMethodInfo);

            infoGroups=[infoGroups,createInfoGroup(sysobjMethodInfo,escapedFilePath,'MATLAB:system:Editor:AnalyzerSystemObjectMethodsTitle'),...
            createInfoGroup(customMethodInfo,escapedFilePath,'MATLAB:system:Editor:AnalyzerCustomMethodsTitle')];

            info=struct(...
            'Name',matlab.system.editor.internal.getClassNameFromFile(filePath),...
            'Groups',infoGroups);
        end

        function analyzer=cleanup(analyzer)
            if isfield(analyzer,'Channel')&&~isempty(analyzer.Channel)
                id=analyzer.Channel.clientId;
                message.unsubscribe(analyzer.Channel.subscription);
                message.publish(['/matlab/system/editor/analyzer/',id,'/update'],'stop');
                analyzer.Channel=[];
            end

            if isfield(analyzer,'Window')&&isValidAnalyzerHandle(analyzer.Window)
                delete(analyzer.Window);
                analyzer.Window=[];
            end
        end
    end
end

function group=createInfoGroup(info,escapedFilePath,groupTitleID)
    if~isempty(info)
        infoRows=struct('Name',{},'GotoFcn',{},'Legacy',{});
        for k=1:numel(info)
            data=info(k);

            if~ismember('Legacy',fieldnames(data))
                data.Legacy=false;
            end
            infoRows(end+1)=struct('Name',data.Name,...
            'GotoFcn',createGotoFcn(escapedFilePath,data.Position),'Legacy',data.Legacy);%#ok<*AGROW>
        end
        group=struct('Title',message(groupTitleID).getString(),...
        'Rows',infoRows);
    else
        group=struct('Title',{},'Rows',{});
    end
end

function fcn=createGotoFcn(escapedFilePath,pos)
    fcn=sprintf('matlab.system.editor.internal.DocumentAction.goto(%s,[%u,%u])',...
    escapedFilePath,pos(1),pos(2));
end

function onAnalyzerReady(msg,document,isLaunch)


    try

        if isempty(document)||~document.Opened
            return;
        end

        if ischar(msg)

            matlab.system.editor.internal.DocumentAction.updateAnalyzer(document.Filename,isLaunch);
        else


            matlab.system.editor.internal.DocumentAction.showAnalyzer(document.Filename,msg);
        end
    catch e

        matlab.system.editor.internal.DocumentAction.abortedAnalyzerLaunch(document.Filename,e);
    end
end

function publishUpdateStatus(clientId)

    message.publish(['/matlab/system/editor/analyzer/',clientId,'/update'],"success");
end

function info=publishUpdate(filePath,clientId,mt,sysobjMethodInfo,customMethodInfo,isLaunch)

    try
        info=matlab.system.editor.internal.Analyzer.getAnalysisInfo(filePath,mt,sysobjMethodInfo,customMethodInfo);
        info.IsLaunch=isLaunch;
        groupInfo=info.Groups;
        groupIndex=find(strcmp({groupInfo.Title},message('MATLAB:system:Editor:AnalyzerSystemObjectMethodsTitle').getString));
        if~isempty(groupIndex)
            rowInfo=info.Groups(groupIndex).Rows;
            rowIndex=find(strcmp({rowInfo.Name},'System object constructor'));
            if~isempty(rowIndex)

                info.Groups(groupIndex).Rows(rowIndex).Name=matlab.system.editor.internal.ParseTreeUtils.getClassName(mt);
            end
        end


        info.FilePath=filePath;
        message.publish(['/matlab/system/editor/analyzer/',clientId,'/update'],info);
    catch e
        publishError(clientId);
        rethrow(e);
    end
end

function updateTitle(window,filePath)

    if isTestVersion(window)
        return
    end

    systemName=matlab.system.editor.internal.getClassNameFromFile(filePath);
    window.Title=message('MATLAB:system:Editor:AnalyzerTitle',systemName).getString();
end

function isValidAnalyzer=isValidAnalyzerHandle(analyzer)
    isValidAnalyzer=~isempty(analyzer)&&...
    ~isTestVersion(analyzer)&&...
    isvalid(analyzer)&&...
    analyzer.isWindowValid;
end

function testVer=getAnalyzerTestVersionKey
    testVer='testversion';
end

function isTestVer=isTestVersion(analyzer)
    isTestVer=ischar(analyzer)&&strcmp(analyzer,getAnalyzerTestVersionKey);
end

function publishError(id)
    message.publish(['/matlab/system/editor/analyzer/',id,'/update'],'error');
end

function URL=getAnalyzerURL(clientId,useDebug)

    if~useDebug&&exist(fullfile(matlabroot,'toolbox','matlab','system','editor','analyzer','release'),'dir')
        htmlPage='index.html';
    else
        htmlPage='index-debug.html';
    end
    URL=connector.getUrl(['/toolbox/matlab/system/editor/analyzer/',...
    htmlPage,'?clientid=',clientId]);
end

function dialogPos=getAnalyzerPosition(document,contentHeight)



    je=document.JavaEditor.getComponent;
    rootPane=je.getRootPane;
    dialogPos=computeDialogPositionFromDocumentPane(rootPane,contentHeight);
end

function dialogPos=computeDialogPositionFromDocumentPane(rootPane,contentHeight)
    editorW=rootPane.getWidth;
    editorH=rootPane.getHeight;
    editorLocationOnScreen=rootPane.getLocationOnScreen;
    editorX=editorLocationOnScreen.getX;
    editorY=editorLocationOnScreen.getY;

    bounds=rootPane.getBounds;
    borderX=bounds.getX;
    borderY=bounds.getY;

    dialogPos=getAnalyzerPositionUsingPositionalParameters(editorW,editorH,editorX,editorY,borderX,borderY,contentHeight);
end

function dialogPos=getAnalyzerPositionForLiveEditorClient(document,contentHeight)
    rootPane=document.Editor.LiveEditorClient.getRootPane();
    dialogPos=computeDialogPositionFromDocumentPane(rootPane,contentHeight);
end

function dialogPos=getAnalyzerPositionUsingPositionalParameters(editorW,editorH,editorX,editorY,borderX,borderY,contentHeight)

    dialogW=matlab.system.editor.internal.Analyzer.DefaultWidth;
    dialogH=max(matlab.system.editor.internal.Analyzer.MinDefaultHeight,...
    min(contentHeight,matlab.system.editor.internal.Analyzer.MaxDefaultHeight));


    screenSize=get(groot,'ScreenSize');
    screenX=screenSize(1);
    screenY=screenSize(2);
    screenW=screenSize(3);
    screenH=screenSize(4);


    dialogW=min(dialogW,screenW-borderX);
    dialogH=min(dialogH,screenH-borderY);



    minX=screenX+borderX;
    maxX=screenX+screenW-dialogW-borderX;
    dialogPos(1)=min(maxX,max(minX,editorX+(editorW-dialogW)/2));

    minY=screenY+borderY;
    maxY=screenY+screenH-dialogH-borderY;
    dialogPos(2)=min(maxY,max(minY,screenH-editorY-dialogH-(editorH-dialogH)/2));

    dialogPos(3)=dialogW;
    dialogPos(4)=dialogH;
end

function dialogPos=getAnalyzerPositionForMotw(contentHeight)

    dialogPos=get(groot,'DefaultFigurePosition');
    dialogPos(3)=matlab.system.editor.internal.Analyzer.DefaultWidth;
    screenSize=get(groot,'ScreenSize');
    dialogH=max(matlab.system.editor.internal.Analyzer.MinDefaultHeight,...
    min(contentHeight,matlab.system.editor.internal.Analyzer.MaxDefaultHeight));

    dialogH=min([dialogH,screenSize(4),500]);
    dialogPos(4)=dialogH;
end
