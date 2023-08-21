classdef BusConverter<...
    matlab.System&...
    matlabshared.tracking.internal.SimulinkBusPropagation


    properties(Nontunable)
        SensorIndex{mustBeNonnegative,mustBeInteger}=0;
        useBusOutput{mustBeNumericOrLogical}=true;
        BusNameSource{mustBeTextScalar}="Auto";
        MountingLocation{mustBeVector,mustBeReal}=[0,0,0];
        MountingOrientation{mustBeVector,mustBeReal}=[0,0,0];
        MaximumRange{mustBeScalarOrEmpty,mustBeReal}=0;
        FieldOfView(1,2){mustBeReal}=[0,0];
    end


    properties(Constant,Access=protected)
        pBusPrefix='BusSimulation3DRangeSensor';
    end


    methods(Access=protected)

        function varargout=stepImpl(self,HasObject,HasRange,Range)
            if~self.useBusOutput
                varargout{1}=HasObject;
                varargout{2}=HasRange;
                varargout{3}=Range;
                return;
            end

            measurement=double(Range);
            if(~HasObject)||(~HasRange)
                measurement=double(0);
            end

            varargout{1}=struct(...
            "NumDetections",double(HasObject),...
            "IsValidTime",true,...
            "Detections",struct(...
            "Time",0,...
            "Measurement",measurement,...
            "SensorIndex",self.SensorIndex,...
            "ObjectAttributes",{...
            struct(...
            "TargetIndex",0,...
            "PointOnTarget",[0,0,0]'...
            )...
            },...
            "MeasurementParameters",struct(...
            "Frame",drivingCoordinateFrameType.Spherical,...
            "OriginPosition",[0,0,0]',...
            "OriginVelocity",[0,0,0]',...
            "Orientation",zeros(3),...
            "IsParentToChild",false,...
            "HasAzimuth",false,...
            "HasElevation",false,...
            "HasRange",HasRange,...
            "HasVelocity",false,...
            "FieldOfView",self.FieldOfView...
            ),...
            "ObjectClassID",0,...
            "MeasurementNoise",2.5e-5...
            )...
            );
        end

        function[detection,argsToBus]=defaultOutput(self)
            numRpts=0;
            isValidTime=false;
            argsToBus={numRpts,isValidTime};

            if isLocked(self)
                detection=self.DefaultReport;
            else
                detection=defaultEmptyReturn(self,0);
            end
        end

        function[output]=sendToBus(~,rpts,numDets,isValidTime)
            numRptsFld='NumDetections';
            rptsFld='Detections';
            rptFlds={'Time','Measurement','SensorIndex',...
            'ObjectAttributes','MeasurementParameters',...
            'ObjectClassID','MeasurementNoise'};

            isCellArray=iscell(rpts);
            if isCellArray
                thisRpt=rpts{1};
            else
                thisRpt=rpts(1);
            end
            thisSt=reportToStruct(thisRpt,rptFlds);
            rptStruct=nullify(thisSt);

            for m=1:numDets
                if isCellArray
                    thisRpt=rpts{m};
                else
                    thisRpt=rpts(m);
                end
                rptStruct(m)=reportToStruct(thisRpt,rptFlds);
            end

            output=struct(...
            numRptsFld,numDets,...
            'IsValidTime',isValidTime,...
            rptsFld,rptStruct...
            );
        end


        function detection=defaultEmptyReturn(self,time)
            distance=0;
            actorID=0;
            pointOnTarget=[0,0,0]';
            detection={objectDetection(time,distance)};

            detection{1}.Time=time;
            detection{1}.Measurement=distance;
            detection{1}.MeasurementNoise=0.005^2;
            detection{1}.SensorIndex=self.SensorIndex;
            detection{1}.ObjectClassID=0;
            detection{1}.MeasurementParameters=...
            matlabshared.tracking.internal.fusion.objectDetection.MeasurementParameters(1);
            detection{1}.MeasurementParameters.Frame=drivingCoordinateFrameType.Spherical;
            detection{1}.MeasurementParameters.OriginPosition(:)=self.MountingLocation;
            detection{1}.MeasurementParameters.FieldOfView=self.FieldOfView;
            detection{1}.ObjectAttributes{1}.TargetIndex=actorID;
            detection{1}.ObjectAttributes{1}.PointOnTarget=pointOnTarget;
        end


        function num=getNumInputsImpl(~)
            num=3;
        end


        function num=getNumOutputsImpl(self)
            if self.useBusOutput
                num=1;
            else
                num=3;
            end
        end


        function names=getInputNamesImpl(~)
            names=[...
            "Has object",...
            "Has range",...
            "Range",...
            ];
        end

        function[names]=getOutputNamesImpl(self)
            if self.useBusOutput
                names=sprintf('Detections');
            else
                names=[...
                "Has object",...
                "Has range",...
                "Range",...
                ];
            end
        end


        function varargout=isOutputFixedSizeImpl(self)
            if~self.useBusOutput
                varargout={true,true,true};
            else
                varargout={true};
            end
        end


        function varargout=getOutputSizeImpl(self)
            if~self.useBusOutput
                varargout={[1,1],[1,1],[1,1]};
            else
                varargout={[1,1]};
            end
        end


        function varargout=isOutputComplexImpl(self)
            if~self.useBusOutput
                varargout={false,false,false};
            else
                varargout={false};
            end
        end


        function varargout=getOutputDataTypeImpl(self)
            if self.useBusOutput
                varargout{1}=self.getBusDataTypes();
            else
                varargout{1}='logical';
                varargout{2}='logical';
                varargout{3}='single';
            end
        end
    end


    methods(Hidden)
        function[sensorType,sensorIndex,fov,maxRange,orientation,...
            location,detCoordSys,detOffset]=getSensorExtrinsicsForBES(self,~)
            sensorType='ULTRASONIC';
            sensorIndex=double(self.SensorIndex);
            fov=double(self.FieldOfView(1,1));
            maxRange=double(self.MaximumRange);
            orientation=double(self.MountingOrientation);
            location=double(self.MountingLocation(1:2));
            detOffset=double([0,0,0]);
            detCoordSys='Sim3D Sensor Cartesian';
        end
    end
end

function out=reportToStruct(in,flds)
    out=struct();
    for m=1:numel(flds)
        thisFld=flds{m};
        thisVal=uncell(in.(thisFld));

        if isstruct(thisVal)
            thisValOut=reportToStruct(thisVal,fieldnames(thisVal));
        else
            if strcmp(thisFld,'Frame')
                thisValOut=drivingCoordinateFrameType(thisVal);
            elseif strcmp(thisFld,'TrackLogic')
                thisValOut=trackLogicType(thisVal);
            else
                thisValOut=thisVal;
            end
        end

        out.(thisFld)=thisValOut;
    end
end

function y=uncell(x)
    if iscell(x)
        y=x{1};
    else
        y=x;
    end
end

function out=nullify(in)




    out=in;
    flds=fieldnames(in);
    for m=1:numel(flds)
        thisFld=flds{m};
        for n=1:numel(in)
            thisVal=in(n).(thisFld);
            if isstruct(thisVal)
                nullVal=nullify(thisVal);
            else
                if isenum(thisVal)
                    nullVal=thisVal;
                else
                    nullVal=zeros(size(thisVal),'like',thisVal);
                end
            end
            out(n).(thisFld)=nullVal;
        end
    end
end