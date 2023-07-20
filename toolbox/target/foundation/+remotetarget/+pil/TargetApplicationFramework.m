classdef TargetApplicationFramework<rtw.pil.RtIOStreamApplicationFramework







    methods

        function this=TargetApplicationFramework(componentArgs)
            narginchk(1,1);

            this@rtw.pil.RtIOStreamApplicationFramework(componentArgs);
            buildInfo=this.getBuildInfo;
            rtiostream_src_path=fullfile(matlabroot,'toolbox','coder','rtiostream','src','rtiostreamtcpip');
            buildInfo.addSourcePaths(rtiostream_src_path);
            buildInfo.addSourceFiles('rtiostream_tcpip.c',rtiostream_src_path);
        end
    end
end
