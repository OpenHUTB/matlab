































function pi=exportDashboardPanel(exportPath,targetConfigs,forEmbedded,editor,panelId,exportedPageTitle)


    if(nargin>3&&~isempty(editor))
        e=editor;
    else
        es=SLM3I.SLDomain.findAllEditors();
        if(isempty(es))
            warning('Expected to find an open editor.');
            error('Export failed.');
        end
        if(length(es)>1)
            warning('Found more than one editor. Only checking the first editor for panel.');
        end
        e=es(1);
    end



    if(nargin>4&&~isempty(panelId))
        pid=panelId;
    else
        pids=SLM3I.SLDomain.getPanelIdsForEditor(e);
        if(isempty(pids))
            warning('Expected to find an open editor with a panel. Found an editor, but it had no panels.');
            error('Export failed.');
        end
        if(length(pids)>1)
            warning('Found more than one panel. Only exporting the first one found.');
        end

        pid=pids{1};
    end
    pp=SLM3I.SLDomain.getPanelInfoWidget(pid);
    if(isempty(pp))
        warning('Passed panelId failed when passed to SLM3I.SLDomain.getPanelInfoWidget.');
        error('Export failed.');
    end
    pi=jsondecode(get_param(pp,'PanelInfo'));


    if(nargin>0)
        disp(['Exporting to ',exportPath,'.']);
    else
        disp('Exporting to current folder. Specify path as arg to export elsewhere.');
    end
    if(nargin<2)
        targetConfigs={};
        forEmbedded=false;
    end
    if(nargin<3)
        forEmbedded=false;
    end


    localConfigPath='localConfig.js';
    if(nargin);localConfigPath=[exportPath,filesep,localConfigPath];end
    fid=fopen(localConfigPath,'w');
    s=SLM3I.SLDomain.getWebManagerInitCmd(e);



    configs=regexp(s,'{dojo.*?}','match');
    configsToKeep={};
    if(~isempty(targetConfigs))
        for i=1:length(configs)
            for j=1:length(targetConfigs)
                if(~isempty(regexp(configs{i},targetConfigs{j},'once')))
                    configsToKeep{end+1}=configs{i};
                    break;
                end
            end
        end
    else
        configsToKeep=configs;
    end
    keptConfigs=strjoin(configsToKeep,',');


    if(forEmbedded)
        keptConfigs=regexprep(keptConfigs,'(dojoBuiltJsPath:.*?)([^\/]*)(\.js'',)','$1$2ForEmbedded$3');
    end

    s=regexprep(s,'configAndStartApp\(.*?\)',['configAndStartApp([',keptConfigs,'])']);
    s=regexprep(s,'\\r','\\\\r');
    s=regexprep(s,'\\n','\\\\n');
    s=append(s,';');
    fprintf(fid,s);
    fclose(fid);


    localDefaultsPath='localDefaults.js';
    if(nargin);localDefaultsPath=[exportPath,filesep,localDefaultsPath];end
    fid=fopen(localDefaultsPath,'w');
    s=SLM3I.SLDomain.getWebManagerDefaultsCmd(e);
    s=regexprep(s,'\\r','\\\\r');
    s=regexprep(s,'\\n','\\\\n');
    s=append(s,';');


    setCanvasSize='webManager.handleCanvasResized(window.innerWidth, window.innerHeight);';
    s=append(s,setCanvasSize);

    fprintf(fid,s);
    fclose(fid);


    localCreatePath='localCreate.js';
    if(nargin);localCreatePath=[exportPath,filesep,localCreatePath];end
    fid=fopen(localCreatePath,'w');
    s=SLM3I.SLDomain.exportDashboardPanel(pid);
    s=regexprep(s,'\\','\\\\');
    s=regexprep(s,'\\r','\\\\r');
    s=regexprep(s,'\\n','\\\\n');
    s=append(s,';');


    panelWidgets=SLM3I.SLDomain.getPanelWidgets(pid);
    panelWidgetsMetaInfo=cell(1,length(panelWidgets));
    for i=1:length(panelWidgets)
        blockHandle=get_param(panelWidgets{i},'handle');
        blockMetaInfo=jsondecode(SLM3I.SLDomain.getWebBlockBrowserInfoJson(e,blockHandle));
        panelWidgetsMetaInfo{i}=blockMetaInfo;
    end



    pageTitle=['''',pi.name,''''];
    if(nargin>5)
        pageTitle=['''',exportedPageTitle,''''];
    end
    showExportedContent=['webManager._postInitForExportedContent(''',jsonencode(panelWidgetsMetaInfo),''', ',pageTitle,');'];
    s=append(s,showExportedContent);

    fprintf(fid,s);
    fclose(fid);

    disp('Panel exported successfully.');
end
