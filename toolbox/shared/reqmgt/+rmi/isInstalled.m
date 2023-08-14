function[yesno,licenseAvailable]=isInstalled()




    persistent rmiInstalled
    if isempty(rmiInstalled)






        rmiInstalled=contains(path,['toolbox',filesep,'slrequirements']);




    end
    yesno=rmiInstalled;

    if nargout>1
        licenseAvailable=license('test','Simulink_Requirements');
    end
end


