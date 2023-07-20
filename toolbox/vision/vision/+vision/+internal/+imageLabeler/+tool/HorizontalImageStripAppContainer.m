


classdef HorizontalImageStripAppContainer<images.internal.app.utilities.thumbnail.Thumbnails

    properties(SetAccess=protected)
        NumberOfThumbnails=0;
        ImageFilename={};
        Datastore=[];
        maxTextChars=15;

        BlockedImageObjects=blockedImage.empty()
        IsDataBlockedImage(1,1)logical=false;

        OverviewBlockedImageSize(1,2)=[1024,1024];
OverviewDir
    end

    events
ImageRemovedInBrowser
ImageRotateInBrowser

GeneratingOverviewImage
OverviewBlockedImageGenerated
    end

    methods
        function this=HorizontalImageStripAppContainer(hParent,IsDataBlockedImage)

            thumbNailSize=[72,72];
            this@images.internal.app.utilities.thumbnail.Thumbnails(hParent,thumbNailSize);
            this.IsDataBlockedImage=IsDataBlockedImage;

            this.Layout='row';

            this.EnableMultiSelect=true;

            this.BlockSize=[96,96];


            this.ImageFilename={};
            this.Datastore=[];
            this.NumberOfThumbnails=0;

            this.refreshThumbnails();



            this.hAxes.Color=[0.94,0.94,0.94];


            fig=ancestor(hParent,'Figure');
            zoomObj=zoom(fig);
            setAllowAxesZoom(zoomObj,this.hAxes,false);
            panObj=pan(fig);
            setAllowAxesPan(panObj,this.hAxes,false);
        end


        function loadImages(this,imageData)




            this.hAxes.Color=[1,1,1];

            if this.IsDataBlockedImage

                if isa(imageData(1),'blockedImage')
                    imageFilenames=cell(numel(imageData),1);
                    for idx=1:numel(imageData)
                        imageFilenames{idx}=char(imageData(idx).Source);
                        this.BlockedImageObjects(idx)=imageData(idx);
                    end
                    this.ImageFilename=imageFilenames;

                else
                    appendData=false;
                    this.ImageFilename=imageData;
                    this.createAndCacheBlockedImages(this.ImageFilename,appendData)
                end

            else
                if isa(imageData,'matlab.io.datastore.ImageDatastore')
                    this.Datastore=copy(imageData);
                    this.ImageFilename=imageData.Files;
                else
                    this.ImageFilename=imageData;
                end
            end

            this.NumberOfThumbnails=numel(this.ImageFilename);
            this.refreshThumbnails();
        end


        function appendImage(this,imageData)




            this.hAxes.Color=[1,1,1];

            if this.IsDataBlockedImage
                if isa(imageData(1),'blockedImage')
                    imageFilenames=cell(numel(imageData),1);
                    for idx=1:numel(imageData)
                        imageFilenames{idx}=char(imageData(idx).Source);
                        this.BlockedImageObjects(end+1)=imageData(idx);
                    end
                else
                    imageFilenames=imageData.Filenames;
                    this.createAndCacheBlockedImages(imageFilenames)
                end
            else

                if isa(imageData,'matlab.io.datastore.ImageDatastore')
                    this.Datastore=copy(imageData);
                    imageFilenames=imageData.Files;
                else

                    if~isempty(this.Datastore)
                        this.Datastore.Files=[this.Datastore.Files;imageData.Filenames];
                    end
                    imageFilenames=imageData.Filenames;
                end

            end

            this.ImageFilename=cat(1,this.ImageFilename,imageFilenames);
            this.NumberOfThumbnails=numel(this.ImageFilename);
            this.appendSpaceForNImages(numel(imageFilenames));


            this.updateGridLayout();
        end


        function selectImageByIndex(this,idx)
            this.setSelection(idx);
        end


        function name=imageFilenameByIndex(this,idx)
            assert(idx>0&&idx<=numel(this.ImageFilename));
            name=this.ImageFilename{idx};
        end


        function n=numberOfVisibleImages(this)
            n=numel(this.ImageFilename);
        end


        function filterSelectedImages(this)

            currentSelection=this.CurrentSelection;


            currentSelection=sort(currentSelection);
            filter(this,currentSelection);
        end


        function restoreAllImages(this)

            numImages=length(this.ImageFilename);
            filter(this,1:numImages);
        end


        function setTempOverviewDirectory(this,overviewDir)
            this.OverviewDir=overviewDir;
        end
    end


    methods
        function updateBlockWithPlaceholder(this,topLeftyx,imageNum)

            if~(this.ImageNumToDataInd(imageNum))

                userdata=[];
                userdata.isPlaceholder=true;
                thumbnail=this.PlaceHolderImage;

                hImage=image(...
                'Parent',this.hAxes,...
                'Tag','Placeholder',...
                'HitTest','off',...
                'CDataMapping','scaled',...
                'UserData',userdata,...
                'Cdata',thumbnail);
                this.hImageData(end+1).hImage=hImage;
                this.ImageNumToDataInd(imageNum)=numel(this.hImageData);

            end
            this.repositionElements(imageNum,topLeftyx);
        end

        function updateBlockWithActual(this,topLeftyx,imageNum)

            hImageInd=this.ImageNumToDataInd(imageNum);

            hImage=this.hImageData(hImageInd).hImage;

            if~strcmp(hImage.Tag,'Realthumbnail')

                [thumbnail,userdata]=this.createThumbnail(imageNum);

                hImage.CData=thumbnail;
                hImage.Tag='Realthumbnail';
                userdata.isPlaceholder=false;
                hImage.UserData=userdata;
            end

            this.repositionElements(imageNum,topLeftyx);
        end

    end

    methods

        function[thumbnail,userdata]=createThumbnail(this,imageNum)

            try
                if this.IsDataBlockedImage






                    resizedBimDir=fullfile(this.OverviewDir,sprintf('OverviewImage_%d',imageNum));

                    if exist(resizedBimDir,'dir')
                        resizedBim=blockedImage(resizedBimDir);
                    else

                        bim=this.BlockedImageObjects(imageNum);

                        [~,name,ext]=fileparts(char(bim.Source));
                        evtData=vision.internal.imageLabeler.events.GeneratingOverviewEventData([name,ext],bim.Size(1,[1,2]));
                        this.notify('GeneratingOverviewImage',evtData)

                        resizedBim=vision.internal.imageLabeler.tool.blockedImage.resize(bim,this.OverviewBlockedImageSize);

                        evtData=vision.internal.imageLabeler.events.OverviewBlockedImageEventData(resizedBim,imageNum);
                        this.notify('OverviewBlockedImageGenerated',evtData);

                    end

                    fullImage=resizedBim.gather();

                else
                    if~isempty(this.Datastore)

                        fullImage=read(subset(this.Datastore,imageNum));
                        vision.internal.inputValidation.validateImage(fullImage);
                    else
                        filename=this.ImageFilename{imageNum};
                        fullImage=vision.internal.readLabelerImages(filename);
                    end

                    fullImage=vision.internal.labeler.normalizeImageData(fullImage);
                end


                thumbnail=this.resizeToThumbnail(fullImage);

            catch ALL %#ok<NASGU>
                fullImage=this.CorruptedImagePlaceHolder;
                fullImage=vision.internal.labeler.normalizeImageData(fullImage);
                thumbnail=this.resizeToThumbnail(fullImage);
            end



            userdata=[];
        end

        function repositionElements(this,imageNum,topLeftyx)
            hDataInd=this.ImageNumToDataInd(imageNum);
            hImage=this.hImageData(hDataInd).hImage;

















            hImage.YData=topLeftyx(1)+(this.BlockSize(1)-size(hImage.CData,1))/2;
            hImage.XData=topLeftyx(2)+(this.BlockSize(2)-size(hImage.CData,2))/2;

            hImage.Visible='on';

        end

        function desc=getFileName(this,imageNum)
            desc=this.ImageFilename{imageNum};
        end

        function removeSelectedImages(this)
            displayMessage=vision.getMessage('vision:imageLabeler:RemoveImageWarning');
            dialogName=vision.getMessage('vision:imageLabeler:RemoveImage');

            yesOption=vision.getMessage('MATLAB:uistring:popupdialogs:Yes');
            noOption=vision.getMessage('MATLAB:uistring:popupdialogs:No');
            hFig=ancestor(this.hParent,'Figure');

            selection=vision.internal.labeler.handleAlert(hFig,'question',displayMessage,dialogName,...
            yesOption,noOption,yesOption);

            if strcmpi(selection,yesOption)
                selectedImageIndices=this.CurrentSelection;


                this.removeImages(selectedImageIndices);
                this.ImageFilename(selectedImageIndices)=[];


                if this.IsDataBlockedImage
                    this.BlockedImageObjects(selectedImageIndices)=[];
                    if isempty(this.BlockedImageObjects)
                        this.BlockedImageObjects=blockedImage.empty();
                    end
                end


                if~isempty(this.Datastore)
                    this.Datastore.Files=setdiff(this.Datastore.Files,...
                    this.Datastore.Files(selectedImageIndices),'stable');
                end

                this.NumberOfThumbnails=numel(this.ImageFilename);

                data=vision.internal.labeler.tool.ItemSelectedEvent(...
                selectedImageIndices);
                notify(this,'ImageRemovedInBrowser',data);

                if isvalid(this)
                    newSelection=min(max(selectedImageIndices),this.NumberOfThumbnails);
                    if newSelection~=0

                        this.setSelection(newSelection);



                        this.updateGridLayout();
                    end
                end
            end
        end

        function rotateSelectedImages(this,rotationType)
            selectedImageIndices=this.CurrentSelection;
            data=vision.internal.labeler.tool.ImageRotateEvent(...
            selectedImageIndices,rotationType);
            notify(this,'ImageRotateInBrowser',data);
            this.recreateThumbnails(selectedImageIndices);
        end
    end

    methods(Access=private)
        function createAndCacheBlockedImages(this,filenames)



            warnStruct=warning('off');
            resetWarnings=onCleanup(@()warning(warnStruct));

            if appendData
                startIdx=numel(this.BlockedImageObjects)+1;
            else
                startIdx=1;
            end

            for idx=1:length(filenames)
                this.BlockedImageObjects(startIdx)=blockedImage(filenames{idx});
                startIdx=startIdx+1;
            end

        end
    end
end
