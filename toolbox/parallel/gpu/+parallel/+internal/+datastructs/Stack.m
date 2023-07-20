classdef Stack<handle





    properties(Access=private)
        Data;
    end

    methods

        function obj=Stack(data)
            if nargin==0
                obj.Data={};
            else
                obj.Data={data};
            end
        end

        function pop(obj)
            data=obj.Data;
            if numel(data)<=1
                obj.Data={};
            else
                obj.Data=data(1:(end-1));
            end
        end

        function element=top(obj)

            element={};
            data=obj.Data;

            if~isempty(data)
                element=data{end};
            end

        end

        function push(obj,element)
            obj.Data{end+1}=element;
        end

        function multiPush(obj,elements)

            assert(iscell(elements),'input must be a cell array.');

            for kk=1:numel(elements)
                obj.Data{end+1}=elements{kk};
            end

        end

        function res=isempty(obj)
            res=isempty(obj.Data);
        end

    end

end





