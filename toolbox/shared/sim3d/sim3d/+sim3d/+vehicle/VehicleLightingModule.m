classdef VehicleLightingModule<handle

    properties(Access=public,Constant)
        ValidLightTypes=["Spotlight","PointLight","MatLight"];
        PassVehLightCategories=["HighBeams","LowBeams","BrakeLights","ReverseLights","LeftSignals","RightSignals","MatHeadlights"];
        MotorcycleLightCategories=["HighBeams","LowBeams","BrakeLights","LeftSignals","RightSignals"];
        AircraftLightCategories=["LandingLights","TaxiLights","AnticollisionBeacons","WingtipStrobeLights",...
        "TailStrobeLights","NavigationLights","PositionLights"];

        GlobalLightParameters=["LightType"];
        SpotlightParameters=["LightType","Category","LightName","LightColor","Intensity","SocketName","RelativeTransform","AttenuationRadius","InnerConeAngle","OuterConeAngle","ReverseState","InitState"];
        PointLightParameters=["LightType","Category","LightName","LightColor","Intensity","SocketName","RelativeTransform","AttenuationRadius","SourceRadius","SoftSourceRadius","SourceLength","ReverseState","InitState"];
        MatLightParameters=["LightType","Category","MatPath","MatSlotName","ParamName","ParamOn","ParamOff","LightColor","ReverseState","InitState"];
    end


    properties(Access=private)
        LightConfigs={};
        LightConfigStrings={};
        LightStates=struct();
        LightSetFlag=true;
        RebuildLightsFlag=false;
    end


    methods(Access=public)
        function self=VehicleLightingModule(configs)
            self.LightConfigs={};
            self.LightConfigStrings={};
            self.LightStates=struct();
            if exist('configs','var')&&~isempty(configs)
                self.addAllLightConfigs(configs);
            end
        end


        function setVehicleLightStatesArray(self,categories,states)
            chk=self.LightStates;
            for i=1:length(categories)
                self.LightStates.(categories(i))=logical(states(i));
            end
            if~isequal(self.LightStates,chk)
                self.LightSetFlag=true;
            end
        end


        function setVehicleLightStates(self,states)
            chk=self.LightStates;
            for i=1:length(states)
                state=states(i);
                self.LightStates.(state.group)=logical(state.state);
            end
            if~isequal(self.LightStates,chk)
                self.LightSetFlag=true;
            end
        end


        function messageString=generateInitMessageString(self)
            self.RebuildLightsFlag=false;
            messageStruct=[];
            messageStruct.cmd="INIT";
            messageStruct.config=self.LightConfigs;
            messageString=jsonencode(messageStruct);
        end


        function messageString=generateStepMessageString(self)
            messageStruct=struct('cmd',"SKIP");
            if self.RebuildLightsFlag
                self.RebuildLightsFlag=false;
                messageStruct=[];
                messageStruct.cmd="REBUILD";
                messageStruct.config=self.LightConfigs;
                messageStruct.states=self.unwrapStateStruct();
            elseif self.LightSetFlag
                self.LightSetFlag=false;
                messageStruct=[];
                messageStruct.cmd="STATES";
                messageStruct.states=self.unwrapStateStruct();
            end
            messageString=jsonencode(messageStruct);
        end


        function states=unwrapStateStruct(self)
            groups=fieldnames(self.LightStates);
            numLights=length(groups);
            states=struct();
            for i=1:numLights
                states(i).group=groups{i};
                states(i).state=self.LightStates.(groups{i});
            end
        end


        function clearLightConfigs(self)
            self.LightConfigs={};
        end
        function addAllLightConfigs(self,configs)
            for i=1:length(configs)
                self.addLightConfig(configs{i});
            end
        end


        function addLightConfig(self,config)
            parser=sim3d.vehicle.VehicleLightingModule.configParser();
            parser.parse(config);
            parsed=parser.Results;
            populated=sim3d.vehicle.VehicleLightingModule.populateLightConfig(parsed);
            self.appendLightConfig(populated);
        end


        function addLight(self,varargin)
            parser=sim3d.vehicle.VehicleLightingModule.configParser();
            parser.parse(varargin{:});
            parsed=parser.Results;
            populated=sim3d.vehicle.VehicleLightingModule.populateLightConfig(parsed);
            self.appendLightConfig(populated);
        end
        function appendLightConfig(self,config)
            self.LightConfigs{length(self.LightConfigs)+1}=config;
            category=config.Category;
            state=config.InitState;
            self.LightStates.(category)=state;
            self.RebuildLightsFlag=true;
        end
    end
    methods(Access=private,Static)
        function populated=populateLightConfig(parsed)
            lightParams=[];
            if parsed.LightType=="Spotlight"
                lightParams=sim3d.vehicle.VehicleLightingModule.SpotlightParameters;
            elseif parsed.LightType=="PointLight"
                lightParams=sim3d.vehicle.VehicleLightingModule.PointLightParameters;
            elseif parsed.LightType=="MatLight"
                lightParams=sim3d.vehicle.VehicleLightingModule.MatLightParameters;
            end

            populated=struct();
            for i=1:length(lightParams)
                pnam=lightParams(i);
                populated.(pnam)=parsed.(pnam);
            end
        end
        function parser=configParser()
            defaultParams=struct(...
            'LightType','Empty',...
            'Category','Miscellaneous',...
            'LightName','None',...
            'LightColor',single([0,0,0]),...
            'Intensity',single(0),...
            'SocketName','None',...
            'RelativeTransform',single([0,0,0,0,0,0]),...
            'AttenuationRadius',single(0),...
            'InnerConeAngle',single(0),...
            'OuterConeAngle',single(0),...
            'SourceRadius',single(0),...
            'SoftSourceRadius',single(0),...
            'SourceLength',single(0),...
            'MatPath','None',...
            'MatSlotName',uint32(0),...
            'ParamName','None',...
            'ParamOn',single(0),...
            'ParamOff',single(0),...
            'ReverseState',logical(false),...
            'InitState',false);

            parser=inputParser;
            parser.StructExpand=true;
            fields=fieldnames(defaultParams);
            for i=1:length(fields)
                field=fields{i};
                parser.addParameter(field,defaultParams.(field));
            end
        end
    end
end