function addToRecentSessionFiles(this,fileName,fileFullPath)







    import matlab.ui.internal.toolstrip.*

    recentPopup=this.OpenButton.Popup.getChildByIndex(2).Popup;

    item=[];
    try
        item=recentPopup.getChildByTag(fileFullPath);
    catch
    end
    if~isempty(item)



        recentPopup.remove(item);
    end



    item=ListItem(fileName,this.GenericFile_icon16);
    item.Tag=fileFullPath;
    item.Description=fileFullPath;
    item.ItemPushedFcn=@(o,e)this.toolstripOpenRecentFileCB(fileName,fileFullPath);
    recentPopup.add(item,2);




    try
        item=recentPopup.getChildByIndex(10);
        recentPopup.remove(item);
    catch
    end



    try
        item=recentPopup.getChildByIndex(2);
        fileNames={item.Text};
        iconFiles={this.SessionFileIcon};
        descriptions={item.Description};
        tags={item.Tag};
        for i=3:9
            item=recentPopup.getChildByIndex(i);
            fileNames{end+1}=item.Text;%#ok
            iconFiles{end+1}=this.SessionFileIcon;%#ok
            descriptions{end+1}=item.Description;%#ok
            tags{end+1}=item.Tag;%#ok
        end
    catch
    end
    s=settings;
    s.slrealtime.slrtAppGenerator.openRecentFiles.text.PersonalValue=fileNames;
    s.slrealtime.slrtAppGenerator.openRecentFiles.iconFile.PersonalValue=iconFiles;
    s.slrealtime.slrtAppGenerator.openRecentFiles.description.PersonalValue=descriptions;
    s.slrealtime.slrtAppGenerator.openRecentFiles.tag.PersonalValue=tags;
end
