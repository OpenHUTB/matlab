classdef AbstractIterator<handle

    properties
        Direction;
    end

    methods(Abstract)

        begin(this,startNode);
        next(this);
        elem=getElement(this);
    end

    methods(Abstract,Access='protected')

        actualStartNode=validateStartNode(this,startNode);
    end

    methods
        function this=AbstractIterator(direction)

            this.Direction=direction;
        end
    end

end