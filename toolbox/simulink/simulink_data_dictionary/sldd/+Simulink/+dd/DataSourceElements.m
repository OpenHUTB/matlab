


classdef DataSourceElements<handle



    properties(SetAccess=private,Transient,Abstract)
HasCurrent
Current
CurrentKey
    end

    properties(SetAccess=private,GetAccess=protected,Transient)
DataSource
    end

    properties(Access=private)
DataSourceAccessor
    end

    methods(Abstract)
        first(obj)
        next(obj)
        element=find(obj,key)
        insert(obj,element)
        remove(obj,element)
    end

    methods(Access=protected)
        function obj=DataSourceElements(accessor)
            validateattributes(accessor,...
            {'Simulink.dd.DataSourceAccessor'},{'scalar'});
            obj.DataSourceAccessor=accessor;
            obj.DataSourceAccessor.ValidIterator=obj;
            obj.first;
        end
    end



    methods
        function value=get.DataSource(obj)



            assert(obj==obj.DataSourceAccessor.ValidIterator);

            value=obj.DataSourceAccessor.DataSource;
        end
    end

end
