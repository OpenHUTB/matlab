classdef HTMLProcessor<handle





    properties(Constant)
        HTTP_PREFIX='http://';
        HTTPS_PREFIX='https://';
    end


    properties



        HTMLString='';



        EnpackedHTMLString='';


        TidyHTMLConfigFilePath=fullfile(matlabroot,'toolbox',...
        'shared','reqmgt','+slreq','+utils','tidyconfig.cfg');


        ReferencedFiles={};



        EnpackedReferencedFiles={};






        BaseDir;


        ReferencedFolderPath;


        OpcMacroPath;


        extToMimeType=initExtToMimeType();
        mimeTypeToExt=initMimeTypeToExt();
    end


    properties(Access=private)

        BodyString='';


        HeadString='';



        HTMLStringWithoutMeta;




        MetaInfo={};
    end


    methods

        function this=HTMLProcessor(htmlStrOrHTMLFilePath,isUsingReqSetMacro)







            if nargin<2
                isUsingReqSetMacro=true;
            end

            if~isempty(htmlStrOrHTMLFilePath)&&exist(htmlStrOrHTMLFilePath,'file')
                fid=fopen(htmlStrOrHTMLFilePath,'r','n','UTF-8');
                if fid==-1

                    return;
                end
                htmlRawString=fread(fid,'*char')';
                fclose(fid);
                this.HTMLString=htmlRawString;
            else
                this.HTMLString=htmlStrOrHTMLFilePath;
            end

            if isUsingReqSetMacro
                this.OpcMacroPath=slreq.uri.ImageSourceConstants.SET_RESOURCE_MACRO_VAR;
            else
                this.OpcMacroPath=slreq.uri.ImageSourceConstants.RESOURCE_MACRO_VAR;
            end

        end






        function setBaseDir(this,dirString)
            this.BaseDir=dirString;
        end


        function setRefFolder(this,dirString)
            this.ReferencedFolderPath=urldecode(dirString);
            if exist(dirString,'dir')~=7
                mkdir(dirString);
            end
        end


        function setTidyHTMLConfigFile(this,configFilePath)
            this.TidyHTMLConfigFilePath=configFilePath;
        end






        function tidyHTML(this)



            if isempty(this.HTMLString)


                htmlStr=' ';
            else
                htmlStr=this.HTMLString;
            end
            this.HTMLString=slreq.utils.HTMLProcessor.tidyHTMLStr(...
            htmlStr,this.TidyHTMLConfigFilePath);
        end

        function out=getEnpackedReferencedFiles(this)
            out=cell(size(this.ReferencedFiles));
            if strcmpi(this.OpcMacroPath,slreq.uri.ImageSourceConstants.SET_RESOURCE_MACRO_VAR)


                baseDir=fullfile(this.BaseDir);
            else
                baseDir=this.BaseDir;
            end

            for index=1:length(this.ReferencedFiles)
                cFile=urldecode(this.ReferencedFiles{index});
                out{index}=strrep(cFile,baseDir,this.OpcMacroPath);
                if ispc
                    out{index}=strrep(out{index},'\','/');
                end
            end
        end


        function out=isHTMLFromWord(this)

            out=false;
            htmlString=this.HTMLString;

            if~isempty(htmlString)&&((length(htmlString)>45&&...
                contains(htmlString(1:45),'<html xmlns:v="urn:schemas-microsoft-com:vml"'))||...
                contains(htmlString,'<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0//EN" "http://www.w3.org/TR/REC-html40/strict.dtd">'))||...
                contains(htmlString,'xmlns:o="urn:schemas-microsoft-com:office:office"')||...
                contains(htmlString,'xmlns:w="urn:schemas-microsoft-com:office:word"')
                out=true;
                return;
            end
        end

        function removeWhiteSpaceStyle(this)
            htmlString=this.HTMLString;
            whitespaceStyle='p, li { white-space: pre-wrap; }';
            this.HTMLString=strrep(htmlString,whitespaceStyle,'');
        end


        function updateHTMLEncoding(this,encodingStr)

            if nargin<2
                encodingStr='UTF-8';
            end
            this.queryHead;
            this.queryMeta;
            this.setEncodingInMeta(encodingStr);














            headPattern='(<head[^>]*>)';
            headStr=regexp(this.HTMLStringWithoutMeta,headPattern,'match');
            metaStr=this.metaDataToHtmlStr;

            if isempty(headStr)

                bodyPattern='(<body[^>]*>)';
                bodyStr=regexp(this.HTMLStringWithoutMeta,bodyPattern,'match');
                if isempty(bodyStr)

                    this.HTMLString=['<head>',metaStr,'</head>',newline,'<body>',newline,this.HTMLStringWithoutMeta,newline,'</body>'];
                else

                    bodyPos=strfind(this.HTMLStringWithoutMeta,bodyStr{1});
                    this.HTMLString=insertAtPosition(this.HTMLStringWithoutMeta,bodyPos,['<head>',metaStr,'</head>']);
                end
            else
                headerPos=strfind(this.HTMLStringWithoutMeta,headStr{1});
                posAfterHeader=headerPos(1)+length(headStr{1});
                this.HTMLString=insertAtPosition(this.HTMLStringWithoutMeta,posAfterHeader,[newline,metaStr]);
            end

            function result=insertAtPosition(original,pos,partToInsert)
                result=[original(1:pos-1),partToInsert,original(pos:end)];
            end

        end


        function refreshAllRequiredFiles(this)

            allReferencedFiles=...
            getAllReferencedFilesInHTML(this);



            allRequiredFiles=...
            getFileListFromWordFile(this);


            this.ReferencedFiles=[allReferencedFiles,allRequiredFiles];
        end


        function serializeBase64(this)




            inhtml=this.HTMLString;
            allbit64Strs=regexp(inhtml,...
            'img\s[^>]*src=\s*"data:image/(\S+);base64,([^"]*?)"','tokens');
            outhtml=inhtml;
            baseFilePath=fullfile(this.ReferencedFolderPath,'image');
            for strIndex=1:length(allbit64Strs)
                if length(allbit64Strs{strIndex})<2
                    continue;
                end

                cBit64MimeType=allbit64Strs{strIndex}{1};
                fileExt=this.getExtFromMimeType(cBit64MimeType);
                baseFilePath=[baseFilePath,fileExt];
                cBit64Str=allbit64Strs{strIndex}{2};
                if~isempty(cBit64Str)
                    newfilepath=slreq.report.utils.generateFileName(baseFilePath);
                    slreq.utils.HTMLProcessor.convertBase64ToFile(cBit64Str,newfilepath);
                    newImageSrc=sprintf('"file:///%s"',strrep(newfilepath,'\','/'));
                    oldImageSrc=['"data:image/',cBit64MimeType,';base64,',cBit64Str,'"'];
                    outhtml=strrep(outhtml,oldImageSrc,newImageSrc);
                end
            end
            this.HTMLString=outhtml;
        end



        function encodeImageSourceToBase64(this)







            inhtml=this.HTMLString;

            allFiles=this.getAllReferencedFilesInHTML(true);

            outhtml=inhtml;

            for fIndex=1:length(allFiles)
                file=allFiles{fIndex};
                filePath=strrep(file,'file:///','');
                [~,~,fileExt]=fileparts(filePath);

                [status,base64Str]=slreq.utils.HTMLProcessor.convertFileToBase64(filePath);
                if status
                    oldImageSrc=file;
                    prefix=this.getBase64PrefixByExt(fileExt);
                    newImageSrc=[prefix,base64Str];
                    outhtml=strrep(outhtml,oldImageSrc,newImageSrc);
                end
            end
            this.HTMLString=outhtml;
        end


        function standardalizeSrcAttributes(this)




            htmlStr=this.HTMLString;
            srcPattern='(<img\s[^>]*src=\s*)([^">]+)';
            this.HTMLString=regexprep(htmlStr,srcPattern,'$1"$2"');
        end



        function normalizeReferencedFilePath(this,isCopyLocalImage)





            this.refreshAllRequiredFiles;

            htmlString=this.HTMLString;
            allFiles=this.ReferencedFiles;
            baseDir=this.BaseDir;
            expDstPath=this.ReferencedFolderPath;



































            if nargin<2
                isCopyLocalImage=false;
            end

            newFileList={};
            for index=1:length(allFiles)

                cFile=allFiles{index};
                newFileList{index}=cFile;


                if isHttpOrHttps(cFile)||isBase64(cFile)
                    continue;
                end


                if strncmpi(cFile,'file:///',8)
                    filePathInHtml=cFile(9:end);
                else
                    filePathInHtml=cFile;
                end



                imageCanonicalPath=locGetCanonicalPath(filePathInHtml,baseDir);









                decodedImagePath=urldecode(imageCanonicalPath);

                if~isCopyLocalImage||(isCopyLocalImage&&contains(decodedImagePath,expDstPath))




                    htmlString=strrep(htmlString,cFile,imageCanonicalPath);
                    newFileList{index}=imageCanonicalPath;
                elseif exist(decodedImagePath,'file')
                    [status,copiedImagePath]=...
                    this.copyImage(decodedImagePath,expDstPath);
                    if status
                        htmlString=strrep(htmlString,cFile,copiedImagePath);
                        newFileList{index}=copiedImagePath;
                    end
                else
                    warning([cFile,'cannot be found']);
                end
            end
            this.HTMLString=htmlString;
            this.ReferencedFiles=newFileList;
        end


        function outStr=enpackImages(this)





            outStr=this.HTMLString;
            fileList=this.ReferencedFiles;
            if~isempty(fileList)
                if strcmpi(this.OpcMacroPath,slreq.uri.ImageSourceConstants.SET_RESOURCE_MACRO_VAR)


                    baseDir=fullfile(this.BaseDir);
                else
                    baseDir=this.BaseDir;
                end
                for index=1:length(fileList)
                    cFilePath=fileList{index};
                    newFilePath=locGetNewSrcPathForData(cFilePath,baseDir,this.OpcMacroPath);
                    this.ReferencedFiles{index}=newFilePath;
                    outStr=strrep(outStr,cFilePath,newFilePath);
                end
            end
            this.EnpackedHTMLString=outStr;
        end


        function outStr=updateReferenceFileSrc(this,oldSrc,newSrc)
            outStr=this.HTMLString;
            fileList=this.ReferencedFiles;
            for index=1:length(fileList)
                cFilePath=fileList{index};
                newFilePath=strrep(cFilePath,oldSrc,newSrc);
                outStr=strrep(outStr,cFilePath,newFilePath);
            end

        end













        function moveImages(this,dstBaseFolder,dstFullPath)









            this.setBaseDir(dstBaseFolder);


            this.setRefFolder(dstFullPath);

            this.normalizeReferencedFilePath(true);
        end


    end

    methods(Access=private)

        function queryBody(this)
            this.BodyString=locQueryRegExpByUniqueMatch(...
            this.HTMLString,'(<body[^>]*>)(.*?)/body\s*>');
        end


        function queryHead(this)
            this.HeadString=locQueryRegExpByUniqueMatch(...
            this.HTMLString,'(<head[^>]*>)(.*?)/head\s*>');
        end


        function queryMeta(this)
            this.MetaInfo={};
            headInfo=this.HeadString;




            allMeta=regexp(headInfo,'(<meta[^>]*?>)','match');
            htmlString=this.HTMLString;

            for index=1:length(allMeta)

                metaMap=locReadMeta(allMeta{index});
                this.MetaInfo{end+1}=metaMap;

                htmlString=regexprep(htmlString,['\s*',allMeta{index},'\s*'],'');
            end
            this.HTMLStringWithoutMeta=htmlString;
        end


        function setEncodingInMeta(this,encodingStr)
            foundCharset=false;
            for index=1:length(this.MetaInfo)
                cMeta=this.MetaInfo{index};
                if isKey(cMeta,'content')&&contains(cMeta('content'),'charset=')
                    cMeta('content')=regexprep(cMeta('content'),'charset=(\S*)',['charset=',encodingStr]);
                    foundCharset=true;
                end

                if isKey(cMeta,'charset')
                    cMeta('charset')=encodingStr;%#ok<NASGU>
                    foundCharset=true;
                end
            end
            if~foundCharset
                newMeta=containers.Map;
                newMeta('charset')=encodingStr;
                this.MetaInfo{end+1}=newMeta;
            end
        end


        function outStr=metaDataToHtmlStr(this)

            outStr='';
            for index=1:length(this.MetaInfo)
                cMeta=this.MetaInfo{index};
                outStr=sprintf('%s<meta',outStr);
                extractedFields={};





                if isKey(cMeta,'name')
                    outStr=sprintf('%s name="%s"',outStr,cMeta('name'));
                    extractedFields=[extractedFields,'name'];%#ok<*AGROW>
                end
                if isKey(cMeta,'http-equiv')
                    outStr=sprintf('%s http-equiv="%s"',outStr,cMeta('http-equiv'));
                    extractedFields=[extractedFields,'http-equiv'];
                end

                if isKey(cMeta,'content')
                    outStr=sprintf('%s content="%s"',outStr,cMeta('content'));
                    extractedFields=[extractedFields,'content'];
                end

                allKeys=cMeta.keys;
                restFields=setdiff(allKeys,extractedFields);

                for kIndex=1:length(restFields)
                    cKey=restFields{kIndex};
                    cValue=cMeta(cKey);
                    outStr=sprintf('%s %s="%s"',outStr,cKey,cValue);
                end
                outStr=sprintf('%s%s\n',outStr,'/>');
            end
        end


        function getReferencedFolderPathFromWordHTML(this)

            htmlStr=this.HTMLString;
            refBasePath=this.BaseDir;
            fileListFilePattern='<link rel=File-List href="([^"]*?)">';
            fileListFile=regexp(htmlStr,fileListFilePattern,'tokens');
            if~isempty(fileListFile)
                fileListName=fileListFile{1}{1};
                fileFullPath=fullfile(refBasePath,fileListName);
                this.setRefFolder(fileparts(fileFullPath));
            end
        end


        function fileList=getFileListFromWordFile(this)




            htmlStr=this.HTMLString;
            refBasePath=this.BaseDir;
            fileListFilePattern='<link rel=File-List href="([^"]*?)">';
            fileListFile=regexp(htmlStr,fileListFilePattern,'tokens');
            fileList={};
            if~isempty(fileListFile)
                fileListName=fileListFile{1}{1};
                fileFullPath=fullfile(refBasePath,fileListName);
                filedir=fileparts(fileFullPath);
                this.setRefFolder(filedir);
                fid=fopen(fileFullPath,'r','n','UTF-8');
                if fid==-1

                    return;
                end

                filecontent=fread(fid,'*char')';
                fclose(fid);
                filePattern='<o:File HRef="([^"]*?)"/>';
                fileListFile=regexp(filecontent,filePattern,'tokens');

                fileShortList=[fileListFile{:}];



                fileRefPath=fileparts(fileListName);

                fileBasePath=fullfile(refBasePath,fileRefPath);

                fileList=fullfile(fileBasePath,fileShortList);
            end
        end


        function allImages=getAllReferencedFilesInHTML(this,imageOnly)
            if nargin<2
                imageOnly=false;
            end
            htmlstr=this.HTMLString;

            if imageOnly
                imgPattern='<img[^>]*?src\s*=\s*"([^"]*?)"';
            else
                imgPattern='<[^>]*?src\s*=\s*"([^"]*?)"';
            end
            allImageSrc=regexp(htmlstr,imgPattern,'tokens');
            allImages={};
            for index=1:length(allImageSrc)
                cImage=allImageSrc{index}{1};

                if isBase64(cImage)||isHttpOrHttps(cImage)
                    continue;
                end
                allImages{end+1}=cImage;
            end
        end


        function prefix=getBase64PrefixByExt(this,extName)
            extName=lower(extName);
            if isKey(this.extToMimeType,extName)
                imageType=this.extToMimeType(extName);
            else
                imageType='png';
            end

            prefix=['data:image/',imageType,';base64,'];
        end


        function ext=getExtFromMimeType(this,mimeType)
            if isKey(this.mimeTypeToExt,mimeType)
                ext=this.mimeTypeToExt(mimeType);
            else
                ext='.png';
            end
        end
    end

    methods(Static)

        function outStr=tidyHTMLStr(inStr,configFileFullPath)
            try
                if nargin<2
                    outStr=char(mlreportgen.utils.tidy(inStr));
                else
                    outStr=char(mlreportgen.utils.tidy(inStr,'ConfigFile',configFileFullPath));
                end
            catch ex

                error(message('Slvnv:slreq:ExternalEditorErrorInTidy'));
            end
        end


        function convertBase64ToFile(cBit64Str,filename)

            bts=matlab.net.base64decode(cBit64Str);

            int8bts=typecast(bts,'int8');
            fid=fopen(filename,'w');
            fwrite(fid,int8bts','int8');
            fclose(fid);
        end


        function[status,base64Str]=convertFileToBase64(fileName)
            fid=fopen(fileName,'rb');
            status=true;
            if fid>0
                bytes=fread(fid,'uint8=>uint8');
                fclose(fid);
                base64Str=matlab.net.base64encode(bytes);
            else
                status=false;
                base64Str='';
            end
        end


        function[status,copiedImagePath]=copyImage(imagePath,dstPath)

            [~,~,fileext]=fileparts(imagePath);
            if exist(dstPath,'dir')~=7
                mkdir(dstPath);
            end

            copiedImagePath=slreq.report.utils.generateFileName(...
            fullfile(dstPath,['image',fileext]));
            status=copyfile(imagePath,copiedImagePath);
            if status

            else

                warning(['copy failed for ',cFile])
            end
        end


        function[outHTML,imageList]=packingImage(inHTML,resourcePath,isUsingReqSetMacro)











            htmlObj=slreq.utils.HTMLProcessor(inHTML,isUsingReqSetMacro);

            htmlObj.setBaseDir(resourcePath);

            htmlObj.refreshAllRequiredFiles;


            htmlObj.enpackImages();


            outHTML=htmlObj.EnpackedHTMLString;
            imageList=htmlObj.getEnpackedReferencedFiles();
        end
    end
end


function out=isHttpOrHttps(imageStr)
    out=strncmpi(imageStr,slreq.utils.HTMLProcessor.HTTP_PREFIX,...
    length(slreq.utils.HTMLProcessor.HTTP_PREFIX))||...
    strncmpi(imageStr,slreq.utils.HTMLProcessor.HTTPS_PREFIX,...
    length(slreq.utils.HTMLProcessor.HTTPS_PREFIX));
end


function out=isBase64(imageStr)



    base64Str='^data:image/\S+;base64,';
    out=~isempty(regexp(imageStr,base64Str,'once'));
end


function newImagePath=locGetNewSrcPathForData(imageOldPath,baseDir,macroPath)



    if isHttpOrHttps(imageOldPath)||isBase64(imageOldPath)
        newImagePath=imageOldPath;
        return;
    end



    imageOldPath=urldecode(imageOldPath);

    imagePath=erase(imageOldPath,'file:///');
    relativePath=erase(imagePath,baseDir);
    relativePathInPkg=strrep(relativePath,'\','/');


    relativePathInPkg=strrep(relativePathInPkg,':','_');

    if relativePathInPkg(1)~='/'
        relativePathInPkg=['/',relativePathInPkg];
    end
    relativePathInPkg=ensureImageFileExists(imagePath,baseDir,relativePathInPkg);
    newImagePath=['file:///',macroPath,relativePathInPkg];
end


function ret=ensureImageFileExists(originalImage,baseDir,relativePathInPkg)


    referredImage=[baseDir,relativePathInPkg];
    ret=relativePathInPkg;

    parentDir=fileparts(referredImage);

    if exist(parentDir,'dir')~=7
        mkdir(parentDir);
    end
    if isfile(originalImage)

        origImage=strrep(originalImage,'\','/');
        refImage=strrep(referredImage,'\','/');
        if~strcmp(origImage,refImage)
            copyfile(originalImage,referredImage);
        end
    end

end


function out=locReadMeta(metaStr)


































    metaContent=regexp(metaStr,'<meta\s*([^>]*?)\s*[\/]*>','tokens');
    out=containers.Map;


    metaTypeList={'name','http-equiv','charset','schema'};

    metaType='';
    if isempty(metaContent)
        return;
    else
        tmpMetaContent=strtrim(metaContent{1}{1});
    end

    while contains(tmpMetaContent,'=')
        eqPos=strfind(tmpMetaContent,'=');



        attName=lower(tmpMetaContent(1:eqPos(1)-1));
        restContent=strtrim(tmpMetaContent(eqPos(1)+1:end));
        if strcmp(restContent(1),'''')

            [attValue,tmpMetaContent]=locGetPropValue(restContent,'''');
        elseif strcmp(restContent(1),'"')

            [attValue,tmpMetaContent]=locGetPropValue(restContent,'"');
        elseif contains(restContent,' ')




            parseResult=regexp(restContent,'(\S+?)\s+(\S.*?$)','tokens');
            attValue=parseResult{1}{1};
            tmpMetaContent=strtrim(parseResult{1}{2});
        else


            attValue=restContent;
            out(attName)=attValue;
            inlineSetMetaType(attName);
            break;
        end

        out(attName)=attValue;
        inlineSetMetaType(attName);
    end

    function inlineSetMetaType(attName)
        if ismember(attName,metaTypeList)
            if isempty(metaType)
                metaType=attName;
            else
                warning(['dup metaType found: ',metaType,'and',attName]);
            end
        end

    end
end


function outString=locQueryRegExpByUniqueMatch(htmlstring,pattern)
    parseInfo=regexp(htmlstring,pattern,'match');
    if isempty(parseInfo)

        outString='';
    else
        outString=parseInfo{1};
    end
end


function[propValue,restString]=locGetPropValue(content,sep)
    sepPos=strfind(content,sep);
    propValue=content(sepPos(1)+1:sepPos(2)-1);
    restString=strtrim(content(sepPos(2)+1:end));
end


function imageCanonicalPath=locGetCanonicalPath(filePath,baseDir)


    if rmiut.isCompletePath(filePath)

        fullImagePathInSys=fullfile(filePath);
    else


        fullImagePathInSys=fullfile(baseDir,filePath);
    end
    fullfolder=fileparts(fullImagePathInSys);
    if contains(fullfolder,'.')





        try

            imageCanonicalPath=slreq.cpputils.getCanonicalPath(fullImagePathInSys);
        catch ex %#ok<NASGU>







            imageCanonicalPath=fullImagePathInSys;
        end
    else
        imageCanonicalPath=fullImagePathInSys;
    end
end


function out=initExtToMimeType()



    exts={'.bmp','.gif','.ico','.jpeg','.jpg','.png','.tif','.tiff','.webp','.svg'};
    mime={'bmp','gif','x-icon','jpeg','jpeg','png','tiff','tiff','webp','svg+xml'};

    out=containers.Map(exts,mime);
end


function out=initMimeTypeToExt()
    exts={'.bmp','.gif','.ico','.jpeg','.png','.tiff','.webp','.svg'};
    mime={'bmp','gif','x-icon','jpeg','png','tiff','webp','svg+xml'};

    out=containers.Map(mime,exts);
end
