function importSpecialTypesToFile(obj)


    typesToImport=obj.TypesToImport;

    if~isempty(typesToImport)

        matFileName=obj.LibraryFileName+"_types.mat";
        matFileNamePath=fullfile(obj.qualifiedSettings.OutputFolder,matFileName);
        if isfile(matFileNamePath)

            delete(matFileNamePath);
        end


        Simulink.importExternalCTypes(obj.LibraryFileName,...
        'OutputDir',obj.qualifiedSettings.OutputFolder,...
        'MATFile',matFileName,'Names',typesToImport);

        loadTypesCmd=sprintf('load(''%s'');',matFileNamePath);
        if isfile(matFileNamePath)
            evalin('base',loadTypesCmd);

            postLoadfcn=sprintf('load(''%s'');',matFileName);
            set_param(obj.LibraryFileName,'PostLoadFcn',postLoadfcn);
        end
    end
end
