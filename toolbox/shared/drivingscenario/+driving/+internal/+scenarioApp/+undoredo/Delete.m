classdef Delete<driving.internal.scenarioApp.undoredo.Edit

    properties(SetAccess=protected)
Index
    end

    properties(Access=protected)
Specification
    end

    methods
        function this=Delete(hDesigner,index)
            this.Application=hDesigner;



            this.Index=sort(index);
        end
    end
end


