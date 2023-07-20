function privatesbioloadlibrary()














    simbioprefdir=fullfile(prefdir,"SimBiology");
    createSimBiologyPrefdir(simbioprefdir);
    loadLibrary(simbioprefdir,"userdefkinlaws.sbklib","mw_aklarray");
    loadLibrary(simbioprefdir,"userdefunits.sbulib",["mw_prefixarray","mw_unitarray"]);
    enableSynchronizationOfLibrariesToDisk(SimBiology.Root.getroot);
end

function createSimBiologyPrefdir(simbioprefdir)


    if~exist(simbioprefdir,'dir')
        mkdir(simbioprefdir);
    end
end

function loadLibrary(simbioprefdir,libname,varNames)
    tfResaveLibrary=false;
    libfilename=fullfile(simbioprefdir,libname);


    if~exist(libfilename,'file')
        return
    end


    try
        lib=load('-mat',libfilename);
    catch e
        warning(message('SimBiology:privatesbioloadlibrary:ERROR_LOADING',libfilename,getReport(e)));
        return
    end

    for varName=varNames

        if~isfield(lib,varName)
            continue
        end

        objArray=(lib.(varName));
        numObjs=numel(objArray);
        for i=1:numObjs
            obj=objArray(i);
            try
                sbioaddtolibrary(obj);
            catch e
                if e.identifier=="Unit:CannotUnregisterBuiltin"&&obj.Name=="week"



                    root=sbioroot;
                    existingNames={root.UserDefinedLibrary.Units.Name,objArray.Name};
                    newName=matlab.lang.makeUniqueStrings("week",existingNames);
                    obj.Name=newName;
                    sbioaddtolibrary(obj);
                    warning(message('SimBiology:privatesbioloadlibrary:RenamedWeekUnit',obj.Name));
                    tfResaveLibrary=true;
                else
                    warning(message('SimBiology:privatesbioloadlibrary:ERROR_REGISTERING_OBJECT',...
                    obj.Type,obj.Name,getReport(e)));
                end
                continue
            end
        end
    end
    if tfResaveLibrary
        privateupdatelibrary('unit');
    end
end
