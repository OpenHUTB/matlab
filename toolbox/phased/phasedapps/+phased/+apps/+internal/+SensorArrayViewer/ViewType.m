


classdef ViewType

    enumeration
        ArrayGeometry(1,'ArrayGeometry',@genCodeGeometry)
        ArrayDirectivity2D(2,'ArrayDirectivity2D',@genCode2D)
        ArrayDirectivity3D(3,'ArrayDirectivity3D',@genCode3D)
        GratingLobe(4,'GratingLobeDiagram',@genCodeGratingLobe)
    end

    properties
ID
Name
GenCodeCallback
    end

    methods

        function obj=ViewType(id,tag,gccb)
            obj.ID=id;
            obj.Name=getString(message(['phased:apps:arrayapp:',tag]));
            obj.GenCodeCallback=gccb;
        end

        function genCode(obj,mcode,options)
            obj.GenCodeCallback(obj,mcode,options);
        end
    end

    methods(Static)
        function vt=getViewTypeAtPosition(pos)

            E=enumeration('phased.apps.internal.SensorArrayViewer.ViewType');

            ids=arrayfun(@(a)a.ID,E);

            [~,I]=sortrows(ids);

            finals=arrayfun(@(a)ismember(a,pos),I);

            vt=E(I(finals));
        end

    end

end

