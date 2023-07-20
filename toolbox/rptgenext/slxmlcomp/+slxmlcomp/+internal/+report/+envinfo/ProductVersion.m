


classdef ProductVersion<slxmlcomp.internal.report.envinfo.EnvInfoRetriever

    properties(Access=public)
Names
Values
    end

    properties(Access=private)
        ProductName;
    end

    methods
        function obj=ProductVersion(productName)
            obj.ProductName=productName;
        end

        function names=get.Names(obj)
            names={obj.ProductName};
        end

        function values=get.Values(obj)
            values={xmlcomp.internal.report.getProductVersion(obj.ProductName)};
        end
    end

end

