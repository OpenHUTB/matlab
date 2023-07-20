


classdef ArrayGraphGeometry<phased.apps.internal.SensorArrayViewer.ArrayGraph

    methods
        function obj=ArrayGraphGeometry(App,panel,tag)
            obj=obj@phased.apps.internal.SensorArrayViewer.ArrayGraph(App,panel,tag);

            obj.CanRotate=true;
            obj.CanPan=false;
        end

        function draw(obj)

            if obj.Application.Visualization.ShowIndex
                index='All';
            else
                index='None';
            end

            if logical(obj.Application.Visualization.ShowNormals)
                obj.ViewAngle=[45,45];
            end

            viewArray(obj.Application.Settings.getCurArrayType().ArrayObj,...
            'Parent',obj.hAxes,...
            'ShowNormals',logical(obj.Application.Visualization.ShowNormals),...
            'ShowIndex',index);

            obj.hAxes.Children(end).Tag='Geometry_Scatter';

        end


        function update(obj)
            if~isempty(obj.ViewAngle)
                view(obj.hAxes,obj.ViewAngle);
            end
        end

        function genCode(obj,mcode)
            if obj.Application.Visualization.ShowIndex
                index='''All''';
            else
                index='''None''';
            end

            if obj.Application.Visualization.ShowNormals
                normals='true';
            else
                normals='false';
            end

            mcode.addcr(['viewArray(h,''Parent'',hAxes,''ShowNormals'',',normals,',''ShowIndex'',',index,');']);
            mcode.addcr(['view(hAxes,',mat2str(obj.hAxes.View),');']);
        end

    end
end

