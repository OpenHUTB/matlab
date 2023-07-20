


classdef DataSourceAccessor<handle



    properties(SetAccess=private)
Name
    end

    properties(Access={?Simulink.dd.DataSourceElements})
ValidIterator

    end

    properties(SetAccess=private,...
        GetAccess={?Simulink.dd.DataSourceElements})
DataSource
    end

    methods
        function obj=DataSourceAccessor(filespec,varargin)







            validateattributes(filespec,{'char'},{'row'});
            obj.Name=filespec;
            obj.DataSource=Simulink.dd.DataSource;
            obj.DataSource.open(filespec,varargin{:});
        end

        function e=entries(obj)













            e=Simulink.dd.DataSourceEntries(obj);
        end

        function refs=dictionaryReferences(obj)










            refs=Simulink.dd.DictionaryReferences(obj);
        end



        function set.ValidIterator(obj,validIterator)
            validateattributes(validIterator,...
            {'Simulink.dd.DataSourceElements'},{'scalar'});
            obj.ValidIterator=validIterator;
        end
    end
end
