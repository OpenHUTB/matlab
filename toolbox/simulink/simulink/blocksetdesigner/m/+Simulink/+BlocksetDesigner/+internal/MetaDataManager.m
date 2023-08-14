classdef MetaDataManager<handle




    properties
MetaData
ProjectFileMetadataManager
Project
ProjectRoot
MetaDataForFiles
    end

    methods
        function this=MetaDataManager()
            import matlab.internal.project.metadata.*;
            try
                project=currentProject();
                applicationName='BlockAuthoring';
                this.ProjectFileMetadataManager=matlab.internal.project.metadata.FileMetadataManager(project,applicationName);
                this.Project=project;
                this.ProjectRoot=char(this.Project.RootFolder);
                this.MetaData=this.ProjectFileMetadataManager.getAllMetadata();
                this.MetaDataForFiles={'S_FUN_MEX_FILE',...
                'S_FUN_FILE',...
                'S_FUN_HEADER',...
                'S_FUN_TLC',...
                'DOC_SCRIPT',...
                'DOC_FILE',...
                'TEST_SCRIPT',...
                'TEST_HARNESS',...
                'BLOCK_LIBRARY',...
                'BLOCK_ICON',...
                'S_FUN_BUILD',...
                'S_FUN_BUILD_REPORT',...
                'BLOCKSET_LIBRARY',...
                'BLOCKSET_SCRIPT',...
                'CHECK_REPORT',...
                'TEST_REPORT',...
                'INFO_XML',...
                'HELPTOC_XML',...
                'BLOCKSET_DOC_SCRIPT',...
                'BLOCKSET_DOC_HTML',...
'SYSTEM_OBJECT_FILE'
                };
            catch ex
            end
        end

        function delete(obj)
            obj.commitMetaData();
        end

        function commitMetaData(obj)
            import matlab.internal.project.metadata.*;
            if~isempty(obj.ProjectFileMetadataManager)
                if isLoaded(obj.Project)
                    newMetaData=FileNodeMap;
                    files=obj.MetaData.listFiles();
                    if~isempty(files)
                        for i=1:numel(files)
                            if~isempty(findFile(obj.Project,files(i)))||isequal(files(i),obj.ProjectRoot)
                                newMetaData.setNode(files(i),obj.MetaData.getNode(files(i)));
                            end
                        end
                        obj.MetaData=newMetaData;
                        obj.ProjectFileMetadataManager.setAllMetadata(obj.MetaData);
                    end
                end
            end
        end

        function clearMetaDataAtRoot(obj)
            obj.ProjectFileMetadataManager.removeEntry(obj.Project.RootFolder);
        end

        function clearAllBlocksMetaData(obj)
            import matlab.internal.project.metadata.*;
            file=obj.Project.RootFolder;
            metaDataNode=obj.MetaData.getNode(file);
            if~isempty(metaDataNode)
                metaDataNode=FileMetadataNode();
                metaDataNode.set('blockList')='';
                obj.MetaData.setNode(file,metaDataNode);
                obj.commitMetaData();
            end
        end

        function setBlockSetMetaData(obj,types,data)
            dataMap=containers.Map();
            if(iscell(types))
                for i=1:numel(types)
                    if any(strcmp(obj.MetaDataForFiles,types{i}))
                        data{i}=obj.normalizeFilePath(data{i});
                    end
                    dataMap(types{i})=data{i};
                end
            else
                if any(strcmp(obj.MetaDataForFiles,types))
                    data=obj.normalizeFilePath(data);
                end
                dataMap(types)=data;
            end
            obj.setFileMetaData(obj.Project.RootFolder,dataMap);
        end

        function data=getBlockSetMetaData(obj,types)
            dataMap=obj.getFileMetaData(obj.ProjectRoot);
            if~isempty(dataMap)
                if(iscell(types))
                    data=cell(1,numel(types));
                    for i=1:numel(types)
                        data{i}=char(dataMap.get(types{i}));
                        if any(strcmp(obj.MetaDataForFiles,types{i}))
                            data{i}=obj.restoreFilePath(data{i});
                        end
                    end
                else
                    data=char(dataMap.get(types));
                    if any(strcmp(obj.MetaDataForFiles,types))
                        data=obj.restoreFilePath(data);
                    end
                end
            else
                data='';
            end
        end

        function setBlockMetaData(obj,blockId,types,data)
            dataMap=containers.Map();
            if(iscell(types))
                for i=1:numel(types)
                    if any(strcmp(obj.MetaDataForFiles,types{i}))
                        data{i}=obj.normalizeFilePath(data{i});
                    end
                    dataMap(types{i})=data{i};
                end
            else
                if any(strcmp(obj.MetaDataForFiles,types))
                    data=obj.normalizeFilePath(data);
                end
                dataMap(types)=data;
            end
            obj.setBlockMetaDataAtRoot(blockId,dataMap);
        end

        function data=getBlockMetaData(obj,blockId,types,varargin)
            if(nargin==3)
                data=obj.getBlockMetaDataAtRoot(blockId,types);
            else
                data=obj.getBlockMetaDataAtRoot(blockId,types,varargin{1});
            end
        end

        function deleteBlockMetaData(obj,blockId)
            import matlab.internal.project.metadata.*;
            file=obj.Project.RootFolder;
            metaDataNode=obj.MetaData.getNode(file);
            if isempty(metaDataNode)
                return;
            end
            childNodes=metaDataNode.getChildNodes();
            for i=1:numel(childNodes)
                childId=char(childNodes(i).get('blockId'));
                if isequal(childId,blockId)
                    keys=childNodes(i).getKeys();
                    for j=1:numel(keys)
                        childNodes(i).set(keys{j},'NA');
                    end
                end
            end
            obj.MetaData.setNode(file,metaDataNode);
            obj.commitMetaData();
        end

        function setBlockMetaDataAtRoot(obj,blockId,dataMap)
            import matlab.internal.project.metadata.*;
            file=obj.Project.RootFolder;
            metaDataNode=obj.MetaData.getNode(file);
            if isempty(metaDataNode)
                metaDataNode=FileMetadataNode();
                childNode=metaDataNode.createChildNode();
                keySet=keys(dataMap);
                for i=1:numel(keySet)
                    if~isempty(dataMap(keySet{i}))
                        childNode.set(keySet{i},char(dataMap(keySet{i})));
                    end
                end
                childNode.set('blockId',blockId);
            else
                blockNode=obj.getBlockMetaDataNode(blockId);
                if~isempty(blockNode)
                    keySet=keys(dataMap);
                    for j=1:numel(keySet)
                        if~isempty(dataMap(keySet{j}))
                            blockNode.set(keySet{j},char(dataMap(keySet{j})));
                        else
                            blockNode.set(keySet{j},char('  '));
                        end
                    end
                else
                    childNode=metaDataNode.createChildNode();
                    keySet=keys(dataMap);
                    for i=1:numel(keySet)
                        if~isempty(dataMap(keySet{i}))
                            childNode.set(keySet{i},char(dataMap(keySet{i})));
                        else
                            childNode.set(keySet{i},char('  '));
                        end
                    end
                    childNode.set('blockId',blockId);
                end
            end
            obj.MetaData.setNode(file,metaDataNode);
            obj.commitMetaData();
        end

        function data=getBlockMetaDataAtRoot(obj,blockId,types,varargin)
            blockMetaDataNode='';
            if(nargin==3)
                blockMetaDataNode=obj.getBlockMetaDataNode(blockId);
            else
                blockMetaDataNode=obj.getBlockMetaDataNode(blockId,varargin{1});
            end
            data='';
            if~isempty(blockMetaDataNode)
                if iscell(types)
                    data=cell(1,numel(types));
                    for j=1:numel(types)
                        data{j}=char(blockMetaDataNode.get(types{j}));
                        if any(strcmp(obj.MetaDataForFiles,types{j}))
                            data{j}=obj.restoreFilePath(data{j});
                        end
                    end
                else
                    data=char(blockMetaDataNode.get(types));
                    if any(strcmp(obj.MetaDataForFiles,types))
                        data=obj.restoreFilePath(data);
                    end
                end
            end
        end

        function node=getFileMetaData(obj,filepath)

            try
                if obj.isFileInMetaData(filepath)
                    node=obj.MetaData.getNode(filepath);
                else
                    node='';
                end
            catch
                node='';
            end
        end

        function setFileMetaData(obj,filepath,dataMap)

            import matlab.internal.project.metadata.*;


            if~obj.isFileInMetaData(filepath)
                metaDataNode=FileMetadataNode();
                keySet=keys(dataMap);
                for i=1:numel(keySet)
                    if~isempty(dataMap(keySet{i}))
                        metaDataNode.set(keySet{i},char(dataMap(keySet{i})));
                    end
                end
            else

                metaDataNode=obj.MetaData.getNode(filepath);
                keySet=keys(dataMap);
                for i=1:numel(keySet)
                    if~isempty(dataMap(keySet{i}))
                        metaDataNode.set(keySet{i},char(dataMap(keySet{i})));
                    end
                end
            end

            obj.MetaData.setNode(filepath,metaDataNode);
            obj.commitMetaData();
        end

        function output=normalizeFilePath(obj,filepath)

            if isempty(filepath)
                output=filepath;
            else
                output=regexprep(filepath,'[\\]','/');
            end

        end

        function output=restoreFilePath(obj,filepath)

            if isempty(filepath)
                output=filepath;
            elseif isequal(filepath,'  ')
                output='';
            else
                output=regexprep(filepath,'[/]',filesep);
            end
        end

        function blockMetaDataNode=getBlockMetaDataNode(obj,blockId,varargin)
            blockMetaDataNode='';
            file=obj.Project.RootFolder;
            metaDataNode=obj.MetaData.getNode(file);
            if isempty(metaDataNode)
                return;
            end
            childNodes=metaDataNode.getChildNodes();
            for i=1:numel(childNodes)
                childId=char(childNodes(i).get('blockId'));
                if isequal(childId,blockId)
                    blockMetaDataNode=childNodes(i);
                    return;
                end
            end
            for i=1:numel(childNodes)
                childId=char(childNodes(i).get('blockId'));
                blockPath=char(childNodes(i).get('BlockPath'));
                openFunction=char(childNodes(i).get('OpenFunction'));
                if isempty(childId)&&nargin==3&&(isequal(blockPath,varargin{1})||isequal(openFunction,varargin{1}))
                    childNodes(i).set('blockId',blockId);
                    obj.MetaData.setNode(file,metaDataNode);
                    obj.commitMetaData();
                    blockMetaDataNode=childNodes(i);
                    return;
                end
            end

        end

        function result=isFileInMetaData(obj,filepath)
            import matlab.internal.project.metadata.*;
            files=obj.MetaData.listFiles();
            if(isempty(files))
                result=false;
                return;
            else
                filesInProject=cellstr(obj.MetaData.listFiles());
                result=any(strcmp(filesInProject,filepath));
            end
        end
    end
end

