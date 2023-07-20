function result=isCPPClassGenEnabled(hConfigSet)







    cppClassCompliant=false;

    if~isempty(hConfigSet)
        rtw=hConfigSet.getComponent('Code Generation');
        if~isempty(rtw)
            target=rtw.getComponent('Target');
            if~isempty(target)
                cppClassCompliant=...
                (strcmp(get_param(target,'CPPClassGenCompliant'),'on'));
            end
        end
    end

    result=cppClassCompliant;

