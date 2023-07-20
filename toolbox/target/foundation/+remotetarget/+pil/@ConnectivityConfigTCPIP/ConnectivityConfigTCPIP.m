classdef ConnectivityConfigTCPIP<rtw.connectivity.Config




    methods

        function this=ConnectivityConfigTCPIP(componentArgs)
            narginchk(1,1);

            framework=remotetarget.pil.TargetApplicationFramework(componentArgs);
            builder=remotetarget.pil.Builder(componentArgs,framework);
            launcher=remotetarget.pil.LauncherTCPIP(componentArgs,builder,boardParams);

            sharedLibExt=system_dependent('GetSharedLibExt');
            rtiostreamLib=['libmwrtiostreamtcpip',sharedLibExt];

            hostCommunicator=rtw.connectivity.RtIOStreamHostCommunicator(...
            componentArgs,launcher,rtiostreamLib);


            hostCommunicator.setInitCommsTimeout(15);


            timeoutReadDataSecs=60;
            hostCommunicator.setTimeoutRecvSecs(timeoutReadDataSecs);


            portNumStr=num2str(linkfoundation.pil.getTCPIPPortNum);




            launcher.setArgString(['-port ',portNumStr,' -blocking 1'])






            serverhostname=linkfoundation.pil.getServerHostName;
            rtIOStreamOpenArgs={...
            '-hostname',serverhostname,...
            '-client','1',...
            '-blocking','1',...
            '-port',portNumStr,...
            };
            hostCommunicator.setOpenRtIOStreamArgList(...
            rtIOStreamOpenArgs);


            this@rtw.connectivity.Config(componentArgs,builder,launcher,hostCommunicator);


            timer=linkfoundation.pil.profilingTimer('uint32',1e9,0);
            this.setTimer(timer);


            stackProfileReportEnabled=this.getStackProfileReportingEnabled(launcher);
            launcher.setStackProfileReportingEnabled(stackProfileReportEnabled);
        end
    end

    methods(Access='private')

        function stackProfileReportEnabled=getStackProfileReportingEnabled(~,~)
            stackProfileReportEnabled=false;
        end
    end
end



