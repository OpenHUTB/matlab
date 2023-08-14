function actx_demopreload





    if ispc&&~rmicom.actx_installed('SLRefButton')
        msg=getString(message('Slvnv:reqmgt:actx_installed:NavFromWordWontWork'));
        msgbox(msg,getString(message('Slvnv:reqmgt:actx_installed:RequiredActiveXNotRegistered')));
    end

end


