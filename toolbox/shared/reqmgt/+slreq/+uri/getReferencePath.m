function refPath=getReferencePath(ref)


    if ischar(ref)

        if isfile(ref)
            refPath=fileparts(ref);
            return;
        end

        if isfolder(ref)

            refPath=ref;

            if~rmiut.isCompletePath(refPath)

                refPath=rmiut.simplifypath(fullfile(pwd,refPath),filesep);
            end
            return;
        end


        if any(ref=='|')
            ref=strtok(ref,'|');
        end


        if rmisl.isSidString(ref)
            ref=strtok(ref,':');
        end


        if~rmiut.isCompletePath(ref)

            whichRef=which(ref);
            if isempty(whichRef)


                [~,refName,fExt]=fileparts(ref);
                if(isempty(fExt)||any(strcmp(fExt,{'.slx','.mdl'})))
                    if dig.isProductInstalled('Simulink')&&bdIsLoaded(refName)
                        whichRef=get_param(refName,'FileName');
                    end
                end
            end
            if isempty(whichRef)

                refPath=pwd;
                return;
            else
                ref=whichRef;
            end
        end


        refPath=fileparts(ref);

    else



        try
            ref=get_param(bdroot(ref),'FileName');
            refPath=ref;
        catch ex %#ok<NASGU>

            refPath=pwd;
        end
    end
end

