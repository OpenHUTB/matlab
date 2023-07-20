function demoteBlockFromWebPanel(blockHandle,left,top,width,height,editorWebId)
    if(~isnumeric(blockHandle))
        blockHandle=str2double(blockHandle);
    end


    editorPath=SLM3I.SLDomain.getPathForPanelsEditor(editorWebId);
    if(isempty(editorPath))
        return
    end


    SEPERATOR=";";
    packedScenePosition=SLM3I.SLDomain.getPanelBlockScenePosition(editorWebId,left,top,width,height);
    if(isempty(packedScenePosition))
        return
    end
    strScenePosition=strsplit(packedScenePosition,SEPERATOR);
    blockScenePos.x=str2double(strScenePosition{1});
    blockScenePos.y=str2double(strScenePosition{2});
    blockScenePos.width=str2double(strScenePosition{3});
    blockScenePos.height=str2double(strScenePosition{4});


    blockPath=getfullname(blockHandle);


    newBlockPath=getUniqueWebBlockPath(editorPath,get_param(blockPath,'Name'));



    editor=SLM3I.SLDomain.getEditorForWebId(editorWebId);
    fontSize=get_param(blockHandle,'FontSize');
    if(~isempty(editor)&&~strcmp(get_param(blockHandle,'BlockType'),'CallbackButton'))
        if(fontSize==-1)
            fontSize=10;
        end
        fontSize=fontSize/editor.getZoomFactor();
    end


    add_block(blockPath,newBlockPath,...
    'PanelInfo','',...
    'Tag','',...
    'FontSize',fontSize,...
    'Position',[...
    blockScenePos.x...
    ,blockScenePos.y...
    ,blockScenePos.x+blockScenePos.width...
    ,blockScenePos.y+blockScenePos.height...
    ]);
    delete_block(blockPath);
end
