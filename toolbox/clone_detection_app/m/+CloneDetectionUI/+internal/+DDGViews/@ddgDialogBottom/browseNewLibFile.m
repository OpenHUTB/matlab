function browseNewLibFile(this)


    ext={'*.mdl;*.slx','Models (*.slx, *.mdl)'};
    text=DAStudio.message('sl_pir_cpp:creator:AddLibraryBrowserTitle');
    currPath=path;
    currWD=pwd;

    dlgHandle=DAStudio.ToolRoot.getOpenDialogs(this);


    [filename,pathname]=uigetfile(ext,text);

    cd(currWD);
    path(currPath);

    if isequal(filename,0)||isequal(pathname,0)
        return;
    end
    [~,~,ext]=fileparts(filename);
    [~,name,~]=fileparts(filename);
    if(~strcmpi(ext,'.slx')&&~strcmpi(ext,'.mdl'))||...
        ~CloneDetectionUI.internal.DDGViews.AddLibrary.checkFileName(name)
        DAStudio.error('sl_pir_cpp:creator:IllegalName4_lib');
    end
    newFile=fullfile(pathname,filename);
    dlgHandle.setWidgetValue('libraryNameTag',newFile);
    this.cloneUIObj.refactoredClonesLibFileName=[pathname,name];
    dlgHandle.refresh;
end

