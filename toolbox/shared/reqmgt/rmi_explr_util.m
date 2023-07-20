function[varargout]=rmi_explr_util(method,obj,varargin)














    switch(lower(method))

    case 'getmodelh'
        varargout{1}=rmisl.getmodelh(obj);

    case 'vnvlicenseactive'
        varargout{1}=slreq_license_active();

    case 'highlightmodel'
        modelH=rmisl.getmodelh(obj);
        if modelH~=0
            rmisl.highlight(modelH);
        end

    case 'unhighlightmodel'
        modelH=rmisl.getmodelh(obj);
        if modelH~=0
            rmisl.unhighlight(modelH);
        end

    case 'doorsinstalled'
        varargout{1}=ispc&&rmi.settings_mgr('get','isDoorsSetup');

    otherwise
        error(message('Slvnv:rmi_explr_util:UnknownMethod'));
    end


    function result=slreq_license_active()
        licenseInUse=license('inuse');
        result=any(strcmp({licenseInUse.feature},'simulink_requirements'));





