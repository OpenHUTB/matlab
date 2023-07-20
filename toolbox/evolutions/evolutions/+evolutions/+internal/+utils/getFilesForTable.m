function allFilesForTable=getFilesForTable(treedigraph,fullfilePathMap,currentProjectFiles,projectPath,~)



    allFilesForTable=cell.empty;

    [mainRootFiles]=getRootFiles(projectPath);
    allFilesForTable{1}=struct('mainRootFiles',mainRootFiles);




    mainParentFolder=getMainParentFolder(projectPath,projectPath,mainRootFiles);



    if(numel(currentProjectFiles)==0)
        allDetails=struct('NodesStruct','','EdgesStruct','');
        allFilesForTable{end+1}=allDetails;
        return;
    end

    [TreeDigraph,fullFilePathMap]=getFileAndFolderStruct(treedigraph,fullfilePathMap,currentProjectFiles,mainParentFolder);

    diagraphNodes=table2struct(TreeDigraph.Nodes);
    diagraphEdges=table2struct(TreeDigraph.Edges);
    diagraphfilePath=table2struct(fullFilePathMap);



    currentProjectDetails=struct('NodesStruct',diagraphNodes,'EdgesStruct',diagraphEdges,'fullFilePathMap',diagraphfilePath);
    allFilesForTable{end+1}=currentProjectDetails;
end

function[mainRootFiles]=getRootFiles(projectPath)



    mainRootFiles=regexp(projectPath,filesep,'split');
end


function mainParentFolder=getMainParentFolder(mainRootPath,projectPath,mainRootFiles)
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


function[TreeDigraph,fullFilePathMap]=getFileAndFolderStruct(treedigraph,fullfilePathMap,currentProjectFiles,mainParentFolder)
    numFile=numel(currentProjectFiles);
    fullFilePathMap=fullfilePathMap;
    TreeDigraph=treedigraph;
    startIndex=1;



    if(isempty(TreeDigraph.Nodes))
        startIndex=2;

        [filePath,pathArray]=getPathArray(1,currentProjectFiles,mainParentFolder);

        [exampleMap,TreeDigraph]=createDigraph(filePath,pathArray,mainParentFolder);

        if(~isempty(exampleMap))
            fullFilePathMap=exampleMap;
        end
    end
    for currentFileIndex=startIndex:numFile
        [filePath,pathArray]=getPathArray(currentFileIndex,currentProjectFiles,mainParentFolder);
        [fullFilePathMap,TreeDigraph,previousId]=updateTreeDigraph(filePath,TreeDigraph,pathArray,fullFilePathMap);

        for id=2:length(pathArray)

            if(id==2)
                [val,previousUuid,entries]=findEdgeExists(TreeDigraph,pathArray,2,previousId);
                if(isempty(previousUuid))
                    previousUuid=previousId;
                end
            else
                pId=previousUuid;
                [val,prevUid,entries]=findEdgeExists(TreeDigraph,pathArray,id,pId);
                if(~isempty(prevUid))
                    previousUuid=prevUid;
                end
            end


            if(~val||isempty(entries))
                parentUuid=previousUuid;
                curUuid={convertStringsToChars(matlab.lang.internal.uuid)};
                [fullFilePathMap,TreeDigraph]=updateDigraphValues(fullFilePathMap,id,filePath,TreeDigraph,parentUuid,curUuid,pathArray);
                previousUuid=curUuid;
            end

        end

    end

end

function[fullFilePathMap,treeDigraph,previousId]=updateTreeDigraph(filePath,treeDigraph,pathArray,fullFilePathMap)
    nodeUuid=treeDigraph.Nodes.Name(1);
    [val,previousId,entries]=findEdgeExists(treeDigraph,pathArray,1,nodeUuid);
    exampleMap=table;%#ok<NASGU>

    if(~val||isempty(entries))
        previousId={convertStringsToChars(matlab.lang.internal.uuid)};
        parentUuid=treeDigraph.Nodes.Name(1);
        [fullFilePathMap,treeDigraph]=updateDigraphValues(fullFilePathMap,1,filePath,treeDigraph,parentUuid,previousId,pathArray);
    end
end

function[fullFilePathMap,TreeDigraph]=updateDigraphValues(fullFilePathMap,id,filePath,TreeDigraph,parentUuid,childUuid,pathArray)
    exampleFilePath=table;%#ok<NASGU>

    if(~isfolder(filePath)&&id==length(pathArray))
        [~,~,ext]=fileparts(filePath);
        exampleFilePath=table(childUuid,{filePath},{ext},'VariableNames',{'Name','FilePath','Extension'});
        fullFilePathMap=[fullFilePathMap;exampleFilePath];
    end

    TreeDigraph=TreeDigraph.addnode(table(childUuid,pathArray(id),'variableNames',{'Name','Dir'}));
    TreeDigraph=TreeDigraph.addedge(table([parentUuid,childUuid],'variableNames',{'EndNodes'}));
end




function[val,previousUuid,entries]=findEdgeExists(treeDigraph,pathArray,id,prevId)
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


function[filePath,pathArray]=getPathArray(currentFileIndex,currentProjectFiles,mainParentFolder)
    file=currentProjectFiles{currentFileIndex};
    filePath=convertCharsToStrings(file);
    afterRootPath=extractAfter(filePath,mainParentFolder);
    pathCellArray=regexp(afterRootPath,filesep,'split');
    vb=cellfun(@isempty,pathCellArray);
    pathArray=pathCellArray(~vb);
end






function[exampleMap,treeDigraph]=createDigraph(filePath,pathArray,mainParentFolder)




    if(length(pathArray)<2)
        tableUuids={convertStringsToChars(matlab.lang.internal.uuid)};
        nodeTable=table({convertStringsToChars(matlab.lang.internal.uuid);tableUuids{1}},...
        {mainParentFolder;pathArray{1}},'variableNames',{'Name','Dir'});
        edgeTable=table([nodeTable.Name(1),nodeTable.Name{2}],'variableNames',{'EndNodes'});

        [exampleMap,treeDigraph]=createInitalDigraph(pathArray,tableUuids,filePath,nodeTable,edgeTable);

    else
        tableUuids={convertStringsToChars(matlab.lang.internal.uuid),convertStringsToChars(matlab.lang.internal.uuid)};
        nodeTable=table({convertStringsToChars(matlab.lang.internal.uuid);tableUuids{1};tableUuids{2}},...
        {mainParentFolder;pathArray{1};pathArray{2}},'variableNames',{'Name','Dir'});
        edgeTable=table([nodeTable.Name(1),nodeTable.Name(2);nodeTable.Name(2),nodeTable.Name(3)],'variableNames',{'EndNodes'});

        [exampleMap,treeDigraph]=createInitalDigraph(pathArray,tableUuids,filePath,nodeTable,edgeTable);



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

function[exampleMap,treeDigraph]=createInitalDigraph(pathArray,tableUuids,filePath,nodeTable,edgeTable)
    exampleMap=table;
    for id=1:length(tableUuids)
        if(~isfolder(filePath)&&id==length(pathArray))
            [~,~,ext]=fileparts(filePath);
            exampleMap=table(tableUuids(id),{filePath},{ext},'VariableNames',{'Name','FilePath','Extension'});
        end
    end
    treeDigraph=digraph(edgeTable,nodeTable);
end


