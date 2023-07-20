






classdef LVIORosbagFileSource<lidar.internal.lidarViewer.lidarViewerIO.LVIOSource

    properties(Constant)
        IOSourceName=getString(message('lidar:lidarViewer:Rosbag'))
    end

    properties(Access=private,Hidden)
ParentPanel
FileBrowserButton
FileBrowserEditBox
LoadSourceButton
NoteText
CancelButton
DescriptionText
ProgressBar
    end

    properties(Access=private,Hidden)
FileBrowserButtonPos
FileEditBoxPos
NoteTextPos
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

    properties(Constant,Access=private)
        ValidMessageTypes="sensor_msgs/PointCloud2";
        ValidSignalTypes=vision.labeler.loading.SignalType.PointCloud;
    end

    properties(Access=private)
BagSelect
ValidBagSelect
TopicSelectArray
TopicId
        ValidTopicNames={}
    end

    properties(Access=private)
PointCloudMessageTxtPos
PointCloudMessageDropDownPos
PointCloudMessageText
PointCloudMessageDropDown
PointCloudMessageWarningTxt
PointCloudMessageWarningTxtPos
    end




    methods
        function configureImportPanel(this,panel)

            vision.internal.requiresROSToolbox(mfilename);

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


            bottomPos=panelPos(4)*0.8;
            this.DescriptionTextPos=[this.MARGIN,bottomPos...
            ,panelPos(3)-2*this.MARGIN,22];


            fileEditBoxWidth=panelPos(3)-3*this.MARGIN-this.BROWSEBUTTONWIDTH;
            bottomPos=panelPos(4)*0.55;
            this.FileEditBoxPos=[this.MARGIN,bottomPos...
            ,fileEditBoxWidth,this.UICOMPONENTHEIGHT];


            this.FileBrowserButtonPos=[fileEditBoxWidth+2*this.MARGIN...
            ,bottomPos,this.BROWSEBUTTONWIDTH,this.UICOMPONENTHEIGHT];

            NoteTextHeight=45;


            this.NoteTextPos=[this.MARGIN,panelPos(4)*0.47-this.UICOMPONENTHEIGHT,...
            fileEditBoxWidth-this.MARGIN,NoteTextHeight];

            widgetHeight=25;
            ptCloudMsgTxtWidth=110;
            ptCloudMsgDropwDownWidth=100;
            bottomPos=panelPos(4)*0.1;


            this.PointCloudMessageTxtPos=[this.MARGIN,bottomPos,...
            ptCloudMsgTxtWidth,this.UICOMPONENTHEIGHT];


            this.PointCloudMessageDropDownPos=[this.MARGIN+ptCloudMsgTxtWidth,...
            bottomPos,ptCloudMsgDropwDownWidth,widgetHeight];

            warningMessagePos=2*this.MARGIN+ptCloudMsgTxtWidth+ptCloudMsgDropwDownWidth;
            this.PointCloudMessageWarningTxtPos=[warningMessagePos,...
            bottomPos,panelPos(3)-2*this.MARGIN-warningMessagePos,40];
        end


        function createUI(this)
            this.createDescriptionText();

            this.createFileBrowserEB();

            this.createFileBrowserButton();

            this.createRosbagNote();

            this.createPtCloudTopicsTextAndDropdown();
        end


        function createDescriptionText(this)
            this.DescriptionText=uilabel(...
            'Parent',this.ParentPanel,...
            'Position',this.DescriptionTextPos,...
            'Text',getString(message('lidar:lidarViewer:ImportDescROSBAG')));
        end


        function createFileBrowserEB(this)
            this.FileBrowserEditBox=uieditfield(...
            'Parent',this.ParentPanel,...
            'Position',this.FileEditBoxPos,...
            'ValueChangedFcn',@(~,~)filterMessages(this));
        end


        function createFileBrowserButton(this)
            this.FileBrowserButton=uibutton(...
            'Parent',this.ParentPanel,...
            'Position',this.FileBrowserButtonPos,...
            'Text',getString(message('lidar:lidarViewer:Browse')),...
            'ButtonPushedFcn',@(~,~)requestToBrowseFile(this));
        end


        function createRosbagNote(this)
            this.NoteText=uilabel('Parent',this.ParentPanel,...
            'Text',getString(message('lidar:lidarViewer:RosbagNote')),...
            'Position',this.NoteTextPos,...
            'HorizontalAlignment','left',...
            'WordWrap','on',...
            'Tag','noteText','FontSize',11);
        end


        function createPtCloudTopicsTextAndDropdown(this)
            this.PointCloudMessageText=uilabel('Parent',this.ParentPanel,...
            'Text',getString(message('lidar:lidarViewer:PointCloudTopics')),...
            'Position',this.PointCloudMessageTxtPos,...
            'HorizontalAlignment','left',...
            'Tag','pointCloudMessageText','WordWrap','on');

            availableMessages=this.ValidTopicNames;

            this.PointCloudMessageDropDown=uidropdown('Parent',this.ParentPanel,...
            'Items',availableMessages,...
            'Position',this.PointCloudMessageDropDownPos,...
            'ValueChangedFcn',@this.pointCloudMessageDropDownCallback,...
            'Tag','pointCloudMessagesList');
        end
    end




    methods
        function data=readData(this,index)


            data=this.createDataStruct();

            msg=readMessages(this.TopicSelectArray,index);
            msg=msg{1};

            xyz=readXYZ(msg);
            data.PointCloud=pointCloud(xyz);
            data.ScalarData.Name=this.Scalars;
            data.ScalarData.Value=[];
        end
    end




    methods
        function loadData(this,dataName,dataParams,dataPath)


            this.TimeVector=[];
            this.DataName=dataName;
            this.DataParams=dataParams;
            this.DataPath=dataPath;
            this.Scalars={};

            assert(~isempty(this.ValidTopicNames),...
            getString(message('lidar:lidarViewer:RosbagInvalidMessage')));

            this.filterTopics();
        end
    end





    methods(Access=private)

        function requestToBrowseFile(this)

            persistent cachedPath

            if isempty(cachedPath)
                cachedPath=pwd;
            end

            [fileName,pathName]=...
            uigetfile('*.bag','Choose a BAG file',cachedPath);


            this.bringToFront();
            hFig=ancestor(this.ParentPanel,'figure');
            figure(hFig);

            if~ischar(fileName)||~ischar(pathName)
                return;
            end

            this.FileBrowserEditBox.Value=...
            fullfile(pathName,fileName);
            cachedPath=pathName;

            this.showProgressInternal(true);
            this.filterMessages();
            this.showProgressInternal(false);
        end


        function pointCloudMessageDropDownCallback(this,~,~)
            this.TopicId=this.PointCloudMessageDropDown.Value;
        end
    end




    methods(Access=private)

        function loadSource(this)

            vision.internal.requiresROSToolbox(mfilename);

            this.BagSelect=this.FileReader;


            this.ValidBagSelect=select(this.BagSelect,'MessageType',...
            this.ValidMessageTypes);

            this.ValidTopicNames=this.ValidBagSelect.AvailableTopics.Properties.RowNames;

            if isempty(this.ValidTopicNames)
                this.PointCloudMessageWarningTxt=uilabel('Parent',this.ParentPanel,...
                'Text',getString(message('lidar:lidarViewer:RosbagInvalidMessage')),...
                'Position',this.PointCloudMessageWarningTxtPos,...
                'HorizontalAlignment','left',...
                'FontColor',[1,0,0],'WordWrap','on');
                return;
            else
                this.PointCloudMessageDropDown.Items=this.ValidTopicNames;
            end
        end


        function filterTopics(this)

            this.TopicSelectArray={};
            if isempty(this.TopicId)
                this.TopicId=1;
            end

            for idx=1:numel(this.ValidTopicNames)
                topicName=this.ValidTopicNames{this.TopicId};
                topicSelect=select(this.ValidBagSelect,'Topic',...
                topicName);

                this.TopicSelectArray=topicSelect;


                topicSelect=this.TopicSelectArray;
                timeStamps=topicSelect.MessageList.Time;
                durationTime=seconds(timeStamps-timeStamps(1));
                this.TimeVector=durationTime;
            end
        end


        function filterMessages(this)

            this.resetDropdownAndWarning();

            [dataPath,~,~]=getLoadPanelData(this);
            try
                this.FileReader=rosbag(dataPath);
            catch ME
                this.PointCloudMessageWarningTxt=uilabel('Parent',this.ParentPanel,...
                'Text',ME.message,...
                'Position',this.PointCloudMessageWarningTxtPos,...
                'HorizontalAlignment','left',...
                'FontColor',[1,0,0]);
                return;
            end
            this.loadSource();
        end


        function resetDropdownAndWarning(this)
            this.PointCloudMessageWarningTxt.Text='';
            this.PointCloudMessageDropDown.Items={};
        end


        function showProgressInternal(this,toOpen)


            if toOpen
                this.ProgressBar=uiprogressdlg(this.ParentPanel.Parent,...
                'Message','Loading Rosbag to filter valid point cloud messages'...
                ,'Title','Please Wait','Indeterminate','on');
            else
                close(this.ProgressBar);
            end
        end
    end




    methods(Static)
        function TF=hasTimeInfo()


            TF=true;
        end
    end
end