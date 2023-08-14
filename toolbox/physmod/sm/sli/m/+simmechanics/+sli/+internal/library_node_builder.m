function libNode=library_node_builder(fullDirName)





















    libNode=[];

    while(fullDirName(end)=='/')||(fullDirName(end)=='\')
        fullDirName=fullDirName(1:end-1);
    end
    [dirPath,dirName]=fileparts(fullDirName);
    if isempty(dirPath)
        dirPath=pwd;
    end




    if exist(dirPath,'dir')&&(dirName(1)=='+')

        libFile=fullfile(fullDirName,'lib');
        dirName=dirName(2:end);
        dirName(1)=upper(dirName(1));

        if exist(libFile,'file')
            setupFunctionH=pm.util.function_handle(libFile);
            libInfo=simmechanics.sli.internal.LibInfo;
            try

                feval(setupFunctionH,libInfo);
                libInfo.SourceFile=libFile;

                if isempty(libInfo.SLBlockProperties.Name)
                    libInfo.SLBlockProperties.Name=dirName;
                end

                if isempty(libInfo.Annotation)
                    libInfo.Annotation=[dirName,' Library'];
                end
                if(strcmpi(libInfo.Hidden,'off'))
                    libNode=pm.util.CompoundNode(fullDirName);
                    libNode.Info=libInfo;
                end
            catch excp
                pm_error('sm:sli:libnodebuilder:InvalidLibSpecFile',...
                libFile,excp.message);
            end


        end
    end
end


