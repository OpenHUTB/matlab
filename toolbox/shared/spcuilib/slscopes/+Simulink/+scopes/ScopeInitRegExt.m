function ScopeInitRegExt


    rd=extmgr.Library.Instance.getRegistrationSet('scopext','register');


    for indx=1:numel(rd.Children)
        meta.class.fromName(rd.Children(indx).Class);
        rd.Children(indx).PropertySet;
    end
