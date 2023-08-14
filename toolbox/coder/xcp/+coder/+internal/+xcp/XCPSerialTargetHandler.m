


classdef XCPSerialTargetHandler<coder.internal.xcp.XCPTargetHandler
    properties(SetAccess=private,GetAccess=private)
        Port='';
        BaudRate='';
        FlowControlType='';
        OpenDelayInMs='';
    end

    methods(Access=public)

        function this=XCPSerialTargetHandler(BuildDir,Port,BaudRate,SymbolsFileName,...
            FlowControlType,OpenDelayInMs)
            this@coder.internal.xcp.XCPTargetHandler(BuildDir,SymbolsFileName);

            this.Port=Port;
            this.BaudRate=BaudRate;
            this.FlowControlType=FlowControlType;
            this.OpenDelayInMs=OpenDelayInMs;
        end
    end

    methods(Access=protected)

        function connection=startTargetConnection(src,timeouts)
            connection=coder.internal.connectivity.XcpTargetConnection('XcpOnSerial');


            connection.setSlaveInfo('timeoutValues',timeouts);


            connection.connect(src.Port,src.BaudRate,...
            src.FlowControlType,src.OpenDelayInMs);
        end


        function stopTargetConnection(src,connection)%#ok
            connection.disconnect();
        end
    end
end
