classdef MetadataUIViewModel<handle



    properties(Access=private)
Metadata
Status
Directory
FilePath
ModelValidity
IconPath
    end

    events
UpdateModelEvent
RegistrationErrorEvent
RegistrationSuccessEvent
CleanUpAppEvent
    end

    methods(Access=public)

        function obj=MetadataUIViewModel(payload)


            import matlab.internal.task.metadata.Constants

            obj.ModelValidity=payload.ModelValidity;

            obj.FilePath=payload.FilePath;
            metadata=payload.Metadata;



            obj.Directory=payload.Directory;
            if strcmp(metadata.status,Constants.NotRegistered)
                metadata=obj.getDefaultMetadata(metadata);
            end

            obj.Status=metadata.status;
            metadata=rmfield(metadata,Constants.Status);

            obj.Metadata=metadata;
        end



        function metadata=getMetadata(obj)
            metadata=obj.Metadata;
        end

        function status=getStatus(obj)
            status=obj.Status;
        end

        function isValid=getModelValidity(obj)
            isValid=obj.ModelValidity;
        end

        function directory=getDirectory(obj)
            directory=obj.Directory;
        end

        function[shortenedFilePath,filePath]=getFilePath(obj)
            import matlab.internal.task.metadata.Constants
            filePath=obj.FilePath;

            if length(filePath)<=Constants.MaxFilePathLength
                shortenedFilePath=filePath;
            else
                [directory,filename,extension]=fileparts(obj.FilePath);
                completeFileName=strcat('...',filesep,filename,extension);
                maxFilePathLength=Constants.MaxFilePathLength;
                directoryPathLength=maxFilePathLength-length(completeFileName);
                if length(directory)>=directoryPathLength
                    directory=directory(1:directoryPathLength);
                end
                shortenedFilePath=[directory,completeFileName];
            end
        end



        function alignFigure(obj,figure)


            figure.Visible='off';
            movegui(figure,'center');
            drawnow;
            figure.Visible='on';
        end

        function registerTask(obj,metadata)



            import matlab.internal.task.metadata.Constants

            didError=obj.canTaskBeCreated(metadata);
            if didError
                return;
            end


            if strcmp(obj.Status,Constants.Registered)
                type=Constants.Update;
            elseif strcmp(obj.Status,Constants.NotRegistered)
                type=Constants.Register;
            end

            eventData=matlab.internal.task.metadata.event.UpdateModelEventData(type,metadata);
            notify(obj,Constants.UpdateModelEvent,eventData);
        end

        function handleRegistrationError(obj,me)



            import matlab.internal.task.metadata.Constants
            eventData=matlab.internal.task.metadata.event.RegistrationErrorEventData(me);
            notify(obj,Constants.RegistrationErrorEvent,eventData);
        end

        function handleRegistrationSuccess(obj)


            import matlab.internal.task.metadata.Constants
            notify(obj,Constants.RegistrationSuccessEvent);
        end

        function cleanUpApp(obj)



            import matlab.internal.task.metadata.Constants
            notify(obj,Constants.CleanUpAppEvent);
        end

        function isValid=validateName(obj,name)

            isValid=~isempty(name);
        end

        function updatedKeywords=validateAndUpdateKeywords(obj,value)


            value=string(value);

            keywords=value.split(",");
            if length(keywords)==1
                keywords=value.split(" ");
                if length(keywords)==1
                    updatedKeywords=value;
                    return;
                end
            end

            processedKeywords=strings(0);
            for i=1:length(keywords)
                if~strcmp(keywords(i),"")
                    processedKeywords(end+1)=keywords(i);
                end
            end
            for i=1:length(processedKeywords)
                processedKeywords(i)=strtrim(processedKeywords(i));
            end
            updatedKeywords=char(processedKeywords.join(","));
        end

        function imageSource=resizeIconImage(obj,iconPath)




            import matlab.internal.task.metadata.Constants

            obj.IconPath=iconPath;

            tmpDir=fullfile(tempdir,'MetadataUIIconUtil');
            [~,~,~]=mkdir(tmpDir);


            tmpFile=fullfile([tempname(tmpDir),'.','png']);


            [RGB,map,alpha]=imread(iconPath);


            if~isempty(map)
                RGB=ind2rgb(RGB,map);
            end

            RGB=imresize(RGB,Constants.TaskLibIconSize);



            if~isempty(alpha)
                alpha=imresize(alpha,Constants.TaskLibIconSize);
                imwrite(RGB,tmpFile,'Alpha',alpha);
            else
                imwrite(RGB,tmpFile);
            end

            imageSource=tmpFile;
        end

        function imageSource=copyIcon(obj)



            import matlab.internal.task.metadata.Constants

            imageSource='';

            if isempty(obj.IconPath)
                return;
            end

            taskFolder=fileparts(obj.FilePath);
            resourcesFolder=[taskFolder,filesep,'resources'];
            if~isfolder(resourcesFolder)
                mkdir(resourcesFolder);
            end

            [~,imageSource,imageExtention]=fileparts(obj.IconPath);
            imageSource=[imageSource,imageExtention];

            imageDestinationFullPath=[resourcesFolder,filesep,imageSource];
            if exist(imageDestinationFullPath,'file')~=2
                copyfile(obj.IconPath,resourcesFolder);
                im=imread(imageDestinationFullPath);
                imR=imresize(im,[24,24]);
                imwrite(imR,imageDestinationFullPath)
            end
        end
    end

    methods(Access=private)
        function metadata=getDefaultMetadata(obj,metadata)


            import matlab.internal.task.metadata.Constants



            previousDir=pwd;
            cd(obj.Directory);

            metadata.description=char(string(message('rich_text_component:liveApps:DefaultDescription',metadata.taskClassName)));


            cd(previousDir);

            dirPath=strjoin(Constants.UserTaskPackagePath,filesep);
            metadata.icon=fullfile(matlabroot,dirPath,Constants.DefaultTaskIcon);
            metadata.keywords='';
            metadata.uniqueId=metadata.taskClassName;
            metadata.docLink='';
        end

        function didError=canTaskBeCreated(obj,metadata)



            import matlab.internal.task.metadata.Constants

            previousDir=pwd;
            cd(obj.Directory);
            cleanupDir=onCleanup(@()cd(previousDir));
            me=[];
            didError=false;

            try
                tempFigure=uifigure('Visible',"off");
                task=feval(metadata.taskClassName,'Parent',tempFigure);
                task.delete();
            catch me
                if strcmp(me.identifier,'MATLAB:class:abstract')
                    me=MException(message([Constants.MessageCatalogPrefix,'AbstractTaskErrorMsg'],metadata.taskClassName));
                end
                delete(tempFigure);
            end

            if~isempty(me)
                obj.handleRegistrationError(me);
                didError=true;
            end
        end
    end
end
