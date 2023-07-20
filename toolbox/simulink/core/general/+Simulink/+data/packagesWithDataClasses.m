function retList=packagesWithDataClasses(classes,refresh)









    mlock;
    persistent paramList signalList paramAndSignalList

    if nargin<2
        refresh=false;
        if nargin<1
            classes='Parameter & Signal';
        end
    end

    if refresh

        [paramList,signalList]=findValidPackages;
        paramAndSignalList=intersect(paramList,signalList);
    elseif isempty(paramList)

        paramList={'Simulink';'mpt'};
        signalList=paramList;
        paramAndSignalList=paramList;
    end


    switch classes
    case 'Signal'
        retList=signalList;
    case 'Parameter & Signal'
        retList=paramAndSignalList;
    case 'Parameter'
        retList=paramList;
    otherwise
        assert(false,'Unexpected mode');
    end

end



function[paramList,signalList]=findValidPackages
    paramList={};
    signalList={};

    WaitbarFindText=DAStudio.message('RTW:configSet:configSetWaitbarMsg');
    WaitbarWaitText=DAStudio.message('RTW:configSet:configSetWaitbarTitle');
    hw=waitbar(0,WaitbarFindText,'Name',WaitbarWaitText);

    packageList=slprivate('find_valid_packages');
    if ishghandle(hw);waitbar(1/length(packageList),hw);end

    for i=1:length(packageList)
        try
            thisPkg=packageList{i};
            if Simulink.data.packageHasDataClasses(thisPkg,'Signal');
                signalList{end+1,1}=thisPkg;%#ok
            end
            if Simulink.data.packageHasDataClasses(thisPkg,'Parameter');
                paramList{end+1,1}=thisPkg;%#ok
            end
        catch

        end
        if ishghandle(hw);waitbar((i+1)/(length(packageList)+1),hw);end
    end
    if ishghandle(hw);close(hw);end
end
