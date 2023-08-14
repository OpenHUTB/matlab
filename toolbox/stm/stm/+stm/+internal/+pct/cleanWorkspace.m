function cleanWorkspace()


    rootPaths={fullfile(tempdir,'_SimulinkTest_'),...
    stm.internal.getMRTRootPath};
    for x=1:numel(rootPaths)
        rootPath=rootPaths{x};
        token='ResultSet';
        tokenLen=length(token);
        if(exist(rootPath,'dir'))
            files=dir(rootPath);
            for k=1:length(files)
                if(files(k).isdir==0)
                    continue;
                end
                if(strncmp(files(k).name,token,tokenLen))
                    tmpPath=fullfile(rootPath,files(k).name);
                    try
                        rmdir(tmpPath,'s');
                    catch
                    end
                end
            end
        end
    end
end
