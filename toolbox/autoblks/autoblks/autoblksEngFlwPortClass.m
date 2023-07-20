
classdef autoblksEngFlwPortClass<handle
    properties(SetAccess=private)
PortHdl
PortName
ParentBlkHdl
ParentBlkObj

MassFracs
    end

    properties(SetAccess=public)
        MassFracReqSrc={};
        MassFracReqSink={};
        MassFracSrc={};

        MassFracSink={};
    end

    methods

        function obj=autoblksEngFlwPortClass(ParentBlkObj,PortName,PortProp)
            obj.ParentBlkObj=ParentBlkObj;
            obj.PortName=PortName;
            if nargin>=3
                for i=1:2:length(PortProp)
                    obj.(PortProp{i})=PortProp{i+1};
                end
            end

            obj.ParentBlkHdl=ParentBlkObj.BlkHdl;
            obj.PortHdl=ParentBlkObj.PortHdls(strcmp(ParentBlkObj.PortNames,PortName));

        end

        function SetMassFracs(obj,MassFracsInput)
            obj.MassFracs=MassFracsInput;
        end
    end
end
