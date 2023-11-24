classdef DeviceStore

    properties(Dependent)
Names
    end

    properties(Constant,Access=?matlab.unittest.TestCase)
        PreferenceGroup='Wireless_Testbench_Toolbox'
        PreferenceName='RadioDevice'
    end

    methods
        function obj=DeviceStore()


        end

        function params=getDeviceParameters(obj,name)


            name=convertStringsToChars(name);
            wt.internal.hardware.DeviceParameterValidator.validateDeviceName(...
            name,'getDeviceParameters','name');

            if isempty(obj.Names)
                error(message('wt:radio:NoRadio'));
            end

            if~ismember(name,obj.Names)


                error(message('wt:radio:ExpectedValidName',...
                strjoin(obj.Names,', '),name));
            end


            try
                devMap=getPreference(obj);
                params=devMap(name);
            catch
                params=[];
            end
        end

        function setDeviceParameters(obj,name,params)

            name=convertStringsToChars(name);
            wt.internal.hardware.DeviceParameterValidator.validateDeviceName(...
            name,'setDeviceParameters','name');
            wt.internal.hardware.DeviceParameterValidator.validateDeviceParameters(...
            params,'setDeviceParameters','params');

            devMap=getPreference(obj);
            if isempty(devMap)
                devMap=containers.Map;
            end
            devMap(name)=params;
            setPreference(obj,devMap);
        end

        function removeDevice(obj,name)

            name=convertStringsToChars(name);
            wt.internal.hardware.DeviceParameterValidator.validateDeviceName(...
            name,'removeDevice','name');

            if~ismember(name,obj.Names)
                error(message('wt:radio:ExpectedValidName',...
                strjoin(obj.Names,', '),name));
            end
            devMap=getPreference(obj);
            if isKey(devMap,name)
                remove(devMap,name);
                setPreference(obj,devMap);
            end
        end

        function deviceNames=get.Names(obj)
            try
                devMap=getPreference(obj);
                deviceNames=devMap.keys;
            catch
                deviceNames={};
            end
        end
    end

    methods(Access=?matlab.unittest.TestCase)
        function prefValue=getPreference(obj)

            if ispref(obj.PreferenceGroup,obj.PreferenceName)
                prefValue=getpref(obj.PreferenceGroup,obj.PreferenceName);
            else
                prefValue=[];
            end
        end

        function setPreference(obj,value)

            setpref(obj.PreferenceGroup,obj.PreferenceName,value);
        end

        function removePreference(obj)

            if ispref(obj.PreferenceGroup,obj.PreferenceName)
                rmpref(obj.PreferenceGroup,obj.PreferenceName);
            end
        end
    end

    methods(Static)
        function radioList=getAvailableRadios()
            ds=wt.internal.hardware.DeviceStore;
            radioList=ds.Names;
        end
    end
end


