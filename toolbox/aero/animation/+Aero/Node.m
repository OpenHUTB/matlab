classdef(CompatibleInexactProperties=true,ConstructOnLoad=true)Node<...
    Aero.animation.internal.TimeSeries






    properties(Transient,SetObservable)
        Name='';
        VRNode={};
        CoordTransformFcn=@nullCoordTransform;
    end

    methods
        function h=Node(varargin)


            if~builtin('license','test','Aerospace_Toolbox')
                error(message('aero:licensing:noLicenseNode'));
            end

            if~builtin('license','checkout','Aerospace_Toolbox')
                return;
            end

            h.TimeSeriesReadFcn=@interp6DoFArrayWithTime;
        end

    end

    methods

        function[tstart,tstop]=findstartstoptimes(h)

            [tstart,tstop]=h.TimeSeriesReadFcn(inf,h);

        end


        function move(h,trans,rot)


            if~isa(h.CoordTransformFcn,'function_handle')
                error(message('aero:node:invalidCoordTransformHandle'));
            end


            [abTrans,abRot]=h.CoordTransformFcn(trans,rot);






            dcmRotBodyVRML=[-1,0,0;0,0,-1;0,-1,0];


            vrmlTrans=(dcmRotBodyVRML*abTrans')';


            vrmlRotAng=(dcmRotBodyVRML*abRot')';


            vrmlRot=euler2aa(vrmlRotAng);


            setfield(h.VRNode,'translation',vrmlTrans,'rotation',vrmlRot);%#ok<STFLD>

        end


        function update(h,t)


            if strcmpi(h.TimeSeriesSourceType,'timeseries')
                if h.TimeSeriesSource.Length==0
                    error(message('aero:node:needTimeData'));
                end
            else
                if isempty(h.TimeSeriesSource)
                    error(message('aero:node:needTimeData'));
                end

            end

            if isempty(which(func2str(h.TimeSeriesReadFcn)))
                error(message('aero:node:noReadFcn'));
            end


            consistencyCheck(h);

            [trans,rot]=h.TimeSeriesReadFcn(t,h);
            h.move(trans,rot);

        end

    end


    methods(Hidden)
        function setTimeSeriesSourceTypeImpl(obj,value)
            switch value
            case "Custom"

            case "Timeseries"
                obj.TimeSeriesReadFcn=@interpTimeseries;
            case "Timetable"
                obj.TimeSeriesReadFcn=@interpTimetable;
            case "StructureWithTime"
                obj.TimeSeriesReadFcn=@interpStructWithTime;
            case "Array3DoF"
                obj.TimeSeriesReadFcn=@interp3DoFArrayWithTime;
            case "Array6DoF"
                obj.TimeSeriesReadFcn=@interp6DoFArrayWithTime;
            end
        end
    end

end



function[vrRot]=euler2aa(abRot)





    cosAbRot=cos(abRot/2);
    sinAbRot=sin(abRot/2);


    w=cosAbRot(2)*cosAbRot(3)*cosAbRot(1)-sinAbRot(2)*sinAbRot(3)*sinAbRot(1);
    x=cosAbRot(2)*cosAbRot(3)*sinAbRot(1)+sinAbRot(2)*sinAbRot(3)*cosAbRot(1);
    y=sinAbRot(2)*cosAbRot(3)*cosAbRot(1)+cosAbRot(2)*sinAbRot(3)*sinAbRot(1);
    z=cosAbRot(2)*sinAbRot(3)*cosAbRot(1)-sinAbRot(2)*cosAbRot(3)*sinAbRot(1);
    angle=2*acos(w);

    norm=x*x+y*y+z*z;
    if(norm<0.000001)

        x=0;
        y=1;
        z=0;
        angle=0;
    else
        norm=sqrt(norm);
        x=x/norm;
        y=y/norm;
        z=z/norm;
    end
    vrRot=[x,y,z,angle];

end

function[nullTrans,nullRot]=nullCoordTransform(trans,rot)
    [nullTrans,nullRot]=Aero.animation.nullCoordTransform(trans,rot);
end

function[xyz,ptp]=interp3DoFArrayWithTime(varargin)
    [xyz,ptp]=Aero.animation.interp3DoFArrayWithTime(varargin{:});
end
function[xyz,ptp]=interp6DoFArrayWithTime(varargin)
    [xyz,ptp]=Aero.animation.interp6DoFArrayWithTime(varargin{:});
end
function[xyz,ptp]=interpStructWithTime(varargin)
    [xyz,ptp]=Aero.animation.interpStructWithTime(varargin{:});
end
function[xyz,ptp]=interpTimeseries(varargin)
    [xyz,ptp]=Aero.animation.interpTimeseries(varargin{:});
end
function[xyz,ptp]=interpTimetable(varargin)
    [xyz,ptp]=Aero.animation.interpTimetable(varargin{:});
end
