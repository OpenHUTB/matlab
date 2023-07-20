classdef FileMetadataManagerJava








    properties(GetAccess=private,SetAccess=private,Hidden=true)
JavaFileMetadata
    end

    methods(Access=public,Hidden=true)
        function obj=FileMetadataManagerJava(projectManager,applicationName)

            javaMatlabProjectManager=projectManager.connectPlugin(obj);
            import matlab.internal.project.util.processJavaCall;

            obj.JavaFileMetadata=processJavaCall(...
            @()javaMatlabProjectManager.getFileMetadataNodeManagerFor(char(applicationName))...
            );

        end
    end

    methods(Access=public)
        function node=getMetadata(obj,file)

            validateattributes(file,{'char','string','slproject.ProjectFile','matlab.project.ProjectFile'},{'nonempty'})
            cFile=obj.asChar(file);

            import matlab.internal.project.util.processJavaCall;
            jNode=processJavaCall(...
            @()obj.JavaFileMetadata.getDataFor(cFile,pwd)...
            );
            import matlab.internal.project.metadata.FileMetadataNodeJava;
            node=FileMetadataNodeJava(jNode);
        end

        function setMetadata(obj,file,node)

            validateattributes(file,{'char','string','slproject.ProjectFile','matlab.project.ProjectFile'},{'nonempty'})
            validateattributes(node,{'matlab.internal.project.metadata.FileMetadataNodeJava'},{'nonempty'})

            cFile=obj.asChar(file);

            jNode=node.extractJNode();

            import matlab.internal.project.util.processJavaCall;
            processJavaCall(...
            @()obj.JavaFileMetadata.setDataFor(cFile,pwd,jNode)...
            );
        end

        function setAllMetadata(obj,allData)
            validateattributes(allData,{'matlab.internal.project.metadata.FileNodeMapJava'},{'nonempty'});

            files=allData.listFiles();
            numFiles=length(files);
            jNodes(numFiles)=allData.getNode(files(numFiles)).extractJNode();

            for idx=1:(numFiles-1)
                jNodes(idx)=allData.getNode(files(idx)).extractJNode();
            end

            cFiles=cellstr(files);

            import matlab.internal.project.util.processJavaCall;
            processJavaCall(...
            @()obj.JavaFileMetadata.setAllData(cFiles,pwd,jNodes)...
            );
        end

        function removeEntry(obj,file)

            validateattributes(file,{'char','string','slproject.ProjectFile','matlab.project.ProjectFile'},{'nonempty'})
            cFile=obj.asChar(file);

            import matlab.internal.project.util.processJavaCall;
            processJavaCall(...
            @()obj.JavaFileMetadata.clearDataFor(cFile,pwd)...
            );
        end

        function allData=getAllMetadata(obj)

            import matlab.internal.project.util.processJavaCall;
            jFileNodeMap=processJavaCall(...
            @()obj.JavaFileMetadata.getAllData()...
            );

            import matlab.internal.project.metadata.FileNodeMapJava;
            allData=FileNodeMapJava(jFileNodeMap);
        end

    end

    methods(Access=private)
        function cFile=asChar(~,file)
            if isa(file,'slproject.ProjectFile')
                cFile=file.Path;
            elseif isa(file,'matlab.project.ProjectFile')
                cFile=char(file.Path);
            elseif isstring(file)
                cFile=char(file);
            else
                cFile=file;
            end
        end
    end
end
