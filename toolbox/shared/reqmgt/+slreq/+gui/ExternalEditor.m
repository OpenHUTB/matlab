classdef ExternalEditor<handle




























    properties(Hidden=true,Constant)

        MAXSYSTEMPATHLENGTH=250;



        MAXFULLPATHLENGTH=230;


        MAXFOLDERLENGTH=200;

        INVOKE_TIDY_CONFIG_FILE=fullfile(matlabroot,'toolbox','shared','reqmgt','+slreq','+utils','tidyconfig.cfg');
    end

    properties(Access=private)
        ReqSetName;
        ReqSID;


        EditedProperty;


        ExternalFullPath;


        FileListener;

        IsDebug=false;














        WordInvoked=false;


        ReqSetTempDir;
    end

    methods

        function this=ExternalEditor(dasReq,editedProperty)






            reqSet=dasReq.RequirementSet;
            this.ReqSetName=reqSet.Name;
            this.ReqSID=dasReq.SID;
            switch editedProperty
            case 'Description'
                this.EditedProperty=slreq.gui.EditedProperty.Description;
            case 'Rationale'
                this.EditedProperty=slreq.gui.EditedProperty.Rationale;
            otherwise
            end

            this.initFilePath();
            this.addListeners();
        end


        function delete(this)


            try
                if~isempty(this.FileListener)
                    this.FileListener.Enabled=false;
                    this.FileListener.Source{1}.EnableRaisingEvents=false;
                    this.FileListener=[];
                end
                rmicom.wordApp('closedoc',this.ExternalFullPath);






            catch ex

                if this.IsDebug
                    rethrow(ex);
                end

            end
        end


        function out=getEditedDasObject(this)
            dataObj=this.getEditedDataObject();
            out=dataObj.getDasObject;
        end


        function out=getEditedDataObject(this)
            reqData=slreq.data.ReqData.getInstance();
            reqSet=reqData.getReqSet(this.ReqSetName);
            out=reqSet.getRequirementById(this.ReqSID);
        end


        function invokeEditor(this)









            this.disableListener();


            this.checkAndUpdateFile();


            this.openFile();


            this.enableListener();
        end


        function out=hasUnsavedChange(this)

            hDoc=rmicom.wordApp('finddoc',this.ExternalFullPath);
            if~isempty(hDoc)&&~hDoc.Saved
                out=true;
            else
                out=false;
            end
        end


        function closeDoc(this)
            rmicom.wordApp('closedoc',this.ExternalFullPath);
            this.WordInvoked=false;
        end


        function disableListener(this)
            if~isempty(this.FileListener)
                this.FileListener.Enabled=false;
                this.FileListener.Source{1}.EnableRaisingEvents=false;
            end
        end


        function enableListener(this)
            if~isempty(this.FileListener)
                this.FileListener.Enabled=true;
                this.FileListener.Source{1}.EnableRaisingEvents=true;
            end
        end
    end

    methods(Static)


        function externalEditingCallBack(~,~,this)

            this.pushContentToEditedObject();
        end


        function out=getBaseDir(reqSID,propertyName)
            out=[num2str(reqSID),'_',upper(propertyName(1))];
        end


        function out=isEditorTypeWord(dataReq,propertyType)
            switch lower(propertyType)
            case 'description'
                out=strcmp(dataReq.descriptionEditorType,'word');
            case 'rationale'
                out=strcmp(dataReq.rationaleEditorType,'word');
            otherwise
                error('wrong property type given')
            end


        end


        function out=getResourceBaseFileName(propertyName)

            out=lower(propertyName(1:3));
        end

        function[outStr,baseExternalName,resourcePath]=getExternalFilePath(dasReq,propertyName)





            reqSet=dasReq.RequirementSet;
            reqSetName=reqSet.Name;
            reqSID=dasReq.SID;
            [outStr,baseExternalName,resourcePath]=slreq.gui.ExternalEditor.constructExternalFilePath(reqSetName,reqSID,propertyName);
        end

        function[outStr,baseExternalName,resourcePath]=constructExternalFilePath(reqSetName,reqSID,propertyName)




            baseExternalName=fullfile(slreq.opc.getReqSetTempDir(reqSetName));




            externalDirName=fullfile(baseExternalName,slreq.gui.ExternalEditor.getBaseDir(reqSID,propertyName));


            if exist(externalDirName,'dir')~=7
                mkdir(externalDirName);
            end

            sourceBaseFileName=slreq.gui.ExternalEditor.getResourceBaseFileName(propertyName);



            assert(length(externalDirName)<slreq.gui.ExternalEditor.MAXFOLDERLENGTH);

            fullpath=fullfile(externalDirName,sourceBaseFileName);

            if length(fullpath)>slreq.gui.ExternalEditor.MAXFULLPATHLENGTH

                expLength=slreq.gui.ExternalEditor.MAXFULLPATHLENGTH-length(externalDirName);
                sourceBaseFileName=sourceBaseFileName(1:expLength);
            end
            outStr=fullfile(externalDirName,[sourceBaseFileName,'.htm']);
            if nargout==3
                resourceMacro=slreq.uri.ImageSourceConstants.SET_RESOURCE_MACRO_VAR;
                resourcePath=strrep(externalDirName,baseExternalName,resourceMacro);
                if ispc
                    resourcePath=strrep(resourcePath,'\','/');
                end
            end
        end


        function copyImagesToNewDstFolder(dstDataReq,oldReqSetName,oldSid,newReqSetName,newSid,propertyName)












            [oldFullPath,~,oldResourceBasePath]=...
            slreq.gui.ExternalEditor.constructExternalFilePath(oldReqSetName,oldSid,propertyName);

            [newFullPath,~,newResourceBasePath]=...
            slreq.gui.ExternalEditor.constructExternalFilePath(newReqSetName,newSid,propertyName);






            if strcmp(propertyName,'Description')
                dstDataReq.setRawDescription(strrep(dstDataReq.getRawDescription,oldResourceBasePath,newResourceBasePath));
            elseif strcmp(propertyName,'Rationale')
                dstDataReq.setRawRationale(strrep(dstDataReq.getRawRationale,oldResourceBasePath,newResourceBasePath));
            else
                error('Wrong property name is given');
            end











            [oldfilepath,oldfilename]=fileparts(oldFullPath);
            [newfilepath,newfilename]=fileparts(newFullPath);

            oldfolder=fullfile(oldfilepath,oldfilename);
            newfolder=fullfile(newfilepath,newfilename);
            if exist(newfolder,'dir')==7
                try

                    rmdir(newfolder,'s');
                catch ME %#ok<NASGU>

                end
            end

            try
                copyfile(oldfolder,newfolder);
                allNewFiles=dir(newfolder);
                imageList={};
                baseFileDir=slreq.gui.ExternalEditor.getResourceBaseFileName(propertyName);
                for index=1:length(allNewFiles)
                    cFile=allNewFiles(index);
                    if~ismember(cFile.name,{'.','..'})
                        imageList{end+1}=[newResourceBasePath,'/',baseFileDir,'/',cFile.name];%#ok<AGROW>
                    end
                end
            catch ME %#ok<NASGU>
                imageList={};
            end




            dataReqSet=dstDataReq.getReqSet;
            dataReqSet.collectImagesForPacking(imageList);
        end

    end

    methods(Access=private)


        function initFilePath(this)





            dasReq=this.getEditedDasObject();



            [this.ExternalFullPath,this.ReqSetTempDir]=...
            slreq.gui.ExternalEditor.getExternalFilePath(...
            dasReq,this.EditedProperty.toDasPropName);
        end


        function titleStr=getTitleStr(this)




            propertyStr=this.EditedProperty;
            titleStr=sprintf('%s of Requirement %s in %s',propertyStr,this.ReqSID,this.ReqSetName);
        end


        function folderName=getFileFolder(this)
            folderName=fileparts(this.ExternalFullPath);
        end

        function fileName=getFileName(this)
            [~,fileShortName,fileExt]=fileparts(this.ExternalFullPath);
            fileName=[fileShortName,fileExt];
        end


        function lastEditorType=getLastEditorType(this)
            dasReq=this.getEditedDasObject();
            switch this.EditedProperty
            case slreq.gui.EditedProperty.Rationale
                lastEditorType=dasReq.LastRatiEditorType;
            case slreq.gui.EditedProperty.Description
                lastEditorType=dasReq.LastDescEditorType;
            otherwise

                error('Invalid edited property given')
            end
        end


        function checkAndUpdateFile(this)

            fname=this.ExternalFullPath;


            if exist(fname,'file')==2
                lastEditorType=getLastEditorType(this);


                if~strcmpi(lastEditorType,'word')||~this.WordInvoked
                    this.pullContentIntoFile();
                    this.WordInvoked=true;
                end
            else
                this.pullContentIntoFile();
                this.WordInvoked=true;
            end
        end


        function openFile(this)
            docH=rmicom.wordApp('dispdoc',this.ExternalFullPath);





            try








                docH.WebOptions.UseLongFileNames=false;


                docH.WebOptions.OrganizeInFolder=true;



                docH.WebOptions.Encoding='msoEncodingUTF8';


                docH.WebOptions.AllowPNG=true;

                docH.ActiveWindow.Caption=this.getTitleStr();


                docH.WebOptions.RelyOnVML=false;





                docH.Save;
            catch ex %#ok<NASGU>

            end
        end


        function addListeners(this)




            fileFolder=this.getFileFolder();
            fileObj=System.IO.FileSystemWatcher(fileFolder);
            this.FileListener=addlistener(fileObj,...
            'Changed',...
            @(fobj,changeEvent)slreq.gui.ExternalEditor.externalEditingCallBack(...
            fobj,changeEvent,this));
        end


        function pullContentIntoFile(this)


            filePath=this.ExternalFullPath;
            filefolder=this.getFileFolder;
            if~exist(filefolder,'dir')
                mkdir(filefolder);
            end

            fid=fopen(filePath,'w+','native','UTF-8');
            if fid==-1



                fileName=this.getFileName();
                me=MException(message('Slvnv:slreq:ExternalEditorWarning',fileName));
                throw(me);
            else
                cleanup=onCleanup(@()fclose(fid));

                initContent=this.getEditedContentFromObject();
                htmlObj=slreq.utils.HTMLProcessor(initContent);


                htmlObj.setBaseDir(this.getFileFolder);





                htmlObj.removeWhiteSpaceStyle();




                if~htmlObj.isHTMLFromWord()
                    htmlObj.setTidyHTMLConfigFile(this.INVOKE_TIDY_CONFIG_FILE);
                    htmlObj.tidyHTML();
                end

                baseFileDir=slreq.gui.ExternalEditor.getResourceBaseFileName(char(this.EditedProperty));


                htmlObj.setRefFolder(fullfile(this.getFileFolder,baseFileDir));



                htmlObj.serializeBase64();








                htmlObj.updateHTMLEncoding('UTF-8');
                htmlObj.normalizeReferencedFilePath(true);

                htmlContent=native2unicode(htmlObj.HTMLString,'UTF-8');
                fprintf(fid,'%s',htmlContent);
            end
        end


        function content=getEditedContentFromObject(this)
            dasReq=this.getEditedDasObject();
            switch this.EditedProperty
            case slreq.gui.EditedProperty.Description
                content=dasReq.Description;
            case slreq.gui.EditedProperty.Rationale
                content=dasReq.Rationale;
            otherwise

                error("Unexpected property given");
            end
        end


        function pushContentToEditedObject(this)



            htmlStr=getFileContent(this);
            htmlObj=slreq.utils.HTMLProcessor(htmlStr);
            htmlObj.setBaseDir(this.getFileFolder);

            htmlObj.normalizeReferencedFilePath(false);
            htmlStr=htmlObj.HTMLString();
            dataReq=this.getEditedDataObject();
            dataReq.(lower(char(this.EditedProperty)))=htmlStr;
        end


        function setEditedPropertyToData(this,value)
            dataReq=this.getEditedDataObject();
            switch this.EditedProperty
            case slreq.gui.EditedProperty.Description
                dataReq.description=value;
            case slreq.gui.EditedProperty.Rationale
                dataReq.rationale=value;
            otherwise

                error("Unexpected property given");
            end
        end



        function filecontent=readFile(this)

            fullpath=this.ExternalFullPath;


            fid=fopen(fullpath,'r','n','UTF-8');
            filecontent='';
            if fid==-1

                return;
            end

            filecontent=fread(fid,'*char')';
            fclose(fid);
        end


        function outStr=getFileContent(this)


            filecontent=this.readFile();
            outStr=slreq.gui.ExternalEditor.cleanUpHTMLFromDoc(filecontent);
        end
    end

    methods(Static,Hidden=true)

        function outStr=cleanUpHTMLFromDoc(inStr)





            htmlObj=slreq.utils.HTMLProcessor(inStr);
            htmlObj.standardalizeSrcAttributes();
            outStr=htmlObj.HTMLString;
        end


        function cleanCachedDirs()
            try
                hashsetFolderPattern=[slreq.opc.getUsrTempDir,'/',slreq.uri.ImageSourceConstants.HASHSET_PREFIX,'*'];
                allDirInfo=dir(hashsetFolderPattern);

                for i=1:length(allDirInfo)
                    cDir=fullfile(allDirInfo(i).folder,allDirInfo(i).name);
                    rmdir(cDir,'s');
                end
            catch ex %#ok<NASGU>

            end
        end
    end
end