function out=tidy(varargin)






































    p=inputParser();
    p.addRequired("Input",@(x)ischar(x)||isstring(x));
    p.addParameter("OutputFile",[],@(x)isempty(x)||ischar(x)||isstring(x));
    p.addParameter("OutputType",[],@(x)isempty(x)||ismember(string(lower(x)),["xml","html","xhtml"]));
    p.addParameter("ConfigFile",[],@(x)isempty(x)||isfile(x)||isfile(fullfile(resourceDir(),x)));
    p.addParameter("WorkingFolder",tempdir(),@(x)ischar(x)||isstring(x));
    p.parse(varargin{:});
    args=p.Results;
    args.Input=string(args.Input);

    if isfile(args.Input)
        inputFile=mlreportgen.utils.internal.canonicalPath(args.Input);
        out=tidyFile(inputFile,args);
    elseif(strlength(args.Input)>0)
        out=tidyString(args);
    else
        out=string.empty();
    end
end

function out=tidyFile(inputFile,args)
    configFile=getConfigFile(args,inputFile);
    outputFile=getOutputFile(args,inputFile);


    [asciiInputFile,scopedInputFileCB]=getASCIIProxyFile(inputFile,args);%#ok
    [asciiOutputFile,scopedOutputFileCB]=getASCIIProxyFile(outputFile,args);%#ok
    [asciiConfigFile,scopedConfigFileCB]=getASCIIProxyFile(configFile,args);%#ok

    try
        [writableFile,scopedWritableFileCB]=getWritableFile(asciiInputFile,args);%#ok
        mlreportgen.utils.internal.tidyFile(writableFile,asciiOutputFile,asciiConfigFile);
    catch ex
        throwAsCaller(ex);
    end
    if(outputFile~=asciiOutputFile)
        copyfile(asciiOutputFile,outputFile);
    end
    out=outputFile;
end

function out=tidyString(args)
    configFile=getConfigFile(args);


    [asciiConfigFile,scopedConfigFileCB]=getASCIIProxyFile(configFile,args);%#ok

    try
        out=string(mlreportgen.utils.internal.tidyString(args.Input,asciiConfigFile));
    catch ex
        throwAsCaller(ex)
    end
end

function outputFile=getOutputFile(args,inputFile)
    if~isempty(args.OutputFile)
        outputFile=mlreportgen.utils.findFile(args.OutputFile,...
        "FileMustExist",false);
    else
        [fPath,fName,fExt]=fileparts(inputFile);
        outputFile=fullfile(fPath,fName+"-tidied"+fExt);
    end
end

function configFile=getConfigFile(args,varargin)
    if~isempty(args.ConfigFile)
        configFile=args.ConfigFile;
        if~isfile(configFile)
            configFile=fullfile(resourceDir(),args.ConfigFile);
        end

    else
        if~isempty(args.OutputType)
            outputType=args.OutputType;
        else
            outputType="xhtml";
            if~isempty(varargin)
                inputFile=varargin{1};
                [~,~,fExt]=fileparts(inputFile);
                if ismember(fExt,[".html",".htm"])
                    outputType="xhtml";
                else
                    outputType="xml";
                end
            end
        end

        switch outputType
        case "html"
            configFile=fullfile(resourceDir(),"tidy-html.cfg");
        case "xhtml"
            configFile=fullfile(resourceDir(),"tidy-xhtml.cfg");
        otherwise
            configFile=fullfile(resourceDir(),"tidy-xml.cfg");
        end
    end
end

function out=resourceDir()
    persistent RESOURCE_DIR

    if isempty(RESOURCE_DIR)
        RESOURCE_DIR=fullfile(toolboxdir("shared"),"mlreportgen/utils/resources");
    end
    out=RESOURCE_DIR;
end

function[proxyFile,scopedCB]=getASCIIProxyFile(file,args)

    if any(double(char(file))>255)
        proxyFile=tempname(args.WorkingFolder);
        if isfile(file)
            copyfile(file,proxyFile);
        end
        scopedCB=onCleanup(@()delete(proxyFile));
    else
        proxyFile=file;
        scopedCB=[];
    end
end

function[writableFile,scopedCB]=getWritableFile(file,args)
    fid=fopen(file,"r+");
    if(fid<0)
        writableFile=tempname(args.WorkingFolder);
        copyfile(file,writableFile);
        fileattrib(writableFile,"+w");
        scopedCB=onCleanup(@()delete(writableFile));
    else
        fclose(fid);
        writableFile=file;
        scopedCB=[];
    end
end

