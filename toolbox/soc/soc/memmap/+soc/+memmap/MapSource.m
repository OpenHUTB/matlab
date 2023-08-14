classdef MapSource<handle
    properties(Access=private)
        mData;
    end
    properties
        mComponentName;
    end
    methods
        function this=MapSource()
            this.mData=[];
        end

        function initData(obj,data,isFixedMemMap)
            obj.mData=[];
            children=[];
            for i=1:length(data)
                childObj=soc.memmap.MapRow(data(i),isFixedMemMap);
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