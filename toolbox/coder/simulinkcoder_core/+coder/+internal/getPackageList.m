function retList=getPackageList(refresh,memsec,clearCache)




    mlock;
    persistent memSecPackageList;
    persistent cscPackageList;

    defaultPackageList={'Simulink';'mpt'};


    if isempty(memSecPackageList)
        memSecPackageList=defaultPackageList;
    end

    if isempty(cscPackageList)||clearCache
        cscPackageList=defaultPackageList;
    end

    if memsec
        retList=memSecPackageList;
    else
        retList=cscPackageList;
    end


    if(refresh)



        hw=waitbar(0,DAStudio.message('RTW:configSet:configSetWaitbarMsg'),...
        'Name',DAStudio.message('RTW:configSet:configSetWaitbarTitle'));
        packageList=defaultPackageList;
        fullPackageList=slprivate('find_valid_packages');
        for i=1:length(fullPackageList)
            thisName=fullPackageList{i};
            try
                if((~any(strcmp(thisName,defaultPackageList)))&&...
                    (~isempty(processcsc('GetCSCRegFile',thisName))))
                    if memsec
                        if~isempty(processcsc('GetMemorySectionDefns',thisName))
                            packageList{end+1}=thisName;%#ok
                        end
                    else
                        packageList{end+1}=thisName;%#ok<AGROW>
                    end
                end
            catch e
                MSLDiagnostic('RTW:configSet:ErrorLoadingMemSecPackage',thisName,e.message).reportAsWarning;
            end
            if ishghandle(hw);waitbar(i/length(fullPackageList),hw);end
        end
        if ishghandle(hw);close(hw);end



        if memsec
            memSecPackageList=packageList;
            retList=memSecPackageList;
        else
            cscPackageList=packageList;
            retList=cscPackageList;
        end
    end
end