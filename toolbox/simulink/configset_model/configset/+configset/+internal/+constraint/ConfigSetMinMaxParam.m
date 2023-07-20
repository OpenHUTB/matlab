classdef ConfigSetMinMaxParam<configset.internal.data.ParamType



    properties
Min
Max
    end

    methods
        function out=isValid(obj,val)
            if val<obj.Min||val>obj.Max
                out=false;
            else
                out=true;
            end
        end

        function out=getTypeName(~)
            out='minmax';
        end

        function out=getAvailableValues(obj)
            out=obj.Min:obj.Max;
        end

        function out=getDisplayedValues(obj)
            n=obj.Max-obj.Min;
            out=cell(1,n+1);
            for i=0:n
                out{i+1}=int2str(obj.Min+i);
            end
        end

        function obj=ConfigSetMinMaxParam(node)
            min=node.getElementsByTagName('min');
            max=node.getElementsByTagName('max');

            obj.Min=str2double(strtrim(min.item(0).getFirstChild.getNodeValue));
            obj.Max=str2double(strtrim(max.item(0).getFirstChild.getNodeValue));
        end
    end
end
