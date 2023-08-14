






classdef(Sealed)LidarViewer<handle

    properties(SetAccess=private,GetAccess={?lidartest.apps.lidarViewer.LidarViewerAppTester,...
        ?LidarViewerPerformanceTester},Hidden,Transient)


        Model lidar.internal.lidarViewer.LVModel


        View lidar.internal.lidarViewer.LVView


        Controller lidar.internal.lidarViewer.LVController
    end

    methods



        function this=LidarViewer()


            this.View=lidar.internal.lidarViewer.LVView();
            this.Model=lidar.internal.lidarViewer.LVModel();
            this.Controller=lidar.internal.lidarViewer.LVController(this.View,this.Model);



            imageslib.internal.apputil.manageToolInstances('add','LidarViewer',this);
        end
    end

    methods(Static,Hidden,Access={?matlab.perftest.TestCase,...
        ?matlab.uitest.TestCase})

        function deleteAllTools()

            webWindowManagerInstance=matlab.internal.webwindowmanager.instance;
            if(isempty(webWindowManagerInstance))
                return;
            end


            imageslib.internal.apputil.manageToolInstances('deleteAll','LidarViewer');

            appTitle=getString(message('lidar:desktop:Tool_lidarViewer_Label'));
            list=[];


            for i=1:length(webWindowManagerInstance.windowList)
                if(~isempty(strfind(webWindowManagerInstance.windowList(i).Title,appTitle)))
                    list=[list,i];%#ok<AGROW>
                end
            end


            if(~isempty(list))
                delete(webWindowManagerInstance.windowList(list));
            end
        end
    end

    methods(Access=?matlab.perftest.TestCase,Hidden)

        function loadSource(this,srcObj,info)





            this.Controller.loadSource(srcObj,info);
        end

        function goToNextFrame(this)

            this.Controller.goToNextFrame();
        end

        function playOrPauseData(this)


            this.Controller.playOrPauseData();
        end

        function viewClusters(this,method,varargin)


            DistanceThreshold=0;
            AngleThreshold=0;
            MinDistance=0;
            NumClusters=0;

            switch method
            case 'segmentLidarData'
                DistanceThreshold=varargin{1};
                AngleThreshold=varargin{2};

            case 'pcsegdist'
                MinDistance=varargin{1};

            case 'imsegkmeans'
                NumClusters=varargin{1};
            end

            eventData=lidar.internal.lidarViewer.events.LidarClusterEventData(...
            true,method,DistanceThreshold,AngleThreshold,...
            MinDistance,NumClusters);

            this.Controller.viewClusters(eventData);
        end

        function enterEditMode(this)

            this.Controller.enterEditTab();
        end

        function exitEditMode(this,varargin)

            acceptEdits=false;
            if nargin>1
                acceptEdits=varargin{1};
            end
            this.Controller.exitEditTab(acceptEdits);
        end

        function exportData(this,destinationFolder,varargin)




            if nargin>2
                toExport=varargin{2};
            else
                toExport=1;
            end
            this.Controller.exportData(destinationFolder,toExport);
        end
    end

    methods(Access=?lidartest.apps.lidarViewer.LidarViewerAppTester,Hidden)

        function createAngleTool(this,pos,axesHandle)


            this.Controller.createAngleTool(pos,axesHandle);
        end
    end
end