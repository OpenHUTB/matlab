classdef(ConstructOnLoad=true)BUFG<eda.internal.component.BlackBox %#ok<MCDIR>








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
        function this=BUFG
            this.I=eda.internal.component.Inport('FiType','boolean');
            this.O=eda.internal.component.Outport('FiType','boolean');
        end
    end

end

