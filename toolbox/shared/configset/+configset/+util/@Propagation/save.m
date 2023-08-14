function save(h)

    if~h.Dirty
        return;
    end

    try
        [path,~,~]=fileparts(h.SaveName);
        if exist(path,'dir')~=7
            mkdir(path);
        end

        infoStruct=h;%#ok
        save(h.SaveName,'infoStruct');

    catch e
        err=configset.util.message(e);
        msg=DAStudio.message('configset:util:CannotSave');
        msg=sprintf('%s: %s',msg,err);
        if h.GUI
            errordlg(msg);
        else
            disp(msg);
        end
    end

    h.Dirty=false;
