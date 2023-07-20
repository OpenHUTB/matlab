
classdef TypeDefs<handle
    properties(SetAccess=protected)
tc
    end
    methods
        function obj=TypeDefs(reuse)
            if nargin==0||~reuse
                obj=dnnfpga.typedefs.TypeDefs.getInstance(true);
            end
        end
        function bus=getBus(obj,name)
            if isKey(obj.tc.Buses,name)
                bus=obj.tc.Buses(name);
            else
                error("No bus named '%s' exists.",name);
            end
        end
    end
    methods(Static)
        function obj=getInstance(clear)
            persistent localObj
            if nargin~=0&&clear
                localObj=[];
            end
            if isempty(localObj)||~isvalid(localObj)
                localObj=dnnfpga.typedefs.TypeDefs(true);
                localObj.tc=dnnfpga.typedefs.TypeContainer();
            end
            obj=localObj;
        end
        function add(object)
            obj=dnnfpga.typedefs.TypeDefs.getInstance();
            if isKey(obj.tc.All,object.Name)
                error("An object named '%s' already exists.",object.Name);
            end

            switch(class(object))
            case 'dnnfpga.typedefs.Bus'
                obj.tc.Buses(object.Name)=object;
            case 'dnnfpga.typedefs.TypeAlias'
                obj.tc.Aliases(object.Name)=object;
            case 'dnnfpga.typedefs.Enum'
                obj.tc.Enums(object.Name)=object;
            case 'dnnfpga.typedefs.Scalar'
                obj.tc.Scalars(object.Name)=object;
            otherwise
                error("Added object must be of type 'dnnfpga.typedefs.Bus', 'dnnfpga.typedefs.Enum', or 'dnnfpga.typedefs.TypeAlias'.");
            end
            obj.tc.Ordered=cat(1,obj.tc.Ordered,{object});
        end
    end
end