classdef(Hidden)HardwareParameterInfo<handle




    methods(Static,Hidden)
        function onDeviceAddressChange(~,hDlg,tag,~)


        end

        function onPasswordChange(~,hDlg,tag,~)


        end

        function onUsernameChange(~,hDlg,tag,~)


        end

        function val=getPassword(varargin)

            val='root';
        end

        function val=getUsername(varargin)

            val='root';
        end

        function val=getDeviceAddress(varargin)

            val='10.10.10.1';
        end

        function val=getBuilddir(varargin)

            val='/tmp';
        end

    end
end




