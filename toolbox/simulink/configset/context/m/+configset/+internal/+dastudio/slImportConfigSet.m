function slImportConfigSet(obj,filename,pathname)




    if nargin<3
        [filename,pathname]=uigetfile({'*.mat;*.m;*.mlx',DAStudio.message('Simulink:ConfigSet:MEContextImportDlgMATLABFiles');...
        '*.m;*.mlx',DAStudio.message('Simulink:busEditor:MATLABFiles');...
        '*.mat',DAStudio.message('Simulink:busEditor:MATFiles')},...
        DAStudio.message('RTW:configSet:saveAsGUIImport'));
    end

    if~ischar(filename)||~ischar(pathname)
        return;
    end

    [~,filenameonly,~]=fileparts(filename);

    if~isvarname(filenameonly)
        msgbox(DAStudio.message('Simulink:tools:badOutputFileName',filename),'Error','warn');
        return;
    end

    filename=fullfile(pathname,filename);

    try
        slprivate('loadConfigSet',obj.handle,filename);
    catch ME
        msgbox(ME.message,'Error','error');
    end

end
