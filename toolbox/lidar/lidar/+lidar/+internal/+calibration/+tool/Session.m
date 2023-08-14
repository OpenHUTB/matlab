classdef Session<handle







    properties(SetAccess='private',GetAccess='public')

        Datapairs=[];
        NumDatapairs=0;
        AlgorithmParameters=[];
        WorldPoints=[];
        BoardSize=[];
        IsCalibrated=false;
        LidarToCameraTransform=[];
        CalibrationErrors=[];

        Version=1.1;
    end

    properties(SetAccess='private',Hidden,...
        GetAccess={?lidar.internal.calibration.tool.SessionManager,...
        ?matlab.unittest.TestCase})


        ViewState=[];
    end

    methods(Access={?lidar.internal.calibration.tool.SessionManager,...
        ?matlab.unittest.TestCase})
        function this=Session(lccModel,lccView)

            if(~isa(lccModel,'lidar.internal.calibration.tool.LCCModel')||...
                ~isa(lccView,'lidar.internal.calibration.tool.LCCView'))
                return;
            end
            if(isempty(lccModel.Datapairs))
                return;
            end

            this.Datapairs=lccModel.Datapairs;
            this.NumDatapairs=lccModel.NumDatapairs;
            this.AlgorithmParameters=lccModel.Params;
            this.WorldPoints=lccModel.WorldPoints;
            this.BoardSize=lccModel.BoardSize;
            this.IsCalibrated=lccModel.isCalibrationDone();
            this.LidarToCameraTransform=lccModel.LidarToCameraTransform;
            this.CalibrationErrors=lccModel.CalibrationErrors;

            this.ViewState=makeSessionData(lccView);
        end

        function isValid=validate(this)


            isValid=false;
            if(isempty(this.Datapairs))
                return;
            end
            for i=1:this.NumDatapairs
                if(~this.Datapairs(i).IsValidPair)
                    return;
                end
            end

            isValid=true;
        end
    end

    methods(Hidden)
        function s=struct(this)

            s.Datapairs=this.Datapairs;
            s.NumDatapairs=this.NumDatapairs;
            s.AlgorithmParameters=this.AlgorithmParameters;
            s.WorldPoints=this.WorldPoints;
            s.BoardSize=this.BoardSize;
            s.IsCalibrated=this.IsCalibrated;
            s.LidarToCameraTransform=this.LidarToCameraTransform;
            s.CalibrationErrors=this.CalibrationErrors;
            s.Version=this.Version;
        end
    end
end