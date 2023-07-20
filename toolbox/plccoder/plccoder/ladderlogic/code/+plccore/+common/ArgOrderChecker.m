classdef ArgOrderChecker<handle



    properties(Access=protected)
AOIName
InStart
OutStart
InOutStart
InEnd
OutEnd
InOutEnd
    end

    methods
        function obj=ArgOrderChecker(aoi_name)
            obj.AOIName=aoi_name;
            obj.InStart=false;
            obj.OutStart=false;
            obj.InOutStart=false;
            obj.InEnd=false;
            obj.OutEnd=false;
            obj.InOutEnd=false;
        end

        function checkArg(obj,arg_name,arg_type)
            import plccore.common.*;
            if strcmpi(arg_name,'enablein')||...
                strcmpi(arg_name,'enableout')
                return;
            end

            switch arg_type
            case ArgType.InArg
                if~obj.InStart
                    if obj.OutStart
                        obj.reportError(arg_name);
                    end
                    obj.InStart=true;
                    if obj.InOutStart
                        obj.InOutEnd=true;
                    end
                    return;
                end
                if obj.InEnd
                    obj.reportError(arg_name);
                end
            case ArgType.InOutArg
                if~obj.InOutStart
                    if obj.OutStart
                        obj.reportError(arg_name);
                    end
                    obj.InOutStart=true;
                    if obj.InStart
                        obj.InEnd=true;
                    end
                    return;
                end
                if obj.InOutEnd
                    obj.reportError(arg_name);
                end
            case ArgType.OutArg
                if~obj.OutStart
                    obj.OutStart=true;

                    obj.InEnd=true;

                    obj.InOutEnd=true;
                end
            otherwise
                assert(false,sprintf('AOI arg %s is not input, output or inout\n',arg_name));
            end
        end
    end
    methods
        function reportError(obj,arg_name)
            plccore.common.plcThrowError(...
            'plccoder:plccore:UnsupportedAOIArgOrder',...
            obj.AOIName,arg_name);
        end
    end
end


