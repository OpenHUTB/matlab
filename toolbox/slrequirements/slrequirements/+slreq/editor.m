











function varargout=editor()


    if builtin('_license_checkout','Simulink_Requirements','quiet')
        errordlg(getString(message('Slvnv:slreq:SimulinkRequirementsNoLicenseForEditor')),...
        getString(message('Slvnv:slreq:SimulinkRequirements')),'modal');
        if nargout>0
            varargout{1}=false;
        end
    else
        mgr=slreq.app.MainManager.getInstance;
        mgr.openRequirementsEditor();
        if nargout>0
            varargout{1}=true;
        end
    end
end

