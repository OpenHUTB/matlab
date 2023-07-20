


classdef XCPTCPTargetHandler<coder.internal.xcp.XCPTargetHandler
    properties(SetAccess=private,GetAccess=private)
        TargetName='';
        TargetPort='';
    end

    methods(Access=public)

        function this=XCPTCPTargetHandler(BuildDir,TargetName,TargetPort,SymbolsFileName)
            this@coder.internal.xcp.XCPTargetHandler(BuildDir,SymbolsFileName);

            this.TargetName=TargetName;
            this.TargetPort=TargetPort;
        end
    end

    methods(Access=protected)

        function connection=startTargetConnection(src,timeouts)
            connection=coder.internal.connectivity.XcpTargetConnection('XcpOnTCPIP');


            connection.setSlaveInfo('timeoutValues',timeouts);


            connection.connect(src.TargetName,src.TargetPort);
        end


        function stopTargetConnection(src,connection)%#ok
            connection.disconnect();
        end
    end
end
