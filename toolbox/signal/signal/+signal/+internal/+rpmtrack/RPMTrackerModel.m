classdef RPMTrackerModel<handle

    properties(Access={...
        ?matlab.unittest.TestCase,...
        ?signal.internal.rpmtrack.RPMTrackerController})

Map
MapTimeVector
MapFrequencyVector
MapPower


DataVector
IsSingle
TimeVector
Fs


Order
RidgePoint
Method
FrequencyResolution
ReferenceENBW
PowerPenalty
FrequencyPenalty
StartTime
EndTime


EstimatedRPM
OutputTimeVector
    end

    methods
        function this=RPMTrackerModel(Sx,Fx,Tx,Px,rpm,tout,opts)

            this.Map=Sx;
            this.MapTimeVector=Tx+opts.TimeVector(1);
            this.MapFrequencyVector=Fx;
            this.MapPower=Px;

            if~isempty(rpm)
                if opts.IsTimeTable
                    this.EstimatedRPM=rpm{:,:};
                    this.OutputTimeVector=seconds(tout);
                else
                    this.EstimatedRPM=rpm;
                    this.OutputTimeVector=tout;
                end
            end

            this.DataVector=opts.DataVector;
            this.IsSingle=opts.IsSingle;
            this.TimeVector=opts.TimeVector;
            this.Fs=opts.Fs;
            this.Order=opts.Order;
            this.RidgePoint=opts.SortedPoints;
            this.Method=opts.Method;
            this.FrequencyResolution=opts.FrequencyResolution;
            this.ReferenceENBW=opts.ReferenceEquivalentNoiseBandwidth;
            this.PowerPenalty=opts.PowerPenalty;
            this.FrequencyPenalty=opts.FrequencyPenalty;
            this.StartTime=opts.StartTime;
            this.EndTime=opts.EndTime;
        end

    end

    methods(Access={?signal.internal.rpmtrack.RPMTrackerController},Hidden)
        function computeMap(this)

            opts.DataVector=this.DataVector;
            opts.Fs=this.Fs;

            opts.Method=this.Method;
            opts.FrequencyResolution=this.FrequencyResolution;
            winLen=ceil(this.ReferenceENBW*this.Fs/this.FrequencyResolution);
            win=kaiser(winLen,20);
            opts.Window=win;


            [Sx,Fx,Tx,Px]=signal.internal.rpmtrack.computeMap(opts);

            this.MapPower=Px;
            this.Map=Sx;
            this.MapFrequencyVector=Fx;
            this.MapTimeVector=Tx+this.TimeVector(1);
        end

        function computeRPM(this)


            Sx=this.Map;
            Fx=this.MapFrequencyVector;
            Tx=this.MapTimeVector-this.TimeVector(1);
            Px=this.MapPower;
            opts.Fs=this.Fs;
            opts.Order=this.Order;
            opts.SortedPoints=this.RidgePoint;
            opts.PowerPenalty=this.PowerPenalty;
            opts.FrequencyPenalty=this.FrequencyPenalty;
            opts.TimeVector=this.TimeVector;
            opts.StartTime=this.StartTime;
            opts.EndTime=this.EndTime;
            opts.Method=this.Method;
            opts.IsSingle=this.IsSingle;
            opts.DataVector=this.DataVector;
            opts.FrequencyResolution=this.FrequencyResolution;


            [rpm,tOut]=signal.internal.rpmtrack.computeRPM(...
            Sx,Fx,Tx,Px,opts);


            this.EstimatedRPM=rpm;
            this.OutputTimeVector=tOut;
        end
    end
end
