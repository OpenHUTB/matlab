function link(explorerFigureHandle,setLinked)




    if isempty(explorerFigureHandle)||~(explorerFigureHandle.isvalid)
        return;
    end

    persistent pData;

    if isempty(pData)
        iconDir=fullfile(matlabroot,'toolbox','physmod','common','logging','sli','m','resources','icons');
        linkIcon=fullfile(iconDir,'linked.png');
        unlinkIcon=fullfile(iconDir,'unlinked.png');
        pData.link.icon=javax.swing.ImageIcon(linkIcon);
        pData.link.toolTip=getMessageFromCatalog('UnlinkExplorer');
        pData.unlink.icon=javax.swing.ImageIcon(unlinkIcon);
        pData.unlink.toolTip=getMessageFromCatalog('LinkExplorer');

    end

    button=lGetLinkButton(explorerFigureHandle);

    if setLinked
        icon=pData.link.icon;
        tooltip=pData.link.toolTip;
        previouslyLinkedExplorerHandle=simscape.logging.internal.linkedExplorerHandle();
        if~isempty(previouslyLinkedExplorerHandle)&&previouslyLinkedExplorerHandle.isvalid
            otherButton=lGetLinkButton(previouslyLinkedExplorerHandle);
            otherButton.setSelected(false);
            otherButton.setIcon(pData.unlink.icon);
            otherButton.setToolTipText(pData.unlink.toolTip);
        end
        simscape.logging.internal.linkedExplorerHandle(explorerFigureHandle);
    else
        icon=pData.unlink.icon;
        tooltip=pData.unlink.toolTip;
        simscape.logging.internal.linkedExplorerHandle([]);
    end
    button.setIcon(icon);
    button.setToolTipText(tooltip);

end

function button=lGetLinkButton(explorerFigureHandle)
    ud=get(explorerFigureHandle,'UserData');


    panels=ud.navPanel.getComponents;
    buttons=panels(1).getComponents;


    button=buttons(4);
end
