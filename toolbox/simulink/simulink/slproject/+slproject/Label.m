classdef Label<slproject.LabelDefinition








    properties(Dependent,GetAccess=public,SetAccess=private)

        File;

        DataType;
    end

    properties(Dependent,GetAccess=public,SetAccess=public)

        Data;
    end

    properties(GetAccess=private,SetAccess=private,Hidden)
        Delegate;
    end

    methods(Access=public,Hidden=true)
        function obj=Label(delegate)



            obj@slproject.LabelDefinition(delegate.CategoryName,delegate.Name);
            obj.Delegate=delegate;
        end
    end

    methods
        function file=get.File(obj)
            file=char(obj.Delegate.File);
        end

        function dataType=get.DataType(obj)
            dataType=char(obj.Delegate.DataType);
        end

        function data=get.Data(obj)
            data=obj.Delegate.Data;
        end

        function obj=set.Data(obj,data)
            obj.Delegate.Data=data;
        end
    end

end
