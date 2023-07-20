






classdef LVIOLASFileSource<lidar.internal.lidarViewer.lidarViewerIO.LVIOSource

    properties(Constant)
        IOSourceName=getString(message('lidar:lidarViewer:LASFile'))
    end

    properties(Access=private,Hidden)
ParentPanel
FileBrowserButton
FileBrowserEditBox
DescriptionText
    end

    properties(Access=private,Hidden)
FileBrowserButtonPos
FileEditBoxPos
DescriptionTextPos
    end

    properties(Access=private)

ScalarVal
    end

    properties
FileReader
    end

    properties(Constant,Hidden)
        MARGIN=15;
        SPACING=40;
        UICOMPONENTHEIGHT=30;
        BROWSEBUTTONWIDTH=100
    end




    methods
        function configureImportPanel(this,panel)


            this.ParentPanel=panel;
            this.computePosition();
            this.createUI();
        end



        function[dataPath,dataParams,dataName]=getLoadPanelData(this)
            dataPath=this.FileBrowserEditBox.Value;

            dataParams=[];

            [~,folderName,~]=fileparts(this.FileBrowserEditBox.Value);
            dataName=this.getUniqueName(folderName);
        end
    end




    methods(Access=private)
        function computePosition(this)


            panelPos=this.ParentPanel.Position;


            bottomPos=panelPos(4)*0.55;
            this.DescriptionTextPos=[this.MARGIN,bottomPos...
            ,panelPos(3)-2*this.MARGIN,22];


            fileEditBoxWidth=panelPos(3)-this.BROWSEBUTTONWIDTH-3*this.MARGIN;
            bottomPos=bottomPos-this.SPACING;
            this.FileEditBoxPos=[this.MARGIN,bottomPos...
            ,fileEditBoxWidth,this.UICOMPONENTHEIGHT];


            this.FileBrowserButtonPos=[fileEditBoxWidth+2*this.MARGIN...
            ,bottomPos,this.BROWSEBUTTONWIDTH,this.UICOMPONENTHEIGHT];
        end


        function createUI(this)
            this.createDescriptionText();

            this.createFileBrowserEB();

            this.createFileBrowserButton();
        end


        function createDescriptionText(this)
            this.DescriptionText=uilabel(...
            'Parent',this.ParentPanel,...
            'Position',this.DescriptionTextPos,...
            'Text',getString(message('lidar:lidarViewer:ImportDescLAS')));
        end


        function createFileBrowserEB(this)
            this.FileBrowserEditBox=uieditfield(...
            'Parent',this.ParentPanel,...
            'Tag','fileBrowserEB',...
            'Position',this.FileEditBoxPos);
        end


        function createFileBrowserButton(this)
            this.FileBrowserButton=uibutton(...
            'Parent',this.ParentPanel,...
            'Position',this.FileBrowserButtonPos,...
            'Text',getString(message('lidar:lidarViewer:Browse')),...
            'Tag','fileBrowserBttn',...
            'ButtonPushedFcn',@(~,~)requestToBrowseFile(this));
        end


        function requestToBrowseFile(this)

            persistent cachedPath

            if isempty(cachedPath)
                cachedPath=pwd;
            end

            [fileName,pathName]=...
            uigetfile('*.las;*.laz','Choose a LAS/LAZ file',cachedPath);


            this.bringToFront();
            drawnow();
            hFig=ancestor(this.ParentPanel,'figure');
            figure(hFig);

            if~ischar(fileName)||~ischar(pathName)
                return;
            end

            this.FileBrowserEditBox.Value=...
            fullfile(pathName,fileName);
            cachedPath=pathName;
        end
    end




    methods
        function data=readData(this,~)

            data=this.createDataStruct();
            data.PointCloud=readPointCloud(this.FileReader);
            data.ScalarData.Name=this.Scalars;
            data.ScalarData.Value=this.ScalarVal;
        end
    end




    methods
        function loadData(this,dataName,dataParams,dataPath)

            this.FileReader=lasFileReader(dataPath);

            this.TimeVector=[];
            this.DataName=dataName;
            this.DataParams=dataParams;
            this.DataPath=dataPath;
            this.ScalarVal={};
            this.Scalars={};
            scalars=...
            {'Classification';'LaserReturn';'NearIR';'ScanAngle';'GPSTimeStamp'};
            scalarsNew={getString(message('lidar:lidarViewer:Classification'));...
            getString(message('lidar:lidarViewer:LaserReturn'));...
            getString(message('lidar:lidarViewer:NearIR'));...
            getString(message('lidar:lidarViewer:ScanAngle'));...
            getString(message('lidar:lidarViewer:GPSTimeStamp'))};



            for i=1:numel(scalars)
                [isPresent,scalarVal]=this.getScalarField...
                (this.FileReader,scalars{i});
                if isPresent
                    this.Scalars{end+1}=scalarsNew{i};
                    this.ScalarVal{end+1}=scalarVal;
                end
            end
        end
    end




    methods(Access=private,Static)
        function[isPresent,scalar]=getScalarField(souceObj,NVP)
            try
                [~,scalar]=readPointCloud(souceObj,"Attributes",NVP);
                scalar=scalar.(NVP);
                isPresent=true;

                if strcmp(NVP,'GPSTimeStamp')
                    switch scalar.Format
                    case 's'
                        scalar=seconds(scalar);
                    case 'h'
                        scalar=hours(scalar);
                    otherwise

                        scalar=[];
                    end
                end
            catch
                isPresent=false;
                scalar=[];
            end
        end
    end
end