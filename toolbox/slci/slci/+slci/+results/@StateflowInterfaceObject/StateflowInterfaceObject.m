


classdef StateflowInterfaceObject<slci.results.FunctionInterfaceObject

    properties(Access=protected)

        fSID;

        fSFObjectPath;
    end

    methods(Access=public,Hidden=true)


        function obj=StateflowInterfaceObject(aKey,aName,aSID,aType)
            if nargin==0

                DAStudio.error('Slci:results:DefaultConstructorError',...
                'FUNCTION INTERFACE');
            end
            obj=obj@slci.results.FunctionInterfaceObject(aKey,aName,aType);

            obj.setSFObjectPath(aSID);
            obj.setSID(aSID);
        end


        function setSID(obj,aSID)
            obj.fSID=aSID;
        end


        function aName=getSID(obj)
            aName=obj.fSID;
        end


        function setSFObjectPath(obj,aSID)
            obj.fSFObjectPath=Simulink.ID.getFullName(aSID);
        end


        function aName=getSFObjectPath(obj)
            aName=obj.fSFObjectPath;
        end
    end

    methods(Access=public,Hidden=true)

        function linkSID=getLink(obj,~)

            linkSID={};
            try


                linkSID{end+1}=obj.fSID;
            catch

            end
        end


        function callback=getCallback(obj,datamgr)


            link=obj.getLink(datamgr);
            if isempty(link)
                callback=obj.getDispName();
            else
                modelFileName=datamgr.getMetaData('ModelFileName');
                encodedModelFileName=slci.internal.encodeString(...
                modelFileName,'all','encode');


                callback=slci.internal.ReportUtil.appendCallBack(...
                obj.getSFObjectPath(),encodedModelFileName,link{1});

                callback=['stateflow ',obj.getDispName(),' for ',callback];
            end
        end
    end
end
