


classdef ArrayDir3dOps

    enumeration


        Polar(1,'3D','Polar','Polar')
        Line(2,'3D','Line','Line')
        UV(3,'3D','UV','UV')
    end

    properties
Format
ResponseCut
Name
ID
Tag
    end

    methods

        function obj=ArrayDir3dOps(id,rc,fmt,tag)
            obj.ID=id;
            obj.ResponseCut=rc;
            obj.Format=fmt;
            obj.Name=getString(message(['phased:apps:arrayapp:',tag]));
            obj.Tag=tag;
        end

    end

    methods(Static)
        function op=getOpAtPosition(pos)

            E=enumeration('phased.apps.internal.SensorArrayViewer.ArrayDir3dOps');

            ids=arrayfun(@(a)a.ID,E);

            [~,I]=sortrows(ids);

            finals=arrayfun(@(a)ismember(a,pos),I);

            op=E(I(finals));
        end
    end

end





