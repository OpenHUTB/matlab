classdef(Abstract)ParamContainer<handle


    properties
        Name='';
ParamMap


ParamList
        Type='base';
    end

    properties(Hidden)
param
    end

    properties(Transient=true)
        isReady=false;
    end

    methods
        function obj=ParamContainer()
            obj.ParamMap=containers.Map('KeyType','char','ValueType','any');
        end

        out=getParam(obj,name,varargin)
        out=getParamAllFeatures(obj,name)
        out=getUniqueParam(obj,uName)
        out=isValidParam(obj,name)
        out=getParamNames(obj,varargin)
        out=getParamObjects(obj)
    end

    methods(Hidden)

        parse(obj,xml)
        setup(obj)
        lines=getFeatureControlScript(mcc,target);
    end

end

