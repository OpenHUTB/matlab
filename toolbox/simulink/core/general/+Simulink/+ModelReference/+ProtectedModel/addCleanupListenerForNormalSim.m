




function addCleanupListenerForNormalSim(topmodel,slxpFile,mexFiles)
    fDeleter=Simulink.ModelReference.ProtectedModel.FileDeleter.Instance();
    [~,modelName,~]=fileparts(slxpFile);
    currentDir=pwd;


    mexfile=fullfile(currentDir,coder.internal.modelRefUtil(modelName,'getSimTargetName',true));
    fDeleter.setSecondaryTop(topmodel);
    fDeleter.addFileToDelete(mexfile);


    simTargetDir=fullfile(currentDir,'slprj','sim',modelName);
    fDeleter.addFileToDelete(simTargetDir);


    fmuLibraryDir=fullfile(currentDir,'slprj','_fmu');
    fDeleter.addFileToDelete(fmuLibraryDir);


    if slfeature('NonInlineSFcnsInProtection')

        parser=mf.zero.io.XmlParser;
        MF0File=coder.internal.modelRefUtil(modelName,'getModelRefInfoFileName','SIM','NONE');
        parsedContents=parser.parseFile(MF0File);
        paramInfo=parsedContents.sFcnInfo;
        for i=1:paramInfo.Size

            if paramInfo(i).willBeDynamicallyLoaded
                mexFileName=paramInfo(i).name;
                mexFile=fullfile(currentDir,[mexFileName,'.',mexext]);

                if~any(strcmp(mexFiles,mexFile))
                    fDeleter.addFileToDelete(mexFile);
                end
            end
        end
    end
end
