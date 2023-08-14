classdef FileListManager<handle




    properties(Hidden,SetAccess=immutable)
AppModel
ProjectInterface
EventHandler
    end

    properties(SetAccess=protected,GetAccess=public)
FileList
FileListTitle
CurrentSelected
FileRelativePath
CurrentSelectedFiles

AllProjectFiles
ReferenceList
WorkingProjectName
SelectedEvolution

ButtonStates
ProjectPath
ProjectName
TreeDigraph
FullFilePathMap
    end

    methods
        function this=FileListManager(appModel)
            this.AppModel=appModel;
            this.ProjectInterface=appModel.ProjectInterface;
            this.EventHandler=appModel.EventHandler;
            update(this);
        end

        function update(this)


            this.ReferenceList=this.ProjectInterface.getReferenceProjects;

            evolutionTreeManager=getSubModel(this.AppModel,'EvolutionsTreeManager');
            this.SelectedEvolution=evolutionTreeManager.SelectedEvolution;


            this.WorkingProjectName=this.getWorkingProject(evolutionTreeManager);

            if~isempty(this.SelectedEvolution)
                this.FileList=evolutions.internal.utils...
                .getBaseToArtifactsKeyValues(this.SelectedEvolution);
                this.setFileListTitle(this.SelectedEvolution);
            else
                this.FileList=cell.empty;
                this.FileListTitle=char.empty;
            end
            this.AllProjectFiles=getAllProjectFiles(this);
            findCurrentFile(this);
            notify(this.EventHandler,'FileListChanged');
        end

        function workingProjectName=getWorkingProject(~,evolutionTreeManager)
            rootEvolution=evolutionTreeManager.RootEvolution;
            if(~isempty(rootEvolution))
                currentWorkingProject=evolutionTreeManager.RootEvolution.getProjectRoot;
                currentWorkingProjectFields=regexp(currentWorkingProject,filesep,'split');
                workingProjectName=currentWorkingProjectFields{end};
            else
                workingProjectName='';
            end
        end


        function allProjectFiles=getAllProjectFiles(this)
            allProjectFiles=cell.empty;
            if(~isempty(this.FileList))
                currentProjectFiles=this.getCurrentProjectFiles(this.FileList);

                projectHierarchy=this.FileList;
                this.ProjectName=projectHierarchy(1).Project.Name;

                [mainProjectPath,mainRootFiles]=this.getRootFiles(projectHierarchy(1));
                allProjectFiles{1}=struct('mainRootFiles',mainRootFiles);


                this.ProjectPath=projectHierarchy(1).Project.RootFolder;




                mainParentFolder=this.getMainParentFolder(mainProjectPath,this.ProjectPath,mainRootFiles);



                if(numel(currentProjectFiles)==0)
                    allDetails=struct('NodesStruct','','EdgesStruct','');
                    allProjectFiles{end+1}=allDetails;
                else

                    [this.TreeDigraph,this.FullFilePathMap]=this.getFileAndFolderStruct(currentProjectFiles,mainParentFolder);
                    diagraphNodes=table2struct(this.TreeDigraph.Nodes);
                    diagraphEdges=table2struct(this.TreeDigraph.Edges);
                    diagraphfilePath=table2struct(this.FullFilePathMap);

                    currentProjectDetails=struct('NodesStruct',diagraphNodes,'EdgesStruct',diagraphEdges,'fullFilePathMap',diagraphfilePath);
                    allProjectFiles{end+1}=currentProjectDetails;
                end
            end
        end

        function currentProjectFiles=getCurrentProjectFiles(~,fileList)
            projectFiles={};
            for idx=1:length(fileList)
                projectFiles{end+1}=fileList(idx).File;%#ok<AGROW> 
            end



            [~,pathLength]=sort(cellfun(@length,projectFiles),'descend');
            currentProjectFiles=projectFiles(pathLength);
        end

        function findCurrentFile(this)
            if~isempty(this.CurrentSelected)&&...
                (isempty(this.FileList)||~ismember(this.CurrentSelected,this.FileList))



                this.CurrentSelected=[];
            end
        end

        function fileFullPaths=getAllFileFullPaths(this)
            fileFullPaths=values(this.FileList);
        end

        function fileFullPath=getFileFullPath(this,fileName)
            if isKey(this.FileList,fileName)
                fileFullPath=this.FileList(fileName);
            else
                fileFullPath=char.empty;
            end
        end

        function fileNames=getFileNames(this)
            fileNames=cell.empty;
            for idx=1:numel(this.FileList)
                [~,name,ext]=fileparts(this.FileList(idx).File);
                fileNames{end+1}=sprintf('%s%s',name,ext);%#ok<AGROW>
            end
        end

        function relativeFilePaths=getRelativeFilePaths(this)

            relativeFilePaths=cell(1,numel(this.FileList));
            for idx=1:numel(this.FileList)
                file=this.FileList(idx).File;
                fileName=this.FileList(idx).FileName;
                root=strrep(file,strcat(filesep,fileName),"");
                [~,currentFolderName]=this.getParentChildFolderName(root);
                fileName=strrep(file,strcat(root,filesep),"");
                rootFolderPath=this.FileList(idx).Project.RootFolder;
                relativePath=strrep(file,strcat(rootFolderPath,filesep),"");
                relativeFilePaths{idx}=struct('fileName',fileName,'parent',currentFolderName,'relativePath',relativePath);
            end
        end

        function setCurrentFile(this,file)
            this.CurrentSelected=file;
        end

        function currentSelected=changeCurrentSelected(this,fileName)
            fileList=this.FileList;
            for idx=1:numel(fileList)
                this.FileRelativePath=evolutions.internal.utils.getRelativePathFromProject(fileList(idx),fileList(idx).File);
                afterRootPath=extractAfter(fileName,fullfile(currentProject().RootFolder,filesep));
                if(strcmp(this.FileRelativePath,afterRootPath))
                    setCurrentFile(this,fileList(idx));
                    currentSelected=this.CurrentSelected;
                end
            end
        end

        function changeLatestSelectedFiles(this,fileList)
            this.CurrentSelectedFiles=fileList;
        end


        function updateButtonStates(this,buttonStates)
            this.ButtonStates=buttonStates;
            notify(this.EventHandler,'ButtonStatesChanged');
        end

    end

    methods(Access=protected)
        function setFileListTitle(this,node)
            this.FileListTitle=node.getName;
        end
    end

    methods(Access=private)
        function[mainProjectPath,mainRootFiles]=getRootFiles(~,topmostProject)


            mainProjectPath=topmostProject.Project.RootFolder;
            mainRootFiles=regexp(mainProjectPath,filesep,'split');
        end




        function[parentFolderName,mainFolderName]=getParentChildFolderName(~,projPath)
            pathFields=regexp(projPath,filesep,'split');
            parentFolderName=pathFields(pathFields.length-1);
            mainFolderName=pathFields(pathFields.length);
        end


        function mainParentFolder=getMainParentFolder(~,mainRootPath,projectPath,mainRootFiles)
            rootPath=strcat(mainRootPath,filesep);
            filePath=strcat(projectPath,filesep);
            mainParentFolderPath=strrep(filePath,rootPath,"");
            mainParentFolderCell=regexp(mainParentFolderPath,filesep,'split');




            if(length(mainParentFolderCell)>1)
                mainParentFolder=mainParentFolderCell{length(mainParentFolderCell)-1};


            elseif isequal(mainParentFolderCell,"")
                mainParentFolder=mainRootFiles{end};
            else
                mainParentFolder=mainParentFolderCell{1};
            end
        end









        function[TreeDigraph,fullFilePathMap]=getFileAndFolderStruct(this,currentProjectFiles,mainParentFolder)
            numFile=numel(currentProjectFiles);
            fullFilePathMap=table;

            [filePath,pathArray]=this.getPathArray(1,currentProjectFiles,mainParentFolder);

            [exampleMap,TreeDigraph]=this.createDigraph(filePath,pathArray,mainParentFolder);

            if(~isempty(exampleMap))
                fullFilePathMap=exampleMap;
            end


            for currentFileIndex=2:numFile
                [filePath,pathArray]=this.getPathArray(currentFileIndex,currentProjectFiles,mainParentFolder);
                [fullFilePathMap,TreeDigraph,previousId]=this.updateTreeDigraph(filePath,TreeDigraph,pathArray,fullFilePathMap);

                for id=2:length(pathArray)
                    if(id==2)
                        [val,previousUuid,entries]=this.findEdgeExists(TreeDigraph,pathArray,2,previousId);
                        if(isempty(previousUuid))
                            previousUuid=previousId;
                        end
                    else
                        pId=previousUuid;
                        [val,prevUid,entries]=this.findEdgeExists(TreeDigraph,pathArray,id,pId);
                        if(~isempty(prevUid))
                            previousUuid=prevUid;
                        end
                    end

                    if(~val||isempty(entries))
                        parentUuid=previousUuid;
                        curUuid={convertStringsToChars(matlab.lang.internal.uuid)};
                        [fullFilePathMap,TreeDigraph]=this.updateDigraphValues(fullFilePathMap,id,filePath,TreeDigraph,parentUuid,curUuid,pathArray);
                        previousUuid=curUuid;
                    end

                end

            end

        end

        function[fullFilePathMap,TreeDigraph]=updateDigraphValues(~,fullFilePathMap,id,filePath,TreeDigraph,parentUuid,childUuid,pathArray)
            exampleFilePath=table;%#ok<NASGU>
            if(~isfolder(filePath)&&id==length(pathArray))
                [~,~,ext]=fileparts(filePath);
                exampleFilePath=table(childUuid,{filePath},{ext},'VariableNames',{'Name','FilePath','Extension'});
                fullFilePathMap=[fullFilePathMap;exampleFilePath];
            end

            TreeDigraph=TreeDigraph.addnode(table(childUuid,pathArray(id),'variableNames',{'Name','Dir'}));
            TreeDigraph=TreeDigraph.addedge(table([parentUuid,childUuid],'variableNames',{'EndNodes'}));
        end


        function[fullFilePathMap,treeDigraph,previousId]=updateTreeDigraph(this,filePath,treeDigraph,pathArray,fullFilePathMap)
            nodeUuid=treeDigraph.Nodes.Name(1);
            [val,previousId,entries]=this.findEdgeExists(treeDigraph,pathArray,1,nodeUuid);
            exampleMap=table;%#ok<NASGU> 

            if(~val||isempty(entries))
                previousId={convertStringsToChars(matlab.lang.internal.uuid)};
                parentUuid=treeDigraph.Nodes.Name(1);
                [fullFilePathMap,treeDigraph]=this.updateDigraphValues(fullFilePathMap,1,filePath,treeDigraph,parentUuid,previousId,pathArray);
            end
        end




        function[val,previousUuid,entries]=findEdgeExists(~,treeDigraph,pathArray,id,prevId)
            val=0;
            previousUuid={};
            entries=find(strcmp(treeDigraph.Nodes.('Dir'),pathArray{id}));
            if(~isempty(entries))
                for idx=1:numel(entries)
                    val=findedge(treeDigraph,prevId,treeDigraph.Nodes.Name(entries(idx)));
                    if(val)
                        previousUuid=treeDigraph.Nodes.Name(entries(idx));
                        break
                    end
                end
            end
        end







        function[exampleMap,treeDigraph]=createDigraph(this,filePath,pathArray,mainParentFolder)




            if(length(pathArray)<2)
                tableUuids={convertStringsToChars(matlab.lang.internal.uuid)};
                nodeTable=table({convertStringsToChars(matlab.lang.internal.uuid);tableUuids{1}},...
                {mainParentFolder;pathArray{1}},'variableNames',{'Name','Dir'});
                edgeTable=table([nodeTable.Name(1),nodeTable.Name{2}],'variableNames',{'EndNodes'});

                [exampleMap,treeDigraph]=this.createInitalDigraph(pathArray,tableUuids,filePath,nodeTable,edgeTable);

            else
                tableUuids={convertStringsToChars(matlab.lang.internal.uuid),convertStringsToChars(matlab.lang.internal.uuid)};
                nodeTable=table({convertStringsToChars(matlab.lang.internal.uuid);tableUuids{1};tableUuids{2}},...
                {mainParentFolder;pathArray{1};pathArray{2}},'variableNames',{'Name','Dir'});
                edgeTable=table([nodeTable.Name(1),nodeTable.Name(2);nodeTable.Name(2),nodeTable.Name(3)],'variableNames',{'EndNodes'});

                [exampleMap,treeDigraph]=this.createInitalDigraph(pathArray,tableUuids,filePath,nodeTable,edgeTable);



                prevUuid=tableUuids(2);



                for id=3:length(pathArray)
                    curUUid={convertStringsToChars(matlab.lang.internal.uuid)};


                    if(~isfolder(filePath)&&id==length(pathArray))
                        [~,~,ext]=fileparts(filePath);
                        exampleMap=table(curUUid,{filePath},{ext},'VariableNames',{'Name','FilePath','Extension'});
                    end

                    treeDigraph=treeDigraph.addnode(table(curUUid,pathArray(id),'variableNames',{'Name','Dir'}));
                    treeDigraph=treeDigraph.addedge(table([prevUuid,curUUid],'variableNames',{'EndNodes'}));
                    prevUuid=curUUid;
                end
            end
        end

        function[exampleMap,treeDigraph]=createInitalDigraph(~,pathArray,tableUuids,filePath,nodeTable,edgeTable)
            exampleMap=table;
            for id=1:length(tableUuids)
                if(isfile(filePath)&&id==length(pathArray))
                    [~,~,ext]=fileparts(filePath);
                    exampleMap=table(tableUuids(id),{filePath},{ext},'VariableNames',{'Name','FilePath','Extension'});
                end
            end
            treeDigraph=digraph(edgeTable,nodeTable);
        end


        function[filePath,pathArray]=getPathArray(~,currentFileIndex,currentProjectFiles,mainParentFolder)
            file=currentProjectFiles{currentFileIndex};
            filePath=convertCharsToStrings(file);
            afterRootPath=extractAfter(filePath,mainParentFolder);
            pathCellArray=regexp(afterRootPath,filesep,'split');
            vb=cellfun(@isempty,pathCellArray);
            pathArray=pathCellArray(~vb);
        end

    end
end


