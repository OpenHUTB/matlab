function resolvedPath=srcToPath(src)

    if isa(src,'char')

        fPath=strtok(src,'|');
        if exist(fPath,'file')==2
            if~contains(fPath,'.sldd')&&~contains(fPath,'.mldatx')
                resolvedPath=fPath;
            elseif~any(fPath==filesep)

                resolvedPath=rmide.getFilePath(fPath);
                if isempty(resolvedPath)
                    resolvedPath=which([fPath,'.mldatx']);
                end
            else
                resolvedPath=fPath;
            end
        elseif rmisl.isSidString(fPath)
            key=strtok(fPath,':');
            if exist(key,'file')==4
                resolvedPath=get_param(key,'FileName');
            else
                resolvedPath='';
            end
        end
    elseif isa(src,'Simulink.DDEAdapter')
        resolvedPath=rmide.getFilePath(src);
    elseif isa(src,'slreq.data.Requirement')
        resolvedPath=src.getReqSet.filepath;
    else
        try
            modelH=rmisl.getmodelh(src(1));
            resolvedPath=get_param(modelH,'FileName');
        catch ex %#ok<NASGU>
            warning(message('Slvnv:rmi:resolveobj:InvalidHandle',num2str(src(1))));
            resolvedPath='';
        end
    end

end