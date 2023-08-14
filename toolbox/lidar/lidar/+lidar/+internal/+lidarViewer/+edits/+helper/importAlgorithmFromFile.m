







function[isSuccess,editObj]=importAlgorithmFromFile(algorithmList,obj,fig,isTemporal)

    editObj=[];

    selectFileTitle=vision.getMessage('vision:uitools:SelectFileTitle');
    [fileName,pathName,filterIndex]=uigetfile('*.m',selectFileTitle);

    lidar.internal.lidarViewer.createAndNotifyExtTrigger(obj,'bringToFront');

    userCanceled=(filterIndex==0);
    if userCanceled
        isSuccess=false;
        return;
    end

    packageStrings=regexp(pathName,'+\w+','match');

    if~isempty(packageStrings)
        index=regexp(pathName,'+\w+');
        removeStr=pathName(index(1):end);
        pathName=strrep(pathName,removeStr,'');
    else

        index=regexp(pathName,'@\w+');
        if~isempty(index)
            removeStr=pathName(index(1):end);
            pathName=strrep(pathName,removeStr,'');
        end
    end

    for i=1:numel(packageStrings)
        packageStrings{i}=strrep(packageStrings{i},'+','');
    end

    fileString=strsplit(fileName,'.');
    clasStrings=[packageStrings,fileString{1}];
    className=strjoin(clasStrings,'.');

    try
        metaClass=meta.class.fromName(className);
    catch
        lidar.internal.lidarViewer.createAndNotifyExtTrigger(...
        obj,'warningDialog',getString(message('lidar:lidarViewer:InValidEditAlgoClass')),...
        getString(message('lidar:lidarViewer:Warning')));
        isSuccess=false;
        return;
    end

    if isempty(metaClass)

        cancelButton=vision.getMessage('vision:uitools:Cancel');
        addToPathButton=vision.getMessage('vision:labeler:addToPath');
        cdButton=vision.getMessage('vision:labeler:cdFolder');

        msg=vision.getMessage(...
        'vision:labeler:notOnPathQuestionAlgImport',className,pathName);

        buttonName=uiconfirm(fig,msg,getString(message('vision:labeler:notOnPathTitle')),...
        'Options',{cdButton,addToPathButton,cancelButton});

        switch buttonName
        case cdButton
            cd(pathName);
        case addToPathButton
            addpath(pathName);
        otherwise
            isSuccess=false;
            return;
        end
        metaClass=meta.class.fromName(className);
    end

    if~isTemporal
        try
            isValid=~isempty(metaClass)&&strcmp(metaClass.SuperclassList.Name,...
            'lidar.internal.lidarViewer.edits.EditAlgorithm');
        catch


            isValid=false;
        end
    else
        try
            superClasses={metaClass.SuperclassList.Name};
            isValid=~isempty(metaClass)&&all(contains({'lidar.internal.lidarViewer.edits.Temporal',...
            'lidar.internal.lidarViewer.edits.EditAlgorithm'},superClasses));
        catch


            isValid=false;
        end
    end

    if~isValid
        if~isTemporal
            warnMsg=getString(message('lidar:lidarViewer:InValidSpatialEditAlgoClass'));
        else
            warnMsg=getString(message('lidar:lidarViewer:InValidTemporalEditAlgoClass'));
        end
        lidar.internal.lidarViewer.createAndNotifyExtTrigger(...
        obj,'warningDialog',warnMsg,...
        getString(message('lidar:lidarViewer:Warning')));
        isSuccess=false;
        return;
    end


    editObj=eval(className);
    algoName=editObj.EditName;


    if~any(ismember(algorithmList,algoName))







        if strcmp(strjoin(packageStrings,'.'),'lidar.lidarViewer')
            isSuccess=true;
        else
            isSuccess=false;
            editObj=[];
        end
    else
        lidar.internal.lidarViewer.createAndNotifyExtTrigger(...
        obj,'warningDialog',getString(message('lidar:lidarViewer:DuplicateEditWarning')),...
        getString(message('lidar:lidarViewer:Warning')));
        editObj=[];
        isSuccess=false;
        return;
    end
end


