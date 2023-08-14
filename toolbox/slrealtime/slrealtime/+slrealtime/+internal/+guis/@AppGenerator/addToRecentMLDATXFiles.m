function addToRecentMLDATXFiles(this,fileName,fileFullPath)







    import matlab.ui.internal.toolstrip.*

    recentPopup=this.NewButton.Popup.getChildByIndex(2).Popup;

    item=[];
    try
        item=recentPopup.getChildByTag(fileFullPath);
    catch
    end
    if~isempty(item)



        recentPopup.remove(item);
    end



    [~,~,ext]=fileparts(fileFullPath);
    if strcmp(ext,'.slx')||strcmp(ext,'.mdl')
        iconFile=this.ModelFile_icon16;
    else
        iconFile=this.GenericFile_icon16;
    end



    item=ListItem(fileName,iconFile);
    item.Tag=fileFullPath;
    item.Description=fileFullPath;
    item.ItemPushedFcn=@(o,e)this.toolstripNewRecentFileCB(fileName,fileFullPath);
    recentPopup.add(item,2);




    try
        item=recentPopup.getChildByIndex(10);
        recentPopup.remove(item);
    catch
    end



    try
        item=recentPopup.getChildByIndex(2);
        fileNames={item.Text};
        iconFiles={getIconFileForSettings(this,item.Icon.Description)};
        descriptions={item.Description};
        tags={item.Tag};

        for i=3:9
            item=recentPopup.getChildByIndex(i);
            fileNames{end+1}=item.Text;%#ok
            iconFiles{end+1}=getIconFileForSettings(this,item.Icon.Description);%#ok
            descriptions{end+1}=item.Description;%#ok
            tags{end+1}=item.Tag;%#ok
        end
    catch
    end
    s=settings;
    s.slrealtime.slrtAppGenerator.newRecentFiles.text.PersonalValue=fileNames;
    s.slrealtime.slrtAppGenerator.newRecentFiles.iconFile.PersonalValue=iconFiles;
    s.slrealtime.slrtAppGenerator.newRecentFiles.description.PersonalValue=descriptions;
    s.slrealtime.slrtAppGenerator.newRecentFiles.tag.PersonalValue=tags;
end

function iconFileForSettings=getIconFileForSettings(this,iconFile)
    switch(iconFile)
    case{this.ModelFile_icon16}
        iconFileForSettings=this.ModelFileIcon;
    case{this.GenericFile_icon16}
        iconFileForSettings=this.MLDATXFileIcon;
    otherwise
        iconFileForSettings=this.MLDATXFileIcon;
    end
end