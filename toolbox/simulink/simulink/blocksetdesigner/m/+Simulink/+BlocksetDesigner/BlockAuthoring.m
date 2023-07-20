classdef BlockAuthoring<handle





    properties(Hidden=true)
        Project='';
        ProjectRoot='';

        S_FUN_FUNCTION_NAME='S_FUN_FUNCTION_NAME';
        S_FUN_MEX_FILE='S_FUN_MEX_FILE';
        S_FUN_FILE='S_FUN_FILE';
        S_FUN_HEADER='S_FUN_HEADER';
        S_FUN_TLC='S_FUN_TLC';
        DOC_SCRIPT='DOC_SCRIPT';
        DOC_FILE='DOC_FILE';
        TEST_SCRIPT='TEST_SCRIPT';
        TEST_HARNESS='TEST_HARNESS';
        BLOCK_LIBRARY='BLOCK_LIBRARY';
        BLOCK_ICON='BLOCK_ICON';
        S_FUN_BUILD='S_FUN_BUILD';
        S_FUN_BUILD_REPORT='S_FUN_BUILD_REPORT';
        BLOCKSET_LIBRARY='BLOCKSET_LIBRARY';
        BLOCKSET_SCRIPT='BLOCKSET_SCRIPT';
        CHECK_REPORT='CHECK_REPORT';
        TEST_REPORT='TEST_REPORT';
        INFO_XML='INFO_XML';
        HELPTOC_XML='HELPTOC_XML';
        BLOCKSET_DOC_SCRIPT='BLOCKSET_DOC_SCRIPT';
        BLOCKSET_DOC_HTML='BLOCKSET_DOC_HTML';
        SYSTEM_OBJECT_FILE='SYSTEM_OBJECT_FILE';
        MLSYS_SYSTEM='MLSYS_SYSTEM';
        BLOCKSET_ROOT_SCRIPT='BLOCKSET_ROOT_SCRIPT';

        BLOCKSET_NAME='BLOCKSET_NAME';
        ISBUILDER='ISBUILDER';
        ISPACKAGED='ISPACKAGED';
        UNDEFINED='UNDEFINED';
        BUILD='BUILD';
        TEST='TEST';
        DOCUMENT='DOCUMENT';
        TEST_TIMESTAMP='TEST_TIMESTAMP';
        BUILD_TIMESTAMP='BUILD_TIMESTAMP';
        DOCUMENT_TIMESTAMP='DOCUMENT_TIMESTAMP';

        PASS='PASS';
        NOTRUN='NOTRUN';
        FAIL='FAIL';
        WARNING='WARNING';
        OUTOFDATE='OUTOFDATE';
        DOCUMENT_CHECKBOX_ENABLE='DOCUMENT_CHECKBOX_ENABLE';
        TEST_CHECKBOX_ENABLE='TEST_CHECKBOX_ENABLE';
        BUILD_CHECKBOX_ENABLE='BUILD_CHECKBOX_ENABLE';


        LibName='LibName'
        LibDesc='LibDesc'
        LibPath='LibPath'
        ParentLibPath='ParentLibPath'
        OpenFunction='OpenFunction'
        IsRoot='IsRoot'
    end

    methods(Static)
        function out=setgetMetaDataManager(manager)
            persistent Var;
            if nargin
                Var=manager;
            end
            out=Var;
        end
    end


    methods(Access=public,Hidden=true)
        function this=BlockAuthoring()
            this.Project=matlab.project.rootProject;
            manager=Simulink.BlocksetDesigner.BlockAuthoring.setgetMetaDataManager;
            if~isempty(this.Project)
                this.ProjectRoot=char(this.Project.RootFolder);
            end
            if isempty(manager)
                Simulink.BlocksetDesigner.BlockAuthoring.setgetMetaDataManager(Simulink.BlocksetDesigner.internal.MetaDataManager());
            end
        end



        function metaDataManager=getMetaDataManager(obj)
            metaDataManager=Simulink.BlocksetDesigner.BlockAuthoring.setgetMetaDataManager();
            if isempty(metaDataManager)
                metaDataManager=Simulink.BlocksetDesigner.BlockAuthoring.setgetMetaDataManager(Simulink.BlocksetDesigner.internal.MetaDataManager());
            end
        end

        function clearAllBlocksMetaData(obj)
            metaDataManager=obj.getMetaDataManager();
            metaDataManager.clearAllBlocksMetaData();
        end

        function setBlockSetMetaData(obj,types,data)
            metaDataManager=obj.getMetaDataManager();
            metaDataManager.setBlockSetMetaData(types,data);
        end

        function data=getBlockSetMetaData(obj,types)
            metaDataManager=obj.getMetaDataManager();
            data=metaDataManager.getBlockSetMetaData(types);
        end

        function writeToDataModel(obj,entityInfo)
            fields={};
            filteredFields={'Id','ParentId','Type','IsLeafNode','IsSupported'};
            if isobject(entityInfo)
                fields=properties(entityInfo);
            elseif isstruct(entityInfo)
                fields=fieldnames(entityInfo);
            else
                return;
            end
            types={};
            data={};
            for i=1:numel(fields)


                if~any(strcmp(filteredFields,fields{i}))
                    types=[{fields{i}},types];
                    data=[{entityInfo.(fields{i})},data];
                end
            end
            obj.setBlockMetaData(entityInfo.Id,types,data);
        end

        function setBlockMetaData(obj,blockId,types,data)
            metaDataManager=obj.getMetaDataManager();
            if~isempty(metaDataManager.ProjectFileMetadataManager)
                metaDataManager.setBlockMetaData(blockId,types,data);
            end
        end

        function data=getBlockMetaData(obj,blockId,types,varargin)
            metaDataManager=obj.getMetaDataManager();
            if~isempty(metaDataManager.ProjectFileMetadataManager)
                if nargin==3
                    data=metaDataManager.getBlockMetaData(blockId,types);
                else
                    data=metaDataManager.getBlockMetaData(blockId,types,varargin{1});
                end
            else
                data='';
            end
        end

        function deleteBlockMetaData(obj,blockId)
            metaDataManager=obj.getMetaDataManager();
            metaDataManager.deleteBlockMetaData(blockId);
        end

        function files=getBlockFilesByType(obj,blockId,type,varargin)

            files='';
            data=obj.getBlockMetaDataAtRoot(blockId,type);
            if isempty(data)
                files='';
                return;
            end
            re=strsplit(data,';');
            if(~isempty(varargin)&&isequal(varargin{1},'all'))
                files=re;
            else
                files=re{1};
            end
        end

        function setFileType(obj,filepath,type,blockId)

            if~isempty(filepath)
                dataMap=containers.Map();
                dataMap('type')=type;
                dataMap('blockId')=blockId;
                obj.setFileMetaData(fullfile(obj.ProjectRoot,filepath),dataMap);
            end
        end

        function[type,blockId]=getFileType(obj,filepath)
            dataMap=obj.getFileMetaData(filepath);
            if(isempty(dataMap))
                type='';
                blockId='';
            else
                type=char(dataMap.get('type'));
                blockId=char(dataMap.get('blockId'));
            end
        end

        function[filepaths,filetype]=getDependsOn(obj,targetfilepath)


            [filetype,blockId]=obj.getFileType(targetfilepath);
            switch filetype
            case obj.S_FUN_MEX_FILE
                filepaths=[obj.getBlockFilesByType(blockId,obj.S_FUN_FILE,'all'),obj.getBlockFilesByType(blockId,obj.S_FUN_BUILD,'all')];
            case obj.TEST_SCRIPT
                filepaths=obj.getBlockFilesByType(blockId,obj.TEST_HARNESS,'all');
            otherwise


                filepaths={};
            end
        end



        function setBlockMetaDataAtRoot(obj,blockName,dataMap)
            metaDataManager=obj.getMetaDataManager();
            metaDataManager.setBlockMetaDataAtRoot(blockName,dataMap);
        end

        function data=getBlockMetaDataAtRoot(obj,blockName,types)
            metaDataManager=obj.getMetaDataManager();
            data=metaDataManager.getBlockMetaDataAtRoot(blockName,types);
        end



        function dataMap=getFileMetaData(obj,filepath)
            metaDataManager=obj.getMetaDataManager();
            dataMap=metaDataManager.getFileMetaData(filepath);
        end

        function setFileMetaData(obj,filepath,dataMap)
            metaDataManager=obj.getMetaDataManager();
            metaDataManager.setFileMetaData(filepath,dataMap);
        end

        function metadataMap=getMetadata(obj)
            metaDataManager=obj.getMetaDataManager();
            metadataMap=metaDataManager.getMetadata();
        end

        function updateSublibraryList(obj,newSublibrary)
            dataMap=containers.Map();
            sublibraries=obj.getSublibrariesInProject();
            if~contains(sublibraries,newSublibrary)
                if(isempty(sublibraries))
                    dataMap('sublibraryList')=newSublibrary;
                else
                    dataMap('sublibraryList')=[sublibraries,';',newSublibrary];
                end
                obj.setFileMetaData(obj.Project.RootFolder,dataMap);
            end
        end

        function sublibraries=getSublibrariesInProject(obj)
            dataMap=obj.getFileMetaData(obj.ProjectRoot);
            if(~isempty(dataMap))
                sublibraryList=dataMap.get('sublibraryList');
                if(isempty(sublibraryList))
                    sublibraries='';
                else
                    sublibraries=char(sublibraryList);
                end
            else
                sublibraries='';
            end
        end

        function updateBlockList(obj,newBlock)
            dataMap=containers.Map();
            blocks=obj.getBlocksInProject();
            if~contains(blocks,newBlock)
                if(isempty(blocks))
                    dataMap('blockList')=newBlock;
                else
                    dataMap('blockList')=[blocks,';',newBlock];
                end
                obj.setFileMetaData(obj.Project.RootFolder,dataMap);
            end
        end

        function blocks=getBlocksInProject(obj)
            dataMap=obj.getFileMetaData(obj.ProjectRoot);
            if~isempty(dataMap)
                blocks=dataMap.get('blockList');
                if isempty(blocks)
                    blocks='';
                else
                    blocks=char(blocks);
                end

            else
                blocks='';
            end
        end



        function output=processName(obj,name)
            output=matlab.lang.makeValidName(name);
        end

        function abpath=abPath(obj,path)
            abpath=fullfile(obj.ProjectRoot,path);
        end

        function path=normPath(obj,abpath)

            path=extractAfter(abpath,[obj.ProjectRoot,filesep]);
        end

        function output=normalizeFilePath(obj,filepath)

            output=regexprep(filepath,'[\\]','/');
        end

        function output=restoreFilePath(obj,filepath)

            output=regexprep(filepath,'[/]',filesep);
        end

        function notifyUI(obj,rawdata)
            message.publish('/blocksetdesigner/mlpublish',rawdata);
        end



        function updateProgressBar(obj,content)
            msg.command='updateProgressBar';
            msg.data=content;
            msg.header='';
            obj.notifyUI(msg);
        end



        function updateLoadingSpinner(obj,content)
            msg.command='updateLoadingSpinner';
            msg.data=content;
            msg.header='';
            obj.notifyUI(msg);
        end

        function result=checkExistingFile(obj,blockName)
            search=which(blockName);
            if contains(search,[blockName,'.m'])||contains(search,[blockName,'.',mexext])
                result=true;
                return;
            end
            result=false;
        end

        function addBlockToParentLibrary(obj,blockName,blockpath,parentLibrary)
            if isempty(parentLibrary)
                blockSetFile=obj.getBlockSetMetaData(obj.BLOCKSET_LIBRARY);
                [~,parentLibrary,~]=fileparts(blockSetFile);
            end
            cleanup='';
            if(~bdIsLoaded(parentLibrary))
                load_system(parentLibrary);
                cleanup=onCleanup(@()close_system(parentLibrary));
            end

            set_param(parentLibrary,'Lock','off');



            numberOfBlocks=numel(find_system(parentLibrary,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices));

            column=mod(numberOfBlocks-1,3);
            row=(numberOfBlocks-1-column)/3;

            position=[150*(column+1),120*(row+1),100+150*(column+1),70+120*(row+1)];

            h=getSimulinkBlockHandle([parentLibrary,'/',blockName]);

            if isequal(h,-1)
                add_block(blockpath,[parentLibrary,'/',blockName],'Position',position);
            else
                oldPosition=get_param([parentLibrary,'/',blockName],'Position');
                delete_block(h);
                add_block(blockpath,[parentLibrary,'/',blockName],'Position',oldPosition);
            end
            save_system(parentLibrary);
        end

        function blockData=openLibraryAndRegisterIconListener(obj,blockId,libFile,isReload)
            [~,model,~]=fileparts(libFile);
            if~bdIsLoaded(model)
                load_system(model);
            end
            blockData=obj.preCallback(blockId,model,isReload);
            blockDiagramHandle=get_param(model,'Object');
            if~blockDiagramHandle.hasCallback('PreSave','picturechanged')
                Simulink.addBlockDiagramCallback(model,'PreSave','picturechanged',@()obj.postCallback(blockId,model));
            end
        end

        function blockData=preCallback(obj,blockId,lib,isReload)
            blockData='';
            blockData.Id=blockId;
            set_param(lib,'Lock','off');
            data=obj.getBlockMetaData(blockId,{'BlockPath','BlockType','BlockName'});
            blockpath=data{1};
            blockType=data{2};
            blockName=data{3};
            Simulink.Block.eval(blockpath);
            hilite_system(blockpath);
            iconfile=obj.generateBlockIcon(blockId);
            if~isempty(iconfile)
                obj.setBlockMetaData(blockId,obj.BLOCK_ICON,iconfile);
                obj.Project.addFile(obj.abPath(iconfile));
            end
            blockData.BLOCK_ICON=iconfile;
            if isReload

                switch blockType
                case 'S-Function'
                    sfunName=get_param(blockpath,'FunctionName');
                    obj.setBlockMetaData(blockId,obj.S_FUN_FUNCTION_NAME,sfunName);
                    blockData.S_FUN_FUNCTION_NAME=sfunName;
                    result=obj.findSfunctionFileInProject(blockName,sfunName,'mex');
                    if~isempty(result)
                        obj.setBlockMetaData(blockId,obj.S_FUN_MEX_FILE,result);
                        blockData.S_FUN_MEX_FILE=result;
                    end
                    result=obj.findSfunctionFileInProject(blockName,sfunName,'src');
                    if~isempty(result)
                        obj.setBlockMetaData(blockId,obj.S_FUN_FILE,result);
                        blockData.S_FUN_FILE=result;
                    end
                case 'MATLABSystem'
                    systemobjName=get_param(blockpath,'System');
                    obj.setBlockMetaData(blockId,obj.MLSYS_SYSTEM,systemobjName);
                    blockData.MLSYS_SYSTEM=systemobjName;
                    result=obj.findMATLABSystemFile(systemobjName,obj.SYSTEM_OBJECT_FILE);
                    if~isempty(result)
                        obj.setBlockMetaData(blockId,obj.SYSTEM_OBJECT_FILE,result);
                        blockData.SYSTEM_OBJECT_FILE=result;
                    end
                end
            end
        end

        function postCallback(obj,blockId,lib)
            param.Id=blockId;
            blockpath=obj.getBlockMetaData(blockId,'BlockPath');
            handle=getSimulinkBlockHandle(blockpath);
            if handle==-1
                h=msgbox(DAStudio.message('Simulink:SFunctions:BlockSetSDKBlockNotFound',blockpath),DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
                h.Tag='Simulink_BlocksetDesigner_Alert';
                return;
            end
            if contains(blockpath,lib)
                Simulink.Block.eval(blockpath);
                iconfile=obj.generateBlockIcon(blockId);
                if~isempty(iconfile)
                    obj.setBlockMetaData(blockId,obj.BLOCK_ICON,iconfile);
                    obj.Project.addFile(obj.abPath(iconfile));
                end
                param.BLOCK_ICON=iconfile;
                blockType=get_param(blockpath,'BlockType');
                blockName=get_param(blockpath,'Name');
                obj.setBlockMetaData(blockId,'BlockType',blockType);
                param.BlockType=blockType;
                param.BlockName=blockName;
                if isequal(blockType,'S-Function')&&isa(obj,'Simulink.BlocksetDesigner.Sfunction')
                    functionName=get_param(blockpath,'FunctionName');
                    mexFile=obj.findSfunctionFileInProject(blockName,functionName,'mex');
                    obj.setBlockMetaData(blockId,{obj.S_FUN_FUNCTION_NAME,obj.S_FUN_MEX_FILE},{functionName,mexFile});
                    param.S_FUN_FUNCTION_NAME=functionName;
                    param.S_FUN_MEX_FILE=mexFile;
                end
                if isequal(blockType,'MATLABSystem')&&isa(obj,'Simulink.BlocksetDesigner.MATLABSystem')
                    systemName=get_param(blockpath,'System');
                    systemobjFile=obj.findMATLABSystemFile(systemName,obj.SYSTEM_OBJECT_FILE);
                    obj.setBlockMetaData(blockId,{obj.MLSYS_SYSTEM,obj.SYSTEM_OBJECT_FILE},{systemName,systemobjFile});
                    param.MLSYS_SYSTEM=systemName;
                    param.SYSTEM_OBJECT_FILE=systemobjFile;
                end
            end
            result.command='refresh';
            result.data=param;
            obj.notifyUI(result);
        end

        function wrappedString=createWrapperString(obj,input)
            wrappedString=['fullfile(blocksetroot,','''',input,'''',')'];
        end

        function rootScriptPath=createRootScript(obj,folder)
            filename='blocksetroot.m';
            rootScriptPath=fullfile(folder,filename);
            fid=fopen(rootScriptPath,'w');
            fwrite(fid,['% This function is used to return blockset root folder across different platforms.',newline]);
            fwrite(fid,['function blocksetroot = blocksetroot()',newline]);
            fwrite(fid,['try',newline]);
            fwrite(fid,['proj = simulinkproject;',newline]);
            fwrite(fid,['blocksetroot=proj.RootFolder;',newline]);
            fwrite(fid,['catch ex',newline]);
            fwrite(fid,['blocksetroot='''';',newline]);
            fwrite(fid,['end',newline]);
            fwrite(fid,['end',newline]);
            fclose(fid);
            rootScriptPath=obj.normPath(rootScriptPath);
        end

        function iconpath=generateBlockIcon(obj,blockId)
            try
                data=obj.getBlockMetaData(blockId,{'BlockPath','BlockType'});
                blockpath=data{1};
                blockType=data{2};
                c=strsplit(blockpath,'/');
                library=c{1};
                blockFolder=obj.getBlockMetaData(blockId,'BlockName');
                blockFolder=obj.processName(blockFolder);
                if isempty(blockFolder)
                    obj.createBlockFolders(blockFolder,blockType);
                end
                cleanup='';
                if~bdIsLoaded(library)
                    load_system(library);
                    cleanup=onCleanup(@()close_system(library,0));
                end
                hiliteancester=get_param(blockpath,'HiliteAncestors');
                hilite_system(blockpath,'none');
                blockhandle=getSimulinkBlockHandle(blockpath);
                iconpath=obj.i_GenerateImage(blockhandle,blockId,blockFolder);
                hilite_system(blockpath,hiliteancester);
            catch me
                iconpath='';
            end
        end


        function[aImageLocation]=i_GenerateImage(obj,aMaskBlkHdl,blockId,blockFolder)
            aImageLocation=i_TakeSnapshot(obj,aMaskBlkHdl,blockId,blockFolder);
        end


        function[aImageLocation]=i_TakeSnapshot(obj,aMaskBlkHdl,blockId,blockFolder)
            aImageLocation=[];


            aSnapshot=i_InitSnapshot(obj,blockId,blockFolder);
            if isempty(aSnapshot)
                return;
            end


            aSnapshot=i_ConfigureSnapshot(obj,aSnapshot,aMaskBlkHdl);


            if~aSnapshot.isTargetValid()
                return;
            end


            aSnapshot.export();


            aImageLocation=obj.normPath(aSnapshot.exportOptions.fileName);
        end


        function aSnapshot=i_InitSnapshot(obj,blockId,blockFolder)
            aSnapshot=GLUE2.Portal;
            aSnapshot.suppressBadges=true;
            aSnapshot.targetContext='ShowTargetOnly';
            aOptions=aSnapshot.exportOptions;
            aOptions.format='PNG';
            targetFolder=fullfile(obj.ProjectRoot,blockFolder,'library','derived');
            if~exist(targetFolder,'dir')
                mkdir(targetFolder);
            end
            aSnapshot.exportOptions.fileName=fullfile(targetFolder,[blockId,'.png']);
        end



        function aSnapshot=i_ConfigureSnapshot(obj,aSnapshot,aMaskBlkHdl)
            aDiagramElement=SLM3I.SLDomain.handle2DiagramElement(aMaskBlkHdl);
            if isempty(aDiagramElement)
                return;
            end

            aSnapshot.setTarget('Simulink',aMaskBlkHdl);

            aWidth=max(aSnapshot.targetSceneRect(3),115);
            aHeight=max(aSnapshot.targetSceneRect(4),115);

            aOptions=aSnapshot.exportOptions;
            aSnapshot.targetOutputRect=[0,0,aWidth,aHeight];
            aOptions.size=[aWidth,aHeight];
        end


        function setBlockOpStatus(obj,blockName,op,status)
            obj.setBlockMetaData(blockName,op,status);
        end

        function updateBlockNameInFile(obj,targetFile,oldName,newName)
            A=strrep(fileread(obj.abPath(targetFile)),oldName,newName);
            fileID=fopen(obj.abPath(targetFile),'w');
            fprintf(fileID,'%s',A);
            fclose(fileID);
        end

        function inputClass=assignFieldsToProperties(obj,inputClass,inputStruct)
            parts=fields(inputStruct);
            for i=1:numel(parts)
                inputClass.(parts{i})=inputStruct.(parts{i});
            end
        end

        function impacted=getImpactedFilesFromDA(obj,libraryFile)
            try
                listRequiredFiles(obj.Project,libraryFile);
                callGraph=obj.Project.Dependencies;
                impactGraph=flipedge(callGraph);
                impacted=bfsearch(impactGraph,fullfile(obj.ProjectRoot,libraryFile));
                if~iscell(impacted)
                    impacted={impacted};
                end
            catch
                impacted={};
            end
        end

        function lc=getLastCause(obj,me)
            if~isempty(me.cause)
                temp=me.cause{1};
                lc=getLastCause(obj,temp);
            else
                lc=me;
            end
        end
    end

end
