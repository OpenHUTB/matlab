classdef LibDictionaryDependencyInfo<handle






    properties(Access=private,Transient)
        slidCache;

serializeInDestructor
        writeLock;
    end

    properties(Access=private)
        version;
libraryGraph

libraryNodeInfoMap

eligibleToolBoxDirectorySet
    end

    methods(Access=public)

        function obj=LibDictionaryDependencyInfo
            obj.libraryGraph=digraph;
            obj.libraryNodeInfoMap=containers.Map;
            obj.version=1;
            obj.eligibleToolBoxDirectorySet=Simulink.data.internal.LibDictionaryDependencyInfo.readEligibleToolBoxDirectorySet();
            obj.serializeInDestructor=false;
        end


        function initializeSlidCache(obj)
            obj.slidCache=slid.broker.Cache.getInstance('');
            obj.slidCache.clearLibraryDictionaryLookupMap();
        end

        function setAutoSerializeInDestructor(obj,status)
            obj.serializeInDestructor=status;
        end


        function list=getLibraryConnectedSLDDs(obj,libPath)
            list=[];


            if~isDirFullPath(obj,libPath)
                [path,fileName,ext]=fileparts(libPath);
                if~isempty(path)
                    libPath=[getFullPathForDir(obj,path),filesep,fileName,ext];
                else
                    libPath=[pwd,filesep,libPath];
                end
            end

            if~isempty(obj.slidCache)
                list=obj.slidCache.lookUpDictionariesForLibrary(libPath);
            end
        end


        function refreshLibraryLinks(obj,fileOrDirectory)
            assert(~isempty(fileOrDirectory));


            if~isfile(fileOrDirectory)&&~isfolder(fileOrDirectory)
                error(message('SLDD:sldd:argNotFileOrDirectory',fileOrDirectory));
            end

            if isfile(fileOrDirectory)










                [filePath,fileName,fileExt]=fileparts(fileOrDirectory);


                if~isequal(fileExt,'.slx')
                    error(message('SLDD:sldd:argInvalidFileExtension',fileOrDirectory));
                end





                fullpathToFile=getFullPathForFile(obj,filePath,[fileName,fileExt]);

                refreshLibraryLinksForAModel(obj,fullpathToFile);
            else
                refreshLibraryLinksForADir(obj,fileOrDirectory)
            end

            obj.setAutoSerializeInDestructor(true);
        end


        function buildDependencyTree(obj,fileOrDirectory)
            if isfile(fileOrDirectory)
                libList=getLibraryForModel(obj,fileOrDirectory);
            else
                libList=getLibraryFromDir(obj,fileOrDirectory);
            end
            if isempty(libList)
                return;
            end

            openLibsAtStart=get_param(Simulink.allBlockDiagrams('library'),'name');
            updateTree(obj,libList);
            openLibsAtEnd=get_param(Simulink.allBlockDiagrams('library'),'name');
            newOpenLibs=setdiff(openLibsAtEnd,openLibsAtStart);
            bdclose(newOpenLibs);
        end


        function mergeGraphs(obj,obj2)
            if~isempty(obj2.libraryGraph.Nodes)
                for aNode=obj2.libraryGraph.Nodes.Name'
                    if isempty(obj.libraryGraph.Nodes)||~obj.libraryGraph.findnode(aNode)
                        obj.libraryGraph=obj.libraryGraph.addnode(aNode);
                    end
                end
            end

            if~isempty(obj2.libraryGraph.Edges)
                for idx=1:size(obj2.libraryGraph.Edges,1)
                    if isempty(obj.libraryGraph.Edges)||~obj.libraryGraph.findedge(obj2.libraryGraph.Edges(idx,1).EndNodes{1},...
                        obj2.libraryGraph.Edges(idx,1).EndNodes{2})
                        obj.libraryGraph=obj.libraryGraph.addedge(obj2.libraryGraph.Edges(idx,1).EndNodes{1},...
                        obj2.libraryGraph.Edges(idx,1).EndNodes{2});
                    end
                end

            end

            for aInfoMapCell=obj2.libraryNodeInfoMap.keys
                obj.libraryNodeInfoMap(aInfoMapCell{1})=obj2.libraryNodeInfoMap(aInfoMapCell{1});
            end
        end


        function disp(obj)
            disp('------------graph nodes------------');
            if~isempty(obj.libraryGraph.Nodes)
                for aNode=obj.libraryGraph.Nodes.Name'
                    directSLDD=obj.libraryNodeInfoMap(aNode{1}).DirectSLDD;
                    disp([aNode{1},'----->',directSLDD]);
                    if~isempty(obj.slidCache)
                        disp(obj.slidCache.lookUpDictionariesForLibrary(aNode{1})');
                    end
                end
            end

            disp('------------graph edges------------');
            if~isempty(obj.libraryGraph.Edges)
                obj.libraryGraph.Edges
            end
        end


        function clear(obj)
            obj.libraryGraph=digraph;
            if~isempty(obj.slidCache)
                obj.slidCache.clearLibraryDictionaryLookupMap();
            end
            obj.libraryNodeInfoMap=containers.Map;
        end


        function updateLibDDHashMapForAllNodes(obj)
            if~isempty(obj.libraryGraph.Nodes)
                libList=obj.libraryGraph.Nodes.Name';
                calculateHashMaplibSet=containers.Map(libList,false(1,length(libList)));
                updateLibDDHashMap(obj,calculateHashMaplibSet);
            end
        end


        function sobj=saveobj(obj)



            tStart=clock;
            maxRunningTime=10;
            while(obj.writeLock)
                tEnd=clock;
                if etime(tEnd,tStart)>maxRunningTime
                    error(message('SLDD:sldd:TimedOutLoadingLibraryCache'));
                end


            end


            obj.writeLock=true;

            sobj.libraryGraph=obj.libraryGraph;
            if(isempty(obj.libraryNodeInfoMap.keys))
                sobj.libraryNodeInfoMap=containers.Map;
            else

                sobj.libraryNodeInfoMap=containers.Map(obj.libraryNodeInfoMap.keys,...
                obj.libraryNodeInfoMap.values);
            end

            for i=1:numel(sobj.libraryGraph.Nodes)



                oldName=sobj.libraryGraph.Nodes(i,:).Name;
                fullNativeStyleName=oldName;
                rootReplacedNativeStyleName=strrep(fullNativeStyleName,matlabroot,'__MATLAB_ROOT__');



                if ispc


                    rootReplacedGenericStyleName=strrep(rootReplacedNativeStyleName,'\','/');
                else
                    rootReplacedGenericStyleName=rootReplacedNativeStyleName;
                end

                sobj.libraryGraph.Nodes(i,:).Name=rootReplacedGenericStyleName;


                key=oldName{1};


                value=sobj.libraryNodeInfoMap(key);
                sobj.libraryNodeInfoMap.remove(key);


                sobj.libraryNodeInfoMap(rootReplacedGenericStyleName{1})=value;
            end

            sobj.version=obj.version;


            obj.writeLock=false;
        end


        function delete(obj)
            if~isempty(obj)&&~obj.isEmptyDependencyInfoMap()&&obj.serializeInDestructor
                libInfoDir=[prefdir,filesep,'SLLibraryLinkageData'];
                if~isfolder(libInfoDir)
                    mkdir(libInfoDir);
                end
                saveFileName=[libInfoDir,filesep,'LibraryLinkageCache.mat'];


                obj.cleanupLibraryInfo;
                obj.removeShippingToolboxLibraries;
                save(saveFileName,'obj');
            end
        end
    end

    methods(Static,Access=public)
        function obj=loadobj(objToBeLoaded)





            obj=Simulink.data.internal.LibDictionaryDependencyInfo;
            if(isempty(fieldnames(objToBeLoaded)))



                return;
            end

            obj.libraryGraph=objToBeLoaded.libraryGraph;

            if~isfield(objToBeLoaded,'version')


                obj.libraryNodeInfoMap=objToBeLoaded.libraryNodeInfo;
            else
                obj.libraryNodeInfoMap=objToBeLoaded.libraryNodeInfoMap;
            end


            for i=1:numel(objToBeLoaded.libraryGraph.Nodes)






                oldName=objToBeLoaded.libraryGraph.Nodes(i,:).Name;
                rootReplacedGenericStyleName=oldName;
                if(startsWith(oldName,'__MATLAB_ROOT__'))




                    stringToReplace='__MATLAB_ROOT__';


                    fullNativeStyleName=strcat(matlabroot,fullfile(extractAfter(rootReplacedGenericStyleName,length(stringToReplace))));
                    obj.libraryGraph.Nodes(i,:).Name=fullNativeStyleName;
                else

                    fullNativeStyleName=fullfile(oldName);
                    obj.libraryGraph.Nodes(i,:).Name=fullNativeStyleName;
                end



                key=oldName{1};


                value=objToBeLoaded.libraryNodeInfoMap(key);
                obj.libraryNodeInfoMap.remove(key);


                obj.libraryNodeInfoMap(fullNativeStyleName{1})=value;
            end
        end
    end


    methods(Access=private)


        function loadedModelName=safeload(obj,modelPath)
            loadedModelName='';
            fileNameOnly=filenameFromFullPath(obj,modelPath);
            if bdIsLoaded(fileNameOnly)
                loadedModelName=fileNameOnly;
            else
                existVal=exist(modelPath,'file');
                if(existVal==4)||...
                    (existVal==2)
                    try
                        load_system(modelPath);
                        loadedModelName=fileNameOnly;
                    catch
                    end
                end
            end
        end


        function refreshLibraryLinksForADir(obj,dirName)


            if(~isDirFullPath(obj,dirName))
                dirName=getFullPathForDir(obj,dirName);
            end

            libList=getLibraryFromDir(obj,dirName);
            processLibList(obj,libList);
        end

        function refreshLibraryLinksForAModel(obj,modelPath)
            libList=getLibraryForModel(obj,modelPath);
            processLibList(obj,libList);
        end


        function libList=getLibraryFromDir(~,thisDir)
            libList={};
            models=dir([thisDir,filesep,'*.slx']);

            if~isempty(models)
                for aModel=models'
                    fullFileName=[thisDir,filesep,aModel.name];

                    mdlInfo=Simulink.MDLInfo(fullFileName);
                    if~mdlInfo.IsLibrary
                        continue;
                    end
                    libList{end+1}=fullFileName;%#ok<AGROW> 
                end
            end
        end


        function libList=getLibraryForModel(obj,modelPath)
            mdlInfo=Simulink.MDLInfo(modelPath);
            if mdlInfo.IsLibrary
                libList={modelPath};
            else
                libList=findDirectChildren(obj,modelPath);
            end
        end


        function processLibList(obj,libList)
            if isempty(libList)
                return;
            end

            openLibsAtStart=get_param(Simulink.allBlockDiagrams('library'),'name');

            parentImpactingLibSet=updateTree(obj,libList);
            impactedLibSet=identifyImpactedLibs(obj,parentImpactingLibSet);
            updateLibDDHashMap(obj,impactedLibSet);

            openLibsAtEnd=get_param(Simulink.allBlockDiagrams('library'),'name');
            newOpenLibs=setdiff(openLibsAtEnd,openLibsAtStart);
            bdclose(newOpenLibs);
        end


        function updateLibDDHashMap(obj,impactedLibSet)
            impactedLibList=impactedLibSet.keys();
            newLibSLDDMap=containers.Map;
            for aImpactedLibCell=impactedLibList
                aImpactedLib=aImpactedLibCell{1};
                [~,newLibSLDDMap]=calculateDDForLib(obj,aImpactedLib,impactedLibSet,newLibSLDDMap);
            end
        end


        function[slddList,newLibSLDDMap]=calculateDDForLib(obj,libPath,impactedLibSet,newLibSLDDMap)

            if~impactedLibSet.isKey(libPath)
                slddList=obj.slidCache.lookUpDictionariesForLibrary(libPath);
            else
                if newLibSLDDMap.isKey(libPath)
                    slddList=newLibSLDDMap(libPath);
                else
                    slddSet=containers.Map;
                    assert(obj.libraryNodeInfoMap.isKey(libPath));
                    directDD=obj.libraryNodeInfoMap(libPath).DirectSLDD;

                    childLibs=obj.libraryGraph.successors(libPath)';
                    for aChildLibCell=childLibs
                        aChildLib=aChildLibCell{1};
                        [childSldds,newLibSLDDMap]=calculateDDForLib(obj,aChildLib,impactedLibSet,newLibSLDDMap);
                        for aChildSLDDCell=childSldds
                            slddSet(aChildSLDDCell{1})=true;
                        end
                    end
                    slddList=slddSet.keys;
                    if~isempty(slddList)
                        obj.slidCache.setLibraryDictionaryLookup(libPath,slddList,true);
                    end

                    if~isempty(directDD)
                        slddSet(directDD)=true;
                    end

                    slddList=slddSet.keys;
                    newLibSLDDMap(libPath)=slddList;
                    if~isempty(slddList)
                        obj.slidCache.setLibraryDictionaryLookup(libPath,slddList);
                    elseif~isempty(obj.slidCache.lookUpDictionariesForLibrary(libPath))
                        obj.slidCache.removeLibraryDictionaryLookup(libPath);
                    end
                end

            end

        end


        function impactedLibSet=identifyImpactedLibs(obj,parentImpactingLibSet)

            impactedLibList=parentImpactingLibSet.keys();
            if isempty(parentImpactingLibSet)
                impactedLibSet=containers.Map();
            else
                impactedLibSet=containers.Map(impactedLibList,false(1,length(impactedLibList)));
            end


            impactedIdx=1;
            while impactedIdx<=length(impactedLibList)
                impactedLib=impactedLibList{impactedIdx};
                parents=obj.libraryGraph.predecessors(impactedLib)';
                for aParentCell=parents
                    aParent=aParentCell{1};
                    if~impactedLibSet.isKey(aParent)
                        impactedLibSet(aParent)=false;
                        impactedLibList{end+1}=aParent;%#ok<AGROW>
                    end
                end
                impactedIdx=impactedIdx+1;
            end
        end


        function parentImpactingLibSet=updateTree(obj,libList)

            exploreLibSet=containers.Map(libList,false(1,length(libList)));
            exploreLibList=libList;


            parentImpactingLibSet=containers.Map;

            explorListIdx=1;
            while explorListIdx<=length(exploreLibList)
                libPath=exploreLibList{explorListIdx};
                if~isModelDirty(obj,libPath)

                    isLibKnown=obj.libraryNodeInfoMap.isKey(libPath);
                    if isLibKnown
                        currentInfo=obj.libraryNodeInfoMap(libPath);
                        if currentInfo.LastModified==dir(libPath).datenum
                            explorListIdx=explorListIdx+1;
                            continue;
                        else
                            [parentImpact,childLibs]=updateLibNode(obj,libPath);

                        end
                    else
                        [parentImpact,childLibs]=addNewLib(obj,libPath);
                    end
                    if(parentImpact)
                        parentImpactingLibSet(libPath)=false;
                    end
                    for aChildLibCell=childLibs
                        aChildLib=aChildLibCell{1};
                        if~exploreLibSet.isKey(aChildLib)
                            exploreLibSet(aChildLib)=false;
                            exploreLibList{end+1}=aChildLib;%#ok<AGROW>
                        end
                    end

                end
                explorListIdx=explorListIdx+1;

            end
        end


        function[parentImpact,currentChildren]=addNewLib(obj,libPath)

            infoStruct=createNodeInfoStruct(obj,libPath);
            if~isempty(infoStruct)
                obj.libraryGraph=obj.libraryGraph.addnode(libPath);
                obj.libraryNodeInfoMap(libPath)=infoStruct;
                currentChildren=findDirectChildren(obj,libPath);
                if~isempty(infoStruct.DirectSLDD)||~isempty(currentChildren)
                    parentImpact=true;
                else
                    parentImpact=false;
                end

                addSuccesorsInTree(obj,libPath,currentChildren);
            end
        end


        function addSuccesorsInTree(obj,parentLib,childLibs)
            for aChildLibCell=childLibs
                aChildLib=aChildLibCell{1};
                isChildLibKnown=obj.libraryNodeInfoMap.isKey(aChildLib);
                if~isChildLibKnown


                    obj.libraryNodeInfoMap(aChildLib)=struct('DirectSLDD','',...
                    'LastModified',[]);
                    obj.libraryGraph=obj.libraryGraph.addnode(aChildLib);
                end
                obj.libraryGraph=obj.libraryGraph.addedge(parentLib,aChildLib);
            end
        end



        function[parentImpact,currentChildren]=updateLibNode(obj,libPath)
            parentImpact=false;
            currentChildren={};
            currentInfoStruct=createNodeInfoStruct(obj,libPath);
            if isempty(currentInfoStruct)

                return;
            end
            storedLibNodeInfoStruct=obj.libraryNodeInfoMap(libPath);
            if~strcmp(storedLibNodeInfoStruct.DirectSLDD,currentInfoStruct.DirectSLDD)
                parentImpact=true;
            end
            obj.libraryNodeInfoMap(libPath)=currentInfoStruct;


            currentChildren=findDirectChildren(obj,libPath);


            oldChildren=obj.libraryGraph.successors(libPath)';

            edgesToDelete=setdiff(oldChildren,currentChildren);
            edgesToAdd=setdiff(currentChildren,oldChildren);
            if~isempty(edgesToDelete)||~isempty(edgesToAdd)
                parentImpact=true;
            end

            if~isempty(edgesToDelete)
                for edgeToDelete=edgesToDelete
                    obj.libraryGraph=obj.libraryGraph.rmedge(libPath,edgeToDelete{1});
                end
            end

            if~isempty(edgesToAdd)
                addSuccesorsInTree(obj,libPath,edgesToAdd);
            end


        end


        function directChildren=findDirectChildren(obj,modelPath)

            directChildren={};
            loadedModelName=safeload(obj,modelPath);
            if isempty(loadedModelName)

                return;
            end


            childrenLibInfo=libinfo(loadedModelName,'FollowLinks','off',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices);
            childrenSet=containers.Map;
            for aChildLibInfo=childrenLibInfo'
                aChild=which(aChildLibInfo.Library);
                if strcmp(modelPath,aChild)||isIneligible(obj,aChild)
                    continue;
                end
                childrenSet(aChild)=true;
            end

            subLibList=slblocksearchdb.getLibraryRootNode(modelPath).Children;
            for aSubLib=subLibList
                if isa(aSubLib.Details,'slblocksearchdb.LibraryDetails')
                    subLibFullPath=which(aSubLib.Details.OpenFunction);
                    if isempty(subLibFullPath)||strcmp(modelPath,subLibFullPath)||isIneligible(obj,subLibFullPath)
                        continue;
                    end
                    childrenSet(subLibFullPath)=true;
                end
            end

            directChildren=childrenSet.keys;
        end


        function isDirty=isModelDirty(obj,modelPath)
            fileNameOnly=filenameFromFullPath(obj,modelPath);
            isDirty=bdIsLoaded(fileNameOnly)&&bdIsDirty(fileNameOnly);
        end


        function fileName=filenameFromFullPath(~,fullspec)
            [~,name,~]=fileparts(fullspec);
            fileName=name;
        end


        function isFullPath=isDirFullPath(~,path)
            if ispc


                pathInDOSStyle=strrep(path,'/','\');





                isFullPath=~isempty(regexp(pathInDOSStyle,...
                '^(([a-zA-z]:\\)|(\\\\))','once'));
            else
                isFullPath=~isempty(regexp(path,'^/','once'));
            end

        end


        function fullPath=getFullPathForDir(~,dirPath)


            currentDir=cd(dirPath);
            cleanupObj=onCleanup(@()cd(currentDir));

            newDirPath=pwd;
            if~isequal(newDirPath,currentDir)

                fullPath=newDirPath;
            end

        end


        function fullPath=getFullPathForFile(~,filePath,fileNameWithExt)
            assert(~isempty(fileNameWithExt));

            if isempty(filePath)
                fullPath=[pwd,filesep,fileNameWithExt];
                return;
            end





            try
                currentDir=cd(filePath);
                cleanupObj=onCleanup(@()cd(currentDir));
            catch e
                error(message('SLDD:sldd:argNotFileOrDirectory',filepath));
            end



            fullPath=[pwd,filesep,fileNameWithExt];
        end


        function retStruct=createNodeInfoStruct(obj,libPath)
            retStruct=[];
            loadedLibName=safeload(obj,libPath);
            if~isempty(loadedLibName)
                retStruct.DirectSLDD=get_param(loadedLibName,'DataDictionary');
                retStruct.LastModified=dir(libPath).datenum;
            end
        end


        function y=isIneligible(obj,aLibPath)
            y=false;
            mrootFindIdx=strfind(aLibPath,matlabroot);
            isInMatlabRoot=~isempty(mrootFindIdx)&&mrootFindIdx(1)==1;
            if isInMatlabRoot
                testDir=[matlabroot,filesep,'test'];
                testDirFindIdx=strfind(aLibPath,testDir);
                isInTestDir=~isempty(testDirFindIdx)&&testDirFindIdx(1)==1;
                if~isInTestDir
                    eligibleToolBoxDirs=obj.eligibleToolBoxDirectorySet.keys;
                    isInEligibleToolbxDir=false;
                    for toolboxDirCell=eligibleToolBoxDirs
                        findIdx=strfind(aLibPath,toolboxDirCell{1});
                        if~isempty(findIdx)&&findIdx(1)==1
                            isInEligibleToolbxDir=true;
                            break;
                        end
                    end
                    if~isInEligibleToolbxDir
                        y=true;
                    end
                end
            end
        end


        function retVal=isEmptyDependencyInfoMap(obj)
            retVal=isempty(obj.libraryGraph.Nodes)&&...
            isempty(obj.libraryGraph.Edges)&&...
            isempty(obj.libraryNodeInfoMap);
        end


        function cleanupLibraryInfo(obj)
            if~isempty(obj.libraryGraph.Nodes)
                for aNodeCell=obj.libraryGraph.Nodes.Name'
                    if~isfile(aNodeCell{1})
                        obj.libraryGraph=obj.libraryGraph.rmnode(aNodeCell{1});
                        obj.libraryNodeInfoMap.remove(aNodeCell{1});
                    end
                end
            end
            updateLibDDHashMapForAllNodes(obj);
        end


        function removeShippingToolboxLibraries(obj)








            for graphNode=obj.libraryGraph.Nodes.Name'
                fullNativeStyleName=graphNode;
                if startsWith(fullNativeStyleName,matlabroot)





                    nodeIdOfInterest=obj.libraryGraph.findnode(fullNativeStyleName);
                    edgesToNode=obj.libraryGraph.inedges(nodeIdOfInterest);
                    nodeShouldBeDeleted=true;
                    for j=1:numel(edgesToNode)
                        [fromNode,~]=obj.libraryGraph.findedge(edgesToNode(j));
                        if~startsWith(obj.libraryGraph.Nodes.Name(fromNode),matlabroot)
                            nodeShouldBeDeleted=false;
                            break;
                        end
                    end

                    if nodeShouldBeDeleted
                        obj.libraryGraph=obj.libraryGraph.rmnode(fullNativeStyleName);
                        obj.libraryNodeInfoMap.remove(fullNativeStyleName);
                    end
                end

            end
        end
    end

    methods(Access=public,Static)

        function dirSet=readEligibleToolBoxDirectorySet()
            dirSet=containers.Map;

            dirListFile=[Simulink.LibraryDictionary.getToolboxInternalPath,filesep,'libddtoolboxdirs.txt'];

            if exist(dirListFile,'file')
                fileText=fileread(dirListFile);
                registeredToolboxPaths=regexp(fileText,'\r\n|\r|\n','split');
                for dirPath=registeredToolboxPaths
                    cleanDirPath=strip(dirPath);
                    if(startsWith(dirPath,'#')||isempty(char(cleanDirPath)))
                        continue;
                    end

                    if ispc
                        unixPathSep='/';
                        fullPath=[matlabroot,filesep,regexprep(char(cleanDirPath),unixPathSep,filesep)];
                    else

                        fullPath=[matlabroot,filesep,char(cleanDirPath)];
                    end

                    dirSet(char(fullPath))=true;
                end
            end
        end
    end

    methods(Access=public,Hidden)

        function graph=getLibraryGraph(obj)
            graph=obj.libraryGraph;
        end










    end

end


