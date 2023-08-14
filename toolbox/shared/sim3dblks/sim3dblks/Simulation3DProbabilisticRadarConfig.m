classdef Simulation3DProbabilisticRadarConfig<...
    matlab.System

    properties(Nontunable)
        RCSactorKeys(1,:)uint8=[];
        RCSactorProfiles={};
        RCSdefaultValue(1,1)double=-20;
    end

    properties(Access=private)
radarProfileManager
    end

    properties(Nontunable)
        aMode='';
    end

    methods
        function self=Simulation3DProbabilisticRadarConfig(varargin)
            setProperties(self,nargin,varargin{:});
        end
    end

    methods(Access=protected)
        function setupImpl(self)
            sim3dblkssharedicon('sim3dblksprobabilisticradarconfig',gcb,'Initialization');

            self.radarProfileManager=sim3d.utils.internal.RadarProfileManager(...
            self.RCSactorKeys,self.RCSactorProfiles,self.RCSdefaultValue);
        end

        function flag=isInactivePropertyImpl(~,property)
            inactive_properties=["aMode"];
            flag=any(inactive_properties==property);
        end

        function num=getNumInputsImpl(~)
            num=0;
        end

        function num=getNumOutputsImpl(~)
            num=0;
        end

        function icon=getIconImpl(~)
            icon=matlab.system.display.Icon("sim3dprobradar_config.png");
        end
    end

    methods(Access=protected,Static)
        function status=getSimulateUsingImpl()
            status='Interpreted execution';
        end

        function status=showSimulateUsingImpl()
            status=false;
        end

        function header=getHeaderImpl()
            header=matlab.system.display.Header(...
            'Title',Simulation3DProbabilisticRadarConfig.string_from_xml("block_title"),...
            'Text',Simulation3DProbabilisticRadarConfig.string_from_xml("block_description"));
        end

        function property_groups=getPropertyGroupsImpl()
            assembleProperty=@(identifier)matlab.system.display.internal.Property(...
            identifier,'Description',Simulation3DProbabilisticRadarConfig.string_from_xml(identifier));

            properties={...
            assembleProperty('RCSactorKeys'),...
            assembleProperty('RCSactorProfiles'),...
            assembleProperty('RCSdefaultValue'),...
            matlab.system.display.internal.Property('aMode'),...
            };






            property_groups=matlab.system.display.Section('PropertyList',properties);
        end

        function string=string_from_xml(identifier)
            full_path=sprintf('shared_sim3dblks:sim3dblkProbRadarConfig:%s',identifier);
            string=message(full_path).getString();
        end
    end
end