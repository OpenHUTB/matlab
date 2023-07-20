



classdef Component<configset.internal.data.ParamContainer

    properties
ShortName
NameKey
Class
Dependency
    end

    properties(Dependent)
FullName
    end

    properties(Transient,Hidden)
typeMap
namespace

        memberFunctions={}
        functionInputs={}
        functionOutputs={}
        initFunction=false;
    end

    properties(Hidden)
key_prefix
key_suffix_name
tag






        Feature={}
        License={}
        Product={}



        PrototypeFeature=[]
    end

    methods
        function out=get.FullName(obj)
            out=obj.Name;
        end
        function set.FullName(obj,name)
            obj.Name=name;
        end
        function name=getDisplayName(obj)
            try
                name=message(obj.NameKey).getString;
            catch
                name=obj.NameKey;
            end
        end
    end

    methods(Hidden)
        createFromXml(obj,xml)
        parse(obj,xml,varargin)
        setup(obj)
        import(obj,xml,params,grt,ert)
        createWebDataFile(obj,dirName)

        str=printHtml(obj)
    end
end
