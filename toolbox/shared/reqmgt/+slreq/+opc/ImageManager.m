
























classdef ImageManager<handle

    properties



        imageSet;


        usrTempDir;



        ReqSetTempDir;


        resourceVar;

        reqSetResourceVar;


        ReqSetName;

    end

    methods
        function this=ImageManager(reqSetName)
            this.imageSet=containers.Map('KeyType','char','ValueType','logical');

            this.usrTempDir='';

            this.resourceVar=slreq.uri.ImageSourceConstants.RESOURCE_MACRO_VAR;

            this.reqSetResourceVar=slreq.uri.ImageSourceConstants.SET_RESOURCE_MACRO_VAR;

            this.ReqSetName=reqSetName;
        end


        function initTempDir(this)
            if~isempty(this.usrTempDir)
                return;
            end

            this.usrTempDir=slreq.opc.getUsrTempDir();

            if exist(this.usrTempDir,'file')~=7
                mkdir(this.usrTempDir);
            end





        end




        function initReqSetTempDir(this)
            if~isempty(this.ReqSetTempDir)
                return;
            end

            this.ReqSetTempDir=slreq.opc.getReqSetTempDir(this.ReqSetName);
            if exist(this.ReqSetTempDir,'file')~=7
                mkdir(this.ReqSetTempDir);
            end
        end


        function[modifiedTxt,macroUsed]=unpackImages(this,txtData,dstDir)




            if nargin<3
                dstDir=[];
            end

            macroUsed='';


            modifiedTxt=this.unpackResourceForReq(txtData,dstDir);
            if~strcmp(modifiedTxt,txtData)
                macroUsed=this.resourceVar;







                return;
            end


            modifiedTxt=this.unpackResourceForReqSet(modifiedTxt,dstDir);
            if~strcmp(modifiedTxt,txtData)
                macroUsed=this.reqSetResourceVar;
            end
        end


        function relativePath=absoluteToRelative(this,absolutePath)
            relativePath=strrep(absolutePath,this.usrTempDir,this.resourceVar);
        end


        function out=getImageFilenamesToPack(this)
            out={};
            imagePaths=this.imageSet.keys();
            for i=1:length(imagePaths)
                imagePath=imagePaths{i};
                out{end+1}=this.unpackImages(imagePath);%#ok<AGROW>
            end
        end

        function out=getImageList(this)

            out=this.imageSet.keys();
        end

        function out=getImageListForReq(this,sid,propertyName)
            [~,~,resourceName]=slreq.gui.ExternalEditor.constructExternalFilePath(this.ReqSetName,sid,propertyName);
            allImages=this.getImageList;
            out={};
            for index=1:length(allImages)
                cImage=allImages{index};
                if startsWith(cImage,resourceName)
                    out{end+1}=cImage;%#ok<AGROW>
                end
            end
        end

        function removeImages(this,imageList)
            warningState=warning('off','MATLAB:Containers:Map:NoKeyToRemove');
            c=onCleanup(@()warning(warningState));
            this.imageSet.remove(imageList);
        end


        function collectImagesForPacking(this,images)
            for i=1:numel(images)

                image=images{i};
                this.imageSet(image)=true;
            end
        end

        function refreshImages(this,images)
            this.imageSet=containers.Map('KeyType','char','ValueType','logical');
            this.collectImagesForPacking(images);
        end

        function refreshImagesMacrosIfNecessary(this,asVersion)
            if ismember(asVersion,{'R2018a','R2017b'})
                allImages=this.getImageList;
                reqSetBaseName=slreq.opc.getReqSetDirBaseName(this.ReqSetName);
                sourceMacro=this.reqSetResourceVar;
                targetMacro=[this.resourceVar,'/',reqSetBaseName];
                newImages=strrep(allImages,sourceMacro,targetMacro);
                this.refreshImages(newImages);
            end
        end

        function collectImagesFromHTML(this,txtData)




            this.initTempDir();
            images=slreq.opc.ImageManager.findImages(txtData,this.usrTempDir,this.resourceVar);
            this.collectImagesForPacking(images);
        end
    end


    methods(Access=private)

        function outTxt=unpackResourceForReq(this,inTxt,dstDir)
            this.initTempDir();

            if isempty(dstDir)
                dstDir=this.usrTempDir;
            end

            outTxt=locExtractMacro(inTxt,this.resourceVar,dstDir);
        end


        function outTxt=unpackResourceForReqSet(this,inTxt,dstDir)
            this.initReqSetTempDir()

            if isempty(dstDir)
                dstDir=this.ReqSetTempDir;
            end

            outTxt=locExtractMacro(inTxt,this.reqSetResourceVar,dstDir);
        end
    end
    methods(Static)

        function images=findImages(txtData,~,rsrcVar)
            images={};
















            rsrcVarLen=length(rsrcVar);


            allLines=strsplit(txtData,newline);

            for i=1:length(allLines)
                line=allLines{i};
                impos=strfind(line,rsrcVar);
                if~isempty(impos)
                    afterTempPath=impos+rsrcVarLen;
                    theRest=line(afterTempPath:end);
                    allQuotes=strfind(theRest,'"');
                    endOfPath=impos+rsrcVarLen+allQuotes(1)-2;
                    images{end+1}=line(impos:endOfPath);%#ok<AGROW>
                end
            end
        end
    end
end


function outText=locExtractMacro(inText,microVarName,targetValue)
    outText=strrep(inText,microVarName,targetValue);
end