classdef TypeContainer<handle
    properties
Enums
Buses
Aliases
Scalars
Ordered
enumMap
    end
    properties(Dependent)
All
    end
    methods
        function obj=TypeContainer()
            obj.Enums=containers.Map('KeyType','char','ValueType','Any');
            obj.Buses=containers.Map('KeyType','char','ValueType','Any');
            obj.Aliases=containers.Map('KeyType','char','ValueType','Any');
            obj.Scalars=containers.Map('KeyType','char','ValueType','Any');
            obj.Ordered={};
            obj.enumMap=containers.Map('KeyType','char','ValueType','Any');
            dnnfpga.codegen.ENUM(obj.enumMap);
        end
        function allMap=get.All(obj)
            allMap=[obj.Enums;obj.Buses;obj.Aliases;obj.Scalars];
        end
        function value=defaultValue(obj,name)
            at=obj.All(name);
            value=at.defaultValue();
        end
        function s=createEnumStruct(obj)
            keys=obj.enumMap.keys;
            values=obj.enumMap.values;
            s=struct();
            for i=1:numel(keys)
                key=keys{i};
                if~contains(key,'.')
                    s.(key)=struct();
                else
                    splt=strsplit(key,'.');
                    s.(splt{1}).(splt{2})=values{i};
                end
            end
        end
        function populateNamespace(obj)
            s=obj.createEnumStruct();
            fns=fieldnames(s);
            structName='nameSpaceStruct__';
            assignin('caller',structName,s);
            for i=1:numel(fns);
                fn=fns{i};
                evalin('caller',sprintf("%s = %s.%s;",fn,structName,fn));
            end
            evalin('caller',sprintf("clear %s;",structName));
        end
    end
end
