


classdef ArrayDir2dOps

    enumeration


        AzimuthCutLine(1,'Az','Line','AzimuthCutLine')
        AzimuthCutPolar(2,'Az','Polar','AzimuthCutPolar')
        ElevationCutLine(3,'El','Line','ElevationCutLine')
        ElevationCutPolar(4,'El','Polar','ElevationCutPolar')
        UCut(5,'U','UV','UCut')
    end

    properties
Format
ResponseCut
Name
ID
Tag
    end

    methods

        function obj=ArrayDir2dOps(id,rc,fmt,tag)
            obj.ID=id;
            obj.ResponseCut=rc;
            obj.Format=fmt;
            obj.Name=getString(message(['phased:apps:arrayapp:',tag]));
            obj.Tag=tag;
        end

    end

    methods(Static)
        function op=getOpAtPosition(pos)

            E=enumeration('phased.apps.internal.SensorArrayViewer.ArrayDir2dOps');

            ids=arrayfun(@(a)a.ID,E);

            [~,I]=sortrows(ids);

            finals=arrayfun(@(a)ismember(a,pos),I);

            op=E(I(finals));
        end
    end

end



