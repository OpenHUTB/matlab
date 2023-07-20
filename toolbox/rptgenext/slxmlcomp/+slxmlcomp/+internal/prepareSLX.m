function results=prepareSLX(filePaths,tempdir)

















    files=i_ResolveFilePaths(filePaths);
    initialNames={files(:).Name};
    namesToAvoid=initialNames;

    i_AssertModelsAreNotDirty(files);



    i_CloseModelClashingWithMine(files(end).Path);


    warningID='Simulink:Engine:MdlFileShadowedByFile';
    w=warning('off',warningID);
    restoreWarning=onCleanup(@()warning(w.state,warningID));

    results=java.util.ArrayList;
    for ii=1:numel(files)
        originalFile=files(ii).Path;
        fileName=files(ii).Name;

        namesToAvoid{ii}='';
        renameModel=i_IsMember(fileName,namesToAvoid);


        fileToCompare=slxmlcomp.internal.saveToLatestVersion(originalFile,tempdir,namesToAvoid,renameModel);


        fileToCompare=sls_resolvename(fileToCompare);


        if renameModel
            [~,newFileName]=slfileparts(fileToCompare);
            namesToAvoid{ii}=newFileName;
            fileToUseInMemory=fileToCompare;
        else
            namesToAvoid{ii}=fileName;
            fileToUseInMemory=originalFile;
        end

        import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.SlxComparisonModelData;
        import java.io.File;
        slxModelData=SlxComparisonModelData(...
        File(originalFile),File(fileToCompare),File(fileToUseInMemory));
        results.add(slxModelData);
    end


    i_SaveConfigSetData();

end


function files=i_ResolveFilePaths(filePaths)
    count=filePaths.size();
    files(1:count)=struct('Name','','Path','');
    for ii=1:count
        fullPath=sls_resolvename(filePaths.get(ii-1));
        files(ii).Path=fullPath;
        [~,files(ii).Name]=slfileparts(fullPath);
    end
end

function isMember=i_IsMember(name,names)
    isMember=any(cellfun(@(x)xmlcomp.internal.compareFilenames(name,x),names));
end

function i_CloseModelClashingWithMine(minePath)
    [~,mdlName,~]=slfileparts(minePath);


    if bdIsLoaded(mdlName)&&~i_areFilePathsEqual(minePath,get_param(mdlName,'FileName'))
        opt=slxmlcomp.options;

        if~opt.getCloseSameNameModel
            yesStr=slxmlcomp.internal.message('xmlexport:Yes');
            noStr=slxmlcomp.internal.message('xmlexport:No');
            cancelStr=slxmlcomp.internal.message('xmlexport:Cancel');

            q=questdlg(...
            slxmlcomp.internal.message('xmlexport:CloseModelQuestion',mdlName),...
            slxmlcomp.internal.message('xmlexport:CloseModelTitle'),...
            yesStr,noStr,cancelStr,yesStr);
            if~strcmpi(q,yesStr)

                slxmlcomp.internal.error('xmlexport:ShadowedModel',mdlName,minePath,mdlName);
            end
        end


        close_system(mdlName);
    end
end

function i_SaveConfigSetData()

    try
        slxmlcomp.internal.configset.populateConfigSetParameterCache();
    catch E %#ok<NASGU>

    end
end

function equal=i_areFilePathsEqual(path1,path2)

    equal=java.io.File(path1).equals(java.io.File(path2));

end

function i_AssertModelsAreNotDirty(files)

    for ii=1:numel(files)
        modelFile=files(ii).Path;
        [~,modelName,~]=fileparts(modelFile);
        if(bdIsLoaded(modelName)&&...
            i_areFilePathsEqual(modelFile,get_param(modelName,'FileName')))

            if~strcmp(get_param(modelName,'Dirty'),'off')
                open_system(modelName);
                slxmlcomp.internal.error('xmlexport:DirtyModel',modelName);
            end
        end
    end

end

