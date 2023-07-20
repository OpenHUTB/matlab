classdef SPPDevicesCache<handle





    properties(Constant,Access=?matlab.bluetooth.test.TestAccessor)

        Devices=containers.Map
    end


    methods(Static,Access=public)
        function obj=getInstance()



            mlock;
            persistent cache;

            if isempty(cache)
                cache=matlab.bluetooth.internal.SPPDevicesCache;
            end
            obj=cache;
        end

        function unlock()
            munlock('matlab.bluetooth.internal.SPPDevicesCache.getInstance');
        end
    end

    methods(Access=public)
        function setDevice(obj,name,address,channel)





            if isKey(obj.Devices,address)&&...
                (name==""&&obj.Devices(address).Name~="")
                obj.Devices(address)=struct("Name",obj.Devices(address).Name,"Channel",channel);
            else
                obj.Devices(address)=struct("Name",name,"Channel",channel);
            end
        end

        function identifiers=getDevices(obj)

            if obj.Devices.Count==0
                identifiers=[];
                return
            end
            identifiers=strings(1,2*obj.Devices.Count);
            addresses=obj.Devices.keys;
            for index=1:obj.Devices.Count
                info=obj.Devices(addresses{index});
                identifiers(index*2-1)=string(addresses{index});
                identifiers(index*2)=info.Name;
            end

            identifiers=unique(identifiers);

            identifiers(identifiers=="")=[];
        end

        function channel=getChannel(obj,identifier)


            channel=[];

            identifier=string(identifier);

            if regexp(identifier,"([0-9A-Fa-f]{2}){6}","match")==identifier
                identifier=upper(identifier);
            end

            if regexp(identifier,"([0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}","match")==identifier
                identifier=replace(identifier,["-",":"],"");
                identifier=upper(identifier);
            end

            addresses=obj.Devices.keys;
            for index=1:obj.Devices.Count
                info=obj.Devices(addresses{index});

                if identifier==string(addresses{index})||...
                    identifier==info.Name
                    channel=info.Channel;
                    return
                end
            end
        end
    end

    methods(Access=private)
        function obj=SPPDevicesCache()
        end
    end
end