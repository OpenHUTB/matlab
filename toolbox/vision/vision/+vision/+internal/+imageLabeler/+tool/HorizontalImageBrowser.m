


classdef HorizontalImageBrowser<handle




    properties(Access=public)
BrowserFigure
BrowserObj

IsDataBlockedImage
Datastore
    end


    properties(Access=private)



        IsFrozen=false;

        ImageFilenames=[]
    end

    events
ImageSelectedInBrowser
ImageRemovedInBrowser
ImageRotateInBrowser
    end




    methods

        function this=HorizontalImageBrowser(containerObj,isDataBlockedImage)
            this.BrowserFigure=containerObj.FigHandle;

            this.BrowserFigure.Units='Pixel';
            figSize=this.BrowserFigure.Position(3:4);


            if figSize(1)==0||figSize(2)==0
                figSize=[20,20];
            end

            this.BrowserObj=images.internal.app.browser.Browser(...
            this.BrowserFigure,...
            [1,1,figSize]);

            this.BrowserObj.LabelVisible=false;
            this.BrowserObj.Layout='row';
            this.BrowserObj.BackgroundColor=[1,1,1];
            this.BrowserObj.ThumbnailSize=[92,92];

            this.IsDataBlockedImage=isDataBlockedImage;
            installContextMenu(this);

            this.BrowserFigure.SizeChangedFcn=@(src,evt)resize(this.BrowserObj,[1,1,src.Position(3:4)]);

            addlistener(this.BrowserFigure,'WindowScrollWheel',@(src,evt)scroll(this.BrowserObj,evt.VerticalScrollCount));
            addlistener(this.BrowserFigure,'KeyPress',@(src,evt)this.browserKeyPress(src,evt));
            addSelectionListener(this);


            this.BrowserFigure.KeyPressFcn=@(varargin)[];
        end


        function appendImage(this,imageData)


            if this.IsDataBlockedImage
                if isa(imageData(1),'blockedImage')
                    imageFilenames=cell(numel(imageData),1);
                    for idx=1:numel(imageData)
                        imageFilenames{idx}=char(imageData(idx).Source);
                    end
                else
                    imageFilenames=imageData.Filenames;
                end
            else

                if isa(imageData,'matlab.io.datastore.ImageDatastore')
                    this.Datastore=copy(imageData);
                    imageFilenames=imageData.Files;
                else

                    if~isempty(this.Datastore)
                        this.Datastore.Files=[this.Datastore.Files;imageData.Filenames];
                    end

                    if isfield(imageData,'Filenames')
                        imageFilenames=imageData.Filenames;
                    else
                        imageFilenames=imageData;
                    end
                end
            end

            add(this.BrowserObj,imageFilenames);
            if isempty(this.ImageFilenames)
                this.ImageFilenames=imageFilenames;
            else
                this.ImageFilenames=[this.ImageFilenames;imageFilenames];
            end


            if isempty(this.BrowserObj.Selected)
                this.BrowserObj.select(1);
            end
        end


        function filterSelectedImages(this)

            selectedImages=selectedItem(this);
            if isempty(selectedImages)
                return;
            end

            imageFilenames=this.ImageFilenames(selectedImages);

            clearBrowser(this);
            add(this.BrowserObj,imageFilenames);

            this.BrowserObj.select(1);
        end


        function restoreAllImages(this)

            clearBrowser(this);
            add(this.BrowserObj,this.ImageFilenames);
        end


        function installContextMenu(this)

            removeImageMenu=uimenu(this.BrowserObj.ContextMenu,'Label',...
            getString(message('vision:imageLabeler:RemoveImage')),...
            'Callback',@(~,~)removeSelectedImages(this),...
            'Tag','ContextMenuRemove');%#ok<NASGU>


            rotateImageMenu=uimenu(this.BrowserObj.ContextMenu,'Label',...
            getString(message('vision:imageLabeler:RotateImage')),...
            'Tag','ContextMenuRotate');


            rotateImageClockwiseMenu=uimenu(rotateImageMenu,'Label',...
            getString(message('vision:imageLabeler:RotateImageClockwise')),...
            'Callback',@(~,~)rotateSelectedImages(this,'Clockwise'),...
            'Tag','ContextMenuRotateClockwise');%#ok<NASGU>


            rotateImageCounterClockWiseMenu=uimenu(rotateImageMenu,'Label',...
            getString(message('vision:imageLabeler:RotateImageCounterClockwise')),...
            'Callback',@(~,~)rotateSelectedImages(this,'Counterclockwise'),...
            'Tag','ContextMenuRotateCounterclockwise');%#ok<NASGU>
        end

        function disableRotation(this)

            contextMenus=this.BrowserObj.ContextMenu.Children;
            contextMenus(string({contextMenus.Tag})=='ContextMenuRotate').Enable='off';
        end

        function removeRotation(this)

            contextMenus=this.BrowserObj.ContextMenu.Children;
            hRotateCM=contextMenus(string({contextMenus.Tag})=='ContextMenuRotate');
            delete(hRotateCM);

        end


        function reset(this)
            if isvalid(this)
                clear(this.BrowserObj);
            end
        end


        function clearBrowser(this)
            clear(this.BrowserObj);
        end


        function deleteBrowser(this)
            delete(this.BrowserObj);
        end


        function itemNo=selectedItem(this)
            itemNo=this.BrowserObj.Selected();
        end


        function numImages=NumImages(this)
            numImages=this.BrowserObj.NumImages();
        end


        function selectImageByIndex(this,entryNo)
            this.BrowserObj.select(entryNo);
        end


        function freeze(this)
            this.IsFrozen=true;
        end


        function unfreeze(this)
            this.IsFrozen=false;
        end


        function fileName=imageNameByIndex(this,entryNo)
            fileName=this.BrowserObj.Sources{entryNo};
        end



        function idx=imageIndexByName(this,source)
            [~,idx]=ismember(source,this.BrowserObj.Sources);
        end


        function setSelectedIndices(this,entryNo)
            newSelection=[this.BrowserObj.Selected;entryNo'];
            this.selectImageByIndex(newSelection);
        end


        function addSelectionListener(this)
            addlistener(this.BrowserObj,'SelectionChanged',@this.doImageSelected);
        end


        function doImageSelected(this,~,~)
            data=vision.internal.labeler.tool.ItemSelectedEvent(...
            this.BrowserObj.Selected);
            notify(this,'ImageSelectedInBrowser',data);
        end

        function removeSelectedImages(this)
            displayMessage=vision.getMessage('vision:imageLabeler:RemoveImageWarning');
            dialogName=vision.getMessage('vision:imageLabeler:RemoveImage');

            yesOption=vision.getMessage('MATLAB:uistring:popupdialogs:Yes');
            noOption=vision.getMessage('MATLAB:uistring:popupdialogs:No');
            hFig=ancestor(this.BrowserFigure,'Figure');

            selection=vision.internal.labeler.handleAlert(hFig,'question',displayMessage,dialogName,...
            yesOption,noOption,yesOption);

            if strcmpi(selection,yesOption)
                selectedImageIndices=this.selectedItem;


                this.BrowserObj.remove(selectedImageIndices);
                this.ImageFilenames(selectedImageIndices)=[];


                if~isempty(this.Datastore)
                    this.Datastore.Files=setdiff(this.Datastore.Files,...
                    this.Datastore.Files(selectedImageIndices),'stable');
                end

                data=vision.internal.labeler.tool.ItemSelectedEvent(...
                selectedImageIndices);
                notify(this,'ImageRemovedInBrowser',data);

                if isvalid(this)
                    newSelection=min(max(selectedImageIndices),this.NumImages);
                    if newSelection~=0

                        this.setSelectedIndices(newSelection);
                    end
                end
            end
        end

        function rotateSelectedImages(this,rotationType)
            selectedImageIndices=this.selectedItem;
            data=vision.internal.labeler.tool.ImageRotateEvent(...
            selectedImageIndices,rotationType);
            notify(this,'ImageRotateInBrowser',data);
            if strcmp(rotationType,'Clockwise')
                theta=-90;
            elseif strcmp(rotationType,'Counterclockwise')
                theta=90;
            end
            rotate(this.BrowserObj,selectedImageIndices,theta);
        end
    end


    methods(Access=private)

        function browserKeyPress(this,~,evt)
            if~this.IsFrozen
                images.internal.app.browser.helper.keyPressCallback(this.BrowserObj,evt);
            end
        end
    end
end