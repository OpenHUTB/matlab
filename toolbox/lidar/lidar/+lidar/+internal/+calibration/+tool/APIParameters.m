classdef APIParameters<handle











    properties(GetAccess='public',SetAccess='private')


        CameraIntrinsics=struct('UseComputedOrLoadedFlag',true,...
        'Computed',[],...
        'Loaded',[],...
        'LoadStringForGenScript',[]);


        CheckerboardSquareSize=81;
        CheckerboardPadding=[0,0,0,0];
        CheckerboardSettingUnits="millimeters";
        MinCornerMetric=0.15;

        ROI=[0,10,-5,5,-2,2];
        ClusterThreshold=0.5;
        DimensionTolerance=0.05;
        RemoveGround=true;



        MinDataPairsForCalibration=4;


        InitialTransform=rigid3d();
    end

    methods(Access={?lidar.internal.calibration.tool.LCCModel,...
        ?lidar.internal.calibration.tool.LCCView,...
        ?lidar.internal.calibration.tool.LCCController,...
        ?lidar.internal.calibration.tool.SessionManager,...
        ?lidar.internal.calibration.tool.LCCDatapair,...
        ?matlab.unittest.TestCase})

        function setCheckerboardSquareSize(this,value)
            this.CheckerboardSquareSize=value;
        end

        function value=getCheckerboardSquareSize(this)
            value=this.CheckerboardSquareSize;
        end

        function value=getCheckerboardSquareSizeInMillimeters(this)
            value=getValueInMillimeters(this,this.CheckerboardSquareSize);
        end

        function setCheckerboardPadding(this,value)
            this.CheckerboardPadding=value;
        end

        function value=getCheckerboardPadding(this)
            value=this.CheckerboardPadding;
        end

        function value=getCheckerboardPaddingInMillimeters(this)
            value=getValueInMillimeters(this,this.CheckerboardPadding);
        end

        function value=getCheckerboardSettingUnits(this)
            value=this.CheckerboardSettingUnits;
        end

        function setCheckerboardSettingUnits(this,value)
            this.CheckerboardSettingUnits=value;
        end

        function value=getMinCornerMetric(this)
            value=this.MinCornerMetric;
        end

        function setMinCornerMetric(this,value)
            this.MinCornerMetric=value;
        end

        function value=getRemoveGround(this)
            value=this.RemoveGround;
        end

        function setRemoveGround(this,value)
            this.RemoveGround=value;
        end
        function value=getROI(this)
            value=this.ROI;
        end

        function value=getDimensionTolerance(this)
            value=this.DimensionTolerance;
        end

        function setDimensionTolerance(this,value)
            this.DimensionTolerance=value;
        end

        function value=getClusterThreshold(this)
            value=this.ClusterThreshold;
        end

        function setClusterThreshold(this,value)
            this.ClusterThreshold=value;
        end

        function value=getInitialTransform(this)
            value=this.InitialTransform;
        end


        function setROIFromCuboidPosition(this,value)





            roi=[value(1),value(1)+value(4),...
            value(2),value(2)+value(5),...
            value(3),value(3)+value(6)];

            this.ROI=roi;
        end

        function value=getCuboidPositionFromROI(this)

            roi=this.ROI;
            value=[roi(1),roi(3),roi(5),...
            roi(2)-roi(1),...
            roi(4)-roi(3),...
            roi(6)-roi(5)];
        end

        function setInitialTransform(this,value)
            if(isempty(value))
                return;
            end
            if(isa(value,'rigid3d')||isa(value,'affine3d'))
                this.InitialTransform=value;
            elseif(isfile(value))

                temp=load(value);

                fields=fieldnames(temp);
                this.InitialTransform=[];
                for i=1:numel(fields)
                    if(isa(getfield(temp,fields{i}),'rigid3d')||isa(getfield(temp,fields{i}),'affine3d'))
                        this.InitialTransform=getfield(temp,fields{i});
                        break;
                    end
                end
            end
        end

        function value=getCameraIntrinsics(this,computedOrLoadedFlag)
            if(~exist('computedOrLoadedFlag','var'))
                computedOrLoadedFlag=this.CameraIntrinsics.UseComputedOrLoadedFlag;
            end
            value=this.CameraIntrinsics.Computed;
            if(~computedOrLoadedFlag)
                value=this.CameraIntrinsics.Loaded;
            end
        end

        function value=getCameraIntrinsicsLoadStringForGenScript(this)
            value=this.CameraIntrinsics.LoadStringForGenScript;
        end

        function setIntrinsicsFlag(this,value)
            if(~isempty(value))
                this.CameraIntrinsics.UseComputedOrLoadedFlag=value;
            end
        end

        function successFlag=setCameraIntrinsics(this,value,workspaceVarOrFilename)
            successFlag=false;


            if(~exist('workspaceVarOrFilename','var'))

                this.CameraIntrinsics.Computed=value;
                return;
            end

            this.CameraIntrinsics.LoadStringForGenScript=workspaceVarOrFilename;

            if(isa(value,'cameraIntrinsics')||isa(value,'cameraParameters'))
                this.CameraIntrinsics.Loaded=value;
            elseif(isfile(value))

                temp=load(value);


                fields=fieldnames(temp);
                this.CameraIntrinsics.Loaded=[];
                for i=1:numel(fields)
                    if(isa(getfield(temp,fields{i}),'cameraIntrinsics')||isa(getfield(temp,fields{i}),'cameraParameters'))
                        this.CameraIntrinsics.Loaded=getfield(temp,fields{i});
                        break;
                    end
                end
            end
            if(isa(this.CameraIntrinsics.Loaded,'cameraParameters'))
                this.CameraIntrinsics.Loaded=this.CameraIntrinsics.Loaded.Intrinsics;
                if(~isempty(workspaceVarOrFilename))
                    this.CameraIntrinsics.LoadStringForGenScript=workspaceVarOrFilename.Intrinsics;
                end
            end
            successFlag=~isempty(this.CameraIntrinsics.Loaded);
        end

    end

    methods(Access='private')
        function value=getValueInMillimeters(this,value)
            switch(this.CheckerboardSettingUnits)
            case 'millimeters'
                scale=1;
            case 'centimeters'
                scale=10;
            case 'meters'
                scale=1000;
            case 'inches'
                scale=25.4;
            otherwise
                scale=1;
            end
            value=value*scale;
        end
    end

end
