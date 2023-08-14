function promoteBlocksToWebPanel(editor,elements)


    rootStudioBlockDiagramHandle=editor.getStudio().App.blockDiagramHandle;
    if(editor.blockDiagramHandle~=rootStudioBlockDiagramHandle)
        notificationTag='ModelReferenceCannotPromote';
        notification=message('simulink_ui:webblocks:resources:ModelReferenceCannotPromote').getString();
        editor.deliverInfoNotification(notificationTag,notification);
        return;
    end

    DEFAULT_PADDING=20;
    SEPERATOR=";";

    count=0;
    webBlocks={};
    boundingBox={};
    for i=1:length(elements)
        element=elements{i};
        if(SLM3I.Util.isValidDiagramElement(element)&&isa(element,'SLM3I.Block')&&...
            strcmp(get_param(element.handle,'isCoreWebBlock'),'on'))


            packedBrowserPosition=SLM3I.SLDomain.getWebBlockBrowserPosition(editor,element.handle);
            strBrowserPos=strsplit(packedBrowserPosition,SEPERATOR);
            blockBrowserPos.left=str2double(strBrowserPos{1});
            blockBrowserPos.top=str2double(strBrowserPos{2});
            blockBrowserPos.width=str2double(strBrowserPos{3});
            blockBrowserPos.height=str2double(strBrowserPos{4});
            blockBrowserPos.right=blockBrowserPos.left+blockBrowserPos.width;
            blockBrowserPos.bottom=blockBrowserPos.top+blockBrowserPos.height;

            if(count==0)
                boundingBox.left=blockBrowserPos.left;
                boundingBox.top=blockBrowserPos.top;
                boundingBox.right=blockBrowserPos.right;
                boundingBox.bottom=blockBrowserPos.bottom;
            else
                boundingBox.left=min(boundingBox.left,blockBrowserPos.left);
                boundingBox.top=min(boundingBox.top,blockBrowserPos.top);
                boundingBox.right=max(boundingBox.right,blockBrowserPos.right);
                boundingBox.bottom=max(boundingBox.bottom,blockBrowserPos.bottom);
            end

            count=count+1;
            webBlocks{count}=struct(...
            'element',element,...
            'blockBrowserPos',blockBrowserPos...
            );%#ok
        end
    end


    panelPosition=[
    boundingBox.left-DEFAULT_PADDING...
    ,boundingBox.top-DEFAULT_PADDING...
    ,boundingBox.right-boundingBox.left+(DEFAULT_PADDING*2)...
    ,boundingBox.bottom-boundingBox.top+(DEFAULT_PADDING*2)
    ];









    panelInfoHandle=createWebPanel(rootStudioBlockDiagramHandle,panelPosition);

    BORDER_ADJUSTMENT=2;
    placementOrigin=struct(...
    'left',DEFAULT_PADDING-BORDER_ADJUSTMENT,...
    'top',DEFAULT_PADDING-BORDER_ADJUSTMENT);

    for i=1:count

        entry=webBlocks{i};

        blockOffset=struct(...
        'left',entry.blockBrowserPos.left-boundingBox.left,...
        'top',entry.blockBrowserPos.top-boundingBox.top...
        );
        moveBlockToPanel(entry.element.handle,...
        placementOrigin.left+blockOffset.left,...
        placementOrigin.top+blockOffset.top,...
        placementOrigin.left+blockOffset.left+entry.blockBrowserPos.width,...
        placementOrigin.top+blockOffset.top+entry.blockBrowserPos.height,...
        panelInfoHandle,...
        rootStudioBlockDiagramHandle,...
        editor);
    end




    notification='';
    notificationTag='promoteToPanel';
    if(rootStudioBlockDiagramHandle~=editor.blockDiagramHandle)
        notification=message('simulink_ui:webblocks:resources:ModelReferencePromoteToPanel').getString();
        notificationTag='ModelReference';
    end


    if(count~=length(elements))
        if~isempty(notification)
            notification=[notification,' '];
        end
        notification=[notification,message('simulink_ui:webblocks:resources:MarqueeSelectionPromoteToPanel').getString()];
        notificationTag=[notificationTag,'MarqueeSelection'];
    end

    if~isempty(notification)
        notificationTag=[notificationTag,'Notification'];
        editor.deliverInfoNotification(notificationTag,notification);
    end
end
