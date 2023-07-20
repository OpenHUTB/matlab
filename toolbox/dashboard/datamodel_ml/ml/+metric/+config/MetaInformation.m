classdef MetaInformation<handle

    properties(Dependent,SetAccess=private)

Locale
ValueName
    end

    properties(Dependent)
        Name string
        Description string
    end

    properties(Access=private)
MF0
MF0MetaInformation
    end

    methods(Access=?metric.config.AlgorithmConfiguration,Hidden)

        function out=getMF0MetaInformation(obj)
            out=obj.MF0MetaInformation;
        end

        function obj=MetaInformation(mf0,mf0MetaInformation)
            obj.MF0=mf0;
            obj.MF0MetaInformation=mf0MetaInformation;
        end
    end

    methods
        function val=get.Locale(obj)
            val=obj.MF0MetaInformation.Locale;
        end

        function val=get.Name(obj)
            val=obj.MF0MetaInformation.Name;
        end

        function set.Name(obj,val)
            obj.MF0MetaInformation.Name=val;
        end

        function val=get.Description(obj)
            val=obj.MF0MetaInformation.Description;
        end

        function set.Description(obj,val)
            obj.MF0MetaInformation.Description=val;
        end

        function val=get.ValueName(obj)
            val=metric.config.ValueMetaInformation(obj.MF0,obj.MF0MetaInformation.ValueName);
        end

        function addParameterName(obj,id,name)
            obj.MF0MetaInformation.ParameterNames.insert(...
            metric.data.ParameterMetaInfo(obj.MF0,...
            struct('ID',id,'Name',name)));
        end

        function name=getParameterName(obj,id)
            name='';
            mfParammMI=obj.MF0MetaInformation.ParameterNames.getByKey(id);

            if~isempty(mfParammMI)
                name=mfParammMI.Name;
            end
        end

    end
end


