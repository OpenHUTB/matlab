classdef BlockedImageDisplay<vision.internal.labeler.tool.display.ImageDisplay




    methods

        function this=BlockedImageDisplay(hFig,nameDisplayedInTab)

            this=this@vision.internal.labeler.tool.display.ImageDisplay(hFig,nameDisplayedInTab);

            this.IsCuboidSupported=false;
            this.IsPixelSupported=false;
            this.SignalType=vision.labeler.loading.SignalType.Image;

        end

    end


    methods

        function configure(this,...
            keyPressCallback,...
            labelChangedCallback,...
            roiInstanceSelectionCallback,...
            appWaitStartedCallback,...
            appWaitFinishedCallback,...
            drawingStartedCallback,...
            drawingFinishedCallback,...
            grabCutEditEnabledCallback,...
            grabCutEditDisabledCallback,...
            multipleROIMovingCallback,...
            toolbarButtonChangedCallback,...
            pasteROIMenuCallback,...
            pastePixelROIMenuCallback,...
            copyDisplayNameCallbackForPixelROI,...
            copyPixelROIMenuCallback,...
            cutPixelROIMenuCallback,...
            deletePixelROIMenuCallback)

            configure@vision.internal.labeler.tool.display.ImageDisplay(this,...
            keyPressCallback,...
            labelChangedCallback,...
            roiInstanceSelectionCallback,...
            appWaitStartedCallback,...
            appWaitFinishedCallback,...
            drawingStartedCallback,...
            drawingFinishedCallback,...
            grabCutEditEnabledCallback,...
            grabCutEditDisabledCallback,...
            multipleROIMovingCallback,...
            toolbarButtonChangedCallback,...
            pasteROIMenuCallback,...
            pastePixelROIMenuCallback,...
            copyDisplayNameCallbackForPixelROI,...
            copyPixelROIMenuCallback,...
            cutPixelROIMenuCallback,...
            deletePixelROIMenuCallback);
        end

    end


    methods

        function installContextMenu(this,isInAlgoMode,numPixelLabels)

            if isempty(this.AxesHandle.UIContextMenu)
                hCMenu=uicontextmenu('Parent',this.Fig,...
                'Tag','DisplayContextMenu');


                pasteUIMenu=uimenu(hCMenu,'Label',...
                getString(message('vision:trainingtool:PastePopup')),...
                'Callback',@this.PasteROIMenuCallback,'Accelerator','V',...
                'Tag','PasteContextMenu');

                if isempty(this.Clipboard)
                    set(pasteUIMenu,'Enable','off');
                end

                if ismac()
                    pastePixString=getString(message('vision:trainingtool:PastePixelROI','[Cmd+Shift+V]'));
                    copyPixString=getString(message('vision:trainingtool:CopyPixelROI','[Cmd+Shift+C]'));
                    cutPixString=getString(message('vision:trainingtool:CutPixelROI','[Cmd+Shift+X]'));
                    deletePixString=getString(message('vision:trainingtool:DeletePixelROI','[Cmd+Shift+Delete]'));
                else
                    pastePixString=getString(message('vision:trainingtool:PastePixelROI','[Ctrl+Shift+V]'));
                    copyPixString=getString(message('vision:trainingtool:CopyPixelROI','[Ctrl+Shift+C]'));
                    cutPixString=getString(message('vision:trainingtool:CutPixelROI','[Ctrl+Shift+X]'));
                    deletePixString=getString(message('vision:trainingtool:DeletePixelROI','[Ctrl+Shift+Delete]'));
                end


                uimenu(hCMenu,'Label',pastePixString,...
                'Callback',@this.PastePixelROIMenuCallback,...
                'Tag','PastePixelROIsContextMenu','Visible','off',...
                'Enable','off');


                uimenu(hCMenu,'Label',copyPixString,...
                'Callback',@this.CopyPixelROIMenuCallback,...
                'Tag','CopyPixelROIsContextMenu','Visible','off',...
                'Enable','off');


                uimenu(hCMenu,'Label',cutPixString,...
                'Callback',@this.CutPixelROIMenuCallback,...
                'Tag','CutPixelROIsContextMenu','Visible','off',...
                'Enable','off');


                uimenu(hCMenu,'Label',deletePixString,...
                'Callback',@this.DeletePixelROIMenuCallback,...
                'Tag','DeletePixelROIsContextMenu','Visible','off',...
                'Enable','off');

                set(this.AxesHandle,'UIContextMenu',hCMenu);
                this.ContextMenuCache=hCMenu;
            else
                this.resetCopyPastePixelContextMenu();
            end

            sessionData.isInAlgoMode=isInAlgoMode;
            sessionData.numPixelLabels=numPixelLabels;
            updateContextMenuCopyPastePixel(this,sessionData);

        end


        function setPasteMenuState(this,copiedROIsTypes,enableState)

            foundPaste=findobj(this.AxesHandle.UIContextMenu.Children,...
            'Tag','PasteContextMenu');
            foundPaste.Text=copiedROIsTypes;
            set(foundPaste,'Enable',enableState);

        end


        function setPasteVisibility(this,visibleState)

            foundPaste=findobj(this.AxesHandle.UIContextMenu.Children,...
            'Tag','PasteContextMenu');
            set(foundPaste,'Visible',visibleState);

        end


        function setPixContextMenuVisibility(this,visibleState)

            copyPixelUIMenu=findobj(this.AxesHandle.UIContextMenu.Children...
            ,'Tag','CopyPixelROIsContextMenu');
            pastePixelUIMenu=findobj(this.AxesHandle.UIContextMenu.Children...
            ,'Tag','PastePixelROIsContextMenu');
            cutPixelUIMenu=findobj(this.AxesHandle.UIContextMenu.Children...
            ,'Tag','CutPixelROIsContextMenu');
            deletePixelUIMenu=findobj(this.AxesHandle.UIContextMenu.Children...
            ,'Tag','DeletePixelROIsContextMenu');
            set(copyPixelUIMenu,'Visible',visibleState);
            set(pastePixelUIMenu,'Visible',visibleState);
            set(cutPixelUIMenu,'Visible',visibleState);
            set(deletePixelUIMenu,'Visible',visibleState);

        end


        function setPixPasteMenuState(this,enableState,visibleState)



            pastePixelUIMenu=findobj(this.AxesHandle.UIContextMenu.Children...
            ,'Tag','PastePixelROIsContextMenu');

            set(pastePixelUIMenu,'Enable',enableState);
            set(pastePixelUIMenu,'Visible',visibleState);

            drawnow('limitrate');

        end


        function updateContextMenuCopyPastePixel(this,sessionData)

            copyPixelUIMenu=findobj(this.AxesHandle.UIContextMenu.Children,...
            'Tag','CopyPixelROIsContextMenu');
            pastePixelUIMenu=findobj(this.AxesHandle.UIContextMenu.Children...
            ,'Tag','PastePixelROIsContextMenu');
            cutPixelUIMenu=findobj(this.AxesHandle.UIContextMenu.Children...
            ,'Tag','CutPixelROIsContextMenu');
            deletePixelUIMenu=findobj(this.AxesHandle.UIContextMenu.Children...
            ,'Tag','DeletePixelROIsContextMenu');

            if isfield(sessionData,'isInAlgoMode')
                if sessionData.isInAlgoMode
                    return;
                end
                numPixelROIDefn=sessionData.numPixelLabels;
            else
                numPixelROIDefn=0;
            end

            if nnz(this.PixelLabeler.LabelMatrix)
                set(copyPixelUIMenu,'Enable','on');
                set(cutPixelUIMenu,'Enable','on');
                set(deletePixelUIMenu,'Enable','on');
            else
                set(copyPixelUIMenu,'Enable','off');
                set(cutPixelUIMenu,'Enable','off');
                set(deletePixelUIMenu,'Enable','off');
            end




            if strcmp(copyPixelUIMenu.Enable,'on')||...
                strcmp(pastePixelUIMenu.Enable,'on')||...
                strcmp(cutPixelUIMenu.Enable,'on')||...
                strcmp(deletePixelUIMenu.Enable,'on')||...
                numPixelROIDefn>0
                set(copyPixelUIMenu,'Visible','on');
                set(pastePixelUIMenu,'Visible','on');
                set(cutPixelUIMenu,'Visible','on');
                set(deletePixelUIMenu,'Visible','on');
            end
        end


        function enableContextMenuCopyPastePixel(this,numPixelROIDefn)

            copyPixelUIMenu=findobj(this.AxesHandle.UIContextMenu.Children,...
            'Tag','CopyPixelROIsContextMenu');
            pastePixelUIMenu=findobj(this.AxesHandle.UIContextMenu.Children,...
            'Tag','PastePixelROIsContextMenu');
            cutPixelUIMenu=findobj(this.AxesHandle.UIContextMenu.Children,...
            'Tag','CutPixelROIsContextMenu');
            deletePixelUIMenu=findobj(this.AxesHandle.UIContextMenu.Children,...
            'Tag','DeletePixelROIsContextMenu');
            if numPixelROIDefn
                set(copyPixelUIMenu,'Visible','on');
                set(pastePixelUIMenu,'Visible','on');
                set(cutPixelUIMenu,'Visible','on');
                set(deletePixelUIMenu,'Visible','on');
            end
        end


        function disableContextMenuCopyPastePixel(this,numPixelROIDefn,roiData)
            if isempty(this.AxesHandle)
                return;
            end


            if~isempty(this.PixelClipboard)
                if~isempty(this.PixelClipboard.Mask)
                    this.PixelClipboard.Mask(this.PixelClipboard.Mask==roiData.PixelLabelID)=0;
                end

                if~isempty(this.PixelClipboard.ActiveROIs)
                    if strcmp(this.PixelClipboard.CopyMode,'grabcutpolygon')
                        if(this.PixelClipboard.ActiveROIs.GrabCutPolygon.UserData==roiData.PixelLabelID)
                            this.PixelClipboard.ActiveROIs=[];
                        end
                    else
                        if(this.PixelClipboard.ActiveROIs.UserData==roiData.PixelLabelID)
                            this.PixelClipboard.ActiveROIs=[];
                        end
                    end
                end

                if~nnz(this.PixelClipboard.Mask)
                    pastePixelUIMenu=findobj(this.AxesHandle.UIContextMenu.Children...
                    ,'Tag','PastePixelROIsContextMenu');
                    set(pastePixelUIMenu,'Enable','off');
                    this.PixelClipboard=[];
                end
            end

            if(numPixelROIDefn==1)
                this.resetCopyPastePixelContextMenu();
                this.PixelClipboard=[];
            end
        end


        function resetCopyPastePixelContextMenu(this)
            copyPixelUIMenu=findobj(this.AxesHandle.UIContextMenu.Children,...
            'Tag','CopyPixelROIsContextMenu');
            pastePixelUIMenu=findobj(this.AxesHandle.UIContextMenu.Children...
            ,'Tag','PastePixelROIsContextMenu');
            cutPixelUIMenu=findobj(this.AxesHandle.UIContextMenu.Children...
            ,'Tag','CutPixelROIsContextMenu');
            deletePixelUIMenu=findobj(this.AxesHandle.UIContextMenu.Children...
            ,'Tag','DeletePixelROIsContextMenu');
            set(copyPixelUIMenu,'Visible','off','Enable','off');
            set(pastePixelUIMenu,'Visible','off','Enable','off');
            set(cutPixelUIMenu,'Visible','off','Enable','off');
            set(deletePixelUIMenu,'Visible','off','Enable','off');
        end

    end


    methods(Access=protected)

        function drawImage(this,data)













            if isfield(data,'LabelMatrix')
                resetPixelLabeler(this,data);
            end

            I=data.Image;

            forceRedraw=isfield(data,'ForceRedraw')&&data.ForceRedraw;

            isSameImage=strcmp(this.CurrentImageFilename,data.ImageFilename);

            if~forceRedraw&&isSameImage

            else

                unwireAxesLimitsListeners(this);

                if isempty(this.ImageHandle)
                    createImage(this,I);





                    xLim=[1,this.ImageHandle.CData.WorldEnd(1,2)]+[-0.5,0.5];
                    yLim=[1,this.ImageHandle.CData.WorldEnd(1,1)]+[-0.5,0.5];
                    set(this.AxesHandle,'XLim',xLim,'YLim',yLim);
                    zoom(this.Fig,'reset')

                else
                    this.ImageHandle.CData=I;


                    if~isSameImage

                        if isempty(data.XLim)&&isempty(data.YLim)
                            xLim=[1,this.ImageHandle.CData.WorldEnd(1,2)]+[-0.5,0.5];
                            yLim=[1,this.ImageHandle.CData.WorldEnd(1,1)]+[-0.5,0.5];
                            set(this.AxesHandle,'XLim',xLim,'YLim',yLim);




                            zoom(this.Fig,'reset');

                        else

                            xLim=[1,this.ImageHandle.CData.WorldEnd(1,2)]+[-0.5,0.5];
                            yLim=[1,this.ImageHandle.CData.WorldEnd(1,1)]+[-0.5,0.5];
                            set(this.AxesHandle,'XLim',xLim,'YLim',yLim);




                            zoom(this.Fig,'reset')

                            xLim=data.XLim;
                            yLim=data.YLim;
                            set(this.AxesHandle,'XLim',xLim,'YLim',yLim);
                        end
                    end
                end

                wireupAxesLimitsListeners(this);


                if ismissing(data.ImageFilename)
                    this.CurrentImageFilename='';
                else
                    this.CurrentImageFilename=data.ImageFilename;
                end



                if~isempty(this.CurrentLabeler)&&strcmp(this.Mode,'ROI')
                    activate(this.CurrentLabeler,this.Fig,this.AxesHandle,this.ImageHandle);
                end



                attachToImage(this.RectangleLabeler,this.Fig,this.AxesHandle,this.ImageHandle);
                attachToImage(this.LineLabeler,this.Fig,this.AxesHandle,this.ImageHandle);
                attachToImage(this.PolygonLabeler,this.Fig,this.AxesHandle,this.ImageHandle);
                attachToImage(this.ProjCuboidLabeler,this.Fig,this.AxesHandle,this.ImageHandle);
                attachToImage(this.PixelLabeler,this.Fig,this.AxesHandle,this.ImageHandle);
            end

        end

    end


    methods(Access=protected)

        function createImage(this,im)


            originalTag=this.AxesHandle.Tag;
            if isempty(originalTag)
                originalTag=getAxesTag(this);
            end

            if~isempty(im)
                this.ImageHandle=bigimageshow(im,'Parent',this.AxesHandle);


                this.RectangleLabeler.MarkersVisible='hover';
                this.LineLabeler.MarkersVisible='hover';
                this.PolygonLabeler.MarkersVisible='hover';



                this.ProjCuboidLabeler.MarkersVisible='hover';
            end

            this.AxesHandle.Tag=originalTag;
            this.AxesHandle.XTick=[];
            this.AxesHandle.YTick=[];


            if isempty(this.AxesHandle.Toolbar.Children)
                delete(this.AxesHandle.Toolbar);
                this.AxesHandle.Toolbar=this.Toolbar;
                this.AxesHandle.Interactions=zoomInteraction;
            end

        end

        function createAxes(this)

            this.AxesHandle=axes('Parent',this.ImagePanel,...
            'Units','normalized',...
            'position',[0,0,1,1],...
            'Visible','off');

            this.Toolbar=axtoolbar(this.AxesHandle,{'pan','zoomin','zoomout','restoreview'});

            this.AxesHandle.Interactions=zoomInteraction;

            gridIcon=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+labeler','+tool','+icons','gridlines_20.png');
            gridBtn=axtoolbarbtn(this.Toolbar,'state',...
            'Icon',gridIcon,...
            'Tooltip',vision.getMessage('vision:labeler:BlockedImageGridTooltip'),...
            'Tag','togglegrid',...
            'ValueChangedFcn',@(~,evt)this.toggleBlockedImageGrid(evt));

            this.AxesHandle.Toolbar.SelectionChangedFcn=@(src,evt)this.axToolbarSelectionChangedCallback(src,evt);
            if~useAppContainer


                this.Fig.ToolBar='figure';
            end
            resizeFigure(this);
        end





        function wireupAxesLimitsListeners(this)
            drawnow;
            this.AxesHandle.XAxis.LimitsChangedFcn=@(~,~)axesLimitsChanged(this);
            this.AxesHandle.YAxis.LimitsChangedFcn=@(~,~)axesLimitsChanged(this);
        end

        function unwireAxesLimitsListeners(this)
            this.AxesHandle.XAxis.LimitsChangedFcn=[];
            this.AxesHandle.YAxis.LimitsChangedFcn=[];
        end

        function axesLimitsChanged(this)
            evtData=vision.internal.labeler.tool.AxesLimitsChangedEventData(this.AxesHandle.XLim,this.AxesHandle.YLim);
            this.notify('AxesLimitsChanged',evtData);
        end

        function mouseMotionCallback(this,~,evt)

            if~this.Fig.IPTROIPointerManager.Enabled||isempty(this.ImageHandle)||~isvalid(this.ImageHandle)
                return;
            end

            if evt.HitObject==this.ImageHandle.Parent
                this.WasImageLastHitObject=true;
                setPointer(this);
            elseif isa(evt.HitObject,'matlab.ui.container.Panel')&&any(strcmp(evt.HitObject.Tag,{'RightFlagPanel','LeftFlagPanel','ScrubberPanel'}))
                this.WasScrubberLastHitObject=true;
                images.roi.internal.setROIPointer(this.Fig,'east');
            else
                if this.WasImageLastHitObject||this.WasScrubberLastHitObject

                    this.WasImageLastHitObject=false;
                    this.WasScrubberLastHitObject=false;
                    if~any(strcmp(class(evt.HitObject.Parent),...
                        {'images.roi.Rectangle',...
                        'vision.roi.ProjectedCuboid',...
                        'images.roi.Polygon',...
                        'images.roi.Polyline'}))
                        set(this.Fig,'Pointer','arrow');
                    end

                end
            end

        end

    end


    methods

        function doMoveMultipleROI(this,varargin)
            this.MultiShapeLabelers.doMoveMultipleROI(this.ShapeLabelers,this.getImageSize(),varargin{:});
        end

        function doReshapeROI(this,varargin)
            this.MultiShapeLabelers.doReshapeROI(this.ShapeLabelers,this.getImageSize(),varargin{:});
        end

        function sz=sizeofImage(this)
            sz=this.getImageSize();
        end

        function setAxesLimits(this,xLim,yLim)

            unwireAxesLimitsListeners(this);
            this.AxesHandle.XLim=xLim;
            this.AxesHandle.YLim=yLim;
            wireupAxesLimitsListeners(this);

        end

        function out=getAxesLimits(this)
            out=struct;

            out.CurrentXLim=this.AxesHandle.XLim;
            out.CurrentYLim=this.AxesHandle.YLim;
        end

        function setGridButtonVisibility(this,flag)
            gridBtn=findobj(this.Toolbar.Children,'tag','togglegrid');
            if flag
                gridBtn.Visible=matlab.lang.OnOffSwitchState.on;
            else
                gridBtn.Value=matlab.lang.OnOffSwitchState.off;
                gridBtn.Visible=matlab.lang.OnOffSwitchState.off;
            end
        end

        function updateUndoOnLabelChange(this,currentIdx,currentROIs,~)





            if this.UndoRedoManagerShape.shouldResetUndoRedo(currentIdx)||...
                this.UndoRedoManagerPixel.shouldResetUndoRedo(currentIdx)


                this.UndoRedoManagerShape.initializeUndoBuffer(currentIdx);
                [labelMatrix,~]=this.getInitialPixelROIs();
                this.UndoRedoManagerPixel.initializeUndoBuffer(currentIdx,...
                labelMatrix{1},[]);



                this.OperationUndoStack={};
            end

            this.OperationRedoStack={};



            this.UndoRedoManagerPixel.resetRedoStack();
            this.addAllCurrentROILabelsToUndoStack(currentIdx,currentROIs);

        end

        function pan(this,str)
            deltaX=diff(this.AxesHandle.XLim)/8;
            deltaY=diff(this.AxesHandle.YLim)/8;
            imSize=this.getImageSize();
            newYLim=this.AxesHandle.YLim;
            newXLim=this.AxesHandle.XLim;
            switch str
            case 'up'
                newYLim=this.AxesHandle.YLim-deltaY;
            case 'down'
                newYLim=this.AxesHandle.YLim+deltaY;
            case 'right'
                newXLim=this.AxesHandle.XLim+deltaX;
            case 'left'
                newXLim=this.AxesHandle.XLim-deltaX;
            end

            if newYLim(1)<0
                newYLim(2)=newYLim(2)-newYLim(1);
                newYLim(1)=0;
            end
            if newYLim(2)>imSize(1)
                newYLim(1)=newYLim(1)-(newYLim(2)-imSize(1));
                newYLim(2)=imSize(1);
            end
            if newXLim(1)<0
                newXLim(2)=newXLim(2)-newXLim(1);
                newXLim(1)=0;
            end
            if newXLim(2)>imSize(2)
                newXLim(1)=newXLim(1)-(newXLim(2)-imSize(2));
                newXLim(2)=imSize(2);
            end
            this.AxesHandle.XLim=newXLim;
            this.AxesHandle.YLim=newYLim;

        end

    end


    methods(Access=protected)

        function toggleBlockedImageGrid(this,evt)
            this.ImageHandle.GridVisible=evt.Value;
        end

    end


    methods(Access=protected)

        function imgSize=getImageSize(this)
            imgSize=this.ImageHandle.CData.Size(1,:);
        end
    end

end

function tf=useAppContainer()
    tf=vision.internal.labeler.jtfeature('UseAppContainer');
end