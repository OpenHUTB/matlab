function type=getFileType(file)




    if~usejava('jvm')
        type='';
        return;
    end

    [~,~,ext]=fileparts(file);
    if strcmp(ext,"")
        type='';
        return;
    end

    filesystem=com.mathworks.mlwidgets.explorer.model.realfs.RealFileSystem.getInstance;
    location=com.mathworks.matlab.api.explorer.FileLocation(file);
    entry=com.mathworks.matlab.api.explorer.FileSystemEntry(filesystem,location,true,false,0,0,0);

    decoration=com.mathworks.matlab.api.explorer.CoreFileDecoration.TYPE_NAME;

    registry=com.mathworks.mlwidgets.explorer.model.ExplorerExtensionRegistry.getInstance;

    type=char(com.mathworks.mlwidgets.explorer.util.UiFileSystemUtils.getDecorationSynchronously(entry,decoration,registry));

end
