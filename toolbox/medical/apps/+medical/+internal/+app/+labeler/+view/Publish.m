classdef Publish<handle




    properties(Access=protected)
NumSlices
DataFormat
    end

    properties

Panel
Grid

PublishButtonGroup
PublishFormatImages
PublishFormatPDF

SliceVolumeButtonGroup
SliceDirectionLabel
SliceDirection
SliceAllVolume
SliceRangeVolume
RangeStartVolume
RangeEndVolume

SliceImageButtonGroup
SliceAllImage
SliceRangeImage
RangeStartImage
RangeEndImage

Add3DScreenshot

PublishData

    end

    properties(Access=protected,Constant)

        PublishFormatPanelHeight=80;
        SliceVolumePanelHeight=125;
        SliceImagePanelHeight=80;
        PublishPanelHeight=20;
        RowSpacing=25;

    end

    events
PublishRequested
BringAppToFront
    end

    methods

        function self=Publish(hParent)

            self.create(hParent);

        end


        function setNumSlices(self,numSlicesTSC)




            self.NumSlices=numSlicesTSC;
            self.sanitizeSliceRange();

        end


        function setup(self,dataFormat)

            switch dataFormat

            case medical.internal.app.labeler.enums.DataFormat.Image
                self.Grid.RowHeight={10,self.PublishFormatPanelHeight,self.RowSpacing,0,self.SliceImagePanelHeight,self.RowSpacing,0,self.RowSpacing,self.PublishPanelHeight,'1x'};

            case medical.internal.app.labeler.enums.DataFormat.Volume
                self.Grid.RowHeight={10,self.PublishFormatPanelHeight,self.RowSpacing,self.SliceVolumePanelHeight,0,self.RowSpacing,20,self.RowSpacing,self.PublishPanelHeight,'1x'};

            end

            self.DataFormat=dataFormat;

        end


        function setIsCurrentDataOblique(self,TF)

            if TF
                directions=[...
                medical.internal.app.labeler.utils.ras2Direction(medical.internal.app.labeler.enums.SliceDirection.Coronal),...
                medical.internal.app.labeler.utils.ras2Direction(medical.internal.app.labeler.enums.SliceDirection.Sagittal),...
                medical.internal.app.labeler.utils.ras2Direction(medical.internal.app.labeler.enums.SliceDirection.Transverse)];
            else

                directions={...
                getString(message('medical:medicalLabeler:coronal')),...
                getString(message('medical:medicalLabeler:sagittal')),...
                getString(message('medical:medicalLabeler:transverse'))};

            end

            self.SliceDirection.Items=directions;

        end


        function enable3DScreenshot(self,TF)
            self.Add3DScreenshot.Enable=TF;
        end


        function enablePublish(self)
            self.PublishData.Enable=true;
        end


        function disablePublish(self)
            self.PublishData.Enable=false;
        end

    end

    methods(Access=protected)


        function create(self,hParent)

            radioButtonBorder=20;

            rowHeights={10,...
            self.PublishFormatPanelHeight,...
            self.RowSpacing,...
            self.SliceVolumePanelHeight,self.SliceImagePanelHeight,...
            self.RowSpacing,...
            20,...
            self.RowSpacing,...
            self.PublishPanelHeight,'1x'};
            self.Grid=uigridlayout('Parent',hParent,...
            'RowHeight',rowHeights,...
            'ColumnWidth',{'1x'},...
            'RowSpacing',0,...
            'Scrollable','on');


            self.PublishButtonGroup=uibuttongroup('Parent',self.Grid,...
            'Title',getString(message('medical:medicalLabeler:publishFormat')),...
            'FontWeight','bold',...
            'BorderType','none');
            self.PublishButtonGroup.Layout.Row=2;
            self.PublishButtonGroup.Layout.Column=1;

            pos=[radioButtonBorder,30,100,20];
            self.PublishFormatImages=uiradiobutton('Parent',self.PublishButtonGroup,...
            'Text',getString(message('medical:medicalLabeler:images')),...
            'Position',pos,...
            'HandleVisibility','off');

            pos=[radioButtonBorder,0,100,20];
            self.PublishFormatPDF=uiradiobutton('Parent',self.PublishButtonGroup,...
            'Text',getString(message('medical:medicalLabeler:pdf')),...
            'Position',pos,...
            'HandleVisibility','off');

            reportGenInstalled=license('test','MATLAB_Report_Gen');
            if~reportGenInstalled
                self.PublishFormatPDF.Enable='off';
                self.PublishFormatPDF.Text=getString(message('medical:medicalLabeler:pdfRptgen'));
            end


            panel=uipanel('Parent',self.Grid,...
            'Title',getString(message('medical:medicalLabeler:slices')),...
            'FontWeight','bold',...
            'BorderType','none',...
            'AutoResizeChildren','off');
            panel.Layout.Row=4;
            panel.Layout.Column=1;

            slicesGrid=uigridlayout('Parent',panel,...
            'RowHeight',{20,'1x'},...
            'ColumnWidth',{'fit',100,100},...
            'RowSpacing',15);
            slicesGrid.Padding(1)=radioButtonBorder;

            self.SliceDirectionLabel=uilabel('Parent',slicesGrid,...
            'Text',getString(message('medical:medicalLabeler:sliceDirection')),...
            'HandleVisibility','off');
            self.SliceDirectionLabel.Layout.Row=1;
            self.SliceDirectionLabel.Layout.Column=1;

            directions={...
            getString(message('medical:medicalLabeler:coronal'));...
            getString(message('medical:medicalLabeler:sagittal'));...
            getString(message('medical:medicalLabeler:transverse'))};
            itemsData={...
            medical.internal.app.labeler.enums.SliceDirection.Coronal,...
            medical.internal.app.labeler.enums.SliceDirection.Sagittal,...
            medical.internal.app.labeler.enums.SliceDirection.Transverse};
            self.SliceDirection=uidropdown('Parent',slicesGrid,...
            'Tag','PublishDirection',...
            'Items',directions,...
            'ItemsData',itemsData,...
            'ValueChangedFcn',@(src,evt)self.sanitizeSliceRange());
            self.SliceDirection.Layout.Row=1;
            self.SliceDirection.Layout.Column=2;

            self.SliceVolumeButtonGroup=uibuttongroup('Parent',slicesGrid,...
            'BorderType','none',...
            'AutoResizeChildren','off',...
            'SelectionChangedFcn',@(src,evt)self.sliceVolumeOptionChanged(evt));
            self.SliceVolumeButtonGroup.Layout.Row=2;
            self.SliceVolumeButtonGroup.Layout.Column=[1,3];

            pos=[1,30,100,20];
            self.SliceAllVolume=uiradiobutton('Parent',self.SliceVolumeButtonGroup,...
            'Text',getString(message('medical:medicalLabeler:allSlices')),...
            'Position',pos,...
            'HandleVisibility','off');

            pos=[1,5,100,20];
            self.SliceRangeVolume=uiradiobutton('Parent',self.SliceVolumeButtonGroup,...
            'Text',getString(message('medical:medicalLabeler:range')),...
            'Position',pos,...
            'HandleVisibility','off');

            rangeStartPos=[self.SliceRangeVolume.Position(1)+self.SliceRangeVolume.Position(3)+radioButtonBorder,...
            self.SliceRangeVolume.Position(2),...
            60,...
            self.SliceRangeVolume.Position(4)];
            self.RangeStartVolume=uispinner('Parent',self.SliceVolumeButtonGroup,...
            'Position',rangeStartPos,...
            'ValueChangedFcn',@(src,evt)self.rangeStartVolumeChanged(evt),...
            'Value',1,...
            'Visible','off');

            rangeEndPos=[rangeStartPos(1)+rangeStartPos(3)+radioButtonBorder,...
            rangeStartPos(2),...
            60,...
            rangeStartPos(4)];
            self.RangeEndVolume=uispinner('Parent',self.SliceVolumeButtonGroup,...
            'Position',rangeEndPos,...
            'Value',1,...
            'Visible','off');


            self.SliceImageButtonGroup=uibuttongroup('Parent',self.Grid,...
            'Title',getString(message('medical:medicalLabeler:slices')),...
            'FontWeight','bold',...
            'BorderType','none',...
            'SelectionChangedFcn',@(src,evt)self.sliceImageOptionChanged(evt));
            self.SliceImageButtonGroup.Layout.Row=5;
            self.SliceImageButtonGroup.Layout.Column=1;

            pos=[radioButtonBorder,30,100,20];
            self.SliceAllImage=uiradiobutton('Parent',self.SliceImageButtonGroup,...
            'Text',getString(message('medical:medicalLabeler:allSlices')),...
            'Position',pos,...
            'HandleVisibility','off');

            pos=[radioButtonBorder,5,100,20];
            self.SliceRangeImage=uiradiobutton('Parent',self.SliceImageButtonGroup,...
            'Text',getString(message('medical:medicalLabeler:range')),...
            'Position',pos,...
            'HandleVisibility','off');

            rangeStartPos=[self.SliceRangeImage.Position(1)+self.SliceRangeImage.Position(3)+radioButtonBorder,self.SliceRangeImage.Position(2),60,self.SliceRangeImage.Position(4)];
            self.RangeStartImage=uispinner('Parent',self.SliceImageButtonGroup,...
            'Position',rangeStartPos,...
            'ValueChangedFcn',@(src,evt)self.rangeStartImageChanged(evt),...
            'Value',1,...
            'Visible','off');

            rangeEndPos=[rangeStartPos(1)+rangeStartPos(3)+radioButtonBorder,rangeStartPos(2),60,rangeStartPos(4)];
            self.RangeEndImage=uispinner('Parent',self.SliceImageButtonGroup,...
            'Position',rangeEndPos,...
            'Value',1,...
            'Visible','off');


            self.Add3DScreenshot=uicheckbox('Parent',self.Grid,...
            'Value',true,...
            'Text',getString(message('medical:medicalLabeler:include3DScreenshot')),...
            'HandleVisibility','off');
            self.Add3DScreenshot.Layout.Row=7;
            self.Add3DScreenshot.Layout.Column=1;

            self.PublishData=uibutton('push',...
            'Tag','PublishData',...
            'Parent',self.Grid,...
            'Text',getString(message('medical:medicalLabeler:publish')),...
            'HandleVisibility','off',...
            'ButtonPushedFcn',@(src,evt)self.publishClicked());
            self.PublishData.Layout.Row=9;
            self.PublishData.Layout.Column=1;

        end


        function sanitizeSliceRange(self)

            switch self.DataFormat

            case medical.internal.app.labeler.enums.DataFormat.Image

                if self.RangeStartImage>self.NumSlices
                    self.RangeStartImage.Value=1;
                    self.RangeEndImage.Value=1;
                elseif self.RangeEndImage>self.NumSlices
                    self.RangeEndImage.Value=self.RangeStartImage.Value;
                end

                if self.NumSlices==1

                    self.SliceAllImage.Value=true;
                    self.SliceRangeImage.Enable=false;

                else

                    self.SliceRangeImage.Enable=true;
                    self.RangeStartImage.Limits=[1,self.NumSlices-1];
                    self.RangeEndImage.Limits=[self.RangeStartImage.Value,self.NumSlices];

                end

            case medical.internal.app.labeler.enums.DataFormat.Volume

                numSlices=self.getNumSlicesInCurrentDir();

                if self.RangeStartVolume>numSlices
                    self.RangeStartVolume.Value=1;
                    self.RangeEndVolume.Value=1;
                elseif self.RangeEndVolume>numSlices
                    self.RangeEndVolume.Value=self.RangeStartVolume.Value;
                end

                if numSlices==1

                    self.SliceAllImage.Value=true;
                    self.SliceRangeImage.Enable=false;

                else

                    self.SliceRangeImage.Enable=true;
                    self.RangeStartVolume.Limits=[1,numSlices-1];
                    self.RangeEndVolume.Limits=[self.RangeStartVolume.Value,numSlices];

                end

            end

        end


        function numSlices=getNumSlicesInCurrentDir(self)

            switch self.SliceDirection.Value
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                numSlices=self.NumSlices(1);

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                numSlices=self.NumSlices(3);

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                numSlices=self.NumSlices(2);
            end

        end


        function[rangeStart,rangeEnd]=getCurrentSliceRange(self)


            switch self.DataFormat
            case medical.internal.app.labeler.enums.DataFormat.Image
                numSlices=self.NumSlices;
                rangeStart=self.RangeStartImage.Value;
                rangeEnd=self.RangeEndImage.Value;
                publishAllSlices=self.SliceAllImage.Value;

            case medical.internal.app.labeler.enums.DataFormat.Volume
                numSlices=self.getNumSlicesInCurrentDir();
                rangeStart=self.RangeStartVolume.Value;
                rangeEnd=self.RangeEndVolume.Value;
                publishAllSlices=self.SliceAllVolume.Value;
            end

            if publishAllSlices
                rangeStart=1;
                rangeEnd=numSlices;
            end


        end

    end


    methods(Access=protected)


        function rangeStartImageChanged(self,evt)
            self.RangeEndImage.Limits(1)=evt.Value;
        end


        function rangeStartVolumeChanged(self,evt)
            self.RangeEndVolume.Limits(1)=evt.Value;
        end


        function sliceImageOptionChanged(self,evt)

            if evt.NewValue==self.SliceRangeImage
                self.RangeStartImage.Visible=true;
                self.RangeEndImage.Visible=true;
            else
                self.RangeStartImage.Visible=false;
                self.RangeEndImage.Visible=false;
            end

        end


        function sliceVolumeOptionChanged(self,evt)

            if evt.NewValue==self.SliceRangeVolume
                self.RangeStartVolume.Visible=true;
                self.RangeEndVolume.Visible=true;
            else
                self.RangeStartVolume.Visible=false;
                self.RangeEndVolume.Visible=false;
            end

        end


        function publishClicked(self)

            if self.PublishButtonGroup.SelectedObject==self.PublishFormatImages

                path=uigetdir();
                self.notify('BringAppToFront');

                if path==0
                    return
                end

                path=string(path);
                publishFormat=medical.internal.app.labeler.enums.PublishFormat.Images;

            elseif self.PublishButtonGroup.SelectedObject==self.PublishFormatPDF

                [file,path]=uiputfile({'*.pdf','PDF (*.pdf)'});
                self.notify('BringAppToFront');

                if file==0
                    return
                end

                path=string(fullfile(path,file));
                publishFormat=medical.internal.app.labeler.enums.PublishFormat.PDF;

            end

            [rangeStart,rangeEnd]=self.getCurrentSliceRange();

            evt=medical.internal.app.labeler.events.PublishEventData(path,publishFormat,rangeStart,rangeEnd);
            evt.Screenshot3D=false;

            if self.DataFormat==medical.internal.app.labeler.enums.DataFormat.Volume
                evt.SliceDirection=self.SliceDirection.Value;
                evt.Screenshot3D=self.Add3DScreenshot.Value;
            end

            self.notify('PublishRequested',evt);

        end

    end


end
