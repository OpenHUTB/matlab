classdef LastConnectionInfo





    properties(Constant,Access=private)
        Group="MATLAB_HARDWARE"
        Pref="BLUETOOTH"
    end

    methods(Static,Access=public)
        function info=get()


            isPref=ispref(matlab.bluetooth.internal.LastConnectionInfo.Group,matlab.bluetooth.internal.LastConnectionInfo.Pref);
            info=[];
            if isPref
                info=getpref(matlab.bluetooth.internal.LastConnectionInfo.Group,matlab.bluetooth.internal.LastConnectionInfo.Pref);
            end
        end

        function set(name,address,channel)



            newPref.Name=name;
            newPref.Address=address;
            newPref.Channel=channel;

            isPref=ispref(matlab.bluetooth.internal.LastConnectionInfo.Group,matlab.bluetooth.internal.LastConnectionInfo.Pref);
            if isPref
                setpref(matlab.bluetooth.internal.LastConnectionInfo.Group,matlab.bluetooth.internal.LastConnectionInfo.Pref,newPref);
            else
                addpref(matlab.bluetooth.internal.LastConnectionInfo.Group,matlab.bluetooth.internal.LastConnectionInfo.Pref,newPref);
            end
        end
    end
end