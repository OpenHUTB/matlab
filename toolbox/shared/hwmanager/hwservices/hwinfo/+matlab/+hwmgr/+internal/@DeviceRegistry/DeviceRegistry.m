classdef DeviceRegistry<handle













    methods(Access='private')
        function obj=DeviceRegistry()

        end


    end

    methods(Static)
        function out=getInstance()
            persistent devRegObj;
            if(isempty(devRegObj))
                devRegObj=matlab.hwmgr.internal.DeviceRegistry();
            end
            out=devRegObj;
        end

        function writeHWInfoToFile(hwInfoFile,hwInfoData)











            [folder,filename,~]=fileparts(hwInfoFile);


            if~isequal(~exist(folder,'dir'),7)
                [status,msg]=mkdir(folder);
                if~status
                    error(message('hwservices:hwinfo:UnableToCreateDevSpecificRegDir',folder,msg));
                end
            end


            fid=fopen(hwInfoFile,'w','n','UTF-8');
            if(fid<0)
                error(message('hwservices:hwinfo:ErrorOpeningDevInfoFile',filename));
            end


            fprintf(fid,'%s',hwInfoData);
            fclose(fid);
        end
    end

    methods

        function add(obj,devInfo)


            validateattributes(devInfo,{'matlab.hwmgr.internal.DeviceInfo'},{'nonempty'});
            filename=devInfo.getDeviceInfoFile();
            if isempty(filename)&&isempty(devInfo.BaseDir)
                error(message('hwservices:hwinfo:RootDirEmpty'));
            end

            serializedDevData=devInfo.serialize();

            encryptedData=matlab.hwmgr.internal.DeviceInfo.encrypt(serializedDevData);
            obj.writeHWInfoToFile(filename,encryptedData);
        end

        function remove(~,devInfo)

            validateattributes(devInfo,{'matlab.hwmgr.internal.DeviceInfo'},{'nonempty'});
            filename=devInfo.getDeviceInfoFile();
            if isequal(exist(filename,'file'),2)
                delete(filename);
            end
        end
    end
end
