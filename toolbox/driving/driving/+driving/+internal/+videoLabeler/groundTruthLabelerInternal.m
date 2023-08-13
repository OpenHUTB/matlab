function groundTruthLabelerInternal(varargin)

    if isdeployed()
        appName=getString(message('vision:labeler:ToolTitleVL'));
        disabledForCompile=~vision.internal.labeler.checkEnabledforCompiling(appName);
        if disabledForCompile
            return;
        end
    end


    [hasCustomDisplay,connectorTargetHandle]=parseCustomDisplay(varargin{:});

    if nargin==0||(nargin==2&&hasCustomDisplay)

        tool=openApp;
        addCustomDisplayIfAny(tool,connectorTargetHandle);
    else

        firstArg=varargin{1};

        if isGroundTruthDataSource(firstArg)

            isImageCollection=(firstArg.SourceType==...
            vision.internal.labeler.DataSourceType.ImageDatastore);
            if isImageCollection
                error(message('vision:labeler:noImageCollection'));
            else
                tool=openApp;
                addCustomDisplayIfAny(tool,connectorTargetHandle);
                protectOnDelete(@(varargin)loadSource(tool,varargin{:}),firstArg);
            end

        else



            validateFirstInput(firstArg);

            if ischar(firstArg)||isstring(firstArg)
                fileName=validateName(firstArg);


                if isSessionFile(fileName)

                    parser=inputParser;
                    parser.CaseSensitive=false;
                    defaults=struct('LabelDefinitions',false,...
                    'ConnectorTargetHandle',connectorTargetHandle);
                    parser.addParameter('LabelDefinitions',...
                    defaults.LabelDefinitions,@(x)validateLabelDefFlag(x));
                    parser.addParameter('ConnectorTargetHandle',...
                    defaults.ConnectorTargetHandle);
                    parser.parse(varargin{2:end});

                    loadLabelDefinitions=parser.Results.LabelDefinitions;

                    if loadLabelDefinitions
                        labelDefinitionFileName=fileName;

                        tool=openApp;
                        protectOnDelete(@(varargin)doLoadLabelDefinitionsFromFile(tool,varargin{:}),labelDefinitionFileName);
                    else
                        [sessionPath,sessionFileName]=loadSessionFile(fileName);

                        tool=openApp;
                        protectOnDelete(@(varargin)doLoadSession(tool,varargin{:}),...
                        sessionPath,sessionFileName,hasCustomDisplay,connectorTargetHandle);
                    end
                else
                    processDataSourceInputs(connectorTargetHandle,varargin{:});
                end

            elseif isGroundTruth(firstArg)||isGroundTruthMultisignal(firstArg)

                validateGroundTruth(firstArg);
                tool=openApp;
                protectOnDelete(@(varargin)importLabelAnnotations(tool,varargin{:}),firstArg);
            end
        end

    end
end


function processDataSourceInputs(connectorTargetHandle,varargin)

    fileName=validateName(varargin{1});

    if isCustomDataSource(varargin{:})
        readerFunction=varargin{2};
        timestamps=validateTimes(varargin{3});

        customImageSource=vision.labeler.loading.CustomImageSource();
        sourceParams.FunctionHandle=readerFunction;
        customImageSource.loadSource(fileName,sourceParams);
        customImageSource.setTimestamps(timestamps);
        tool=openApp;
        addCustomDisplayIfAny(tool,connectorTargetHandle);
        protectOnDelete(@(varargin)loadSource(tool,varargin{:}),customImageSource);


    elseif isImageDir(fileName)

        imds=loadImageSequence(fileName);
        numFiles=numel(imds.Files);
        timestamps=getTimestamps(connectorTargetHandle,numFiles,varargin{:});

        [pathname,~]=fileparts(imds.Files{1});

        imageSeqSource=vision.labeler.loading.ImageSequenceSource();
        imageSeqSource.loadSource(pathname,[]);
        imageSeqSource.setTimestamps(timestamps);

        tool=openApp;
        addCustomDisplayIfAny(tool,connectorTargetHandle);
        protectOnDelete(@(varargin)loadSource(tool,varargin{:}),imageSeqSource);


    elseif isVideoFile(fileName)

        videoSource=vision.labeler.loading.VideoSource();
        videoSource.loadSource(fileName,[]);
        tool=openApp;
        addCustomDisplayIfAny(tool,connectorTargetHandle);
        protectOnDelete(@(varargin)loadSource(tool,varargin{:}),videoSource);

        hasCustomDisp=~isempty(connectorTargetHandle);
        if(~hasCustomDisp&&nargin>2)||(hasCustomDisp&&nargin>4)
            warning(message('vision:labeler:noTimestampsWithVideo'))
        end


    else
        error(message('vision:labeler:InvalidFile',fileName))
    end
end

function timestamps=getTimestamps(connectorTargetHandle,numFiles,varargin)
    hasCustomDisplay=~isempty(connectorTargetHandle);
    numVarArgs=length(varargin);













    if(hasCustomDisplay&&(numVarArgs==4))||...
        (~hasCustomDisplay&&(numVarArgs==2))
        timestamps=validateTimes(varargin{2});
    else
        timestamps=seconds(0:numFiles-1);
    end
end

function[hasCustomDisplay,connectorTargetHandle]=parseCustomDisplay(varargin)

    connectorTargetHandle=[];
    hasCustomDisplay=false;
    if nargin>=2
        isValidFcnHandle=isa(varargin{end},'function_handle');
        isValidName=strcmpi(varargin{end-1},'ConnectorTargetHandle');

        if isValidName&&isValidFcnHandle
            connectorTargetHandle=varargin{end};
            validateConnectorClassHandle(connectorTargetHandle);
            hasCustomDisplay=true;
        elseif isValidName&&~isValidFcnHandle
            error(message('vision:labeler:NotAFunctionHandle'));
        elseif~isValidName&&isValidFcnHandle
            error(message('vision:labeler:InvalidName'));
        end
    end
end


function validateConnectorClassHandle(fcnHandle)

    if~isa(fcnHandle,'function_handle')
        error(message('vision:labeler:NotAFunctionHandle'));
    end

    fStruct=functions(fcnHandle);

    if strcmpi(fStruct.type,'anonymous')
        return;
    end

    funcName=fStruct.function;
    isvalid=exist(funcName,'class')==8;
    if~isvalid
        error(message('vision:labeler:connectorNotOnPath',funcName))
    end

    validateMetaClass(funcName);
end

function validateMetaClass(funcName)



    metaClass=meta.class.fromName(funcName);
    if isempty(metaClass)
        error(message('vision:labeler:unknownConnectorClassObject',funcName));


    else
        baseClassList=metaClass.SuperclassList;
        isvalid=false;
        if~isempty(baseClassList)
            isvalid=any(strcmp({baseClassList.Name},'driving.connector.Connector'));
        end

        if~isvalid
            error(message('vision:labeler:baseClassNotConnector',funcName));
        end
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


function tf=isGroundTruth(x)
    tf=isa(x,'groundTruth');
end


function tf=isGroundTruthMultisignal(x)
    tf=isa(x,'groundTruthMultisignal');
end


function addCustomDisplayIfAny(tool,connectorTargetHandle)
    if~isempty(connectorTargetHandle)
        tool.addCustomDisplay(connectorTargetHandle);
    end
end


function tool=openApp()
    isVL=false;
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


function TF=isVideoFile(fileName)
    TF=exist(fileName,'file')==2;
end


function TF=isCustomDataSource(varargin)
    TF=nargin>1&&isa(varargin{2},'function_handle');
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


function validateGroundTruth(gTruth)
    validateattributes(gTruth,{'groundTruth','groundTruthMultisignal'},...
    {'scalar','nonempty'},mfilename,'gTruth');


    if~hasValidDataSource(gTruth)
        error(message('vision:labeler:invalidDataSource','gTruth'));
    end

    if isa(gTruth,'groundTruth')

        if isImageCollection(gTruth.DataSource)||isImageDatastore(gTruth.DataSource)
            error(message(...
            'vision:labeler:UnableToLoadAnnotationsDlgMessageImageCollection',...
            'gTruth'));
        end
    end

end


function validateFirstInput(firstArg)


    validateattributes(firstArg,...
    {'char','string','groundTruth','groundTruthMultisignal'},...
    {'nonempty'},1);



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