function videoLabelerInternal(varargin)






    if isdeployed()
        appName=getString(message('vision:labeler:ToolTitleVL'));
        disabledForCompile=~vision.internal.labeler.checkEnabledforCompiling(appName);
        if disabledForCompile
            return;
        end
    end

    if nargin==0

        openApp;
    else

        firstArg=varargin{1};

        validateFirstInput(firstArg);

        if isGroundTruthDataSource(firstArg)

            isImageCollection=(firstArg.SourceType==...
            vision.internal.labeler.DataSourceType.ImageDatastore);
            if isImageCollection
                error(message('vision:labeler:noImageCollection'));
            else
                tool=openApp;
                tool.loadSource(firstArg);
            end

        elseif isGroundTruth(firstArg)

            validateGroundTruth(firstArg)
            tool=openApp;
            tool.importLabelAnnotations(firstArg);

        elseif ischar(firstArg)||isstring(firstArg)
            fileName=validateName(firstArg);


            if isSessionFile(fileName)

                parser=inputParser;
                parser.CaseSensitive=false;
                defaults=struct('LabelDefinitions',false);
                parser.addParameter('LabelDefinitions',...
                defaults.LabelDefinitions,@(x)validateLabelDefFlag(x));
                parser.parse(varargin{2:end});

                loadLabelDefinitions=parser.Results.LabelDefinitions;

                if loadLabelDefinitions
                    labelDefinitionFileName=fileName;

                    tool=openApp;
                    doLoadLabelDefinitionsFromFile(tool,labelDefinitionFileName);
                else

                    [sessionPath,sessionFileName]=loadSessionFile(fileName);

                    tool=openApp;
                    tool.doLoadSession(sessionPath,sessionFileName);
                end

            else

                processDataSourceInputs(varargin{:});
            end

        else
            assert(0,'Unexpected input type');
        end

    end
end


function processDataSourceInputs(varargin)

    fileName=validateName(varargin{1});

    if isImageDir(fileName)

        imds=loadImageSequence(fileName);
        numFiles=numel(imds.Files);
        timestamps=getTimestamps(numFiles,varargin{:});

        [pathname,~]=fileparts(imds.Files{1});
        gTSource=groundTruthDataSource(pathname,timestamps);

        tool=openApp;
        protectOnDelete(@(varargin)loadSource(tool,varargin{:}),gTSource);


    elseif isVideoFile(fileName)

        gTSource=groundTruthDataSource(fileName);
        tool=openApp;
        protectOnDelete(@(varargin)loadSource(tool,varargin{:}),gTSource);

        if(nargin>1)
            warning(message('vision:labeler:noTimestampsWithVideo'))
        end


    else
        error(message('vision:labeler:InvalidFile',fileName))
    end
end

function timestamps=getTimestamps(numFiles,varargin)
    numVarArgs=length(varargin);






    if(numVarArgs==2)
        timestamps=validateTimes(varargin{2});
    else
        timestamps=seconds(0:numFiles-1);
    end
end


function fileName=validateName(fileName)

    validateattributes(fileName,{'string','char'},{'scalartext','nonempty'});


    fileName=char(fileName);
end


function timestamps=validateTimes(timestamps)
    validateattributes(timestamps,{'double','duration'},...
    {'nonempty','vector'},mfilename,'Timestamps');

    if~isduration(timestamps)
        timestamps=seconds(timestamps);
    end

    if~iscolumn(timestamps)
        timestamps=reshape(timestamps,numel(timestamps),1);
    end

end


function validateGroundTruth(gTruth)
    validateattributes(gTruth,{'groundTruth'},{'scalar','nonempty'},...
    mfilename,'gTruth');


    if~hasValidDataSource(gTruth)
        error(message('vision:labeler:invalidDataSource','gTruth'));
    end


    if isImageCollection(gTruth.DataSource)||isImageDatastore(gTruth.DataSource)
        error(message(...
        'vision:labeler:UnableToLoadAnnotationsDlgMessageImageCollection',...
        'gTruth'));
    end

end


function tool=openApp()
    isVL=true;
    tool=vision.internal.videoLabeler.tool.VideoLabelingTool(isVL);
    tool.show();
end


function TF=isSessionFile(fileName)
    [~,~,ext]=fileparts(fileName);
    TF=strcmpi(ext,'.mat')||exist([fileName,'.mat'],'file');
end


function TF=isImageDir(fileName)
    TF=isfolder(fileName);
end


function TF=isGroundTruthDataSource(fileName)
    TF=isa(fileName,'groundTruthDataSource');
end


function TF=isGroundTruth(fileName)
    TF=isa(fileName,'groundTruth');
end


function TF=isVideoFile(fileName)
    TF=exist(fileName,'file')==2;
end


function[sessionPath,sessionFileName]=loadSessionFile(fileName)
    try
        [sessionPath,sessionFileName]=vision.internal.calibration.tool.parseSessionFileName(fileName);
    catch ME
        error(message('vision:labeler:FileNotFound',fileName));
    end
end


function imds=loadImageSequence(fileName)
    try
        imds=imageDatastore(fileName);
    catch
        error(message('vision:groundTruthDataSource:InvalidFolderContent'))
    end
end


function validateFirstInput(firstArg)


    validateattributes(firstArg,...
    {'char','string','groundTruth','groundTruthDataSource'},...
    {'nonempty'},mfilename);



end


function validateLabelDefFlag(flag)
    validateattributes(flag,{'logical'},{'scalar'});
end


function varargout=protectOnDelete(fHandle,varargin)





    try
        [varargout{1:nargout}]=fHandle(varargin{:});
    catch ME


        if isDebugMode()||~strcmp(ME.identifier,'MATLAB:class:InvalidHandle')
            rethrow(ME)
        end
    end
end


function tf=isDebugMode()
    tf=strcmpi(vision.internal.videoLabeler.gtlfeature('debug'),'on');
end