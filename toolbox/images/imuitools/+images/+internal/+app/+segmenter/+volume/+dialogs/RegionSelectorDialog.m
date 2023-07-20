classdef RegionSelectorDialog<images.internal.app.utilities.OkCancelDialog




    events

SliceAtLocationRequested

UpdateSummary

ThrowError

    end

    properties(GetAccess=public,SetAccess=protected)

        MaskOne logical
        MaskTwo logical

        SliceOne double
        SliceTwo double

        Value double

    end

    properties(GetAccess={?images.uitest.factory.Tester,...
        ?uitest.factory.Tester,...
        ?medical.internal.app.labeler.view.dialogs.RegionSelectorDialog},...
        SetAccess=protected,Transient)

        Slice images.internal.app.segmenter.volume.display.Slice
        Slider images.internal.app.segmenter.volume.display.Slider
        Rotate images.internal.app.utilities.Rotate
        Summary images.internal.app.segmenter.volume.display.Summary

        ROIOne images.roi.Freehand
        ROITwo images.roi.Freehand

        Tag="RegionSelectorDialog"
    end

    properties(Access=protected)

RegionOne
RegionTwo
DeselectAll
Instructions
SliceLabel

ContrastLimits
        Data(:,:)uint8=uint8.empty;
Colormap
        CurrentIndex(1,1)double
        AutoSwap(1,1)logical=true;

    end

    properties(Access=protected,Constant)

        SliderHeight=20;

    end

    properties(Constant)

        Connectivity(1,1)double=4;

    end

    methods




        function self=RegionSelectorDialog(loc,alpha,contrastLimits,rotationState)

            self=self@images.internal.app.utilities.OkCancelDialog(loc,getString(message('images:segmenter:manualInterpNameOneLine')));

            self.Size=[500,500];
            self.ContrastLimits=contrastLimits;

            create(self,alpha);

            self.Ok.Enable='off';

            self.Rotate=images.internal.app.utilities.Rotate();
            self.Slice.RotationState=rotationState;
            self.Rotate.Current=rotationState;
            self.Slice.Alpha=alpha;

        end




        function initialize(self)




            requestSliceAtLocation(self,[]);

            self.Slider.Enabled=true;
            self.Slice.Enabled=true;

            self.Summary.Enabled=true;
            self.Summary.Empty=false;

            self.Slice.Image.Visible=true;

            refreshSummary(self);

        end




        function update(self,vol,labels,cmap,idx,maxIdx)

            self.Data=applyForward(self.Rotate,labels);
            self.Colormap=cmap;
            self.CurrentIndex=idx;

            if(~isempty(self.SliceOne)&&self.SliceOne==idx)||...
                (~isempty(self.SliceTwo)&&self.SliceTwo==idx)
                labels=0*labels;
            end

            if~isempty(self.Value)
                labels(labels~=self.Value)=0;
            end

            draw(self.Slice,vol,labels,cmap,self.ContrastLimits);
            update(self.Slider,idx,maxIdx);
            drawIndicator(self.Summary,idx,maxIdx);

            if~isempty(self.SliceOne)&&self.SliceOne==idx&&strcmp(self.ROIOne.Visible,'off')
                self.ROIOne.Visible='on';
            elseif strcmp(self.ROIOne.Visible,'on')
                self.ROIOne.Visible='off';
            end

            if~isempty(self.SliceTwo)&&self.SliceTwo==idx&&strcmp(self.ROITwo.Visible,'off')
                self.ROITwo.Visible='on';
            elseif strcmp(self.ROITwo.Visible,'on')
                self.ROITwo.Visible='off';
            end

            set(self.SliceLabel,'Text',getString(message('images:segmenter:sliceNumber',idx,maxIdx)));

        end




        function updateSummary(self,data,color)

            if sum(data>0)<2

                notify(self,'ThrowError',images.internal.app.segmenter.volume.events.ErrorEventData(getString(message('images:segmenter:notEnoughData'))));
                return;
            end

            if any(data==2)&&sum(data==2)<2


                notify(self,'ThrowError',images.internal.app.segmenter.volume.events.ErrorEventData(getString(message('images:segmenter:noMatchingRegion'))));
                return;
            end

            draw(self.Summary,data,color);

        end




        function create(self,alpha)

            create@images.internal.app.utilities.OkCancelDialog(self);

            self.Ok.Text=getString(message('images:segmenter:run'));
            set(self.Ok,'Position',[self.Size(1)-(2*self.ButtonSpace)-(2*self.ButtonSize(1)),self.ButtonSpace,self.ButtonSize]);
            set(self.Cancel,'Position',[self.Size(1)-self.ButtonSpace-self.ButtonSize(1),self.ButtonSpace,self.ButtonSize]);

            addButtons(self);
            addInstruction(self);

            wireUpSlider(self);
            wireUpSummary(self);
            wireUpSlice(self);

            createROIs(self,alpha);

            addlistener(self.FigureHandle,'WindowMouseMotion',@(src,evt)managePointer(self,src,evt));

        end




        function setFirstRegion(self,val,mask)




            pos=images.internal.builtins.bwborders(double(applyForward(self.Rotate,mask)),self.Connectivity);

            if sum(self.Colormap(val+1,:))>1.5
                labelcolor=[0,0,0];
            else
                labelcolor=[0.94,0.94,0.94];
            end

            set(self.ROIOne,'Position',fliplr(pos{1}),'Color',self.Colormap(val+1,:),'LabelTextColor',labelcolor,'UserData',true);
            self.MaskOne=mask;
            self.SliceOne=self.CurrentIndex;
            self.Value=val;

            self.MaskTwo=logical.empty;
            self.SliceTwo=[];

            self.RegionTwo.Value=1;
            updateButtonState(self);
            refreshSummary(self);

        end

    end

    methods(Access=protected)


        function requestSliceAtLocation(self,idx)
            notify(self,'SliceAtLocationRequested',images.internal.app.segmenter.volume.events.SliderMovingEventData(idx,[]));
        end


        function okClicked(self)

            if self.ROIOne.UserData&&self.ROITwo.UserData&&~isempty(self.Value)
                self.Canceled=false;
                close(self);
            end

        end


        function reactToImageClick(self,pos)

            if isValidLocation(self,pos)

                click=getClickPosition(self,pos);

                slice=self.Data;
                labelval=slice(click(2),click(1));

                BW=bwselect(slice==labelval,...
                click(1),click(2),self.Connectivity);

                pos=images.internal.builtins.bwborders(double(BW),self.Connectivity);

                if sum(self.Colormap(labelval+1,:))>2
                    labelcolor=[0,0,0];
                else
                    labelcolor=[0.94,0.94,0.94];
                end

                if self.RegionOne.Value



                    set(self.ROIOne,'Position',fliplr(pos{1}),'Color',self.Colormap(labelval+1,:),'LabelTextColor',labelcolor,'UserData',true);
                    self.MaskOne=applyBackward(self.Rotate,BW);
                    self.SliceOne=self.CurrentIndex;
                else
                    set(self.ROITwo,'Position',fliplr(pos{1}),'Color',self.Colormap(labelval+1,:),'LabelTextColor',labelcolor,'UserData',true);
                    self.MaskTwo=applyBackward(self.Rotate,BW);
                    self.SliceTwo=self.CurrentIndex;
                end

                self.Value=labelval;

                validateStatus(self);

                if self.AutoSwap&&self.RegionOne.Value
                    self.RegionTwo.Value=1;
                end

                requestSliceAtLocation(self,self.CurrentIndex);

                refreshSummary(self);

            end

        end


        function TF=isValidLocation(self,pos)

            if any(isnan(pos))
                return;
            end

            click=getClickPosition(self,pos);

            slice=self.Data;
            labelval=slice(click(2),click(1));




            TF=labelval>0&&...
            (isempty(self.Value)||labelval==self.Value)&&...
            (isempty(self.SliceOne)||self.SliceOne~=self.CurrentIndex)&&...
            (isempty(self.SliceTwo)||self.SliceTwo~=self.CurrentIndex);

        end


        function click=getClickPosition(self,pos)

            slice=self.Data;
            click=round(pos);

            if any(isnan(pos))
                return;
            end

            sz=size(slice);

            if click(2)>sz(1)
                click(2)=sz(1);
            elseif click(2)<1
                click(2)=1;
            end

            if click(1)>sz(2)
                click(1)=sz(2);
            elseif click(1)<1
                click(1)=1;
            end

        end


        function updateButtonState(self)

            self.AutoSwap=false;

            if self.RegionOne.Value&&~isempty(self.SliceOne)
                self.CurrentIndex=self.SliceOne;
            end

            if self.RegionTwo.Value&&~isempty(self.SliceTwo)
                self.CurrentIndex=self.SliceTwo;
            end

            requestSliceAtLocation(self,self.CurrentIndex);

        end


        function deselectAll(self)

            self.MaskOne=logical.empty;
            self.MaskTwo=logical.empty;

            self.SliceOne=[];
            self.SliceTwo=[];

            self.Value=[];

            set(self.ROIOne,'Visible','off','UserData',false);
            set(self.ROITwo,'Visible','off','UserData',false);

            self.RegionOne.Value=1;

            requestSliceAtLocation(self,self.CurrentIndex);

            refreshSummary(self);

        end


        function validateStatus(self)

            if self.ROIOne.UserData&&self.ROITwo.UserData&&~isempty(self.Value)
                self.Ok.Enable='on';
            else
                self.Ok.Enable='off';
            end

        end


        function refreshSummary(self)

            if isempty(self.Value)
                val=0;
                color=[0,0,0];
            else
                val=self.Value;
                color=self.Colormap(val+1,:);
            end

            notify(self,'UpdateSummary',images.internal.app.segmenter.volume.events.SummaryUpdatedEventData(val,color));

        end


        function addButtons(self)

            buttonGroup=uibuttongroup(...
            'Parent',self.FigureHandle,...
            'BorderType','none',...
            'Position',[(self.Size(1)/2)-(2*self.ButtonSize(1))-(self.ButtonSpace/2),self.Size(2)-(2*self.ButtonSize(2))-(2*self.ButtonSpace),4*self.ButtonSize(1)+self.ButtonSpace,self.ButtonSize(2)],...
            'SelectionChangedFcn',@(~,~)updateButtonState(self));

            self.RegionOne=uitogglebutton('Parent',buttonGroup,...
            'Position',[1,1,2*self.ButtonSize(1),self.ButtonSize(2)],...
            'Tag','RegionOne',...
            'Value',1,...
            'Text',getString(message('images:segmenter:regionOne')));

            self.RegionTwo=uitogglebutton('Parent',buttonGroup,...
            'Position',[2*self.ButtonSize(1)+self.ButtonSpace,1,2*self.ButtonSize(1),self.ButtonSize(2)],...
            'Tag','RegionTwo',...
            'Value',0,...
            'Text',getString(message('images:segmenter:regionTwo')));

            self.DeselectAll=uibutton('Parent',self.FigureHandle,...
            'ButtonPushedFcn',@(~,~)deselectAll(self),...
            'Position',[self.ButtonSpace,self.ButtonSpace,self.ButtonSize],...
            'Tag','DeselectAll',...
            'Text',getString(message('images:segmenter:deselectAll')));

            self.SliceLabel=uilabel('Parent',self.FigureHandle,...
            'Position',[(2*self.ButtonSpace)+self.ButtonSize(1),self.ButtonSpace,self.Size(1)-(5*self.ButtonSpace)-(3*self.ButtonSize(1)),self.ButtonSize(2)],...
            'Tag','SliceLabel',...
            'Text','');

        end


        function addInstruction(self)

            self.Instructions=uilabel(...
            'Parent',self.FigureHandle,...
            'Position',[self.ButtonSpace,self.Size(2)-self.ButtonSize(2)-self.ButtonSpace,self.Size(1),self.ButtonSize(2)],...
            'FontSize',12,...
            'HorizontalAlignment','left',...
            'Tag','SelectionInstructions',...
            'Text',getString(message('images:segmenter:manualInterpInstructions')));

        end


        function createROIs(self,~)

            ax=get(self.Slice.ImageHandle,'Parent');

            self.ROIOne=images.roi.Freehand(...
            'InteractionsAllowed','none',...
            'Multiclick',true,...
            'FaceSelectable',false,...
            'Deletable',false,...
            'ContextMenu',[],...
            'Smoothing',0,...
            'Parent',ax,...
            'Visible','off',...
            'UserData',false,...
            'LabelLocation','center',...
            'LabelAlpha',0,...
            'LabelVisible','on',...
            'LabelTextColor',[0.94,0.94,0.94],...
            'FaceAlpha',1,...
            'Label',getString(message('images:segmenter:regionOne')));

            self.ROITwo=images.roi.Freehand(...
            'InteractionsAllowed','none',...
            'Multiclick',true,...
            'FaceSelectable',false,...
            'Deletable',false,...
            'ContextMenu',[],...
            'Smoothing',0,...
            'Parent',ax,...
            'Visible','off',...
            'UserData',false,...
            'LabelLocation','center',...
            'LabelAlpha',0,...
            'LabelVisible','on',...
            'LabelTextColor',[0.94,0.94,0.94],...
            'FaceAlpha',1,...
            'Label',getString(message('images:segmenter:regionTwo')));

        end


        function wireUpSlice(self)

            self.Slice=images.internal.app.segmenter.volume.display.Slice(self.FigureHandle,[1,(2*self.SliderHeight)+self.ButtonSize(2)+(2*self.ButtonSpace),self.Size(1),self.Size(2)-(2*self.SliderHeight)-(3*self.ButtonSize(2))-(4*self.ButtonSpace)]);

            addlistener(self.Slice,'ImageClicked',@(src,evt)reactToImageClick(self,evt.IntersectionPoint));

        end


        function wireUpSlider(self)

            self.Slider=images.internal.app.segmenter.volume.display.Slider(self.FigureHandle,[1,self.ButtonSize(2)+(2*self.ButtonSpace),self.Size(1),self.SliderHeight]);

            addlistener(self.Slider,'NextPressed',@(src,evt)requestSliceAtLocation(self,evt.Index));
            addlistener(self.Slider,'PreviousPressed',@(src,evt)requestSliceAtLocation(self,evt.Index));
            addlistener(self.Slider,'SliderMoving',@(src,evt)requestSliceAtLocation(self,evt.Index));

        end


        function wireUpSummary(self)

            self.Summary=images.internal.app.segmenter.volume.display.Summary(self.FigureHandle,[1,self.SliderHeight+self.ButtonSize(2)+(2*self.ButtonSpace),self.Size(1),self.SliderHeight]);
            self.Summary.BackgroundColor=[0.94,0.94,0.94];

            addlistener(self.Summary,'SummaryClicked',@(src,evt)requestSliceAtLocation(self,evt.Index));

        end


        function managePointer(self,src,evt)

            if(isa(evt.HitObject,'matlab.graphics.primitive.Image')||isa(evt.HitObject,'matlab.graphics.axis.Axes'))
                if strcmp(get(ancestor(evt.HitObject,'uipanel'),'Tag'),'SummaryPanel')
                    images.roi.setBackgroundPointer(src,'push');
                elseif isValidLocation(self,evt.IntersectionPoint)
                    images.roi.setBackgroundPointer(src,'crosshair');
                else
                    images.roi.setBackgroundPointer(src,'arrow');
                end
            else
                images.roi.setBackgroundPointer(src,'arrow');
            end

        end

    end

end
