









classdef(Abstract)EditAlgorithm<handle

    properties(Abstract,Constant)

EditName



Icon



Description
    end

    properties(Access=protected)

        SPACING=15


        UNITHEIGHT=22

    end

    properties





PointCloud
    end

    properties(Access=private)

EditPanel


        OkButton matlab.ui.control.Button


        CancelButton matlab.ui.control.Button


        ApplyAllFrames matlab.ui.control.CheckBox


Default


        IsDisabled=false;


        ApplyAllFramesValue=false;


        IsTemporal=false
    end

    events




PointCloudChanging




PointCloudChanged
    end

    methods

        function setUpEditOperation(this,varargin)

            this.PointCloud=varargin{1};
        end


        function[ptCldOut,selectedFrames]=doProcess(this,ptCldIn,params)



            selectedFrames=[];
            if~this.IsTemporal
                ptCldOut=this.applyEdits(ptCldIn,params);
            else
                [ptCldOut,selectedFrames]=this.applyEdits(ptCldIn,params);
            end
        end


        function configurePanel(this,panel,isTemporal)


            this.IsTemporal=isTemporal;
            this.IsDisabled=false;
            this.EditPanel=panel;

            algoGrid=panel.UserData{1};
            algoGrid.Scrollable='on';
            delete(algoGrid.Children);

            this.setUpAlgorithmConfigurePanel(algoGrid);
            scroll(algoGrid,'bottom');

            bottomGrid=panel.UserData{2};
            delete(bottomGrid.Children);
            this.addOkCancelButton(bottomGrid,algoGrid);

            drawnow();



            evt=this.createEventData(false,true);
            notify(this,'PointCloudChanging',evt);
        end
    end




    methods(Abstract,Static)
        ptCldOut=applyEdits(ptCldIn,parameters)















    end




    methods(Abstract)
        params=getCurrentParams(this)
















        setUpAlgorithmConfigurePanel(this,panel)














    end




    methods(Access=protected)
        function addOkCancelButton(this,grid,algoGrid)




            this.OkButton=uibutton('Parent',grid,'Text',...
            getString(message('MATLAB:uistring:popupdialogs:OK')),...
            'ButtonPushedFcn',@(~,~)OKClicked(this,algoGrid));
            this.OkButton.Layout.Row=3;
            this.OkButton.Layout.Column=1;



            this.OkButton.Enable=~this.IsDisabled;



            this.CancelButton=uibutton('Parent',grid,'Text',...
            getString(message('MATLAB:uistring:popupdialogs:Cancel')),...
            'ButtonPushedFcn',@(~,~)CancelClicked(this,algoGrid));
            this.CancelButton.Layout.Row=3;
            this.CancelButton.Layout.Column=3;






            if numel(algoGrid.Children)>2

                this.Default=uibutton('Parent',grid,'Text',...
                getString(message('lidar:lidarViewer:Default')),...
                'Tooltip',getString(message('lidar:lidarViewer:DefaultTooltip')),...
                'ButtonPushedFcn',@(~,~)defaultClicked(this,grid));
                this.Default.Layout.Row=1;
                this.Default.Layout.Column=1;
            end




            if~this.IsTemporal
                this.ApplyAllFrames=uicheckbox('Parent',grid,'Text',...
                getString(message('lidar:lidarViewer:ApplyAllFrames')),...
                'Tooltip',getString(message('lidar:lidarViewer:ApplyAllFramesTooltip')));
                this.ApplyAllFrames.Layout.Row=2;
                this.ApplyAllFrames.Layout.Column=[1,3];
            end

        end



        function setOkCancelButtonPos(this)


            panel=this.OkButton.Parent;
            bottomPos=this.SPACING;
            panelWidth=panel.Position(3);


            this.OkButton.Position=[panelWidth*0.1,bottomPos,panelWidth*0.35,22];
            this.CancelButton.Position=[panelWidth*0.55,bottomPos,panelWidth*0.35,22];


            if~this.IsTemporal
                bottomPos=bottomPos+22+this.SPACING;


                this.ApplyAllFrames.Position=[panelWidth/4,bottomPos,panelWidth/2,22];
            end

            bottomPos=bottomPos+22+this.SPACING;
            try
                this.Default.Position=[this.SPACING,bottomPos,panelWidth*0.3,22];
            catch

            end
        end



        function evt=createEventData(this,isOkButton,isResize)







            if nargin==1
                isOkButton=false;
                isResize=false;

            end


            parameters=this.getCurrentParams();
            parameters.IsClass=true;

            if isOkButton&&~this.IsTemporal

                toApplyOnAllFrames=this.ApplyAllFrames.Value;
            else

                toApplyOnAllFrames=false;
            end


            evt=lidar.internal.lidarViewer.events.EditParameterChangeEventData(parameters,...
            this.EditName,isOkButton,this.IsTemporal,this.PointCloud,toApplyOnAllFrames);

            if~isResize



                if this.IsDisabled&&~this.OkButton.Enable
                    this.OkButton.Enable=true;
                    this.IsDisabled=false;
                end
            end
        end
    end





    methods(Access=protected)

        function OKClicked(this,~)





            this.OkButton.Enable='off';
            this.IsDisabled=1;

            evt=this.createEventData(true,true);
            notify(this,'PointCloudChanged',evt);
        end


        function CancelClicked(this,~)





            evt=this.createEventData(false,false);
            notify(this,'PointCloudChanged',evt);
            this.ApplyAllFramesValue=false;
        end


        function defaultClicked(this,~)


            this.setUpEditOperation(this.PointCloud,false);

            this.IsDisabled=false;
            this.configurePanel(this.EditPanel,this.IsTemporal);
        end


        function applyAllFramesChanged(this)


            this.ApplyAllFramesValue=this.ApplyAllFrames.Value;
        end
    end
end


