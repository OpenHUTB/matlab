


classdef DataSourceEntries<Simulink.dd.DataSourceElements











    properties(SetAccess=private,Transient,Dependent)
HasCurrent
Current
CurrentKey
    end

    methods
        function first(obj)

            obj.DataSource.firstEntry;
        end

        function next(obj)

            obj.DataSource.nextEntry;
        end

        function entry=find(obj,key)





            entry=obj.DataSource.getEntry(key);
        end

        function insert(obj,entry)




            obj.DataSource.addEntry(entry);
        end

        function update(obj,entry)







            obj.DataSource.updateEntry(entry);
        end

        function remove(obj,entry)




            obj.DataSource.deleteEntry(entry);
        end



        function value=get.HasCurrent(obj)

            value=obj.DataSource.hasCurrentEntry;
        end

        function value=get.Current(obj)

            value=obj.DataSource.getCurrentEntry;
        end

        function value=get.CurrentKey(obj)

            value=obj.DataSource.getCurrentEntryKey;
        end

    end

    methods(Access={?Simulink.dd.DataSourceAccessor})
        function obj=DataSourceEntries(accessor)
            obj=obj@Simulink.dd.DataSourceElements(accessor);
        end
    end
end
