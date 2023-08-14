classdef ValueMetaInformation<handle

    properties(Dependent)
Name
Fields
EnumNames
Unit
    end

    properties(Access=private)
MF0
MF0ValueMetaInformation
    end

    methods(Access=?metric.config.MetaInformation,Hidden)

        function out=getMF0ValueMetaInformation(obj)
            out=obj.MF0ValueMetaInformation;
        end

        function obj=ValueMetaInformation(mf0,mf0ValueMetaInformation)
            obj.MF0=mf0;
            obj.MF0ValueMetaInformation=mf0ValueMetaInformation;
        end
    end

    methods

        function val=get.Name(obj)
            val=obj.MF0ValueMetaInformation.Name;
        end

        function set.Name(obj,val)
            obj.MF0ValueMetaInformation.Name=val;
        end

        function val=get.Unit(obj)
            val=obj.MF0ValueMetaInformation.Unit;
        end

        function set.Unit(obj,val)
            obj.MF0ValueMetaInformation.Unit=val;
        end

        function val=get.EnumNames(obj)
            val=obj.MF0ValueMetaInformation.EnumNames.toArray;
        end

        function set.EnumNames(obj,val)
            obj.MF0ValueMetaInformation.EnumNames.clear();
            for n=1:numel(val)
                value=val(n);
                if iscell(value)
                    value=value{1};
                end
                obj.MF0ValueMetaInformation.EnumNames.add(value);
            end
        end

        function val=get.Fields(obj)
            val=obj.MF0ValueMetaInformation.Fields.toArray;
        end

        function set.Fields(obj,val)
            obj.MF0ValueMetaInformation.Fields.clear();
            for n=1:numel(val)
                value=val(n);
                if iscell(value)
                    value=value{1};
                end
                obj.MF0ValueMetaInformation.Fields.add(value);
            end
        end
    end
end


