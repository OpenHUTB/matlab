function moveBlockToPanel(blockHandle,left,top,right,bottom,panelInfoHandle,blockDiagramHandle,editor)
    if(~isnumeric(blockHandle))
        blockHandle=str2double(blockHandle);
    end
    if(~isnumeric(panelInfoHandle))
        panelInfoHandle=str2double(panelInfoHandle);
    end

    blockPath=getfullname(blockHandle);
    panelInfoPath=getfullname(panelInfoHandle);
    panelSubsystemPath=regexprep(panelInfoPath,'/panelInfo$','');


    panelInfoJson=get_param(panelInfoPath,'PanelInfo');
    panelInfo=jsondecode(panelInfoJson);
    panelId=panelInfo.panelId;


    name=get_param(blockPath,'Name');
    name=regexprep(name,'/','//');
    newBlockPath=getUniqueWebBlockPath(panelSubsystemPath,name);


    PANEL_INFO_CHILD_TYPE='panelChild';

    panelInfo=struct;
    panelInfo.version=getCurrentPanelVersion();
    panelInfo.panelId=panelId;
    panelInfo.type=PANEL_INFO_CHILD_TYPE;
    panelInfo.left=left;
    panelInfo.top=top;
    panelInfo.width=right-left;
    panelInfo.height=bottom-top;
    panelInfoJson=jsonencode(panelInfo);


    set_param(blockPath,'ClipboardFcn','');
    set_param(blockPath,'CloseFcn','');
    set_param(blockPath,'ContinueFcn','');
    set_param(blockPath,'CopyFcn','');
    set_param(blockPath,'DeleteFcn','');
    set_param(blockPath,'DestroyFcn','');
    set_param(blockPath,'InitFcn','');
    set_param(blockPath,'LoadFcn','');
    set_param(blockPath,'ModelCloseFcn','');
    set_param(blockPath,'MoveFcn','');
    set_param(blockPath,'NameChangeFcn','');
    set_param(blockPath,'OpenFcn','');
    set_param(blockPath,'ParentCloseFcn','');
    set_param(blockPath,'PauseFcn','');
    set_param(blockPath,'PostSaveFcn','');
    set_param(blockPath,'PreCopyFcn','');
    set_param(blockPath,'PreDeleteFcn','');
    set_param(blockPath,'PreSaveFcn','');
    set_param(blockPath,'StartFcn','');
    set_param(blockPath,'StopFcn','');
    set_param(blockPath,'UndoDeleteFcn','');



    fontSize=get_param(blockPath,'fontsize');
    if(isempty(get_param(blockHandle,'PanelInfo')))

        if(~isobject(editor))
            editor=SLM3I.SLDomain.getEditorForWebId(editor);
        end
        if(~isempty(editor)&&~strcmp(get_param(blockPath,'BlockType'),'CallbackButton'))
            blockHandle=get_param(blockPath,'handle');
            blockMetaInfo=jsondecode(SLM3I.SLDomain.getWebBlockBrowserInfoJson(editor,blockHandle));
            if(isfield(blockMetaInfo,'renderedFontSize'))
                fontSize=blockMetaInfo.renderedFontSize;
            end
        end
    end





    add_block(blockPath,newBlockPath,...
    'PanelInfo',panelInfoJson,...
    'Tag','HiddenForWebPanel',...
    'Position',[left,top,right,bottom],...
    'FontSize',fontSize);
    delete_block(blockPath);


    if(~isnumeric(blockDiagramHandle))
        blockDiagramHandle=str2double(blockDiagramHandle);
    end
    SLM3I.SLDomain.ensurePanelBlocksAreRegistered(blockDiagramHandle);
end
