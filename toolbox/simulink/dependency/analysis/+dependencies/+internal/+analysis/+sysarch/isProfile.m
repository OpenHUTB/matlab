function accept=isProfile(filepath)




    accept=endsWith(filepath,".apfx")...
    ||Simulink.loadsave.find(filepath,'/MF0/systemcomposer.profile.Profile');

end

