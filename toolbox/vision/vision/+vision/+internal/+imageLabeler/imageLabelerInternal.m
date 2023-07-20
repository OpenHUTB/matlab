function imageLabelerInternal(imageData,importAsBlockedImage,loadLabelDefinitions)






    if isdeployed()
        appName=getString(message('vision:labeler:ToolTitleIL'));
        disabledForCompile=~vision.internal.labeler.checkEnabledforCompiling(appName);
        if disabledForCompile
            return;
        end
    end

    if nargin>=1
        validateInput(imageData)
    else
        imageData=[];
    end




    shouldLoadDefinitions=false;
    if nargin==3

        parser=inputParser;
        parser.CaseSensitive=false;
        defaults=struct('LabelDefinitions',false);
        parser.addParameter('LabelDefinitions',...
        defaults.LabelDefinitions,@(x)validateLabelDefFlag(x));
        parser.parse(importAsBlockedImage,loadLabelDefinitions);

        shouldLoadDefinitions=parser.Results.LabelDefinitions;

    end

    if nargin==2
        mustBeNonsparse(importAsBlockedImage);
    else
        importAsBlockedImage=false;
    end

    if~isempty(imageData)
        imageData=convertStringsToChars(imageData);
    end

    shouldAddDatastore=false;
    shouldAddImages=false;
    shouldAddBlockedImagesFromWksp=false;
    issueWarning=false;
    shouldOpenSession=false;
    shouldImportGroundTruth=false;


    if nargin==0
        tool=vision.internal.imageLabeler.tool.ImageLabelerTool();
        tool.show();
        return

    elseif isa(imageData,'matlab.io.datastore.ImageDatastore')
        narginchk(1,1);
        issueWarning=false;
        shouldAddDatastore=true;
        ds=imageData;

    elseif isa(imageData,'blockedImage')

        narginchk(1,1);
        issueWarning=false;
        shouldAddBlockedImagesFromWksp=true;
        blockedImages=imageData;

    elseif isa(imageData,'groundTruth')
        narginchk(1,1);
        validateGroundTruth(imageData);
        shouldImportGroundTruth=true;

    else

        validateattributes(imageData,{'char'},{'vector'},mfilename,'input name');

        if exist(imageData,'dir')


            narginchk(1,2);


            folder=imageData;
            folder=vision.internal.getFullPath(folder);
            fileNames=parseFolder(folder);
            if(isempty(fileNames))

                issueWarning=true;
            else
                shouldAddImages=true;
            end

        elseif exist(imageData,'file')||exist([imageData,'.mat'],'file')
            if~shouldLoadDefinitions
                if nargin~=3
                    narginchk(1,1);
                end

                sessionFileName=imageData;
                import vision.internal.calibration.tool.*;
                try
                    [sessionPath,sessionFileName]=parseSessionFileName(sessionFileName);
                    shouldOpenSession=true;
                catch ME
                    throwAsCaller(ME);
                end
            else
                narginchk(1,3);
                labelDefinitionFileName=imageData;
            end
        else
            error(message('vision:imageLabeler:InvalidInput',imageData));
        end
    end

    tool=vision.internal.imageLabeler.tool.ImageLabelerTool();
    tool.show();

    if shouldAddImages
        protectOnDelete(@(varargin)doLoadImageAs(tool,varargin{:}),fileNames,importAsBlockedImage);

    elseif shouldAddBlockedImagesFromWksp
        tool.doLoadBlockedImagesFromWksp(blockedImages);

    elseif shouldAddDatastore
        protectOnDelete(@(varargin)doLoadDatastore(tool,varargin{:}),ds);

    elseif issueWarning
        warndlg(...
        getString(message('vision:imageLabeler:NoImagesFoundMessage',folder)),...
        getString(message('vision:uitools:NoImagesAddedTitle')),'modal');

    elseif shouldOpenSession
        protectOnDelete(@(varargin)doLoadSession(tool,varargin{:}),sessionPath,sessionFileName);

    elseif shouldImportGroundTruth
        validateGroundTruth(imageData);
        tool.importLabelAnnotations(imageData);

    elseif shouldLoadDefinitions
        doLoadLabelDefinitionsFromFile(tool,labelDefinitionFileName);
    end
    makeSureToolbarVisible(tool);

end


function validateGroundTruth(gTruth)
    validateattributes(gTruth,{'groundTruth'},{'scalar','nonempty'},...
    mfilename,'gTruth');


    if~hasValidDataSource(gTruth)
        error(message('vision:labeler:invalidDataSource','gTruth'));
    end


    if~(isImageCollection(gTruth.DataSource)||isImageDatastore(gTruth.DataSource))
        error(message('vision:imageLabeler:ImportLabelsInvalidGroundTruthSrc'));
    end

end


function imageFilenames=parseFolder(fileFolder)


    formats=imformats();
    ext=[formats(:).ext];


    contents=dir(fileFolder);
    imageFilenames=contents(~[contents(:).isdir]);
    imageFilenames={imageFilenames(:).name};
    exp=sprintf('(.*\\.%s$)|',ext{:});


    idx=cellfun(@(x)~isempty(x),regexpi(imageFilenames,exp,'once'));
    imageFilenames=fullfile(fileFolder,imageFilenames(idx));
end



function validateInput(in)



    if isa(in,'blockedImage')


    else


        validateattributes(in,...
        {'char','string','groundTruth','matlab.io.datastore.ImageDatastore'},...
        {'nonempty'},'imageLabeler');
    end


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