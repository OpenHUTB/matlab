function pref=getPreference(name,varargin)




    assert(numel(name)<=63,'The ESB preference name longer than 63 characters');
    esbPrefGroup='ESBPreferences';
    if ispref(esbPrefGroup,name)
        pref=getpref(esbPrefGroup,name);
    else
        pref=[];
    end
end