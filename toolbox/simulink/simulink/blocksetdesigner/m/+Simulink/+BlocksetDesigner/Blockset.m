classdef Blockset<Simulink.BlocksetDesigner.BlockAuthoring




    properties
    end

    methods(Access=public,Hidden=true)
        function obj=Blockset()
            obj=obj@Simulink.BlocksetDesigner.BlockAuthoring();
        end

        function bsddata=init(obj)
            blockSetLibrary=obj.getBlockSetMetaData(obj.BLOCKSET_LIBRARY);
            if isempty(blockSetLibrary)||~exist(blockSetLibrary,'file')
                obj.createBlockSetFolders();
                obj.createBlockSetFiles();
                blockSetLibrary=obj.getBlockSetMetaData(obj.BLOCKSET_LIBRARY);
            end


            rootNode=slblocksearchdb.getLibraryRootNode(blockSetLibrary);
            bsddata=obj.createBlocksetTreeData(rootNode,'');
        end

        function viewBlockSet(obj)
            file=obj.getBlockSetMetaData(obj.BLOCKSET_LIBRARY);
            if~isempty(file)&&exist(file,'file')==4
                open_system(file);
            else
                h=msgbox(DAStudio.message('Simulink:SFunctions:BlockSetSDKFileCannotFound',file),DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
                h.Tag='Simulink_BlocksetDesigner_Alert';
            end
        end

        function openLibraryHelp(obj)
            file=obj.getBlockSetMetaData(obj.BLOCKSET_DOC_SCRIPT);
            if(~isempty(file))
                edit(file);
            end
        end

        function viewBlockSetInSlBrowser(obj)
            blocksetFile=obj.getBlockSetMetaData(obj.BLOCKSET_LIBRARY);
            if exist(blocksetFile,'file')==4

                [~,mdl,~]=fileparts(blocksetFile);
                impacted=dependencies.fileDependencyAnalysis(mdl);
                if~iscell(impacted)
                    impacted={impacted};
                end
                close_system(mdl,0);
                for i=1:numel(impacted)
                    temp=impacted{i};
                    [~,library,ext]=fileparts(temp);
                    if isequal(ext,'.slx')
                        cleanup='';

                        try
                            if(~bdIsLoaded(library))
                                load_system(library);
                                cleanup=onCleanup(@()close_system(library));
                            end
                            if bdIsLibrary(library)
                                save_system(library);
                            end
                        catch
                            continue;
                        end
                    end
                end
                [~,blocksetName,~]=fileparts(blocksetFile);

                slb=slLibraryBrowser;
                slb.refresh();
                components=LibraryBrowser.LBStandalone.getLBComponents;
                if~isempty(components)
                    component=components(cellfun(@(a)isempty(a.getStudio),components));
                    o.LBComponent=component{1};
                    target=blocksetName;
                    o.LBComponent.selectTreeNodeByName(target);
                end
            else
                msgbox(DAStudio.message('Simulink:SFunctions:BlockSetSDKNoTopLibraryOrSlblocks'),DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
            end
        end

        function sublibraryInfo=renameBlockset(obj,sublibraryInfo,newName)
            if~isvarname(newName)
                h=msgbox(DAStudio.message('Simulink:SFunctions:BlockSetSDKInvalidIdentifier',newName),DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
                h.Tag='Simulink_BlocksetDesigner_Alert';
                newName=obj.processName(newName);
            end
            oldName=sublibraryInfo.LibName;
            sublibraryInfo.LibName=newName;
            sublibraryInfo.OpenFunction=newName;
            files=obj.getBlockSetMetaData({obj.BLOCKSET_LIBRARY,obj.BLOCKSET_DOC_SCRIPT,obj.BLOCKSET_DOC_HTML});
            if isempty(files)
                obj.setBlockSetMetaData(obj.BLOCKSET_NAME,newName);
                return;
            end
            newfiles=cell(1,numel(files));
            for i=1:numel(files)
                if exist(files{i},'file')
                    if i==1
                        close_system(files{i},0);
                    end
                    newfiles{i}=strrep(files{i},oldName,newName);
                    if~isequal(newfiles{i},files{i})
                        obj.Project.removeFile(files{i});
                        movefile(files{i},newfiles{i},'f');
                        obj.Project.addFile(fullfile(obj.ProjectRoot,newfiles{i}));
                    end
                end
            end
            obj.setBlockSetMetaData({obj.BLOCKSET_LIBRARY,obj.BLOCKSET_DOC_SCRIPT,obj.BLOCKSET_DOC_HTML},newfiles);
            sublibraryInfo.LibPath=newfiles{1};
            sublibraryInfo.DocScript=newfiles{2};

            blocksetLibraryFile=obj.getBlockSetMetaData(obj.BLOCKSET_LIBRARY);
            [~,library,~]=fileparts(blocksetLibraryFile);
            load_system(library);
            save_system(library,blocksetLibraryFile);
            close_system(library);

            blocksetScript=obj.getBlockSetMetaData(obj.BLOCKSET_SCRIPT);
            obj.updateBlockNameInFile(blocksetScript,oldName,newName);



            obj.writeToDataModel(sublibraryInfo);
        end


        function publish(obj,inputInfo)
            obj.copyFilesForPublish();
            loc=fullfile(obj.ProjectRoot,'publish','doc');
            obj.createInfoXML(loc);
            obj.createHelpTocXML(loc);

            if~isfield(inputInfo,'mode')
                matlab.tbxpkg.internal.create(fullfile(obj.ProjectRoot,'publish'),'doPackage',false);
                open(fullfile(obj.ProjectRoot,'publish.prj'))
            end
        end

    end


    methods(Hidden=true)

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

        function createBlockSetFiles(obj)
            projectRoot=obj.ProjectRoot;
            proj=obj.Project;
            sharedRoot=fullfile(projectRoot,'common');
            sharedSrc=fullfile(sharedRoot,'script');
            sharedDoc=fullfile(sharedRoot,'doc');
            sharedLib=fullfile(sharedRoot,'library');
            blockSetLibrary=obj.getBlockSetMetaData(obj.BLOCKSET_LIBRARY);
            if isempty(blockSetLibrary)||~exist(blockSetLibrary,'file')
                blocksetName=obj.getBlockSetMetaData(obj.BLOCKSET_NAME);
                if isempty(blocksetName)
                    blocksetName=obj.processName(char(obj.Project.Name));
                end
                blocksetlibrarypath=obj.createBlockSetLibraryFile(sharedLib,blocksetName);
                slblockspath=obj.createSlblocksScript(blocksetName);
                [startScript,startHTML]=obj.generateBlockSetDocs(sharedDoc,blocksetName);

                proj.addFolderIncludingChildFiles('common');

                obj.setFileType(blocksetlibrarypath,obj.BLOCKSET_LIBRARY,blocksetName);
                obj.setFileType(slblockspath,obj.BLOCKSET_SCRIPT,blocksetName);
                obj.setFileType(startScript,obj.BLOCKSET_DOC_SCRIPT,blocksetName);
                obj.setFileType(startHTML,obj.BLOCKSET_DOC_HTML,blocksetName);
                obj.setBlockSetMetaData({obj.BLOCKSET_LIBRARY,obj.BLOCKSET_SCRIPT,obj.BLOCKSET_DOC_SCRIPT,obj.BLOCKSET_DOC_HTML},...
                {blocksetlibrarypath,slblockspath,startScript,startHTML});
            end
            rootScriptPath=obj.getBlockSetMetaData(obj.BLOCKSET_ROOT_SCRIPT);
            if isempty(rootScriptPath)||~exist(rootScriptPath,'file')
                rootScriptPath=obj.createRootScript(sharedSrc);
                obj.Project.addFile(rootScriptPath);
                obj.setBlockSetMetaData(obj.BLOCKSET_ROOT_SCRIPT,rootScriptPath);
            end
        end

        function result=createBlockSetLibraryFile(obj,targetDir,blocksetName)
            mdlName=blocksetName;
            mdlH=new_system(mdlName,'Library');
            load_system(mdlH);

            set_param(mdlH,'EnableLBRepository','on');
            save_system(mdlH,fullfile(targetDir,[mdlName,'.slx']));
            close_system(mdlName);
            result=obj.normPath(fullfile(targetDir,[mdlName,'.slx']));
        end

        function slblockspath=createSlblocksScript(obj,blocksetName)
            targetFolder=fullfile(obj.ProjectRoot,'common','library');
            slblockspath='';
            if exist(targetFolder,'dir')
                targetFile=fullfile(targetFolder,'slblocks.m');
                fid=fopen(targetFile,'w');
                fwrite(fid,['function blkStruct = slblocks',newline]);
                fwrite(fid,['    Browser.Library =''',blocksetName,''';',newline]);
                fwrite(fid,['    Browser.Name =''',blocksetName,''';',newline]);
                fwrite(fid,['    blkStruct.Browser = Browser; ',newline]);
                fwrite(fid,['end',newline]);
                fclose(fid);
                slblockspath=obj.normPath(targetFile);
            end
        end

        function[startScript,startHTML]=generateBlockSetDocs(obj,loc,blocksetName)
            docScriptPath=fullfile(loc,['help_',blocksetName,'.m']);
            description=['Blockset ',blocksetName,' description.'];
            fid=fopen(docScriptPath,'w');
            fwrite(fid,['%% Help page for blockset ',blocksetName,newline]);
            fwrite(fid,['%% Description:',newline]);
            fwrite(fid,['% ',description,newline]);
            fclose(fid);

            docScriptLive=fullfile(loc,['help_',blocksetName,'.mlx']);
            matlab.internal.liveeditor.openAndSave(docScriptPath,docScriptLive);
            delete(docScriptPath);
            htmlFile=fullfile(loc,['help_',blocksetName,'.html']);
            matlab.internal.liveeditor.openAndConvert(docScriptLive,htmlFile);

            startScript=obj.normPath(docScriptLive);
            startHTML=obj.normPath(htmlFile);
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

        function result=createBlocksetTreeData(obj,root,parentId)
            result='';
            current='';
            if(root.isLeafNode)
                blockType=root.Details.BlockType;
                blockReference=root.Details.BlockReference;
                blockPath=root.Details.BlockPath;
                blockName=root.Details.BlockName;
                obj.updateLoadingSpinner(getString(message('slblocksetdesigner:messages:addBlocksToProject',blockName)));
                if~isempty(blockReference)
                    blockPath=blockReference;
                    temp=strsplit(blockReference,'/');
                    blockName=temp{end};
                end
                bsddata='';

                switch blockType
                case 'S-Function'
                    bsddata=Simulink.BlocksetDesigner.SfunInfo(blockName,blockPath,parentId);
                    h=Simulink.BlocksetDesigner.Sfunction();
                    bsddata=h.loadBlockInfo(bsddata);
                case 'MATLABSystem'
                    bsddata=Simulink.BlocksetDesigner.MATLABSysInfo(blockName,blockPath,parentId);
                    h=Simulink.BlocksetDesigner.MATLABSystem();
                    bsddata=h.loadBlockInfo(bsddata);
                case 'SubSystem'
                    bsddata=Simulink.BlocksetDesigner.SubsysInfo(blockName,blockPath,parentId);
                    h=Simulink.BlocksetDesigner.Subsystem();
                    bsddata=h.loadBlockInfo(bsddata);
                otherwise
                    bsddata=Simulink.BlocksetDesigner.UnSupportedBlockInfo(blockName,blockPath,parentId);
                end
                current.id=bsddata.Id;
                current.label=bsddata.BlockName;
                current.parent=bsddata.ParentId;
                current.data=bsddata;
                result=[result,{current}];
            else
                bsddata=Simulink.BlocksetDesigner.SublibraryInfo(root.Details.LibName,root.Details.OpenFunction,parentId);
                h=Simulink.BlocksetDesigner.Sublibrary();




                bsddata=h.loadSublibraryInfo(bsddata);
                current.id=bsddata.Id;
                current.label=bsddata.LibName;
                current.parent=bsddata.ParentId;
                current.data=bsddata;
                result=[result,{current}];
                for i=1:numel(root.Children)
                    temp=obj.createBlocksetTreeData(root.Children(i),bsddata.Id);
                    result=[result,temp];
                end
            end
        end


        function helpTocXML=createHelpTocXML(obj,loc)
            helpTocXML=fullfile(loc,'helptoc.xml');
            template=fullfile(matlabroot,'toolbox','simulink','core','general','+Simulink','+BlockAuthoringTemplate','src','helptoc.xml');
            doc=parseFile(matlab.io.xml.dom.Parser,template);
            rootToc=doc.getElementsByTagName("tocitem").item(0);
            attr=rootToc.getAttributes();
            idAttr=attr.getNamedItem('target');
            [~,t1,t2]=fileparts(obj.getBlockSetMetaData(obj.BLOCKSET_DOC_HTML));
            idAttr.setTextContent([t1,t2]);
            rootToc.setTextContent([char(obj.Project.Name),newline]);
            blockList=strsplit(obj.getBlocksInProject(),';');
            for i=1:numel(blockList)
                helpfile=obj.getBlockMetaData(blockList{i},obj.DOC_FILE);
                if~isempty(helpfile)
                    blockName=obj.getBlockMetaData(blockList{i},'BlockName');
                    age=doc.createElement('tocitem');
                    [~,target,ext]=fileparts(helpfile);
                    age.setAttribute('target',[target,ext]);
                    age.appendChild(doc.createTextNode(blockName));
                    rootToc.appendChild(age);
                end
            end
            domWriter=matlab.io.xml.dom.DOMWriter;
            domWriter.writeToURI(doc,helpTocXML);
        end

        function infoXML=createInfoXML(obj,loc)
            infoXML=fullfile(loc,'info.xml');
            template=fullfile(matlabroot,'toolbox','simulink','core','general','+Simulink','+BlockAuthoringTemplate','src','info.xml');
            doc=parseFile(matlab.io.xml.dom.Parser,template);
            matlabrelease=doc.getElementsByTagName('matlabrelease').item(0);
            matlabrelease.setTextContent(['R',version('-release')]);
            toolboxname=doc.getElementsByTagName('name').item(0);
            toolboxname.setTextContent(char(obj.Project.Name));
            domWriter=matlab.io.xml.dom.DOMWriter;
            domWriter.writeToURI(doc,infoXML);
        end

        function copyFilesForPublish(obj)
            publishdir=fullfile(obj.ProjectRoot,'publish');

            publishdoc=fullfile(publishdir,'doc');
            publishlib=fullfile(publishdir,'library');
            publishscript=fullfile(publishdir,'script');
            publishmex=fullfile(publishdir,'mex');
            publishpackage=fullfile(publishdir,'package');
            publishsysobj=fullfile(publishdir,'sysobj');
            publishextra=fullfile(publishdir,'extra');
            publishcommon=fullfile(publishdir,'common');
            [~,~,~]=mkdir(publishdir);
            [~,~,~]=mkdir(publishdoc);
            [~,~,~]=mkdir(publishlib);
            [~,~,~]=mkdir(publishscript);
            [~,~,~]=mkdir(publishmex);
            [~,~,~]=mkdir(publishpackage);
            [~,~,~]=mkdir(publishsysobj);
            [~,~,~]=mkdir(publishextra);
            [~,~,~]=mkdir(publishcommon);

            addPath(obj.Project,publishdir);
            addPath(obj.Project,publishdoc);
            addPath(obj.Project,publishlib);
            addPath(obj.Project,publishscript);
            addPath(obj.Project,publishsysobj);
            addPath(obj.Project,publishextra);

            commonFolder=fullfile(obj.ProjectRoot,'common');
            if exist(commonFolder,'dir')
                commonDoc=fullfile(commonFolder,'doc');
                commonLib=fullfile(commonFolder,'library');
                commonScript=fullfile(commonFolder,'script');
                if exist(commonDoc,'dir')
                    htmlfiles=dir([commonDoc,filesep,'*.html']);
                    for j=1:numel(htmlfiles)
                        copyfile([htmlfiles(j).folder,filesep,htmlfiles(j).name],publishdoc);
                    end
                end
                if exist(commonLib,'dir')
                    copyfile(commonLib,publishlib);
                end
                if exist(commonScript,'dir')
                    copyfile(commonScript,publishscript);
                end
            end
            blocksInProject=obj.getBlocksInProject();
            if~isempty(blocksInProject)
                blockList=strsplit(obj.getBlocksInProject(),';');
                addedMexPath=false;
                addedPackagePath=false;
                foldersToIgnore={};
                for i=1:numel(blockList)
                    blockId=blockList{i};
                    data=obj.getBlockMetaData(blockId,{'BlockName','BlockType'});
                    blockName=data{1};
                    blockType=data{2};
                    blockFolder=fullfile(obj.ProjectRoot,blockName);
                    if exist(blockFolder,'dir')
                        if isequal(blockType,'S-Function')
                            blockpackagefolder=fullfile(blockFolder,'package');
                            isPackaged=isequal(obj.getBlockMetaData(blockId,obj.ISPACKAGED),'true');
                            packagefile=fullfile(blockpackagefolder,[blockName,getSFcnPackageExtension]);
                            if~isPackaged
                                if~addedMexPath
                                    addPath(obj.Project,publishmex);
                                    addedMexPath=true;
                                end
                                blockmexfolder=fullfile(blockFolder,'mex');
                                if exist(blockmexfolder,'dir')
                                    mexfiles=dir([blockmexfolder,filesep,'*.',mexext]);
                                    for j=1:numel(mexfiles)
                                        copyfile([mexfiles(j).folder,filesep,mexfiles(j).name],publishmex);
                                    end
                                end
                            else





                                blockDir=fullfile(obj.ProjectRoot,blockName);
                                foldersToIgnore=[foldersToIgnore(:)'...
                                ,{...
                                fullfile(blockDir,'src')...
                                ,fullfile(blockDir,'mex')...
                                ,fullfile(blockDir,'build')}];
                                if~addedPackagePath
                                    addPath(obj.Project,publishpackage);
                                    addPath(obj.Project,publishcommon);
                                    addedPackagePath=true;
                                end
                                commonFiles={};
                                if exist(blockpackagefolder,'dir')



                                    if isfile(packagefile)
                                        sfcnFiles=Simulink.SFcnPackage.getFileDependenciesFromPackage(packagefile);
                                        for fInd=1:numel(sfcnFiles)
                                            f=sfcnFiles{fInd};
                                            if(startsWith(f,'common/')||...
                                                startsWith(f,'common\'))&&...
                                                ~strcmp(blockName,'common')
                                                commonFiles=[commonFiles(:)',{f}];
                                            end
                                        end
                                    end


                                    t=tempname(tempdir);
                                    [~,~,~]=mkdir(t);
                                    preservedPackageFile='';
                                    if isfolder(t)&&isfile(packagefile)
                                        if copyfile(packagefile,t)
                                            [~,fileName,e]=fileparts(packagefile);
                                            preservedPackageFile=fullfile(t,[fileName,e]);
                                        end
                                    end

                                    Simulink.SFcnPackage.createSFcnPackageForBSDPublisher(blockName,obj.ProjectRoot,fullfile(obj.ProjectRoot,blockName),false);
                                    copyfile(packagefile,publishpackage);



                                    if isfile(preservedPackageFile)
                                        copyfile(preservedPackageFile,blockpackagefolder);
                                    end
                                end

                                for iCommonFile=1:numel(commonFiles)
                                    if isfile(fullfile(obj.ProjectRoot,commonFiles{iCommonFile}))&&...
                                        ~isfile(fullfile(publishdir,commonFiles{iCommonFile}))
                                        [dest,~,~]=fileparts(fullfile(publishdir,commonFiles{iCommonFile}));
                                        if~isfolder(dest)
                                            [~,~,~]=mkdir(dest);
                                        end
                                        copyfile(commonFiles{iCommonFile},dest);
                                    end
                                end
                            end
                        end
                        if isequal(blockType,'MATLABSystem')
                            blocksysobjfolder=fullfile(blockFolder,'sysobj');
                            if exist(blocksysobjfolder,'dir')
                                copyfile(blocksysobjfolder,publishsysobj);
                            end
                        end
                        blockLibfolder=fullfile(blockFolder,'library');
                        if exist(blockLibfolder,'dir')
                            libfiles=dir([blockLibfolder,filesep,'*.slx']);
                            for j=1:numel(libfiles)
                                copyfile([libfiles(j).folder,filesep,libfiles(j).name],publishlib);
                            end
                        end
                        blockDocfolder=fullfile(blockFolder,'doc');
                        htmlfiles=dir([blockDocfolder,filesep,'*.html']);
                        for j=1:numel(htmlfiles)
                            copyfile([htmlfiles(j).folder,filesep,htmlfiles(j).name],publishdoc);
                        end
                    end
                end
            end
            cd(publishdir);
            blocksetfile=obj.getBlockSetMetaData(obj.BLOCKSET_LIBRARY);
            [~,mdl,~]=fileparts(blocksetfile);
            impacted=dependencies.fileDependencyAnalysis(mdl);
            if~iscell(impacted)
                impacted={impacted};
            end
            slblockScript=fullfile(obj.ProjectRoot,obj.getBlockSetMetaData(obj.BLOCKSET_SCRIPT));
            if exist(slblockScript,'file')==2
                copyfile(slblockScript,publishlib);
            end
            blocksetHtml=fullfile(obj.ProjectRoot,obj.getBlockSetMetaData(obj.BLOCKSET_DOC_HTML));
            if exist(blocksetHtml,'file')==2
                copyfile(blocksetHtml,publishdoc);
            end
            blocksetLibrary=fullfile(obj.ProjectRoot,obj.getBlockSetMetaData(obj.BLOCKSET_LIBRARY));
            if exist(blocksetLibrary,'file')==4
                copyfile(blocksetLibrary,publishlib);
            end

            close_system(mdl,0);





            if~isempty(impacted)&&~isempty(foldersToIgnore)
                impacted=impacted(cellfun(@(x)~contains(x,foldersToIgnore),impacted));
            end
            for i=1:numel(impacted)
                temp=impacted{i};
                [~,name,ext]=fileparts(temp);
                if any(cellfun(@(x)isequal(x,exist(temp,'file')),{2,3,4,6}))
                    target=dir(['**/',name,ext]);
                    if isempty(target)
                        copyfile(temp,publishextra);
                    end
                end
            end

        end

        function generateBlockSetDocHTMLFromScript(obj,docScriptPath)
            [x,y,z]=fileparts(docScriptPath);
            if isequal(z,'.mlx')
                htmlfile=fullfile(x,[y,'.html']);
                matlab.internal.liveeditor.openAndConvert(docScriptPath,htmlfile);
                obj.setBlockSetMetaData({obj.BLOCKSET_DOC_HTML},{obj.normPath(htmlfile)});
            end
        end

    end
end

