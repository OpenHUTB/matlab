classdef IPSource<handle
    properties(Access=private)
        mData;
    end
    methods
        function this=IPSource()
            this.mData=[];
        end

        function initData(obj,data)
            obj.mData=[];
            children=[];
            for i=1:length(data)
                childObj=soc.memmap.IPRow(data(i));
                children=[children,childObj];%#ok<AGROW>
            end
            obj.mData=children;
        end

        function children=getChildren(obj)
            children=obj.mData;
        end
    end

    methods(Static,Access=public)
    end
end