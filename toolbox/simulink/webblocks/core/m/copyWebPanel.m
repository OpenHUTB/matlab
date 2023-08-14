function copyWebPanel(blockDiagramHandle,panelHandle,panelId,positionJson)


    if(~isnumeric(blockDiagramHandle))
        blockDiagramHandle=str2double(blockDiagramHandle);
    end
    model=get(bdroot(blockDiagramHandle),'object');


    newSubSystemPath=getUniqueWebBlockPath(model.Path,'untitledPanel');


    panelPath=getfullname(str2double(panelHandle));
    panelSubsystemPath=regexprep(panelPath,'/panelInfo$','');


    sourceWebBlocksList=SLM3I.SLDomain.getPanelWidgets(panelId);


    for n=1:length(sourceWebBlocksList)
        webblock=strsplit(sourceWebBlocksList{n},'/');
        sourceWebBlocksList{n}=strcat(newSubSystemPath,'/',webblock{length(webblock)});
    end


    add_block(panelSubsystemPath,newSubSystemPath,...
    'IsWebBlockPanel','on',...
    'Position',[100,100,100,100],...
    'Tag','HiddenForWebPanel',...
    'ShowName','off',...
    'ContentPreviewEnabled','off');


    panelId=SLM3I.SLDomain.generateWebPanelId();
    panelInfoPath=strcat(newSubSystemPath,'/panelInfo');

    panelInfo=jsondecode(get_param(panelInfoPath,'PanelInfo'));


    panelInfo.panelId=panelId;
    panelInfo.name=getUniqueWebPanelName(blockDiagramHandle,panelInfo.name);


    if(isfield(panelInfo,'labels'))
        copiedLabels=struct();
        originalLabelIds=fieldnames(panelInfo.labels);
        for i=1:numel(originalLabelIds)

            newLabelId=['label',num2str(floor((1+rand())*10^10))];
            copiedLabels.(newLabelId)=panelInfo.labels.(originalLabelIds{i});
        end
        panelInfo.labels=copiedLabels;
    end


    position=jsondecode(positionJson);
    panelInfo.top=position.top;
    panelInfo.left=position.left;


    panelInfo.zIndex=-1;



    if(isfield(panelInfo,'tabbedSetId'))
        panelInfo=rmfield(panelInfo,'tabbedSetId');
        panelInfo=rmfield(panelInfo,'tabIndex');
        panelInfo=rmfield(panelInfo,'isActiveTab');
    end


    set_param(panelInfoPath,'PanelInfo',jsonencode(panelInfo));


    for n=1:length(sourceWebBlocksList)
        webblock=sourceWebBlocksList{n};
        panelInfo=jsondecode(get_param(webblock,'PanelInfo'));
        panelInfo.panelId=panelId;
        set_param(webblock,'PanelInfo',jsonencode(panelInfo));
    end


    if(~isnumeric(blockDiagramHandle))
        blockDiagramHandle=str2double(blockDiagramHandle);
    end
    SLM3I.SLDomain.ensurePanelBlocksAreRegistered(blockDiagramHandle);
end