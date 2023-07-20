function slExportConfigSet(obj,filename,pathname)




    if nargin<2
        if isa(obj,'Simulink.ConfigSetRoot')
            msgTitle=DAStudio.message('RTW:configSet:saveAsGUIExport');
        else
            msgTitle=DAStudio.message('RTW:configSet:saveAsGUIExportMdl');
        end

        [filename,pathname]=uiputfile({'*.mat;*.m;*.mlx',DAStudio.message('Simulink:ConfigSet:MEContextImportDlgMATLABFiles');...
        '*.m;*.mlx',DAStudio.message('Simulink:busEditor:MATLABFiles');...
        '*.mat',DAStudio.message('Simulink:busEditor:MATFiles')},msgTitle);
    end

    if~ischar(filename)||~ischar(pathname)
        return;
    end

    [~,filenameonly,ext]=fileparts(filename);

    title=getString(message('Simulink:dialog:ErrorText'));
    if~isvarname(filenameonly)
        msgbox(DAStudio.message('Simulink:tools:badOutputFileName',filenameonly),title,'warn');
        return;
    end

    if~(strcmp(ext,'.m')||strcmp(ext,'.mlx'))&&~strcmp(ext,'.mat')
        msgbox(DAStudio.message('Simulink:tools:badFileNameExtension',ext),title,'warn');
        return;
    end

    filename=fullfile(pathname,filename);

    try
        if isa(obj,'Simulink.ConfigSetRoot')
            configset.internal.util.save(obj,filename);
        elseif isa(obj,'Simulink.BlockDiagram')
            Simulink.BlockDiagram.saveActiveConfigSet(obj.handle,filename);
        end
    catch ME
        msgbox(ME.message,'Error','error');
    end
