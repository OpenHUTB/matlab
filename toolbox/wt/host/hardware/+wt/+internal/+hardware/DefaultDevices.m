classdef DefaultDevices





    properties(Dependent,SetAccess=private)
Product
    end

    properties(Access=private)
        DeviceParameters containers.Map
    end

    methods
        function obj=DefaultDevices()


            obj.DeviceParameters=containers.Map;


            params.Type='N310';
            params.Product=params.Type;
            params.Variant='HG';
            params.Name='';
            params.Network.HostIP0='';
            params.Network.DeviceIP0='';
            params.Network.HostIP1='';
            params.Network.DeviceIP1='';
            params.ImageInfo.DOWNLOAD_URL='https://files.ettus.com/binaries/cache/n3xx/meta-ettus-v4.1.0.4/n3xx_common_sdimg_default-v4.1.0.4.zip';
            params.ImageInfo.ZIP_FILE_SIZE=713125936;
            params.ImageInfo.ZIP_FILE_CHECKSUM='ca115b0d9f1715c8a30d460a18c0f2f0';
            params.ImageInfo.IMG_FILE_SIZE=15879634944;
            params.ImageInfo.IMG_FILE_CHECKSUM='a743688d0b44f9e98b81935e5470b51c';
            params.ImageInfo.UHD_VERSION='4.1.0.4';
            obj.DeviceParameters(params.Type)=params;


            params.Type='N320';
            params.Product=params.Type;
            obj.DeviceParameters(params.Type)=params;


            params.Type='N321';
            params.Product=params.Type;
            obj.DeviceParameters(params.Type)=params;


            params.Type='X310';
            params.Product=params.Type;
            params.ImageInfo.DOWNLOAD_URL='';
            params.ImageInfo.ZIP_FILE_SIZE=0;
            params.ImageInfo.ZIP_FILE_CHECKSUM='';
            params.ImageInfo.IMG_FILE_SIZE=0;
            params.ImageInfo.IMG_FILE_CHECKSUM='';
            obj.DeviceParameters(params.Type)=params;
        end

        function product=get.Product(obj)
            product=obj.DeviceParameters.keys;
        end

        function params=getDeviceParameters(obj,name)


            if~ismember(name,obj.Product)
                error(message('wt:radio:ExpectedValidName',...
                strjoin(obj.Product,', '),name));
            end
            params=obj.DeviceParameters(name);
        end
    end
end


