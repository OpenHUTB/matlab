classdef(CompatibleInexactProperties=true,ConstructOnLoad=true)Body<...
    Aero.animation.internal.TimeSeries

    properties(Transient,SetObservable)
        Name='';
        CoordTransformFcn=@nullCoordTransform;
        Position=[0,0,0];
        Rotation=[0,0,0];
        Geometry=Aero.Geometry;
        PatchGenerationFcn=@generatePatchesFromFvcData;
        PatchHandles=[];
        ViewingTransform=[];
    end

    methods
        function h=Body(varargin)
            if~builtin('license','test','Aerospace_Toolbox')
                error(message('aero:licensing:noLicenseBody'));
            end

            if~builtin('license','checkout','Aerospace_Toolbox')
                return;
            end
            h.TimeSeriesReadFcn=@interp6DoFArrayWithTime;
            h.Geometry=Aero.Geometry;

        end

    end

    methods
        function set.Name(obj,value)


            obj.Name=value;
        end

        function set.Geometry(obj,value)

            validateattributes(value,{'handle'},{'scalar'},'','Geometry')
            obj.Geometry=value;
        end

    end

    methods

        function generatePatches(h,ax)

            if isempty(ax)||~ishghandle(ax,'axes')
                error(message('aero:Body:InvalidAxes'));
            end
            h.PatchGenerationFcn(ax,h);

        end


        function load(h,bodyDataSrc,varargin)



            if nargin>2
                h.Geometry.Source=varargin{1};
            end

            if(isa(bodyDataSrc,'char')&&isempty(which(bodyDataSrc)))
                error(message('aero:Body:NoGeometry'));
            end

            h.Geometry.read(bodyDataSrc);
            h.Name=h.Geometry.Name;

        end


        function move(h,trans,rot)



            h.Position=trans;
            h.Rotation=rot;









            if~isa(h.CoordTransformFcn,'function_handle')
                error(message('aero:Body:InvalidCoordTransformHandle'));
            end

            [abTrans,abRot]=h.CoordTransformFcn(trans,rot);


            hgTrans=-abTrans([1,3,2]);
            hgRot=-abRot([1,3,2]);



            if ishghandle(h.ViewingTransform,'hgtransform')

                TR=makehgtform(...
                'translate',hgTrans,...
                'yrotate',hgRot(2),...
                'zrotate',hgRot(3),...
                'xrotate',hgRot(1));

                set(h.ViewingTransform,'Matrix',TR);

            end

        end


        function update(h,t)

            if(isempty(h.Geometry.FaceVertexColorData)&&isempty(h.Geometry.Name))
                error(message('aero:Body:updateGeometry'));
            end


            if strcmpi(h.TimeSeriesSourceType,'timeseries')
                if h.TimeSeriesSource.Length==0
                    error(message('aero:Body:NeedTimeData'));
                end
            else
                if isempty(h.TimeSeriesSource)
                    error(message('aero:Body:NeedTimeData'));
                end
            end

            if isempty(which(func2str(h.TimeSeriesReadFcn)))
                error(message('aero:Body:NoReadFcn'));
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


        function[tstart,tstop]=findstartstoptimes(h,~)

            [tstart,tstop]=h.TimeSeriesReadFcn(inf,h);

        end

    end

end


function generatePatchesFromFvcData(ax,h)








    h.ViewingTransform=hgtransform('Parent',ax);



    fvc=h.Geometry.FaceVertexColorData;
    if isempty(fvc)
        warning(message('aero:Body:NoGeometryDefined'));
    else
        h.PatchHandles=zeros(numel(fvc),1);

        for m=1:numel(fvc)

            if isempty(fvc(m).faces)
                h.PatchHandles(m)=[];
            else


                if~isfield(fvc(m),'alpha')||isempty(fvc(m).alpha)
                    numCData=size(fvc(m).cdata,1);
                    fvc(m).alpha=ones(numCData,1);
                end



                h.PatchHandles(m)=patch(...
                'Faces',fvc(m).faces,...
                'Vertices',fvc(m).vertices,...
                'FaceVertexCData',fvc(m).cdata,...
                'FaceColor','flat',...
                'FaceLighting','phong',...
                'AlphaDataMapping','none',...
                'FaceVertexAlphaData',fvc(m).alpha,...
                'FaceAlpha','flat',...
                'Parent',h.ViewingTransform...
                );
            end
        end
    end

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
