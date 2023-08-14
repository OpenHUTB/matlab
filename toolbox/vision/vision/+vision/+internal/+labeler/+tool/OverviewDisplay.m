
classdef OverviewDisplay<vision.internal.uitools.AppFig

    properties


        OverviewDir=''


        OverviewImageSize(1,2)=[1024,1024];


        Enabled(1,1)logical=false;

    end


    properties(Access=private)

Axes
ImagePanel
Image

        CurrentViewROI=gobjects;

    end


    properties(Access=private)


        OverviewImages(1,:)string

    end

    properties(Access=private,Constant)

        CurrentViewROIEnabledColor(1,3)=[217,83,25]/255;
        CurrentViewROIDisabledColor(1,3)=[0.7,0.7,0.7];
        CurrentViewROIStripeColor(1,3)=[1,1,1];

        CurrentViewImageArea(1,1)=1;
        CurrentViewBlockImageArea(1,1)=0.50;

        Border=10;

    end

    properties
MouseMotionListener
MouseClickListener
MouseReleaseListener
    end

    events
CurrentViewChanged
OverviewBlockedImWrittenToDisk
    end

    methods

        function self=OverviewDisplay(hFig)

            hFig.AutoResizeChildren='off';
            self=self@vision.internal.uitools.AppFig(hFig,'Overview',true);
            self.Fig.Resize='on';

            self.ImagePanel=uipanel('Parent',self.Fig,...
            'BorderType','none',...
            'Units','normalized',...
            'Position',[0,0,1,1],...
            'HandleVisibility','off',...
            'Tag','OverviewImagePanel',...
            'Visible','on',...
            'AutoResizeChildren','off');
            self.ImagePanel.SizeChangedFcn=@(~,~)self.reactToAppResize();

            self.Axes=axes('Parent',self.ImagePanel,...
            'Units','pixels',...
            'Position',[0,0,1,1],...
            'Tag','OverviewImageAxes',...
            'HandleVisibility','off',...
            'Visible','off');

            self.MouseMotionListener=addlistener(self.Fig,'WindowMouseMotion',...
            @(src,evt)self.managePointer(src,evt));

            hFig.WindowButtonMotionFcn=@(~,~)images.roi.internal.emptyCallback();

        end

        function delete(self)
            self.reset();
        end

        function initialize(self,dispType)

            if self.Enabled
                return
            end

            if isa(self.Image,'matlab.graphics.primitive.Image')||isa(self.Image,'bigimageshow')


                return
            end

            switch(dispType)
            case{displayType.Image,displayType.ImageMixedSize}
                im=zeros(100);
                self.Image=imshow(im,'Parent',self.Axes,...
                'InitialMagnification','fit');

            case displayType.BlockedImageMixedSize
                bim=blockedImage(zeros(100));
                self.Image=bigimageshow(bim,...
                'Parent',self.Axes,...
                'ResolutionLevelMode','auto',...
                'GridLevelMode','auto',...
                'Visible','off');
            end
            self.Axes.Visible='off';

            self.Enabled=true;
            self.disableDefaultInteractions();

            self.MouseClickListener=addlistener(self.Fig,'WindowMousePress',...
            @(~,~)self.mouseClicked());

            self.MouseReleaseListener=addlistener(self.Fig,'WindowMouseRelease',...
            @(~,~)self.mouseReleased());

        end

        function draw(self,data,idx)

            if isa(data.Image,'blockedImage')
                self.drawBlockedImage(data,idx);
            else
                self.drawImage(data,idx);
            end

            self.Axes.Visible='on';
            self.Image.Visible='on';



            isValidROIMask=isgraphics(self.CurrentViewROI);
            set(self.CurrentViewROI(isValidROIMask),'Visible','off');
            set(self.CurrentViewROI(idx),'Visible','on');



            evtData=vision.internal.imageLabeler.events.CurrentViewROIMovedEventData(self.CurrentViewROI(idx).Position,idx);
            self.notify('CurrentViewChanged',evtData);

        end

        function writeOverviewBlockedImage(self,overviewBim,idx)


            dirname=fullfile(self.OverviewDir,sprintf("OverviewImage_%d",idx));
            if exist(dirname,'dir')
                return
            end

            overviewBim=self.preserveWorldCordinates(overviewBim);
            overviewBim.write(dirname,'DisplayWaitbar',false);
            self.OverviewImages(idx)=dirname;


            if idx>numel(self.CurrentViewROI)||~isa(self.CurrentViewROI(idx),'images.roi.Rectangle')



                imSize=[overviewBim.WorldEnd(1,1),overviewBim.WorldEnd(1,2)]-0.5;
                hRect=self.createCurrentViewROI(imSize,self.CurrentViewBlockImageArea);

                self.CurrentViewROI(idx)=hRect;
            end

            self.notifyOverviewBlockedImageWritten(idx);

        end

        function loadCurrentViewPosFromSession(self,currentViewPos)
            if all(currentViewPos==0)





                return
            end

            numROIs=size(currentViewPos,1);
            for i=1:numROIs
                if i<=numel(self.CurrentViewROI)&&isa(self.CurrentViewROI(i),'images.roi.Rectangle')
                    self.CurrentViewROI(i).Position=currentViewPos(i,:);
                else
                    hRect=self.createROI(currentViewPos(i,:));
                    self.CurrentViewROI(i)=hRect;
                end
            end

        end

        function setROIPosition(self,idx,pos)

            if idx>numel(self.CurrentViewROI)||~isa(self.CurrentViewROI(idx),'images.roi.Rectangle')||...
                ~isvalid(self.CurrentViewROI(idx))


            else
                self.CurrentViewROI(idx).Position=pos;
            end

        end

        function removeImage(self,removedImageIndices)





            if isa(self.Image,'matlab.graphics.primitive.Image')


                self.removeCurrentViewROIs(removedImageIndices);

                return

            else
                self.removeCurrentViewROIs(removedImageIndices);
                self.removeAndRenameImages(removedImageIndices);
            end

        end

        function rotateCurrentViewROI(self,imagesToBeRotatedIdx,imageSizes,rotationType)

            for i=1:numel(imagesToBeRotatedIdx)

                idx=imagesToBeRotatedIdx(i);

                if idx>numel(self.CurrentViewROI)||~isa(self.CurrentViewROI(idx),'images.roi.Rectangle')

                    return
                else
                    roiPos=self.CurrentViewROI(idx).Position;
                    imageSize=imageSizes(i,:);

                    if strcmpi(rotationType,'Clockwise')
                        x=imageSize(1)-(roiPos(2)+roiPos(4));
                        y=roiPos(1);
                    elseif strcmpi(rotationType,'CounterClockwise')
                        x=roiPos(2);
                        y=imageSize(2)-(roiPos(1)+roiPos(3));
                    end
                    newPos=[x,y,roiPos(4),roiPos(3)];

                    self.CurrentViewROI(idx).Position=newPos;
                    evtData=vision.internal.imageLabeler.events.CurrentViewROIMovedEventData(newPos,idx);
                    self.notify('CurrentViewChanged',evtData);
                end
            end
        end

        function reset(self)




            self.OverviewImages=string(missing);
            self.OverviewDir='';

            delete(self.Image);
            self.Image=[];

            delete(self.CurrentViewROI);
            self.CurrentViewROI=gobjects;

            self.Enabled=false;

        end

    end


    methods

        function set.Enabled(self,TF)

            isValidROIMask=isgraphics(self.CurrentViewROI);%#ok<*MCSUP>           

            if TF
                set(self.CurrentViewROI(isValidROIMask),'InteractionsAllowed','translate');
                set(self.CurrentViewROI(isValidROIMask),'Color',self.CurrentViewROIEnabledColor);
            else
                set(self.CurrentViewROI(isValidROIMask),'InteractionsAllowed','none');
                set(self.CurrentViewROI(isValidROIMask),'Color',self.CurrentViewROIDisabledColor);
            end


        end

    end

    methods(Access=private)

        function drawBlockedImage(self,data,idx)

            if idx>numel(self.OverviewImages)||...
                (idx<=numel(self.OverviewImages)&&ismissing(self.OverviewImages(idx)))




                overviewBim=vision.internal.imageLabeler.tool.blockedImage.resize(data.Image,self.OverviewImageSize);


                self.writeOverviewBlockedImage(overviewBim,idx);

            else
                overviewBim=blockedImage(self.OverviewImages(idx));
                overviewBim=self.loadWorldCordinates(overviewBim);

            end

            self.Image.CData=overviewBim;

        end

        function drawImage(self,data,idx)

            if size(data.Image,3)>3
                im=data.Image(:,:,1:3);
            else
                im=data.Image;
            end

            self.Image.CData=im;
            self.Axes.XLim=[1,size(self.Image.CData,2)]+[-0.5,0.5];
            self.Axes.YLim=[1,size(self.Image.CData,1)]+[-0.5,0.5];

            if idx>numel(self.CurrentViewROI)||~isa(self.CurrentViewROI(idx),'images.roi.Rectangle')||...
                ~isvalid(self.CurrentViewROI(idx))
                imSize=size(im,[1,2]);
                hRect=self.createCurrentViewROI(imSize,self.CurrentViewImageArea);
                self.CurrentViewROI(idx)=hRect;
            end
        end

        function hRect=createCurrentViewROI(self,imSize,areaRatio)



            rectWidth=areaRatio*imSize(2);
            rectHeight=areaRatio*imSize(1);
            x=max(0.5,imSize(2)/2-rectWidth/2);
            y=max(0.5,imSize(1)/2-rectHeight/2);
            pos=[x,y,rectWidth,rectHeight];

            hRect=self.createROI(pos);

        end

        function hRect=createROI(self,pos)

            hRect=images.roi.Rectangle('Parent',self.Axes,...
            'Position',pos,...
            'StripeColor',self.CurrentViewROIStripeColor,...
            'MarkerSize',0.01,...
            'LineWidth',1,...
            'LabelVisible','on',...
            'ContextMenu',[],...
            'Visible','off');

            if self.Enabled
                hRect.Color=self.CurrentViewROIEnabledColor;
                hRect.InteractionsAllowed='translate';
            else
                hRect.Color=self.CurrentViewROIDisabledColor;
                hRect.InteractionsAllowed='none';
            end

            addlistener(hRect,'ROIMoved',@(src,evt)self.currentViewROIMoved(evt));

        end

        function removeCurrentViewROIs(self,removedImageIndices)

            for i=removedImageIndices
                if i<=numel(self.CurrentViewROI)&&isvalid(self.CurrentViewROI(i))
                    delete(self.CurrentViewROI(i));
                end
            end

            if~any(isgraphics(self.CurrentViewROI))


                self.CurrentViewROI=gobjects;
            else
                self.CurrentViewROI(removedImageIndices)=[];
            end

        end

        function removeAndRenameImages(self,removedImageIndices)

            firstRemovedImgIdx=removedImageIndices(1);
            lastOverviewImageIdx=numel(self.OverviewImages);
            offset=0;

            for idx=firstRemovedImgIdx:lastOverviewImageIdx

                if ismissing(self.OverviewImages(idx))

                    continue
                end

                try

                    if~isempty(find(removedImageIndices==idx,1))
                        dirName=fullfile(self.OverviewDir,sprintf('OverviewImage_%d',idx));
                        if exist(dirName,'dir')
                            rmdir(dirName,'s');
                            self.OverviewImages(idx)=string(missing);
                        end

                        offset=offset+1;

                    else

                        newDirIndex=idx-offset;
                        newDirName=fullfile(self.OverviewDir,sprintf('OverviewImage_%d',newDirIndex));
                        currDirName=fullfile(self.OverviewDir,sprintf('OverviewImage_%d',idx));
                        if exist(currDirName,'dir')
                            movefile(currDirName,newDirName);
                            self.OverviewImages(newDirIndex)=newDirName;
                            self.OverviewImages(idx)=string(missing);
                        end

                    end

                catch ME %#ok<NASGU>

                end

            end

        end

        function notifyOverviewBlockedImageWritten(self,idx)
            overviewBim=blockedImage(self.OverviewImages(idx));
            overviewBim=self.loadWorldCordinates(overviewBim);

            evtData=vision.internal.imageLabeler.events.OverviewBlockedImageEventData(overviewBim,idx);
            self.notify('OverviewBlockedImWrittenToDisk',evtData);
        end


    end


    methods(Access=protected)

        function managePointer(~,src,evt)
            if isa(evt.HitObject.Parent,'images.roi.Rectangle')
                images.roi.setBackgroundPointer(src,'drag');
            elseif isa(evt.HitObject,'matlab.graphics.axis.Axes')||...
                isa(evt.HitObject,'matlab.graphics.primitive.Image')
                images.roi.setBackgroundPointer(src,'push');
            else
                images.roi.setBackgroundPointer(src,'arrow');
            end
        end

        function clickToJumpOverviewRect(self,~,~)

            imageSize=self.getImageSize();
            newCenter=self.Axes.CurrentPoint(1,1:2);

            isValidROIMask=isgraphics(self.CurrentViewROI);
            currViewROI=findobj(self.CurrentViewROI(isValidROIMask),'Visible','on');
            idx=find(self.CurrentViewROI==currViewROI);
            currWidth=currViewROI.Position(3);
            currHeight=currViewROI.Position(4);

            allowedXCenterMin=currWidth/2+1;
            allowedXCenterMax=imageSize(2)-currWidth/2;
            allowedYCenterMin=currHeight/2+1;
            allowedYCenterMax=imageSize(1)-currHeight/2;

            newCenter(1)=max(newCenter(1),allowedXCenterMin);
            newCenter(1)=min(newCenter(1),allowedXCenterMax);

            newCenter(2)=max(newCenter(2),allowedYCenterMin);
            newCenter(2)=min(newCenter(2),allowedYCenterMax);

            currViewROI.CenteredPosition([1,2])=newCenter;

            evtData=vision.internal.imageLabeler.events.CurrentViewROIMovedEventData(currViewROI.Position,idx);
            self.notify('CurrentViewChanged',evtData);

        end

        function mouseClicked(self)
            self.MouseMotionListener.Enabled=false;
            self.clickToJumpOverviewRect();
        end

        function mouseReleased(self)
            self.MouseMotionListener.Enabled=true;
        end

        function currentViewROIMoved(self,evtData)

            self.MouseMotionListener.Enabled=true;
            idx=find(self.CurrentViewROI==evtData.Source);

            evtData=vision.internal.imageLabeler.events.CurrentViewROIMovedEventData(evtData.CurrentPosition,idx);
            self.notify('CurrentViewChanged',evtData);

        end

        function reactToAppResize(self)
            origUnits=self.ImagePanel.Units;
            self.ImagePanel.Units='pixels';
            panelPos=self.ImagePanel.Position;
            self.ImagePanel.Units=origUnits;

            self.Axes.Position=[self.Border,self.Border,panelPos(3)-2*self.Border,panelPos(4)-2*self.Border];
        end

    end


    methods(Access=private)

        function disableDefaultInteractions(self)

            self.Axes.Toolbar=[];
            disableDefaultInteractivity(self.Axes);
            self.Axes.XTick=[];
            self.Axes.YTick=[];

        end

        function bim=preserveWorldCordinates(~,bim)



            bim.UserData.WorldStart=bim.WorldStart;
            bim.UserData.WorldEnd=bim.WorldEnd;

        end

        function bim=loadWorldCordinates(~,bim)



            bim.WorldStart=bim.UserData.WorldStart;
            bim.WorldEnd=bim.UserData.WorldEnd;

        end

        function imgSize=getImageSize(self)

            if isa(self.Image,'bigimageshow')
                imgSize=self.Image.CData.WorldEnd(1,1:2)-[0.5,0.5];
            else
                imgSize=size(self.Image.CData,1:2);
            end

        end

    end


end