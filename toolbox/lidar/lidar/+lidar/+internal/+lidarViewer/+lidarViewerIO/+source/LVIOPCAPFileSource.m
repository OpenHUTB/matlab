






classdef LVIOPCAPFileSource<lidar.internal.lidarViewer.lidarViewerIO.LVIOSource

    properties(Constant)
        IOSourceName=getString(message('lidar:lidarViewer:PCAP'))
    end

    properties(Access=private,Hidden)
ParentPanel
FileBrowserButton
FileBrowserEditBox
DeviceModelText
DeviceModelDropDown
CalibrationFileText
CalibrationFileBrowserEditBox
CalibrationFileBrowseButton
DescriptionText
    end

    properties(Access=private,Hidden)
FileBrowserButtonPos
FileEditBoxPos
DeviceModelTextPos
DeviceModelDropDownPos
CalibrationFileTextPos
CalibrationFileBrowserEditBoxPos
CalibrationFileBrowseButtonPos
DescriptionTextPos
    end

    properties
FileReader
    end

    properties(Constant,Hidden)
        MARGIN=15;
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

            dataParams=struct('DeviceModel',this.DeviceModelDropDown.Value,...
            'CalibrationFile',this.CalibrationFileBrowserEditBox.Value);

            [~,fileName,~]=fileparts(this.FileBrowserEditBox.Value);
            dataName=this.getUniqueName(fileName);
        end
    end




    methods(Access=private)
        function computePosition(this)


            panelPos=this.ParentPanel.Position;
            spacing=panelPos(4)*0.2;


            bottomPos=panelPos(4)*0.84;
            this.DescriptionTextPos=[this.MARGIN,bottomPos...
            ,panelPos(3)-2*this.MARGIN,this.UICOMPONENTHEIGHT];


            fileEditBoxWidth=panelPos(3)-this.BROWSEBUTTONWIDTH-3*this.MARGIN;
            bottomPos=bottomPos-spacing;
            this.FileEditBoxPos=[this.MARGIN,bottomPos...
            ,fileEditBoxWidth,this.UICOMPONENTHEIGHT];


            this.FileBrowserButtonPos=[fileEditBoxWidth+2*this.MARGIN...
            ,bottomPos,this.BROWSEBUTTONWIDTH,this.UICOMPONENTHEIGHT];


            bottomPos=bottomPos-spacing;
            this.DeviceModelTextPos=[this.MARGIN...
            ,bottomPos,panelPos(3)*0.15,this.UICOMPONENTHEIGHT];


            this.DeviceModelDropDownPos=[this.MARGIN*1.5+panelPos(3)*0.15...
            ,bottomPos,this.BROWSEBUTTONWIDTH,this.UICOMPONENTHEIGHT];


            bottomPos=bottomPos-spacing;
            this.CalibrationFileTextPos=[this.MARGIN,bottomPos...
            ,fileEditBoxWidth,this.UICOMPONENTHEIGHT];


            bottomPos=bottomPos-spacing;
            this.CalibrationFileBrowserEditBoxPos=[this.MARGIN,bottomPos...
            ,fileEditBoxWidth,this.UICOMPONENTHEIGHT];


            this.CalibrationFileBrowseButtonPos=[this.MARGIN*2+fileEditBoxWidth...
            ,bottomPos,this.BROWSEBUTTONWIDTH,this.UICOMPONENTHEIGHT];
        end


        function createUI(this)
            this.createDescriptionText();

            this.createFileBrowserEB();
            this.createFileBrowserButton();

            this.createDeviceModelText();
            this.createDeviceModelDropDown();

            this.createCalibrationFileText();
            this.createCalibrationFileBrowserEB();
            this.createCalibrationFileBrowserButton();
        end


        function createDescriptionText(this)
            this.DescriptionText=uilabel(...
            'Parent',this.ParentPanel,...
            'Position',this.DescriptionTextPos,...
            'Text',getString(message('lidar:lidarViewer:ImportDescPCAP')));
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


        function createDeviceModelText(this)
            this.DeviceModelText=uilabel('Parent',this.ParentPanel,...
            'Text',getString(message('lidar:lidarViewer:DeviceModel')),...
            'Position',this.DeviceModelTextPos,...
            'HorizontalAlignment','left',...
            'Tag','deviceModelText','WordWrap','on');
        end


        function createDeviceModelDropDown(this)

            validDeviceModels=["VLP16","PuckLITE","PuckHiRes",...
            "VLP32C","HDL32E","HDL64E"];

            this.DeviceModelDropDown=uidropdown(...
            'Parent',this.ParentPanel,...
            'Position',this.DeviceModelDropDownPos,...
            'Items',validDeviceModels,...
            'Tag','deviceModelDD',...
            'ValueChangedFcn',@(~,~)deviceModelDropDownCB(this));


        end


        function createCalibrationFileText(this)
            this.CalibrationFileText=uilabel('Parent',this.ParentPanel,...
            'Text',getString(message('lidar:lidarViewer:ImportCalibText')),...
            'Position',this.CalibrationFileTextPos,...
            'HorizontalAlignment','left',...
            'Tag','calibrationFileText','WordWrap','on');
        end


        function createCalibrationFileBrowserEB(this)
            calibFileName=fullfile(matlabroot,'toolbox','shared',...
            'pointclouds','utilities',...
            'velodyneFileReaderConfiguration','VLP16.xml');

            this.CalibrationFileBrowserEditBox=uieditfield(...
            'Parent',this.ParentPanel,...
            'Position',this.CalibrationFileBrowserEditBoxPos,...
            'Tag','calibfileEB',...
            'Value',calibFileName);
        end


        function createCalibrationFileBrowserButton(this)
            this.CalibrationFileBrowseButton=uibutton(...
            'Parent',this.ParentPanel,...
            'Position',this.CalibrationFileBrowseButtonPos,...
            'Text',getString(message('lidar:lidarViewer:Browse')),...
            'Tag','calibFileBrowseBttn',...
            'ButtonPushedFcn',@(~,~)calibBrowseButtonCB(this));
        end


        function requestToBrowseFile(this)

            persistent cachedPath

            if isempty(cachedPath)
                cachedPath=pwd;
            end

            [fileName,pathName]=...
            uigetfile('*.pcap','Choose a Velodyne Lidar file',cachedPath);


            this.bringToFront();
            hFig=ancestor(this.ParentPanel,'figure');
            figure(hFig);

            if~ischar(fileName)||~ischar(pathName)
                return;
            end

            this.FileBrowserEditBox.Value=...
            fullfile(pathName,fileName);
            cachedPath=pathName;
        end


        function calibBrowseButtonCB(this)

            [fileName,pathName]=...
            uigetfile('.xml','Choose a calibration file');

            if~ischar(fileName)||~ischar(pathName)
                return;
            end

            this.CalibrationFileBrowserEditBox.Value=...
            fullfile(pathName,fileName);
        end


        function deviceModelDropDownCB(this)
            deviceModel=this.DeviceModelDropDown.Value;
            fileName=strcat(deviceModel,'.xml');

            calibFileName=fullfile(matlabroot,'toolbox','shared',...
            'pointclouds','utilities',...
            'velodyneFileReaderConfiguration',fileName);

            this.CalibrationFileBrowserEditBox.Value=...
            calibFileName;
        end
    end




    methods
        function data=readData(this,index)

            data=this.createDataStruct();

            ptCld=readFrame(this.FileReader,index);
            data.PointCloud=ptCld;
            data.ScalarData.Name=this.Scalars;
            scalars={};count=ptCld.Count;
            scalars{end+1}=ptCld.RangeData(1:count)';
            scalars{end+1}=ptCld.RangeData(count*2+1:end)';
            scalars{end+1}=ptCld.RangeData(count+1:count*2)';
            data.ScalarData.Value=scalars;
        end
    end




    methods
        function loadData(this,dataName,dataParams,dataPath)

            deviceModel=dataParams.DeviceModel;
            calibrationFile=dataParams.CalibrationFile;

            this.FileReader=velodyneFileReader(dataPath,deviceModel,...
            'CalibrationFile',calibrationFile);

            this.TimeVector=(this.FileReader.Timestamps-this.FileReader.Timestamps(1))';
            this.DataName=dataName;
            this.DataParams=dataParams;
            this.DataPath=dataPath;
            this.Scalars={getString(message('lidar:lidarViewer:ColormapValueRange'));...
            getString(message('lidar:lidarViewer:ColormapValueAzimuth'));...
            getString(message('lidar:lidarViewer:ColormapValueElevation'))};
        end
    end




    methods(Static)
        function TF=hasTimeInfo()


            TF=true;
        end
    end
end