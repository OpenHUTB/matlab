function panelInfoHandle=createWebPanel(blockDiagramHandle,position,otherParams)

    if(~isnumeric(blockDiagramHandle))
        blockDiagramHandle=str2double(blockDiagramHandle);
    end
    model=get(bdroot(blockDiagramHandle),'object');

    panelSubSystemPath=getUniqueWebBlockPath(model.Path,...
    DAStudio.message('simulink_ui:webblocks:resources:PanelDefaultBaseName'));




    add_block('built-in/SubSystem',panelSubSystemPath,...
    'IsWebBlockPanel','on',...
    'Position',[100,100,100,100],...
    'Tag','HiddenForWebPanel',...
    'ShowName','off',...
    'ContentPreviewEnabled','off');


    panelId=SLM3I.SLDomain.generateWebPanelId();
    panelInfoPath=strcat(panelSubSystemPath,'/panelInfo');


    PANEL_INFO_PANEL_TYPE='panel';

    panelInfo=struct;
    panelInfo.name=getUniqueWebPanelName(blockDiagramHandle,'Panel');
    panelInfo.version=getCurrentPanelVersion();
    panelInfo.type=PANEL_INFO_PANEL_TYPE;
    panelInfo.panelId=panelId;
    panelInfo.compacted=false;
    panelInfo.left=position(1);
    panelInfo.top=position(2);
    panelInfo.width=position(3);
    panelInfo.height=position(4);

    if(nargin==3)
        if(isfield(otherParams,'tabbedSetId'))
            panelInfo.tabbedSetId=otherParams.tabbedSetId;
            panelInfo.tabIndex=otherParams.tabIndex;
            panelInfo.isActiveTab=otherParams.isActiveTab;
        end
    end

    panelInfoJson=jsonencode(panelInfo);


    add_block('built-in/PanelWebBlock',panelInfoPath,...
    'PanelInfo',panelInfoJson,...
    'Tag','HiddenForWebPanel');
    panelInfoHandle=getSimulinkBlockHandle(panelInfoPath);


    SLM3I.SLDomain.ensurePanelBlocksAreRegistered(blockDiagramHandle);
end
