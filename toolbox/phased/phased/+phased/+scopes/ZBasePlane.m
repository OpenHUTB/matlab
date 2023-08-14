classdef ZBasePlane<matlab.graphics.primitive.Data




    properties(Dependent=true)
        Value;
    end

    properties
        Alpha matlab.internal.datatype.matlab.graphics.datatype.MeshAlpha=.5;
        Color matlab.internal.datatype.matlab.graphics.datatype.RGBAColor='black';
        Value_I=0;
    end

    properties(NeverAmbiguous)
        ValueMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    properties(Access=private)
        Plane matlab.graphics.primitive.Patch;
    end

    methods
        function hObj=ZBasePlane(varargin)
            doSetup(hObj);
            set(hObj,varargin{:});
        end

        function doSetup(hObj)
            hObj.Plane=matlab.graphics.primitive.Patch('HandleVisibility','off');
            hObj.Plane.Vertices=[0,0,0;0,1,0;1,1,0;1,0,0];
            hObj.Plane.Faces=[1,2,3,4];



            hObj.Plane.XLimInclude='off';
            hObj.Plane.YLimInclude='off';
            hObj.Plane.ZLimInclude='off';

            addDependencyConsumed(hObj,'xyzdatalimits');
        end

        function set.Plane(hObj,newValue)
            delete(hObj.Plane);
            if~isempty(newValue)
                hObj.addNode(newValue);
            end
            hObj.Plane=newValue;
        end

        function set.Alpha(hObj,newValue)
            hObj.Alpha=newValue;
            hObj.MarkDirty('all');
        end

        function set.Color(hObj,newValue)
            hObj.Color=newValue;
            hObj.MarkDirty('all');
        end

        function val=get.Value(hObj)
            val=hObj.Value_I;
        end

        function set.Value(hObj,newValue)
            hObj.ValueMode='manual';
            hObj.Value_I=newValue;
            hObj.MarkDirty('all');
        end

        function set.ValueMode(hObj,newValue)
            hObj.ValueMode=newValue;
            hObj.MarkDirty('all');
        end

        function doUpdate(hObj,us)

            x=us.DataSpace.XLim;
            y=us.DataSpace.YLim;
            xMargin=(x(2)-x(1))/2;yMargin=(y(2)-y(1))/2;
            margin=max(xMargin,yMargin);

            [X,Y]=meshgrid([x(1)-margin,us.XMajorTickValues,x(2)+margin],...
            [y(1)-margin,us.YMajorTickValues,y(2)+margin]);


            if strcmp(hObj.ValueMode,'auto')
                hObj.Value_I=us.DataSpace.ZLim(1);
            end
            z=hObj.Value_I;
            s2p=surf2patch(X,Y,ones(size(X))*z);

            hObj.Plane.Vertices=s2p.vertices;
            hObj.Plane.Faces=s2p.faces;

            hObj.Plane.FaceColor=hObj.Color;
            hObj.Plane.EdgeColor=hObj.Color;
            hObj.Plane.FaceAlpha=hObj.Alpha;
            hObj.Plane.EdgeAlpha=(hObj.Alpha)*.25;
        end

        function varargout=getXYZDataExtents(hObj,~,constraints)
            xlim=matlab.graphics.chart.primitive.utilities.arraytolimits([]);
            ylim=matlab.graphics.chart.primitive.utilities.arraytolimits([]);

            if strcmp(hObj.ValueMode,'manual')
                zlim=matlab.graphics.chart.primitive.utilities.arraytolimits(hObj.Value);
            else
                zlim=matlab.graphics.chart.primitive.utilities.arraytolimits([]);
            end

            varargout{1}=[xlim;ylim;zlim];
        end
    end
end
