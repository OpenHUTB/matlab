function filePath=findFile(filename,varargin)





















    p=inputParser();
    p.addRequired('FileName',@(x)ischar(x)||isstring(x));
    p.addParameter('FileExtensions',[]);
    p.addParameter('FileMustExist',true);
    p.parse(filename,varargin{:});
    args=p.Results;


    args.FileName=string(args.FileName);
    args.FileExtensions=string(args.FileExtensions);


    args.FileExtensions=regexprep(args.FileExtensions,"^\.","");


    args.FileName=ensureFilePath(args.FileName);


    filePath=findFileImpl(args.FileName);
    if isempty(filePath)
        nFileExts=numel(args.FileExtensions);
        i=1;
        while((i<=nFileExts)&&isempty(filePath))
            filename=args.FileName+"."+args.FileExtensions(i);
            filePath=findFileImpl(filename);
            i=i+1;
        end
    end


    if(~args.FileMustExist&&isempty(filePath))

        filePath=args.FileName;


        [~,~,fExt]=fileparts(args.FileName);
        hasFileExtension=(fExt.strlength>0);



        if(~hasFileExtension&&~isempty(args.FileExtensions))
            filePath=filePath+"."+args.FileExtensions(1);
        end

        filePath=mlreportgen.utils.internal.canonicalPath(filePath);
        filePath=string(filePath);
    end
end

function fullName=findFileImpl(fileName)

    fullName=string(which(fileName));
    if(fullName=="")
        fullName=string.empty();
    else


        [~,foundName,foundExt]=fileparts(fullName);
        foundFileName=strcat(foundName,foundExt);

        [~,inName,inExt]=fileparts(fileName);
        inFileName=strcat(inName,inExt);

        if~strcmp(inFileName,foundFileName)
            fullName=string.empty();
        end
    end

    if(isempty(fullName)&&isfile(fileName))

        fullName=mlreportgen.utils.internal.canonicalPath(fileName);
        fullName=string(fullName);
    end
end

function outFilePath=ensureFilePath(filePath)

    if startsWith(filePath,"file:")

        outFilePath=string(urldecode(filePath));


        outFilePath=regexprep(outFilePath,"^file:","");


        if ispc()
            if isUNCPath(outFilePath)



            else



                outFilePath=regexprep(outFilePath,"^///","");
            end
        else



            outFilePath=regexprep(outFilePath,"^//","");
        end
    else

        outFilePath=filePath;
    end


    outFilePath=regexprep(outFilePath,"\\|/",filesep);
end

function tf=isUNCPath(filePath)
    tf=~isempty(regexp(filePath,"^//[\w]+/","once"));
end