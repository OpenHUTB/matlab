function tf=isProfileSupported()
    tf=false;
    if reqmgt('rmiFeature','SupportProfile')
        tf=true;
    end
end