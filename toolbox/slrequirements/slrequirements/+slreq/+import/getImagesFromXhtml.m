function[text,imageWasCopied]=getImagesFromXhtml(text,srcPath)








    imageWasCopied=false;




    srcPos=strfind(text,' data="');
    if~isempty(srcPos)
        srcAttr=' data="';
    else
        srcPos=strfind(text,' src="');
        srcAttr=' src="';
    end
    if isempty(srcPos)
        return;
    end
    srcDir=fileparts(srcPath);
    srcDirFS=strrep(srcDir,filesep,'/');
    absUrlPrefix=['file:///',strrep(srcDirFS,filesep,'/'),'/'];
    [reqifCacheDir,resourcePart]=slreq.import.resourceCachePaths('REQIF');
    totalImages=length(srcPos);
    imageWasCopied=false;
    oleObjectFound=false;
    objectWrappingFound=false;
    for i=1:totalImages
        imgNameStart=srcPos(i)+length(srcAttr);
        qMarks=strfind(text(imgNameStart:end),'"');
        imgNameEnd=imgNameStart+qMarks-1;
        imageName=unescapeImageUrl(text(imgNameStart:imgNameEnd-1));
        [~,~,imExt]=fileparts(imageName);
        if strcmpi(imExt,'.ole')


            oleObjectFound=true;
        elseif strncmp(imageName,'file://',7)

            [imageWasCopied,objectWrappingFound]=copyImageGivenFullPath(text,imageName,srcDirFS,reqifCacheDir);
        else

            [imageWasCopied,objectWrappingFound]=copyImageGivenRelativePath(text,imageName,reqifCacheDir);
        end
    end
    if imageWasCopied


        if oleObjectFound||objectWrappingFound
            text=unwrapObjects(text);
            srcAttr=' src="';
        end





        text=replaceSpacesInImagePaths(text,srcAttr);








        text=strrep(text,[srcAttr,absUrlPrefix],srcAttr);


        text=slreq.import.html.absPathToImages(text,resourcePart,'REQIF');
    end

    function out=replaceSpacesInImagePaths(in,attr)

        out=in;





        userTempDirGoodFilesep=strrep(tempdir,'\','/');
        attrWithTemp=[attr,'file:///',userTempDirGoodFilesep];
        srcAttrPos=strfind(in,attrWithTemp);
        if isempty(srcAttrPos)

            srcAttrPos=strfind(in,attr);
            attrLen=length(attr);
        else
            attrLen=length(attrWithTemp);
        end

        for j=1:length(srcAttrPos)
            pathStartPos=srcAttrPos(j)+attrLen;
            toNextQuote=strfind(in(pathStartPos:end),'"');
            nextQuotePos=pathStartPos+toNextQuote(1)-1;
            pathMask=false(1,length(in));
            pathMask(pathStartPos:nextQuotePos)=true;
            isSpace=(in==' ');
            out(pathMask&isSpace)='_';
        end
    end

    function out=unescapeImageUrl(in)
        out=strrep(strrep(in,'%5B','['),'%5D',']');
    end
end

function[imageWasCopied,objectWrappingFound]=copyImageGivenFullPath(text,imageName,srcDirFS,reqifCacheDir)
    imageWasCopied=false;
    objectWrappingFound=false;
    if ispc
        imageLocation=regexprep(imageName,'file:/+','');
    else
        imageLocation=regexprep(imageName,'file:/+','/');
    end
    cacheImageLocation=strrep(imageLocation,srcDirFS,reqifCacheDir);
    [imDir,imName,imExt]=fileparts(imageLocation);
    if exist(imageLocation,'file')~=2
        if exist(fullfile(imDir,imName),'file')==2

            imageLocation=fullfile(imDir,imName);
        else
            return;
        end
    end


    imageFolder=fileparts(cacheImageLocation);
    cacheImageDir=getValidOPCPath(imageFolder);
    if exist(cacheImageDir,'dir')~=7
        mkdir(cacheImageDir);
    end

    copyfile(imageLocation,fullfile(cacheImageDir,[imName,imExt]),'f');
    imageWasCopied=true;
    objectWrappingFound=isWrappedObject(text);

end

function[imageWasCopied,objectWrappingFound]=copyImageGivenRelativePath(text,imageName,reqifCacheDir)
    imageWasCopied=false;
    objectWrappingFound=false;
    [imDir,imName,imExt]=fileparts(imageName);
    imageSubFolder=getValidOPCPath(imDir);
    cacheImageDir=fullfile(reqifCacheDir,imageSubFolder);
    if exist(cacheImageDir,'dir')~=7
        mkdir(cacheImageDir);
    end
    if exist(imageName,'file')~=2
        if exist(imName,'file')==2

            imageName=imName;
        else
            return;
        end
    end
    copyfile(imageName,fullfile(cacheImageDir,[imName,imExt]),'f');
    imageWasCopied=true;
    objectWrappingFound=isWrappedObject(text);
end

function tf=isWrappedObject(text)






    tf=~contains(text,'<img ')&&(contains(text,'<object ')||contains(text,'<reqif-object '));
end

function out=unwrapObjects(in)





















    objectStarts=strfind(in,'<reqif-object ');
    objectEnds=strfind(in,'</reqif-object>');
    if~isempty(objectStarts)
        closingTag='</reqif-object>';
    else

        closingTag='</object>';
        objectStarts=strfind(in,'<object ');
        objectEnds=strfind(in,'</object>');
    end

    if isempty(objectStarts)
        out=in;
        return;
    end

    if isempty(objectEnds)

        closingTag='';
        tailTagLength=0;
        for i=1:length(objectStarts)
            findBrackets=strfind(in(objectStarts(1):end),'>');
            if isempty(findBrackets)
                error('Invalid content: %s',in);
            end
            objectEnds(i)=objectStarts(i)+findBrackets(1);
        end
    else
        tailTagLength=length(closingTag);
    end

    out=in(1:objectStarts(1)-1);
    tagCount=length(objectStarts);
    for i=1:tagCount
        start=objectStarts(i);
        if i>1&&start<objectEnds(i-1)


            out=strrep(out,closingTag,'');
        else
            endi=objectEnds(i)+tailTagLength-1;
            replacement=unwrapObject(in(start:endi));
            out=[out,replacement];%#ok<AGROW>
            if i<tagCount
                out=[out,in(endi+1:objectStarts(i+1)-1)];%#ok<AGROW>
            end
        end
    end
    out=[out,in(objectEnds(end)+tailTagLength:end)];
end

function out=unwrapObject(in)










    imgPath=getAttrValue(in,'data');
    imgWidth=getAttrValue(in,'width');

    function val=getAttrValue(tag,attr)
        val='';
        attrPattern=[' ',attr,'="'];
        attrPos=strfind(tag,attrPattern);
        if~isempty(attrPos)
            valStart=attrPos(end)+length(attrPattern);
            nextQuotePos=strfind(tag(valStart:end),'"');
            if~isempty(nextQuotePos)
                val=tag(valStart:valStart+nextQuotePos(1)-2);
            end
        end
    end

    if~isempty(imgPath)
        if~isempty(imgWidth)
            out=sprintf('<img src="%s" width="%s">',imgPath,imgWidth);
        else
            out=sprintf('<img src="%s">',imgPath);
        end
    else
        out=in;
    end
end

function out=getValidOPCPath(in)







    userTempDirGoodFilesep=strrep(tempdir,'\','/');
    tempFolderPos=strfind(in,userTempDirGoodFilesep);
    if isempty(tempFolderPos)

        out=strrep(in,' ','_');
    else
        tempFolderLength=length(userTempDirGoodFilesep);
        tempFolderEndPos=tempFolderPos+tempFolderLength;
        out=[in(1:tempFolderEndPos-1),strrep(in(tempFolderEndPos:end),' ','_')];
    end
end


