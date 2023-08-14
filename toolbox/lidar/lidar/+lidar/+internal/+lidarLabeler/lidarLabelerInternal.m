function lidarLabelerInternal(varargin)




    if isdeployed()
        appName=getString(message('lidar:labeler:ToolTitleLL'));
        disabledForCompile=~vision.internal.labeler.checkEnabledforCompiling(appName);
        if disabledForCompile
            return;
        end
    end

    [hasCustomDisplay,SyncImageViewerTargetHandle]=parseCustomDisplay(varargin{:});

    if nargin==0||(nargin==2&&hasCustomDisplay)

        tool=openApp;
        addCustomDisplayIfAny(tool,SyncImageViewerTargetHandle);
    else


        firstArg=varargin{1};
        validateFirstInput(firstArg);

        if ischar(firstArg)||isstring(firstArg)
            fileName=validateName(firstArg);

...
...
...
...
...
...

            if isSessionFile(fileName)

                parser=inputParser;
                parser.CaseSensitive=false;
                defaults=struct('LabelDefinitions',false,...
                'SyncImageViewerTargetHandle',SyncImageViewerTargetHandle);
                parser.addParameter('LabelDefinitions',...
                defaults.LabelDefinitions,@(x)validateLabelDefFlag(x));
                parser.addParameter('SyncImageViewerTargetHandle',...
                defaults.SyncImageViewerTargetHandle);
                parser.parse(varargin{2:end});

                loadLabelDefinitions=parser.Results.LabelDefinitions;

                if loadLabelDefinitions
                    labelDefinitionFileName=fileName;

                    tool=openApp;
                    doLoadLabelDefinitionsFromFile(tool,labelDefinitionFileName);
                else

                    [sessionPath,sessionFileName]=loadSessionFile(fileName);

                    tool=openApp;
                    tool.doLoadSession(sessionPath,sessionFileName,...
                    hasCustomDisplay,SyncImageViewerTargetHandle);
                end

                return;
            end

        elseif isa(firstArg,'groundTruthLidar')

            validateGroundTruthLidar(firstArg);
            tool=openApp;
            tool.importLabelAnnotations(firstArg);
            return;
        end



        processDataSourceInputs(SyncImageViewerTargetHandle,varargin{:});
    end
end

function processDataSourceInputs(SyncImageViewerTargetHandle,varargin)

    fileName=validateName(varargin{1});
    if isVelodyneLidarFile(fileName)&&nargin>3
        sourceParams.DeviceModel=varargin{2};
        sourceParams.CalibrationFile=varargin{3};
    end

    if isCustomDataSource(varargin{:})
        readerFunction=varargin{2};
        timestamps=validateTimes(varargin{3});

        customPointCloudSource=lidar.labeler.loading.CustomPointCloudSource();
        sourceParams.FunctionHandle=readerFunction;
        sourceParams.Timestamps=timestamps;
        customPointCloudSource.loadSource(fileName,sourceParams);
        customPointCloudSource.setTimestamps(timestamps);
        tool=openApp;
        addCustomDisplayIfAny(tool,SyncImageViewerTargetHandle);
        tool.loadSource(customPointCloudSource);


    elseif isPointCloudDir(fileName)

        ext={'.pcd','.ply'};
        lds=fileDatastore(fileName,'ReadFcn',@pcread,'FileExtensions',ext);
        numFiles=numel(lds.Files);
        timestamps=getTimestamps(SyncImageViewerTargetHandle,numFiles,varargin{:});

        [pathname,~]=fileparts(lds.Files{1});

        lasFileSeqSource=vision.labeler.loading.PointCloudSequenceSource();
        lasFileSeqSource.loadSource(pathname,[]);
        lasFileSeqSource.setTimestamps(timestamps);

        tool=openApp;
        addCustomDisplayIfAny(tool,SyncImageViewerTargetHandle);
        tool.loadSource(lasFileSeqSource);


    elseif isVelodyneLidarFile(fileName)

        if nargin>2
            velodyneSource=vision.labeler.loading.VelodyneLidarSource();
            velodyneSource.loadSource(fileName,sourceParams);
            tool=openApp;
            addCustomDisplayIfAny(tool,SyncImageViewerTargetHandle);
            tool.loadSource(velodyneSource);
        else
            error(message('lidar:labeler:VelodyneLidarLoadError'))
        end


    elseif isLASLAZFile(fileName)

        ext={'.las','.laz'};
        lds=fileDatastore(fileName,'ReadFcn',@lasFileReader,'FileExtensions',ext);
        numFiles=numel(lds.Files);
        timestamps=getTimestamps(SyncImageViewerTargetHandle,numFiles,varargin{:});

        [pathname,~]=fileparts(lds.Files{1});

        lasFileSeqSource=lidar.labeler.loading.LasFileSequenceSource();
        lasFileSeqSource.loadSource(pathname,[]);
        lasFileSeqSource.setTimestamps(timestamps);

        tool=openApp;
        addCustomDisplayIfAny(tool,SyncImageViewerTargetHandle);
        tool.loadSource(lasFileSeqSource);


    else
        error(message('vision:labeler:InvalidFile',fileName))
    end
end

function timestamps=getTimestamps(SyncImageViewerTargetHandle,numFiles,varargin)
    hasCustomDisplay=~isempty(SyncImageViewerTargetHandle);
    numVarArgs=length(varargin);













    if(hasCustomDisplay&&(numVarArgs==4))||...
        (~hasCustomDisplay&&(numVarArgs==2))
        timestamps=validateTimes(varargin{2});
    else
        timestamps=seconds(0:numFiles-1);
    end
end

function[hasCustomDisplay,SyncImageViewerTargetHandle]=parseCustomDisplay(varargin)

    SyncImageViewerTargetHandle=[];
    hasCustomDisplay=false;
    if nargin>=2
        isValidFcnHandle=isa(varargin{end},'function_handle');
        isValidName=strcmpi(varargin{end-1},'SyncImageViewerTargetHandle');

        if isValidName&&isValidFcnHandle
            SyncImageViewerTargetHandle=varargin{end};
            validateSyncImageViewerClassHandle(SyncImageViewerTargetHandle);
            hasCustomDisplay=true;
        elseif isValidName&&~isValidFcnHandle
            error(message('lidar:labeler:NotAFunctionHandle'));
        elseif~isValidName&&isValidFcnHandle
            error(message('lidar:labeler:InvalidName'));
        end
    end
end


function validateSyncImageViewerClassHandle(fcnHandle)

    if~isa(fcnHandle,'function_handle')
        error(message('lidar:labeler:NotAFunctionHandle'));
    end

    fStruct=functions(fcnHandle);

    if strcmpi(fStruct.type,'anonymous')
        return;
    end

    funcName=fStruct.function;
    isvalid=exist(funcName,'class')==8;
    if~isvalid
        error(message('lidar:labeler:syncImageViewerNotOnPath',funcName))
    end

    validateMetaClass(funcName);
end

function validateMetaClass(funcName)



    metaClass=meta.class.fromName(funcName);
    if isempty(metaClass)
        error(message('lidar:labeler:unknownSyncImageViewerClassObject',funcName));


    else
        baseClassList=metaClass.SuperclassList;
        isvalid=false;
        if~isempty(baseClassList)
            isvalid=any(strcmp({baseClassList.Name},'lidar.syncImageViewer.SyncImageViewer'));
        end

        if~isvalid
            error(message('lidar:labeler:baseClassNotSyncImageViewer',funcName));
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

function addCustomDisplayIfAny(tool,SyncImageViewerTargetHandle)
    if~isempty(SyncImageViewerTargetHandle)
        tool.addCustomDisplay(SyncImageViewerTargetHandle);
    end
end


function validateGroundTruthLidar(gTruth)
    validateattributes(gTruth,{'groundTruthLidar'},{'scalar','nonempty'},...
    mfilename,'gTruth');


    if~hasValidDataSource(gTruth)
        error(message('vision:labeler:invalidDataSource','gTruth'));
    end

end


function tool=openApp()
    isLL=true;
    tool=lidar.internal.lidarLabeler.tool.LidarLabelingTool(isLL);
    tool.show();
end


function closeAllApps()
    isLL=true;
    lidar.internal.lidarLabeler.tool.LidarLabelingTool.deleteAllTools(isLL);
end

function TF=isSessionFile(fileName)
    [~,~,ext]=fileparts(fileName);
    TF=strcmpi(ext,'.mat')||exist([fileName,'.mat'],'file');
end


function TF=isPointCloudDir(fileName)
    folderName=dir(fileName);
    if~isempty(folderName)
        if numel(folderName)>1
            ext={'.pcd','.ply'};
            for i=3:numel(folderName)
                TF=contains(folderName(i).name,ext);
            end
        else
            TF=false;
        end
    else
        TF=false;
    end
end

function TF=isLASLAZFile(fileName)
    folderName=dir(fileName);
    if~isempty(folderName)
        if numel(folderName)>1
            ext={'.las','.laz'};
            for i=3:numel(folderName)
                TF=contains(folderName(i).name,ext);
            end
        else
            TF=false;
        end
    else
        TF=false;
    end
end


function TF=isVelodyneLidarFile(fileName)
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


function validateFirstInput(firstArg)


    validateattributes(firstArg,...
    {'char','string','groundTruthLidar'},...
    {'nonempty'},1);



end


function validateLabelDefFlag(flag)
    validateattributes(flag,{'logical'},{'scalar'});
end