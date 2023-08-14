


classdef SettingChecksum2InterfaceAndFullChecksumManager<handle

    properties(Constant)
        instance=CGXE.CustomCode.SettingChecksum2InterfaceAndFullChecksumManager;
    end

    properties(Access=private)
ChecksumMap
    end

    methods
        function obj=SettingChecksum2InterfaceAndFullChecksumManager()
            obj.ChecksumMap=containers.Map;
        end

    end

    methods(Static)
        function reset()
            obj=CGXE.CustomCode.SettingChecksum2InterfaceAndFullChecksumManager.instance;
            obj.ChecksumMap.remove(obj.ChecksumMap.keys());
        end

        function status=hasCached(settingsChecksum)
            obj=CGXE.CustomCode.SettingChecksum2InterfaceAndFullChecksumManager.instance;
            status=obj.ChecksumMap.isKey(settingsChecksum);
        end

        function setCached(settingsChecksum,checksumStruct)
            obj=CGXE.CustomCode.SettingChecksum2InterfaceAndFullChecksumManager.instance;
            obj.ChecksumMap(settingsChecksum)=checksumStruct;
        end

        function checksumStruct=getCached(settingsChecksum)
            obj=CGXE.CustomCode.SettingChecksum2InterfaceAndFullChecksumManager.instance;
            checksumStruct=obj.ChecksumMap(settingsChecksum);
        end
    end
end