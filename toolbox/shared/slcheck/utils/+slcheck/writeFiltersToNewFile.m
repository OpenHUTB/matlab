function[writeFilePath,updatedReadFilePath]=writeFiltersToNewFile(system,readFilePath,bInsideModel)
























    assert(3==nargin);


    writeFilePath='';
    updatedReadFilePath=readFilePath;

    if isempty(readFilePath)
        return;
    end



    isCloneFile=contains(fileread(readFilePath),'CloneDetection');



    if bInsideModel
        writeFilePath=slcheck.getFilterFilePath(system);;
        if~isCloneFile


            copyfile(readFilePath,writeFilePath);
            updatedReadFilePath=writeFilePath;




        end
    else

        if~isCloneFile



            service=slcheck.ExclusionBackwardCompatibilityService.getInstance;
            if service.getForceConversionStatus(system)
                writeFilePath=readFilePath;
                set_param(system,'MAModelFilterFile',writeFilePath);
                mdlObj=get_param(system,'Object');
                mdlObj.setDirty('ModelAdvisorFilters',true);
                disp(DAStudio.message('slcheck:filtercatalog:BackwardCompatibilityMAExclusionFile',readFilePath));
            else
                writeFilePath=handleCloneFile(system,readFilePath);

            end
        else

            writeFilePath=handleCloneFile(system,readFilePath);
        end
    end
end


function writeFilePath=handleCloneFile(system,readFilePath)

    [filepath,name,ext]=fileparts(readFilePath);
    tag=DAStudio.message('slcheck:filtercatalog:BackwardCompatibilityFileTag');
    writeFilePath=fullfile(filepath,filesep,[name,tag,ext]);


    set_param(system,'MAModelFilterFile',writeFilePath);
    mdlObj=get_param(system,'Object');
    mdlObj.setDirty('ModelAdvisorFilters',true);
    disp(DAStudio.message('slcheck:filtercatalog:BackwardCompatibilityCloneExclusionFile',readFilePath,writeFilePath));

end



























































