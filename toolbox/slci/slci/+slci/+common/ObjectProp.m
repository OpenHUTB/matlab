


classdef ObjectProp


    properties(Access=private)

        propMap=[];
    end


    methods(Access=public)
        function obj=ObjectProp()
            obj.propMap=containers.Map('KeyType','char',...
            'ValueType','any');
        end
    end


    methods(Access=public)


        function out=hasProperty(obj,propName)
            out=obj.propMap.isKey(propName);
        end


        function prop=getProperty(obj,propName)
            assert(obj.hasProperty(propName),'Unknown property.');
            prop=obj.propMap(propName);
        end


        function obj=setProperty(obj,propName,propValue)
            obj.propMap(propName)=propValue;
        end


        function out=getPropNames(obj)
            out=obj.propMap.keys();
        end
    end

end