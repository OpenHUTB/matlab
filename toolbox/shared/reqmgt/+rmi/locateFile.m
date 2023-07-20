function resolvedPath=locateFile(relPath,reference)









    resolvedPath='';

    if rmiut.isCompletePath(relPath)
        resolvedPath=relPath;

    elseif isempty(reference)

        resolvedPath=rmiut.full_path(relPath,pwd);

    elseif ischar(reference)

        if rmisl.isSidString(reference)
            reference=strtok(reference,':');
        end

        isa=exist(reference);%#ok<EXIST>

        if isa==0

            [reffile,remainder]=strtok(reference,'|');
            if~isempty(remainder)
                reference=reffile;
                isa=exist(reference);%#ok<EXIST>
            end
        end

        switch isa
        case 7
            resolvedPath=rmiut.full_path(relPath,reference);
        case 4
            resolvedPath=rmisl.locateFile(relPath,reference);
        case 2
            referencePathDir=fileparts(reference);
            if~isempty(referencePathDir)
                resolvedPath=rmiut.full_path(relPath,referencePathDir);
            end
        otherwise

        end
    else

        if dig.isProductInstalled('Simulink')
            resolvedPath=rmisl.locateFile(relPath,rmisl.getmodelh(reference(1)));
        end
    end
end

