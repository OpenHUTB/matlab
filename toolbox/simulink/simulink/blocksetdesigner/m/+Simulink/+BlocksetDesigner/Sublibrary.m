classdef Sublibrary<Simulink.BlocksetDesigner.BlockAuthoring




    properties
    end

    methods(Access=public,Hidden=true)
        function obj=Sublibrary()
            obj=obj@Simulink.BlocksetDesigner.BlockAuthoring();
        end

        function sublibraryInfo=create(obj,sublibraryName,parent)
            targetdir=fullfile('common','library');
            if~exist(targetdir,'dir')
                obj.createBlockSetFolders();
            end
            sublibraryInfo='';
            if isempty(sublibraryName)
                h=msgbox(DAStudio.message('Simulink:SFunctions:BlockSetSDKBlockEmptyInput'),DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
                h.Tag='Simulink_BlocksetDesigner_Alert';
                return;
            end
            if~isvarname(sublibraryName)
                h=msgbox(DAStudio.message('Simulink:SFunctions:BlockSetSDKInvalidIdentifier',sublibraryName),DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
                h.Tag='Simulink_BlocksetDesigner_Alert';
                sublibraryName=obj.processName(sublibraryName);
            end
            parentLibrary=obj.getBlockMetaData(parent,obj.OpenFunction);
            parentLibrary=obj.processName(parentLibrary);


            if exist([sublibraryName,'.slx'],'file')==4
                msgbox(DAStudio.message('Simulink:SFunctions:BlockSetSDKSfcnExist'),DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
                return;
            end

            libraryFile=fullfile(targetdir,[sublibraryName,'.slx']);
            mdlG=new_system(sublibraryName,'Library');
            load_system(mdlG);
            set_param(mdlG,'EnableLBRepository','on');
            save_system(mdlG,obj.abPath(libraryFile));
            close_system(mdlG,0);

            obj.updateProgressBar(getString(message('slblocksetdesigner:messages:addFilesToProject')));
            obj.Project.addFile(libraryFile);
            obj.addSublibraryBlockToParentLibrary(sublibraryName,parentLibrary);

            sublibraryInfo=Simulink.BlocksetDesigner.SublibraryInfo(sublibraryName,sublibraryName,parent);

            obj.updateSublibraryList(sublibraryInfo.Id);
            obj.writeToDataModel(sublibraryInfo);
        end

        function sublibraryInfo=import(obj,sublibraryInfo)

            obj.updateSublibraryList(sublibraryInfo.Id);
            obj.writeToDataModel(sublibraryInfo);
        end

        function deleteSublibrary(obj,sublibraryId)
            sublibraryName=obj.getBlockMetaData(sublibraryId,obj.LibName);
            libraryfile=which(sublibraryName);
            if~isempty(findFile(obj.Project,libraryfile))
                close_system(libraryfile,0);
                impacted=obj.getImpactedFilesFromDA(obj.normPath(libraryfile));
                obj.updateProgressBar(getString(message('slblocksetdesigner:messages:deleteBlocksFromProject')));
                for i=1:numel(impacted)
                    if~isequal(impacted{i},libraryfile)
                        obj.removeBlockWithBlockCallback(impacted{i},sublibraryName);
                    end
                end
                obj.updateProgressBar(getString(message('slblocksetdesigner:messages:deleteFilesFromProject')));
                removeFile(obj.Project,libraryfile);
                delete(libraryfile);

            end

            obj.deleteBlockMetaData(sublibraryId);
            projectRoot=obj.Project.RootFolder;
            dataMap=obj.getFileMetaData(projectRoot);
            sublibraryList=char(dataMap.get('sublibraryList'));
            s1=[sublibraryId,';'];
            s2=[';',sublibraryId];
            if contains(sublibraryList,s1)
                sublibraryList=erase(sublibraryList,s1);
            elseif contains(sublibraryList,s2)
                sublibraryList=erase(sublibraryList,s2);
            elseif contains(sublibraryList,blockId)
                sublibraryList='';
            end
            dataMap=containers.Map();
            dataMap('sublibraryList')=sublibraryList;
            obj.setFileMetaData(obj.Project.RootFolder,dataMap);
        end

        function moveSublibrary(obj,sublibraryId,oldParentLibrary,newParentLibrary)
            sublibraryName=obj.getBlockMetaData(sublibraryId,obj.LibName);
            obj.addSublibraryBlockToParentLibrary(sublibraryName,newParentLibrary)
            obj.removeBlockWithBlockCallback([oldParentLibrary,'.slx'],sublibraryName);
        end


        function open(obj,libraryPath)
            c=strsplit(libraryPath,'/');
            if~isempty(c)
                library=c{1};
                if exist(library,'file')==4
                    load_system(library);
                    open_system(libraryPath);
                else
                    h=msgbox(DAStudio.message('Simulink:SFunctions:BlockSetSDKFileCannotFound',library),DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
                    h.Tag='Simulink_BlocksetDesigner_Alert';
                end
            end
        end

        function sublibraryInfo=renameSublibrary(obj,sublibraryInfo,newName)
            if~isvarname(newName)
                h=msgbox(DAStudio.message('Simulink:SFunctions:BlockSetSDKInvalidIdentifier',newName),DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
                h.Tag='Simulink_BlocksetDesigner_Alert';
                newName=obj.processName(newName);
            end

            if exist(['library_',newName,'.slx'],'file')==4
                h=msgbox(DAStudio.message('Simulink:SFunctions:BlockSetSDKSfcnExist'),DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
                h.Tag='Simulink_BlocksetDesigner_Alert';
                sublibraryInfo="";
                return;
            end


            if exist([newName,'.slx'],'file')==4
                h=msgbox(DAStudio.message('Simulink:SFunctions:BlockSetSDKSfcnExist'),DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
                h.Tag='Simulink_BlocksetDesigner_Alert';
                sublibraryInfo="";
                return;
            end
            oldName=sublibraryInfo.LibName;
            sublibraryInfo.LibName=newName;
            sublibraryInfo.OpenFunction=newName;

            libraryfile=which(oldName);
            if~isempty(findFile(obj.Project,obj.normPath(libraryfile)))
                close_system(libraryfile,0);
                impacted=obj.getImpactedFilesFromDA(obj.normPath(libraryfile));
                obj.updateProgressBar(getString(message('slblocksetdesigner:messages:removeFilesFromProject')));
                obj.Project.removeFile(libraryfile);
                newlibraryfile=strrep(libraryfile,oldName,newName);
                movefile(libraryfile,newlibraryfile,'f');
                obj.updateProgressBar(getString(message('slblocksetdesigner:messages:addFilesToProject')));
                obj.Project.addFile(newlibraryfile);
                [~,newlibrary,~]=fileparts(newlibraryfile);
                if~bdIsLoaded(newlibrary)
                    load_system(newlibrary);
                end
                set_param(newlibrary,'lock','off');
                set_param(newlibrary,'EnableLBRepository','on');
                set_param(newlibrary,'lock','on');
                save_system(newlibrary);
                close_system(newlibrary);

                for i=1:numel(impacted)
                    if~isequal(impacted{i},libraryfile)
                        obj.renameBlockWithBlockCallback(impacted{i},oldName,newName);
                    end
                end
            end
            obj.writeToDataModel(sublibraryInfo);

        end
    end


    methods(Hidden=true)

        function addSublibraryBlockToParentLibrary(obj,sublibraryName,parentLibrary)
            cleanupobj1='';
            if(~bdIsLoaded(parentLibrary))
                load_system(parentLibrary);
                cleanupobj1=onCleanup(@()close_system(parentLibrary));
            end
            set_param(parentLibrary,'Lock','off');


            numberOfBlocks=numel(find_system(parentLibrary,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices));
            column=mod(numberOfBlocks-1,3);
            row=(numberOfBlocks-1-column)/3;

            position=[150*(column+1),120*(row+1),100+150*(column+1),70+120*(row+1)];
            add_block('built-in/Subsystem',[parentLibrary,'/',sublibraryName],'Position',position);
            set_param([parentLibrary,'/',sublibraryName],'OpenFcn',sublibraryName);
            save_system(parentLibrary);
        end

        function sublibraryInfo=loadSublibraryInfo(obj,sublibraryInfo)


            openFunction=sublibraryInfo.OpenFunction;
            subLibraryList=strsplit(obj.getSublibrariesInProject(),';');
            subId='';
            for i=1:numel(subLibraryList)
                temp=obj.getBlockMetaData(subLibraryList{i},'OpenFunction',openFunction);
                if strcmp(openFunction,temp)
                    subId=subLibraryList{i};
                    break;
                end
            end

            if~isempty(subId)
                sublibraryInfo.Id=subId;
            else
                sublibraryInfo=obj.import(sublibraryInfo);
            end

            if isequal(sublibraryInfo.IsRoot,'true')
                blockSetLibrary=obj.getBlockSetMetaData(obj.BLOCKSET_LIBRARY);
                blockSetDocScript=obj.getBlockSetMetaData(obj.BLOCKSET_DOC_SCRIPT);
                sublibraryInfo.LibPath=blockSetLibrary;
                sublibraryInfo.DocScript=blockSetDocScript;
            end
        end

        function renameBlockWithBlockCallback(obj,libraryFile,oldName,newName)
            [~,library,ext]=fileparts(libraryFile);
            if isequal(ext,'.slx')||isequal(ext,'.mdl')
                cleanup='';
                if~bdIsLoaded(library)
                    load_system(library);
                    cleanup=onCleanup(@()close_system(library));
                end
                if bdIsLibrary(library)
                    set_param(library,'Lock','off');



                    allblocks=find_system(library,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices);
                    numberOfBlocks=numel(allblocks);
                    for i=2:numberOfBlocks
                        if isequal(get_param(allblocks{i},'OpenFcn'),oldName)
                            set_param(allblocks{i},'OpenFcn',newName);
                            set_param(allblocks{i},'Name',newName);
                        end
                    end
                    set_param(library,'EnableLBRepository','on');
                    set_param(library,'Lock','on');
                    save_system(library);

                end
            end
        end

        function removeBlockWithBlockCallback(obj,libraryFile,sublibraryName)
            [~,library,ext]=fileparts(libraryFile);
            if isequal(ext,'.slx')||isequal(ext,'.mdl')
                cleanup='';
                if~bdIsLoaded(library)
                    load_system(library);
                    cleanup=onCleanup(@()close_system(library));
                end
                if bdIsLibrary(library)
                    set_param(library,'Lock','off');



                    allblocks=find_system(library,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices);
                    numberOfBlocks=numel(allblocks);
                    for i=2:numberOfBlocks
                        if isequal(get_param(allblocks{i},'openFcn'),sublibraryName)
                            delete_block(allblocks{i});
                        end
                    end



                    allblocks=find_system(library,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices);
                    numberOfBlocks=numel(allblocks);
                    for i=2:numberOfBlocks
                        column=mod(i-2,3);
                        row=(i-2-column)/3;
                        set_param(allblocks{i},'Position',[150*(column+1),120*(row+1),100+150*(column+1),70+120*(row+1)]);
                    end

                    set_param(library,'Lock','on');
                    save_system(library);
                end
            end
        end

        function createBlockSetFolders(obj)
            projectRoot=obj.ProjectRoot;
            proj=obj.Project;
            sharedRoot=fullfile(projectRoot,'common');
            sharedSrc=fullfile(sharedRoot,'script');
            sharedLib=fullfile(sharedRoot,'library');
            sharedDoc=fullfile(sharedRoot,'doc');
            if~exist(sharedRoot,'dir')
                mkdir(sharedRoot);
                proj.addPath(sharedRoot);
            end
            if~exist(sharedSrc,'dir')
                mkdir(sharedSrc);
                proj.addPath(sharedSrc);
            end
            if~exist(sharedLib,'dir')
                mkdir(sharedLib);
                proj.addPath(sharedLib);
            end
            if~exist(sharedDoc,'dir')
                mkdir(sharedDoc);
                proj.addPath(sharedDoc);
            end
        end

    end
end

