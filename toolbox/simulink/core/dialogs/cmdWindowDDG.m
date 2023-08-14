function cmdWindow=cmdWindowDDG(hObj)











    userData.ws=get_workspace(hObj);
    userData.nodeName=get_nodename(hObj);
    userData.url=get_url(hObj);
    userData.prompt='>>';
    userData.title=get_title(hObj);


    logArea.Name='cmdHistory';
    logArea.Tag='cmdWebbrowser';
    logArea.Type='webbrowser';
    logArea.WebKit=1;
    logArea.ClearCache=true;
    logArea.DialogRefresh=1;
    logArea.Mode=1;
    logArea.Url=userData.url;
    logArea.RowSpan=[1,1];
    logArea.ColSpan=[1,1];
    logArea.Enabled=1;


    cmdEdit.Name=userData.prompt;
    cmdEdit.Tag='cmdEdit';
    cmdEdit.Type='edit';
    cmdEdit.RowSpan=[2,2];
    cmdEdit.ColSpan=[1,1];
    cmdEdit.Visible=1;
    cmdEdit.Mode=1;
    cmdEdit.Value='';
    cmdEdit.DialogRefresh=1;
    cmdEdit.MatlabMethod='cmdWindowDDG_cb';
    cmdEdit.Graphical=1;
    cmdEdit.MatlabArgs={'%dialog','%value',...
    userData};



    cmdWindow.Name=userData.title;
    cmdWindow.Type='group';
    cmdWindow.LayoutGrid=[2,1];
    cmdWindow.RowStretch=[1,0];
    cmdWindow.Items={logArea,cmdEdit};
    cmdWindow.BackgroundColor=[255,255,255];
end





function ws=get_workspace(hObj)
    if isa(hObj,'Simulink.Root')
        ws='base';
    elseif isa(hObj,'Simulink.BlockDiagram')
        ws=hObj.getWorkspace;
    elseif isa(hObj,'Simulink.DataDictionaryScopeNode')
        strCell=strsplit(hObj.getFullName,'''');
        ddPath=strCell{2};
        dd=Simulink.data.dictionary.open(ddPath);
        wsName=hObj.getDisplayLabel;
        ws=dd.getSection(wsName);
    else
        ws='';
        warning('Invalid Simulink node name');
    end
end

function nodeName=get_nodename(hObj)
    if isa(hObj,'Simulink.Root')
        nodeName='Base';
    elseif isa(hObj,'Simulink.BlockDiagram')
        nodeName='Model';
    elseif isa(hObj,'Simulink.DataDictionaryScopeNode')
        nodeName='DD';
    else
        nodeName='';
        warning('Invalid Simulink node name');
    end
end

function url=get_url(hObj)
    if isa(hObj,'Simulink.Root')
        filePath='';
        preUrl='logBW';
    elseif isa(hObj,'Simulink.BlockDiagram')
        filePath=hObj.FileName;
        preUrl='logMDL';
    elseif isa(hObj,'Simulink.DataDictionaryScopeNode')
        switch hObj.getDisplayLabel
        case 'Design Data'
            preUrl='logDSG';
        case 'Configurations'
            preUrl='logCFG';
        case 'Other Data'
            preUrl='logOTH';
        end
        tmpStr=hObj.getFullName;
        strCell=strsplit(tmpStr,'''');
        filePath=strCell{2};
    else
        preUrl='logTmp';
        filePath='';
        warning('Invalid Simulink node name');
    end

    if(~isempty(filePath))
        [pathStr,name,~]=fileparts(filePath);
        filePath=fullfile(pathStr,name);
    end

    pidStr=num2str(feature('getpid'));
    path=tempdir;
    filePath=strrep(filePath,filesep,'_');
    filePath=strrep(filePath,'.','_');
    filePath=strrep(filePath,':','_');
    url=fullfile(path,[preUrl,pidStr,filePath,'.html']);
end

function title=get_title(hObj)
    if isa(hObj,'Simulink.Root')
        title=DAStudio.message('Simulink:dialog:WorkspaceRootDlgStructDialogTitle');
    elseif isa(hObj,'Simulink.BlockDiagram')
        title=[hObj.Name,': '...
        ,DAStudio.message('Simulink:dialog:WorkspaceDlgStructDialogTitle')];
    elseif isa(hObj,'Simulink.DataDictionaryScopeNode')
        nameCell=strsplit(hObj.getSourceName,'.');
        title=[nameCell{1},': ',hObj.getDisplayLabel];
    else
        title='';
        warning('Invalid Simulink node name');
    end
end
