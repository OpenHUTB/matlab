classdef SnapshotDialog<images.internal.app.utilities.OkCancelDialog




    properties

        SelectedViews=string.empty();

FilenamePrefix

    end

    properties(SetAccess=private,GetAccess=?uitest.factory.Tester)

PrefixEditfield

Axial
Coronal
Sagittal
Volume

Image

Screenshots

    end

    methods

        function self=SnapshotDialog(loc,sliceNames)

            self=self@images.internal.app.utilities.OkCancelDialog(loc,getString(message('medical:medicalLabeler:saveSnapshot')));
            self.Size=[300,175];

            self.create(sliceNames);

        end

        function create(self,sliceNames)

            create@images.internal.app.utilities.OkCancelDialog(self);

            self.layoutDialog(sliceNames);

        end

    end

    methods(Access=protected)

        function okClicked(self)


            [filename,path]=uiputfile("*.png",getString(message('medical:medicalLabeler:saveSnapshot')));
            if filename==0
                return
            end
            self.FilenamePrefix=fullfile(path,filename);


            if self.Axial.Value
                self.SelectedViews(end+1)="Axial";
            end
            if self.Coronal.Value
                self.SelectedViews(end+1)="Coronal";
            end
            if self.Sagittal.Value
                self.SelectedViews(end+1)="Sagittal";
            end
            if self.Volume.Value
                self.SelectedViews(end+1)="Volume";
            end


            self.Canceled=false;
            close(self);

        end

        function layoutDialog(self,sliceNames)

            border=5;
            topBorder=10;

            bottomStart=self.Ok.Position(2)+self.Ok.Position(4)+border;

            pos=[border,...
            bottomStart,...
            self.FigureHandle.Position(3)-2*border,...
            self.FigureHandle.Position(4)-bottomStart-topBorder];
            panel=uipanel('Parent',self.FigureHandle,...
            'Position',pos,...
            'BorderType','none',...
            'HandleVisibility','off');

            grid=uigridlayout('Parent',panel,...
            'RowHeight',{0,0,20,20,20,20},...
            'ColumnWidth',{'1x'},...
            'Padding',5,...
            'RowSpacing',10,...
            'ColumnSpacing',10);


            self.Axial=uicheckbox('Parent',grid,...
            'Text',sliceNames(1),...
            'Value',1,...
            'HandleVisibility','off');
            self.Axial.Layout.Row=3;
            self.Axial.Layout.Column=1;

            self.Coronal=uicheckbox('Parent',grid,...
            'Text',sliceNames(2),...
            'Value',1,...
            'HandleVisibility','off');
            self.Coronal.Layout.Row=4;
            self.Coronal.Layout.Column=1;

            self.Sagittal=uicheckbox('Parent',grid,...
            'Text',sliceNames(3),...
            'Value',1,...
            'HandleVisibility','off');
            self.Sagittal.Layout.Row=5;
            self.Sagittal.Layout.Column=1;

            self.Volume=uicheckbox('Parent',grid,...
            'Text',getString(message('medical:medicalLabeler:volume3D')),...
            'Value',1,...
            'HandleVisibility','off');
            self.Volume.Layout.Row=6;
            self.Volume.Layout.Column=1;


            self.Ok.Text=getString(message('medical:medicalLabeler:save'));


        end

    end

end