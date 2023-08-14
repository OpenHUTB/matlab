classdef UsageLogger





    properties(Constant)

        ICDEVICE_APPCOMPONENT="IC_ICDEVICE";
        ICDEVICE_CTOR_EVENTKEY="IC_ICDEVICE_CTORARGS";

        TMTOOL_APPCOMPONENT="IC_TMTOOL";
        TMTOOL_OBJCREATE_EVENTKEY="IC_TMTOOL_DEVICE";

    end

    methods

        function logIcDeviceUsage(obj,varargin)
            p=inputParser;
            p.addParameter('driver',"",@isstring);
            p.addParameter('resourceStr',"",@isstring);
            p.addParameter('hwObj',"",@isstring);

            p.parse(varargin{:});

            dataStruct=p.Results;


            try
                instrument.internal.logInstrUsageData(...
                obj.ICDEVICE_APPCOMPONENT,...
                obj.ICDEVICE_CTOR_EVENTKEY,...
                dataStruct);
            catch

            end
        end


        function logTmToolHardwareUsage(obj,varargin)
            p=inputParser;
            p.addParameter('interfaceObj',"",@isstring);
            p.addParameter('deviceObj',"",@isstring);
            p.addParameter('IviClassDriver',"",@isstring);

            p.parse(varargin{:});

            dataStruct=p.Results;


            try
                instrument.internal.logInstrUsageData(...
                obj.TMTOOL_APPCOMPONENT,...
                obj.TMTOOL_OBJCREATE_EVENTKEY,...
                dataStruct);
            catch

            end
        end

    end

end
