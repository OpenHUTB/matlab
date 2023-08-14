classdef Layout




    enumeration

Default
Grid2x2

FocusTransverse

FocusSagittal

FocusCoronal

FocusVolume

Image

DicomDatabase


    end

    methods




        function layout=getLayout(self,appLayout)

            layout=appLayout;

            if isempty(fieldnames(layout))

                screenToContainerRatio=0.8;
                [~,~,width,height]=imageslib.internal.app.utilities.ScreenUtilities.getInitialToolPosition(screenToContainerRatio);

                layout.majorVersion=2;
                layout.minorVersion=1;

                layout.toolstripCollapsed=false;
                layout.documentLayout.referenceWidth=width;
                layout.documentLayout.referenceHeight=height;

            end

            switch self

            case{medical.internal.app.labeler.view.Layout.Default,...
                medical.internal.app.labeler.view.Layout.Grid2x2}

                layout=self.getDefaultLayout(layout);

            case medical.internal.app.labeler.view.Layout.FocusVolume
                layout=self.getFocusVolumeLayout(layout);

            case medical.internal.app.labeler.view.Layout.FocusTransverse
                layout=self.getFocusTransverseLayout(layout);

            case medical.internal.app.labeler.view.Layout.FocusSagittal
                layout=self.getFocusSagittalLayout(layout);

            case medical.internal.app.labeler.view.Layout.FocusCoronal
                layout=self.getFocusCoronalLayout(layout);

            case medical.internal.app.labeler.view.Layout.Image
                layout=self.getImageLayout(layout);

            case medical.internal.app.labeler.view.Layout.DicomDatabase
                layout=self.getDicomDatabaseLayout(layout);

            end

        end

    end

    methods(Static,Access=private)

        function layout=getDefaultLayout(layout)

            layout.documentLayout.gridDimensions=struct('w',2,'h',2);
            layout.documentLayout.tileCount=4;
            layout.documentLayout.tileCoverage=[1,2;3,4];
            layout.documentLayout.emptyTileCount=0;

            layout.documentLayout.columnWeights=[0.5,0.5];
            layout.documentLayout.rowWeights=[0.5,0.5];
            layout.documentLayout.rowTop=[0;round(layout.documentLayout.referenceHeight/2);layout.documentLayout.referenceHeight];
            layout.documentLayout.columnLeft=[0;round(layout.documentLayout.referenceWidth/2);layout.documentLayout.referenceWidth];

            slicesDocGroupTag=char(medical.internal.app.labeler.enums.Tag.SlicesDocGroup);
            axialDocumentTag=char(medical.internal.app.labeler.enums.Tag.TransverseFigure);
            sagittalDocumentTag=char(medical.internal.app.labeler.enums.Tag.SagittalFigure);
            coronalDocumentTag=char(medical.internal.app.labeler.enums.Tag.CoronalFigure);

            volumeDocGroupTag=char(medical.internal.app.labeler.enums.Tag.VolumeDocGroup);
            volumeDocumentTag=char(medical.internal.app.labeler.enums.Tag.VolumeFigure);

            id=[slicesDocGroupTag,'_',axialDocumentTag];
            tile1=struct('children',struct('id',id),'showingChildId',id);

            id=[slicesDocGroupTag,'_',sagittalDocumentTag];
            tile2=struct('children',struct('id',id),'showingChildId',id);

            id=[slicesDocGroupTag,'_',coronalDocumentTag];
            tile3=struct('children',struct('id',id),'showingChildId',id);

            id=[volumeDocGroupTag,'_',volumeDocumentTag];
            tile4=struct('children',struct('id',id),'showingChildId',id);

            layout.documentLayout.tileOccupancy=[tile1;tile2;tile3;tile4];

        end

        function layout=getFocusVolumeLayout(layout)

            layout.documentLayout.gridDimensions=struct('w',2,'h',3);
            layout.documentLayout.tileCount=4;
            layout.documentLayout.tileCoverage=[1,2;1,3;1,4];
            layout.documentLayout.emptyTileCount=0;

            layout.documentLayout.columnWeights=[0.7,0.3];
            layout.documentLayout.rowWeights=[1/3,1/3,1/3];
            layout.documentLayout.rowTop=[0;round(layout.documentLayout.referenceHeight/3);round(layout.documentLayout.referenceHeight*2/3);layout.documentLayout.referenceHeight];
            layout.documentLayout.columnLeft=[0;round(layout.documentLayout.referenceWidth*0.7);layout.documentLayout.referenceWidth];

            slicesDocGroupTag=char(medical.internal.app.labeler.enums.Tag.SlicesDocGroup);
            axialDocumentTag=char(medical.internal.app.labeler.enums.Tag.TransverseFigure);
            sagittalDocumentTag=char(medical.internal.app.labeler.enums.Tag.SagittalFigure);
            coronalDocumentTag=char(medical.internal.app.labeler.enums.Tag.CoronalFigure);

            volumeDocGroupTag=char(medical.internal.app.labeler.enums.Tag.VolumeDocGroup);
            volumeDocumentTag=char(medical.internal.app.labeler.enums.Tag.VolumeFigure);

            id=[volumeDocGroupTag,'_',volumeDocumentTag];
            tile1=struct('children',struct('id',id),'showingChildId',id);

            id=[slicesDocGroupTag,'_',axialDocumentTag];
            tile2=struct('children',struct('id',id),'showingChildId',id);

            id=[slicesDocGroupTag,'_',coronalDocumentTag];
            tile3=struct('children',struct('id',id),'showingChildId',id);

            id=[slicesDocGroupTag,'_',sagittalDocumentTag];
            tile4=struct('children',struct('id',id),'showingChildId',id);

            layout.documentLayout.tileOccupancy=[tile1;tile2;tile3;tile4];

        end

        function layout=getFocusTransverseLayout(layout)

            layout.documentLayout.gridDimensions=struct('w',2,'h',3);
            layout.documentLayout.tileCount=4;
            layout.documentLayout.tileCoverage=[1,2;1,3;1,4];
            layout.documentLayout.emptyTileCount=0;

            layout.documentLayout.columnWeights=[0.7,0.3];
            layout.documentLayout.rowWeights=[1/3,1/3,1/3];
            layout.documentLayout.rowTop=[0;round(layout.documentLayout.referenceHeight/3);round(layout.documentLayout.referenceHeight*2/3);layout.documentLayout.referenceHeight];
            layout.documentLayout.columnLeft=[0;round(layout.documentLayout.referenceWidth*0.7);layout.documentLayout.referenceWidth];

            slicesDocGroupTag=char(medical.internal.app.labeler.enums.Tag.SlicesDocGroup);
            axialDocumentTag=char(medical.internal.app.labeler.enums.Tag.TransverseFigure);
            sagittalDocumentTag=char(medical.internal.app.labeler.enums.Tag.SagittalFigure);
            coronalDocumentTag=char(medical.internal.app.labeler.enums.Tag.CoronalFigure);

            volumeDocGroupTag=char(medical.internal.app.labeler.enums.Tag.VolumeDocGroup);
            volumeDocumentTag=char(medical.internal.app.labeler.enums.Tag.VolumeFigure);

            id=[slicesDocGroupTag,'_',axialDocumentTag];
            tile1=struct('children',struct('id',id),'showingChildId',id);

            id=[slicesDocGroupTag,'_',coronalDocumentTag];
            tile2=struct('children',struct('id',id),'showingChildId',id);

            id=[slicesDocGroupTag,'_',sagittalDocumentTag];
            tile3=struct('children',struct('id',id),'showingChildId',id);

            id=[volumeDocGroupTag,'_',volumeDocumentTag];
            tile4=struct('children',struct('id',id),'showingChildId',id);

            layout.documentLayout.tileOccupancy=[tile1;tile2;tile3;tile4];

        end

        function layout=getFocusCoronalLayout(layout)

            layout.documentLayout.gridDimensions=struct('w',2,'h',3);
            layout.documentLayout.tileCount=4;
            layout.documentLayout.tileCoverage=[1,2;1,3;1,4];
            layout.documentLayout.emptyTileCount=0;

            layout.documentLayout.columnWeights=[0.7,0.3];
            layout.documentLayout.rowWeights=[1/3,1/3,1/3];
            layout.documentLayout.rowTop=[0;round(layout.documentLayout.referenceHeight/3);round(layout.documentLayout.referenceHeight*2/3);layout.documentLayout.referenceHeight];
            layout.documentLayout.columnLeft=[0;round(layout.documentLayout.referenceWidth*0.7);layout.documentLayout.referenceWidth];

            slicesDocGroupTag=char(medical.internal.app.labeler.enums.Tag.SlicesDocGroup);
            axialDocumentTag=char(medical.internal.app.labeler.enums.Tag.TransverseFigure);
            sagittalDocumentTag=char(medical.internal.app.labeler.enums.Tag.SagittalFigure);
            coronalDocumentTag=char(medical.internal.app.labeler.enums.Tag.CoronalFigure);

            volumeDocGroupTag=char(medical.internal.app.labeler.enums.Tag.VolumeDocGroup);
            volumeDocumentTag=char(medical.internal.app.labeler.enums.Tag.VolumeFigure);

            id=[slicesDocGroupTag,'_',coronalDocumentTag];
            tile1=struct('children',struct('id',id),'showingChildId',id);

            id=[slicesDocGroupTag,'_',axialDocumentTag];
            tile2=struct('children',struct('id',id),'showingChildId',id);

            id=[slicesDocGroupTag,'_',sagittalDocumentTag];
            tile3=struct('children',struct('id',id),'showingChildId',id);

            id=[volumeDocGroupTag,'_',volumeDocumentTag];
            tile4=struct('children',struct('id',id),'showingChildId',id);

            layout.documentLayout.tileOccupancy=[tile1;tile2;tile3;tile4];

        end

        function layout=getFocusSagittalLayout(layout)

            layout.documentLayout.gridDimensions=struct('w',2,'h',3);
            layout.documentLayout.tileCount=4;
            layout.documentLayout.tileCoverage=[1,2;1,3;1,4];
            layout.documentLayout.emptyTileCount=0;

            layout.documentLayout.columnWeights=[0.7,0.3];
            layout.documentLayout.rowWeights=[1/3,1/3,1/3];
            layout.documentLayout.rowTop=[0;round(layout.documentLayout.referenceHeight/3);round(layout.documentLayout.referenceHeight*2/3);layout.documentLayout.referenceHeight];
            layout.documentLayout.columnLeft=[0;round(layout.documentLayout.referenceWidth*0.7);layout.documentLayout.referenceWidth];

            slicesDocGroupTag=char(medical.internal.app.labeler.enums.Tag.SlicesDocGroup);
            axialDocumentTag=char(medical.internal.app.labeler.enums.Tag.TransverseFigure);
            sagittalDocumentTag=char(medical.internal.app.labeler.enums.Tag.SagittalFigure);
            coronalDocumentTag=char(medical.internal.app.labeler.enums.Tag.CoronalFigure);

            volumeDocGroupTag=char(medical.internal.app.labeler.enums.Tag.VolumeDocGroup);
            volumeDocumentTag=char(medical.internal.app.labeler.enums.Tag.VolumeFigure);

            id=[slicesDocGroupTag,'_',sagittalDocumentTag];
            tile1=struct('children',struct('id',id),'showingChildId',id);

            id=[slicesDocGroupTag,'_',axialDocumentTag];
            tile2=struct('children',struct('id',id),'showingChildId',id);

            id=[slicesDocGroupTag,'_',coronalDocumentTag];
            tile3=struct('children',struct('id',id),'showingChildId',id);

            id=[volumeDocGroupTag,'_',volumeDocumentTag];
            tile4=struct('children',struct('id',id),'showingChildId',id);

            layout.documentLayout.tileOccupancy=[tile1;tile2;tile3;tile4];

        end

        function layout=getImageLayout(layout)




            layout.documentLayout.gridDimensions=struct('w',1,'h',1);
            layout.documentLayout.tileCount=1;
            layout.documentLayout.tileCoverage=1;
            layout.documentLayout.emptyTileCount=0;

            layout.documentLayout.columnWeights=1;
            layout.documentLayout.rowWeights=1;
            layout.documentLayout.rowTop=[0;layout.documentLayout.referenceHeight];
            layout.documentLayout.columnLeft=[0;layout.documentLayout.referenceWidth];

            dicomDBDocGroupTag=char(medical.internal.app.labeler.enums.Tag.SlicesDocGroup);
            dicomDBDocumentTag=char(medical.internal.app.labeler.enums.Tag.TransverseFigure);

            id=[dicomDBDocGroupTag,'_',dicomDBDocumentTag];
            tile1=struct('children',struct('id',id),'showingChildId',id);

            layout.documentLayout.tileOccupancy=tile1;

        end

        function layout=getDicomDatabaseLayout(layout)

            layout.documentLayout.gridDimensions=struct('w',1,'h',1);
            layout.documentLayout.tileCount=1;
            layout.documentLayout.tileCoverage=1;
            layout.documentLayout.emptyTileCount=0;

            layout.documentLayout.columnWeights=1;
            layout.documentLayout.rowWeights=1;
            layout.documentLayout.rowTop=[0;layout.documentLayout.referenceHeight];
            layout.documentLayout.columnLeft=[0;layout.documentLayout.referenceWidth];

            dicomDBDocGroupTag=char(medical.internal.app.labeler.enums.Tag.DicomDatabaseDocGroup);
            dicomDBDocumentTag=char(medical.internal.app.labeler.enums.Tag.DicomDatabaseFigure);

            id=[dicomDBDocGroupTag,'_',dicomDBDocumentTag];
            tile1=struct('children',struct('id',id),'showingChildId',id);

            layout.documentLayout.tileOccupancy=tile1;

        end

    end

end
