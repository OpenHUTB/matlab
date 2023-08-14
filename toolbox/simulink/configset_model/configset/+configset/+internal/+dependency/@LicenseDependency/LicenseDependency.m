classdef LicenseDependency





    properties
        StatusLimit=3;
LicenseNames
ProductNames
    end

    methods
        function obj=LicenseDependency(licenses)
            obj.LicenseNames={};
            obj.ProductNames={};
            for i=1:licenses.getLength
                item=licenses.item(i-1);
                lic=strtrim(item.getFirstChild.getNodeValue);
                obj.LicenseNames{i}=lic;

                prod=strtrim(item.getAttribute('product'));
                if isempty(prod)
                    error(['Product name should be specified for license: ',lic]);
                else
                    obj.ProductNames{i}=prod;
                end
            end
        end

        out=getStatus(obj,~,~)

        function out=getInfo(obj)
            out.product=obj.ProductNames;
            out.license=obj.LicenseNames;
            out.statusLimit=obj.StatusLimit;
        end
    end

end
