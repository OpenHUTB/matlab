classdef Subsystem<Simulink.BlocksetDesigner.Block




    properties

    end

    methods

        function obj=Subsystem()
            obj=obj@Simulink.BlocksetDesigner.Block();
        end

        function subsysInfo=create(obj,subsysName,parent)
            blockName=subsysName;
            subsysInfo='';
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

            if exist(blockName)~=0
                msgbox(DAStudio.message('Simulink:SFunctions:BlockSetSDKSfcnExist'),DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
                return;
            end
            create@Simulink.BlocksetDesigner.Block(obj,blockName,'SubSystem');

            libFolder=fullfile(blockName,'library');
            [libraryModelPath,library]=obj.createBlockLibrary(blockName,libFolder);
            blockpath=[library,'/',blockName];
            obj.updateProgressBar(getString(message('slblocksetdesigner:messages:addFilesToProject')));
            obj.addBlockToParentLibrary(blockName,blockpath,parentLibrary);

            obj.Project.addFolderIncludingChildFiles(blockName);


            subsysInfo=Simulink.BlocksetDesigner.SubsysInfo(blockName,blockpath,parent);
            subsysInfo.BLOCK_LIBRARY=libraryModelPath;

            blockId=subsysInfo.Id;
            obj.updateBlockList(blockId);
            obj.writeToDataModel(subsysInfo);

            obj.openLibraryAndRegisterIconListener(blockId,libraryModelPath,false);
            iconfile=obj.generateBlockIcon(blockId);
            obj.Project.addFile(obj.abPath(iconfile));
            subsysInfo.BLOCK_ICON=iconfile;
            obj.setBlockMetaData(blockId,obj.BLOCK_ICON,iconfile);
            obj.setFileType(libraryModelPath,obj.BLOCK_LIBRARY,blockId);
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
                add_block('built-in/Subsystem',blkName,'Position',[100,100,200,200]);
                add_block('built-in/Inport',[blkName,'/inport'],'Position',[100,100,130,120]);
                add_block('built-in/Outport',[blkName,'/outport'],'Position',[250,100,280,120]);
                add_block('built-in/Gain',[blkName,'/Gain'],'Position',[170,100,200,120]);
                add_line(blkName,'inport/1','Gain/1');
                add_line(blkName,'Gain/1','outport/1');
                set_param(mdlName,'EnableLBRepository','on');
                libraryFilePath=fullfile(libFolder,[mdlName,'.slx']);
                maskObj=Simulink.Mask.create(blkName);
                maskObj.Description='Default Mask';
                save_system(mdlH,obj.abPath(libraryFilePath));
            else
                warning('Library is not created since one exists.');
                libraryFilePath=fullfile(libFolder,[mdlName,'.slx']);
            end
        end

    end
end

