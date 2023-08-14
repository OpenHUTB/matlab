function out=getAllModelsWithLibrary(libname,allmodels)



    out={};
    if ishandle(libname)
        libname=get_param(libname,'Name');
    end

    if nargin<2


        allmodels=getfullname(Simulink.allBlockDiagrams('model'));

        if~iscell(allmodels)
            allmodels={allmodels};
        end
    end
    for mindex=1:length(allmodels)
        cModel=allmodels{mindex};
        allLibs=rmisl.getLoadedLibraries(cModel);
        libList=unique(allLibs);
        if ismember(libname,libList)
            out{end+1}=cModel;%#ok<AGROW> Not Big. 
        end
    end
end
