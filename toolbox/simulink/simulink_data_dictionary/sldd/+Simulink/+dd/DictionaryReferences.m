


classdef DictionaryReferences<Simulink.dd.DataSourceElements













    properties(SetAccess=private,Transient,Dependent)
HasCurrent
Current
CurrentKey
    end

    methods
        function first(obj)

            obj.DataSource.firstDictionaryReference;
        end

        function next(obj)

            obj.DataSource.nextDictionaryReference;
        end

        function ref=find(obj,key)





            ref=obj.DataSource.getDictionaryReference(key);
        end

        function insert(obj,ref)





            obj.DataSource.addDictionaryReference(ref);
        end




        function remove(obj,ref)





            obj.DataSource.deleteDictionaryReference(ref);
        end



        function value=get.HasCurrent(obj)
            value=obj.DataSource.hasCurrentDictionaryReference;
        end

        function value=get.Current(obj)
            value=obj.DataSource.getCurrentDictionaryReference;
        end

        function value=get.CurrentKey(obj)
            value=obj.DataSource.getCurrentDictionaryReferenceKey;
        end

    end

    methods(Access={?Simulink.dd.DataSourceAccessor})
        function obj=DictionaryReferences(accessor)
            obj=obj@Simulink.dd.DataSourceElements(accessor);
        end
    end
end
