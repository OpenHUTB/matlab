











function file=getComponentFile(identifier,type)
    file='';

    switch(type)
    case Advisor.component.Types.Model
        modelname=identifier;
        file=sls_resolvename(modelname);




        if bdIsLoaded(modelname)&&Simulink.harness.isHarnessBD(modelname)
            file=get_param(modelname,'OwnerFileName');
        end

    case Advisor.component.Types.MFile
        filename=identifier;
        extensions={'.m','.mlx'};

        file=loc_getFileFromWhich(filename,extensions);

    case Advisor.component.Types.ProtectedModel
        filename=identifier;
        extensions={'.slxp'};

        file=loc_getFileFromWhich(filename,extensions);

    case Advisor.component.Types.LibraryBlock
        libname=identifier;
        file=sls_resolvename(libname);

    otherwise

    end


end

function file=loc_getFileFromWhich(filename,extensions)
    files=which(filename,'-all');


    for n=1:length(files)
        [~,~,ext]=fileparts(files{n});

        if any(strcmp(ext,extensions))
            file=files{n};
            break;
        end
    end
end