classdef(ConstructOnLoad=true)IBUFG<eda.internal.component.BlackBox








    properties
I
O
    end

    properties(SetAccess=protected)
compDeclNotNeeded
wrapperFileNotNeeded
NoHDLFiles
    end

    methods
        function this=IBUFG(varargin)
            this.I=eda.internal.component.Inport('FiType','boolean');
            this.O=eda.internal.component.Outport('FiType','boolean');

        end
    end

end

