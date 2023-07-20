classdef DriveCycles<handle

















































    properties
dt
StopSpeedTh
OperationModeBoundaries
UrbanRatioRange
RuralRatioRange
MotorwayRatioRange
MotorwayUsualMaxSpeed
MotorwayAbsoluteSpeedTimeRatio
MotorwayAbsoluteMaxSpeed
UrbanAverageSpeedRange
UrbanStopRatioRange
UrbanMinStopTime
UrbanMinStopCount
MotorwayUsualMinSpeed
MotorwayUsualMinSpeedTime
TripDurationRange
UrbanMinDistance
RuralMinDistance
MotorwayMinDistance
RuralAverageSpeedRange
MotorwayAverageSpeedRange
VA95VelocityThreshold
VA95BoundarySpeedCoeff1
VA95BoundaryBias1
VA95BoundarySpeedCoeff2
VA95BoundaryBias2
RPAVelocityThreshold
RPABoundarySpeedCoeff
RPABoundaryBias
RPALowerBound
ShapeParameter
SmoothingMethod
SmoothingWindowLength
NTrips
NumberOfIterations
OutputFolder
Constraints
ConstraintsValues
Data
    end

    methods

        function generateDriveCycles(obj)

            obj.Constraints=RDE.functions.getConstraintHandles();

            if~exist(obj.OutputFolder,'dir')&&~isempty(obj.OutputFolder)
                mkdir(obj.OutputFolder)
            end

            for k=1:obj.NTrips
                [obj.Data{k},obj.ConstraintsValues{k}]=RDE.functions.createValidTrip(obj,obj.Constraints);
                p=fullfile(obj.OutputFolder,sprintf('drive_cycle_%i.csv',k));
                writetimetable(obj.Data{k},p);
            end
        end

        function openParameterList(~)
            winopen([matlabroot,filesep,'toolbox',filesep,'autoblks'...
            ,filesep,'autoblksutilities',filesep,'+RDE',filesep...
            ,'doc',filesep,'RDE.xlsx'])
        end

        function plotDriveCycles(obj)

figure
            nx=floor(sqrt(obj.NTrips));
            ny=floor(obj.NTrips/nx);
            tabGroup=uitabgroup('TabLocation',"top");
            thisTab=uitab(tabGroup,'Title','RDE');
            tabGroup.SelectedTab=thisTab;
            axes('Parent',thisTab);
            for k=1:obj.NTrips
                while nx*ny<obj.NTrips
                    ny=ny+1;
                end
                subplot(nx,ny,k)
                RDE.functions.plotTrip(obj.Data{k},obj);
                title(['RDE Trip ',num2str(k)]);
            end

            thisTab=uitab(tabGroup,'Title','Histogram');
            tabGroup.SelectedTab=thisTab;
            axes('Parent',thisTab);
            for k=1:obj.NTrips
                while nx*ny<obj.NTrips
                    ny=ny+1;
                end
                subplot(nx,ny,k)
                RDE.functions.plotVelocityHistogram(obj.Data{k},obj);
                title(['RDE Trip Histogram ',num2str(k)]);
            end

            thisTab=uitab(tabGroup,'Title','Acc');
            tabGroup.SelectedTab=thisTab;
            axes('Parent',thisTab);
            for k=1:obj.NTrips
                while nx*ny<obj.NTrips
                    ny=ny+1;
                end
                subplot(nx,ny,k)
                RDE.functions.plotAcc(obj.Data{k},obj);
                title(['RDE Trip Velocity Acceleration Scatter ',num2str(k)]);
            end

            thisTab=uitab(tabGroup,'Title','VA95 condition');
            tabGroup.SelectedTab=thisTab;
            axes('Parent',thisTab);
            for k=1:obj.NTrips
                while nx*ny<obj.NTrips
                    ny=ny+1;
                end
                subplot(nx,ny,k)
                RDE.functions.plotVA95(obj.Data{k},obj);
                title(['High Dynamic Boundary Condition ',num2str(k)]);
            end

            thisTab=uitab(tabGroup,'Title','RPA condition');
            tabGroup.SelectedTab=thisTab;
            axes('Parent',thisTab);
            for k=1:obj.NTrips
                while nx*ny<obj.NTrips
                    ny=ny+1;
                end
                subplot(nx,ny,k)
                RDE.functions.plotRPA(obj.Data{k},obj);
                title(['Low Dynamic Boundary Condition ',num2str(k)]);
            end

            tabGroup.SelectedTab=tabGroup.Children(1);
        end

        function set.dt(obj,dt)
            classes={'double'};
            attributes={'size',[1,1]};
            validateattributes(dt,classes,attributes);
            obj.dt=dt;
        end

        function set.StopSpeedTh(obj,StopSpeedTh)
            classes={'double'};
            attributes={'size',[1,1]};
            validateattributes(StopSpeedTh,classes,attributes);
            obj.StopSpeedTh=StopSpeedTh;
        end

        function set.OperationModeBoundaries(obj,OperationModeBoundaries)
            classes={'double'};
            attributes={'size',[1,2],'increasing'};
            validateattributes(OperationModeBoundaries,classes,attributes);
            obj.OperationModeBoundaries=OperationModeBoundaries;
        end

        function set.UrbanRatioRange(obj,UrbanRatioRange)
            classes={'double'};
            attributes={'size',[1,2],'increasing'};
            validateattributes(UrbanRatioRange,classes,attributes);
            obj.UrbanRatioRange=UrbanRatioRange;
        end

        function set.RuralRatioRange(obj,RuralRatioRange)
            classes={'double'};
            attributes={'size',[1,2],'increasing'};
            validateattributes(RuralRatioRange,classes,attributes);
            obj.RuralRatioRange=RuralRatioRange;
        end

        function set.MotorwayRatioRange(obj,MotorwayRatioRange)
            classes={'double'};
            attributes={'size',[1,2],'increasing'};
            validateattributes(MotorwayRatioRange,classes,attributes);
            obj.MotorwayRatioRange=MotorwayRatioRange;
        end

        function set.MotorwayUsualMaxSpeed(obj,MotorwayUsualMaxSpeed)
            classes={'double'};
            attributes={'size',[1,1]};
            validateattributes(MotorwayUsualMaxSpeed,classes,attributes);
            obj.MotorwayUsualMaxSpeed=MotorwayUsualMaxSpeed;
        end

        function set.MotorwayAbsoluteSpeedTimeRatio(obj,MotorwayAbsoluteSpeedTimeRatio)
            classes={'double'};
            attributes={'size',[1,1]};
            validateattributes(MotorwayAbsoluteSpeedTimeRatio,classes,attributes);
            obj.MotorwayAbsoluteSpeedTimeRatio=MotorwayAbsoluteSpeedTimeRatio;
        end

        function set.MotorwayAbsoluteMaxSpeed(obj,MotorwayAbsoluteMaxSpeed)
            classes={'double'};
            attributes={'size',[1,1]};
            validateattributes(MotorwayAbsoluteMaxSpeed,classes,attributes);
            obj.MotorwayAbsoluteMaxSpeed=MotorwayAbsoluteMaxSpeed;
        end

        function set.UrbanAverageSpeedRange(obj,UrbanAverageSpeedRange)
            classes={'double'};
            attributes={'size',[1,2],'increasing'};
            validateattributes(UrbanAverageSpeedRange,classes,attributes);
            obj.UrbanAverageSpeedRange=UrbanAverageSpeedRange;
        end

        function set.UrbanStopRatioRange(obj,UrbanStopRatioRange)
            classes={'double'};
            attributes={'size',[1,2],'increasing'};
            validateattributes(UrbanStopRatioRange,classes,attributes);
            obj.UrbanStopRatioRange=UrbanStopRatioRange;
        end

        function set.UrbanMinStopTime(obj,UrbanMinStopTime)
            classes={'double'};
            attributes={'size',[1,1]};
            validateattributes(UrbanMinStopTime,classes,attributes);
            obj.UrbanMinStopTime=UrbanMinStopTime;
        end

        function set.UrbanMinStopCount(obj,UrbanMinStopCount)
            classes={'double'};
            attributes={'size',[1,1]};
            validateattributes(UrbanMinStopCount,classes,attributes);
            obj.UrbanMinStopCount=UrbanMinStopCount;
        end

        function set.MotorwayUsualMinSpeed(obj,MotorwayUsualMinSpeed)
            classes={'double'};
            attributes={'size',[1,1]};
            validateattributes(MotorwayUsualMinSpeed,classes,attributes);
            obj.MotorwayUsualMinSpeed=MotorwayUsualMinSpeed;
        end

        function set.MotorwayUsualMinSpeedTime(obj,MotorwayUsualMinSpeedTime)
            classes={'double'};
            attributes={'size',[1,1]};
            validateattributes(MotorwayUsualMinSpeedTime,classes,attributes);
            obj.MotorwayUsualMinSpeedTime=MotorwayUsualMinSpeedTime;
        end

        function set.TripDurationRange(obj,TripDurationRange)
            classes={'double'};
            attributes={'size',[1,2],'increasing'};
            validateattributes(TripDurationRange,classes,attributes);
            obj.TripDurationRange=TripDurationRange;
        end

        function set.UrbanMinDistance(obj,UrbanMinDistance)
            classes={'double'};
            attributes={'size',[1,1]};
            validateattributes(UrbanMinDistance,classes,attributes);
            obj.UrbanMinDistance=UrbanMinDistance;
        end

        function set.RuralMinDistance(obj,RuralMinDistance)
            classes={'double'};
            attributes={'size',[1,1]};
            validateattributes(RuralMinDistance,classes,attributes);
            obj.RuralMinDistance=RuralMinDistance;
        end

        function set.MotorwayMinDistance(obj,MotorwayMinDistance)
            classes={'double'};
            attributes={'size',[1,1]};
            validateattributes(MotorwayMinDistance,classes,attributes);
            obj.MotorwayMinDistance=MotorwayMinDistance;
        end

        function set.RuralAverageSpeedRange(obj,RuralAverageSpeedRange)
            classes={'double'};
            attributes={'size',[1,2],'increasing'};
            validateattributes(RuralAverageSpeedRange,classes,attributes);
            obj.RuralAverageSpeedRange=RuralAverageSpeedRange;
        end

        function set.MotorwayAverageSpeedRange(obj,MotorwayAverageSpeedRange)
            classes={'double'};
            attributes={'size',[1,2],'increasing'};
            validateattributes(MotorwayAverageSpeedRange,classes,attributes);
            obj.MotorwayAverageSpeedRange=MotorwayAverageSpeedRange;
        end
        function set.VA95VelocityThreshold(obj,VA95VelocityThreshold)
            classes={'double'};
            attributes={'size',[1,1]};
            validateattributes(VA95VelocityThreshold,classes,attributes);
            obj.VA95VelocityThreshold=VA95VelocityThreshold;
        end

        function set.VA95BoundarySpeedCoeff1(obj,VA95BoundarySpeedCoeff1)
            classes={'double'};
            attributes={'size',[1,1]};
            validateattributes(VA95BoundarySpeedCoeff1,classes,attributes);
            obj.VA95BoundarySpeedCoeff1=VA95BoundarySpeedCoeff1;
        end

        function set.VA95BoundaryBias1(obj,VA95BoundaryBias1)
            classes={'double'};
            attributes={'size',[1,1]};
            validateattributes(VA95BoundaryBias1,classes,attributes);
            obj.VA95BoundaryBias1=VA95BoundaryBias1;
        end

        function set.VA95BoundarySpeedCoeff2(obj,VA95BoundarySpeedCoeff2)
            classes={'double'};
            attributes={'size',[1,1]};
            validateattributes(VA95BoundarySpeedCoeff2,classes,attributes);
            obj.VA95BoundarySpeedCoeff2=VA95BoundarySpeedCoeff2;
        end

        function set.VA95BoundaryBias2(obj,VA95BoundaryBias2)
            classes={'double'};
            attributes={'size',[1,1]};
            validateattributes(VA95BoundaryBias2,classes,attributes);
            obj.VA95BoundaryBias2=VA95BoundaryBias2;
        end

        function set.RPAVelocityThreshold(obj,RPAVelocityThreshold)
            classes={'double'};
            attributes={'size',[1,1]};
            validateattributes(RPAVelocityThreshold,classes,attributes);
            obj.RPAVelocityThreshold=RPAVelocityThreshold;
        end

        function set.RPABoundarySpeedCoeff(obj,RPABoundarySpeedCoeff)
            classes={'double'};
            attributes={'size',[1,1]};
            validateattributes(RPABoundarySpeedCoeff,classes,attributes);
            obj.RPABoundarySpeedCoeff=RPABoundarySpeedCoeff;
        end

        function set.RPABoundaryBias(obj,RPABoundaryBias)
            classes={'double'};
            attributes={'size',[1,1]};
            validateattributes(RPABoundaryBias,classes,attributes);
            obj.RPABoundaryBias=RPABoundaryBias;
        end

        function set.RPALowerBound(obj,RPALowerBound)
            classes={'double'};
            attributes={'size',[1,1]};
            validateattributes(RPALowerBound,classes,attributes);
            obj.RPALowerBound=RPALowerBound;
        end

        function set.ShapeParameter(obj,ShapeParameter)
            classes={'double'};
            attributes={'size',[1,1]};
            validateattributes(ShapeParameter,classes,attributes);
            obj.ShapeParameter=ShapeParameter;
        end

        function set.SmoothingMethod(obj,SmoothingMethod)
            classes={'char'};
            attributes={};
            validateattributes(SmoothingMethod,classes,attributes);
            obj.SmoothingMethod=SmoothingMethod;
        end

        function set.SmoothingWindowLength(obj,SmoothingWindowLength)
            classes={'double'};
            attributes={'size',[1,1],'nonnegative'};
            validateattributes(SmoothingWindowLength,classes,attributes);
            obj.SmoothingWindowLength=SmoothingWindowLength;
        end

        function set.NTrips(obj,NTrips)
            classes={'double'};
            attributes={'size',[1,1]};
            validateattributes(NTrips,classes,attributes);
            obj.NTrips=NTrips;
        end

        function set.NumberOfIterations(obj,NumberOfIterations)
            classes={'double'};
            attributes={'size',[1,1]};
            validateattributes(NumberOfIterations,classes,attributes);
            obj.NumberOfIterations=NumberOfIterations;
        end

        function set.OutputFolder(obj,OutputFolder)
            classes={'char'};
            attributes={};
            validateattributes(OutputFolder,classes,attributes);
            obj.OutputFolder=OutputFolder;
        end
    end
end
