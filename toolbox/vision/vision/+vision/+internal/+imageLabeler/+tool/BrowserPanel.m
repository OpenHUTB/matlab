


classdef BrowserPanel<handle

    properties

Figure


OuterPanel


Panel


Browser
    end

    properties(Dependent)
Position

SelectedItemIndex


VisibleItemIndex
    end

    properties(Access=private)



        IsFrozen=false;










        MultiSelectMode=false;
    end

    events
ImageSelectedInBrowser
ImageRemovedInBrowser
ImageRotateInBrowser

GeneratingOverviewImage
OverviewBlockedImageGenerated

PlacingThumbnailsStarted
PlacingThumbnailsFinished
    end

    methods



        function this=BrowserPanel(containerObj,isDataBlockedImage)

            retrieveParamsFromObject(this,containerObj);

            this.OuterPanel=uipanel('Parent',this.Figure,...
            'Units','pixels',...
            'BorderType','none');

            isAppContainer=vision.internal.labeler.jtfeature('useAppContainer');
            if isAppContainer

                this.Panel=uipanel('Parent',this.OuterPanel,...
                'Units','pixels',...
                'BorderType','none',...
                'Tag','Browser',...
                'Scrollable','on',...
                'DeleteFcn',@(varargin)delete(this.Browser));
                this.Browser=vision.internal.imageLabeler.tool.HorizontalImageStripAppContainer(this.Panel,isDataBlockedImage);
            else

                this.Panel=uipanel('Parent',this.OuterPanel,...
                'Units','pixels',...
                'BorderType','none',...
                'Tag','Browser',...
                'DeleteFcn',@(varargin)delete(this.Browser));



                this.Browser=vision.internal.imageLabeler.tool.HorizontalImageStrip(this.Panel,isDataBlockedImage);
            end

            installContextMenu(this);

            addlistener(this.Browser,'SelectionChange',@this.doImageSelected);
            addlistener(this.Browser,'ImageRemovedInBrowser',@this.doImageRemoval);
            addlistener(this.Browser,'ImageRotateInBrowser',@this.doImageRotate);

            addlistener(this.Browser,'PlacingThumbnailsStarted',@this.doOpenProgressDlg);
            addlistener(this.Browser,'PlacingThumbnailsFinished',@(~,~)this.notify('PlacingThumbnailsFinished'));

            addlistener(this.Browser,'GeneratingOverviewImage',@(~,evtData)this.notify('GeneratingOverviewImage',evtData));
            addlistener(this.Browser,'OverviewBlockedImageGenerated',@(~,evtData)this.notify('OverviewBlockedImageGenerated',evtData));
        end

        function resizeBrowserPanelForFig(this)


            set(this.OuterPanel,'unit','normalized','position',[0,0,1,1]);
            set(this.Panel,'unit','normalized','position',[0,0,1,1]);


...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
        end


        function doKeyPress(this,src)
            if~this.IsFrozen
                this.Browser.keyPressFcn([],src);

                if~isempty(src.Modifier)...
                    &&(any(strcmp(src.Modifier,'control'))...
                    ||any(strcmp(src.Modifier,'command')))...
                    &&(strcmpi(src.Key,'control')||...
                    strcmpi(src.Key,'command'))

                    this.MultiSelectMode=true;
                end
            end
        end


        function TF=hasImages(this)
            TF=this.Browser.numberOfVisibleImages()>0;
        end


        function loadImages(this,imageData)
            this.Browser.loadImages(imageData)
        end


        function appendImage(this,imageData)
            this.Browser.appendImage(imageData)
        end


        function selectImageByIndex(this,idx)
            this.Browser.selectImageByIndex(idx);
        end


        function filterSelectedImages(this)



            if isempty(this.SelectedItemIndex)
                return;
            end
            this.Browser.filterSelectedImages();
        end


        function restoreAllImages(this)



            this.Browser.restoreAllImages();
        end


        function setTempOverviewDirectory(this,overviewDir)
            this.Browser.setTempOverviewDirectory(overviewDir);
        end


        function doFigureKeyPress(this,varargin)
        end


        function freeze(this)
            this.IsFrozen=true;
        end


        function unfreeze(this)
            this.IsFrozen=false;
        end


        function name=imageNameByIndex(this,idx)

            name=this.Browser.imageFilenameByIndex(idx);
        end


        function set.Position(this,pos)
            this.OuterPanel.Position=pos;
            margin=20;
            this.Panel.Position=[0,0,pos(3),pos(4)-margin];
        end


        function pos=get.Position(this)
            pos=this.OuterPanel.Position;
        end


        function idx=get.SelectedItemIndex(this)
            idx=this.Browser.CurrentSelection;
        end


        function idx=get.VisibleItemIndex(this)
            idx=this.Browser.BlockNumToImageNum;
        end


        function doMouseButtonDownFcn(this,varargin)

            if~this.IsFrozen



                hEvent=varargin{2};
                newStruct.Source.SelectionType=hEvent.Source.SelectionType;
                newStruct.Source.CurrentModifier='';
                if this.MultiSelectMode
                    newStruct.Source.CurrentModifier='control';
                    this.MultiSelectMode=false;
                end
                varargin{2}=newStruct;

                this.Browser.mouseButtonDownFcn(varargin{:});
            end
        end


        function doImageSelected(this,~,~)
            data=vision.internal.labeler.tool.ItemSelectedEvent(...
            this.Browser.CurrentSelection);
            notify(this,'ImageSelectedInBrowser',data);
        end


        function doOpenProgressDlg(this,~,evtData)


            if nnz(evtData.ImageIndex==0)
                return
            end
            for idx=evtData.ImageIndex
                if~strcmp(this.Browser.hImageData(idx).hImage.Tag,'Realthumbnail')
                    this.notify('PlacingThumbnailsStarted');
                    break
                end
            end
        end


        function setTimerToZero(this)


            this.Browser.CoalescePeriod=0;
        end


        function algorithmRunSetup(this)
            setTimerToZero(this);
        end


        function resetTimer(this)
            this.Browser.CoalescePeriod=1;
        end

        function algorithmRunTearDown(this)
            resetTimer(this)
        end


        function doImageRemoval(this,~,data)
            notify(this,'ImageRemovedInBrowser',data);
        end


        function doImageRotate(this,~,data)
            notify(this,'ImageRotateInBrowser',data);
        end

        function hideContent(this)
            this.OuterPanel.Visible='off';

        end

        function showContent(this)
            this.OuterPanel.Visible='on';

        end

        function reset(this)
            if isvalid(this)
                if ishandle(this.Figure)

                    delete(this.OuterPanel);
                    this.OuterPanel=[];
                end
            end
            delete(this);
        end










    end


    methods

        function installContextMenu(this)

            removeImageMenu=uimenu(this.Browser.hContextMenu,'Label',...
            getString(message('vision:imageLabeler:RemoveImage')),...
            'Callback',@(~,~)removeSelectedImages(this.Browser),...
            'Tag','ContextMenuRemove');%#ok<NASGU>


            rotateImageMenu=uimenu(this.Browser.hContextMenu,'Label',...
            getString(message('vision:imageLabeler:RotateImage')),...
            'Tag','ContextMenuRotate');%#ok<NASGU> 


            rotateImageClockwiseMenu=uimenu(rotateImageMenu,'Label',...
            getString(message('vision:imageLabeler:RotateImageClockwise')),...
            'Callback',@(~,~)rotateSelectedImages(this.Browser,'Clockwise'),...
            'Tag','ContextMenuRotateClockwise');%#ok<NASGU> 


            rotateImageCounterClockWiseMenu=uimenu(rotateImageMenu,'Label',...
            getString(message('vision:imageLabeler:RotateImageCounterClockwise')),...
            'Callback',@(~,~)rotateSelectedImages(this.Browser,'Counterclockwise'),...
            'Tag','ContextMenuRotateCounterclockwise');%#ok<NASGU>             
        end


        function disableRotation(this)

            contextMenus=this.Browser.hContextMenu.Children;
            contextMenus(string({contextMenus.Tag})=='ContextMenuRotate').Enable='off';
        end

        function removeRotation(this)

            contextMenus=this.Browser.hContextMenu.Children;
            hRotateCM=contextMenus(string({contextMenus.Tag})=='ContextMenuRotate');
            delete(hRotateCM);

        end

    end

    methods

        function retrieveParamsFromObject(this,containerObj)
            this.Figure=containerObj.FigHandle;
...
...
...
...
...
...
...
...
        end
    end
end
