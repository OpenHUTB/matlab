classdef HashMap<handle





    properties(Access=private)
fMap
    end

    methods
        function obj=HashMap(varargin)
            if nargin==1&&isa(varargin{1},'coder.advisor.internal.HashMap')

                rhs=varargin{1};
                obj.fMap=containers.Map(rhs.fMap.keys,rhs.fMap.values);
            else
                obj.fMap=containers.Map(varargin{:});
            end
        end

        function put(obj,key,value)
            obj.fMap(key)=value;
        end

        function out=get(obj,key)
            if obj.fMap.isKey(key)
                out=obj.fMap(key);
            else
                out=[];
            end
        end
    end
end
