classdef MATLABSystem<Simulink.BlocksetDesigner.Block




    properties
    end

    methods

        function obj=MATLABSystem()
            obj=obj@Simulink.BlocksetDesigner.Block();
        end

        function mlsysInfo=create(obj,mlsysName,templateType,parent)
            blockName=mlsysName;
            mlsysInfo='';
            if isempty(blockName)
                h=msgbox(DAStudio.message('Simulink:SFunctions:BlockSetSDKBlockEmptyInput'),DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
                h.Tag='Simulink_BlocksetDesigner_Alert';
                return;
            end
            if~isvarname(blockName)
                h=msgbox(DAStudio.message('Simulink:SFunctions:BlockSetSDKInvalidIdentifier',blockName),DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
                h.Tag='Simulink_BlocksetDesigner_Alert';
                blockName=obj.processName(blockName);
            end

            parentLibrary=obj.getBlockMetaData(parent,obj.OpenFunction);
            parentLibrary=obj.processName(parentLibrary);

            if exist(blockName)~=0||obj.checkExistingFile(blockName)
                h=msgbox(DAStudio.message('Simulink:SFunctions:BlockSetSDKSfcnExist'),DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
                h.Tag='Simulink_BlocksetDesigner_Alert';
                return;
            end

            create@Simulink.BlocksetDesigner.Block(obj,blockName,'MATLABSystem');


            projectRoot=obj.ProjectRoot;
            blockFolder=blockName;
            proj=obj.Project;
            binFolder=[blockFolder,filesep,'sysobj'];
            if~exist(fullfile(projectRoot,binFolder),'dir')
                [status,msg,msgid]=mkdir(fullfile(projectRoot,binFolder));
                if status~=1
                    error(msgid,msg);
                end
                proj.addPath(binFolder);
            end


            systemobjectFile=obj.generateSystemObjectFile(blockName,templateType);
            systemobjectFile=obj.normPath(systemobjectFile);
            obj.Project.addFolderIncludingChildFiles(blockName);
            libFolder=fullfile(blockName,'library');
            [libraryModelPath,library]=obj.createBlockLibrary(blockName,libFolder);
            blockpath=[library,'/',blockName];
            obj.updateProgressBar(getString(message('slblocksetdesigner:messages:addFilesToProject')));
            obj.addBlockToParentLibrary(blockName,blockpath,parentLibrary);
            obj.Project.addFile(fullfile(obj.ProjectRoot,libraryModelPath));

            mlsysInfo=Simulink.BlocksetDesigner.MATLABSysInfo(blockName,blockpath,parent);
            mlsysInfo.BLOCK_LIBRARY=libraryModelPath;
            mlsysInfo.SYSTEM_OBJECT_FILE=systemobjectFile;
            mlsysInfo.DOCUMENT=obj.PASS;
            mlsysInfo.MLSYS_SYSTEM=blockName;
            blockId=mlsysInfo.Id;
            obj.updateBlockList(blockId);
            obj.writeToDataModel(mlsysInfo);

            obj.openLibraryAndRegisterIconListener(blockId,libraryModelPath,false);
            iconfile=obj.generateBlockIcon(blockId);
            obj.Project.addFile(obj.abPath(iconfile));
            obj.setBlockMetaData(blockId,obj.BLOCK_ICON,iconfile);
            mlsysInfo.BLOCK_ICON=iconfile;
            obj.setFileType(libraryModelPath,obj.BLOCK_LIBRARY,blockId);
            obj.setFileType(systemobjectFile,obj.SYSTEM_OBJECT_FILE,blockId);
        end

        function mlsysInfo=import(obj,mlsysInfo)
            mlsysInfo=import@Simulink.BlocksetDesigner.Block(obj,mlsysInfo);
            blockId=mlsysInfo.Id;
            mlSystem=mlsysInfo.MLSYS_SYSTEM;

            systemobject=obj.findMATLABSystemFile(mlSystem,obj.SYSTEM_OBJECT_FILE);
            if~isempty(systemobject)
                mlsysInfo.SYSTEM_OBJECT_FILE=systemobject;
            end
            mlsysInfo.DOCUMENT=obj.PASS;

            obj.updateBlockList(blockId);
            obj.writeToDataModel(mlsysInfo);
        end

        function editBlockSource(obj,blockId)
            systemobject=obj.getBlockMetaData(blockId,obj.SYSTEM_OBJECT_FILE);
            if(~isempty(systemobject))
                edit(systemobject);
            end
        end
    end


    methods(Access=public,Hidden=true)
        function[libraryFilePath,mdlName]=createBlockLibrary(obj,blockName,libFolder)
            mdlName=['library_',blockName];
            if isempty(which(mdlName))
                mdlH=new_system(mdlName,'Library');
                finishup=onCleanup(@()close_system(mdlH,0));
                load_system(mdlH);
                blkName=[mdlName,'/',blockName];
                add_block('built-in/MATLABSystem',blkName,'Position',[100,100,200,200]);
                set_param(blkName,'System',blockName);
                set_param(mdlName,'EnableLBRepository','on');
                libraryFilePath=fullfile(libFolder,[mdlName,'.slx']);
                save_system(mdlH,obj.abPath(libraryFilePath));
            else
                warning('Library is not created since one exists.');
                libraryFilePath=fullfile(libFolder,[mdlName,'.slx']);
            end
        end

        function systemobjectfilepath=generateSystemObjectFile(obj,blockName,templateType)
            systemobjectfilepath=obj.abPath(fullfile(blockName,'sysobj',[blockName,'.m']));
            creator=Simulink.BlocksetDesigner.internal.NewSystemObjectFile();
            switch templateType
            case 0
                systemobjectfilepath=creator.createBasic(systemobjectfilepath);
            case 1
                systemobjectfilepath=creator.createAdvanced(systemobjectfilepath);
            case 2
                systemobjectfilepath=creator.createSimulinkExtension(systemobjectfilepath);
            end

        end

    end
end

