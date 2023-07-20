

classdef SelectionListener<handle

    methods(Access=public)
        function obj=SelectionListener()
            obj.document=[];
            obj.listener=[];
        end
    end

    properties(Access=public)
        document=[];
        listener=[];
    end
end
