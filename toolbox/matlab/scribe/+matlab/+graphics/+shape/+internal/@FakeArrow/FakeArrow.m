classdef(Sealed)FakeArrow<matlab.graphics.primitive.world.Group




    properties
        DisplayLineColor;
        DisplayLineStyle;
        DisplayLineWidth;
        Tag='';
        StartPoint;
        EndPoint;
    end

    methods
        function hObj=FakeArrow(varargin)



            hObj.Description='FakeArrow';
            parProp=strcmpi('Parent',varargin);
            idx=find(parProp);
            if idx~=0
                parVal=varargin{idx+1};
                hObj.Parent=parVal;
            end
        end
    end
end
