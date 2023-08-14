classdef UITools<matlabshared.application.UITools


    methods

        function next=addrow(~,layout,hobj,row,col,varargin)
            next=row+1;
            add(layout,hobj,row,col,varargin{:});
        end

        function resetToggleValue(this,prop,newValue)
            setToggleValue(this,prop,newValue)
        end
    end
end