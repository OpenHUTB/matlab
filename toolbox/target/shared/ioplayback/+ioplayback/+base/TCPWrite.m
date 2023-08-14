classdef TCPWrite<ioplayback.base.tcpip&ioplayback.SinkSystem











%#codegen


    properties(Nontunable)

        NetworkRole='Client';

        RemoteAddress='127.0.0.1';

        RemotePort=25000;

        LocalAddress='';

        LocalPort=-1;

        SendBufferSize=-1;

        ByteOrder='LittleEndian';
        DataTypeWarningasError=0;


        OutputStatus(1,1)logical=false;
    end

    properties(Transient,Hidden)
        NetworkRoleSet=matlab.system.StringSet({'Server','Client'});%#ok<STRSET>
        ByteOrderSet=matlab.system.StringSet({'BigEndian','LittleEndian'});%#ok<STRSET>
    end

    properties(Nontunable,Hidden)
        Logo='Generic';
    end

    methods
        function obj=TCPWrite(varargin)
            coder.allowpcode('plain');
            obj@ioplayback.base.tcpip(varargin{:});
            setProperties(obj,nargin,varargin{:});

            obj.DataFileFormat='Raw-TimeStamp';
        end

        function set.SendBufferSize(obj,value)
            if value~=-1
                validateattributes(value,{'numeric'},...
                {'scalar','integer','>=',128,'<=',intmax('int32')},'','Send buffer size (bytes)');
            end
            obj.SendBufferSize=value;
        end



        function set.LocalPort(obj,value)


            validateattributes(value,{'numeric'},{'integer','scalar','nonnan','finite','nonempty','>=',-1,'<=',65535},'','Local Port');

            coder.internal.errorIf((value==0),'ioplayback:svd:ZeroPortNumber','Local');

            obj.LocalPort=value;
        end



        function set.RemotePort(obj,value)

            validateattributes(value,{'numeric'},{'integer','nonnan','scalar','finite','nonempty','positive','<=',65535},'','Remote Port');

            obj.RemotePort=value;
        end

        function set.RemoteAddress(obj,value)
            validateattributes(strtrim(value),{'char','string'},{'nonempty'},'','Remote address');

            obj.RemoteAddress=value;
        end
    end

    methods(Access=protected)
        function setupImpl(obj,varargin)
            if ioplayback.base.target
                data=varargin{1};

                obj.DataFileFormat='TimeStamp';
                obj.SignalInfo.Name='TCP_Write';
                obj.SignalInfo.Dimensions=[numel(data),1];
                obj.SignalInfo.DataType=class(data);
                obj.SignalInfo.IsComplex=false;
                setupImpl@ioplayback.SinkSystem(obj,data);
            else
                setReceiveBufferSize(obj,-1);
                setTransmitBufferSize(obj,obj.SendBufferSize);
                setNetworkByteOrder(obj,obj.ByteOrder);
                initTimeOut(obj,0);


                if isequal(obj.NetworkRole,'Server')
                    open(obj,obj.LocalPort,obj.LocalAddress,'NetworkRole',obj.NetworkRole);
                else
                    open(obj,obj.RemotePort,obj.RemoteAddress,obj.LocalPort);
                end
            end
        end

        function varargout=stepImpl(obj,varargin)
            if ioplayback.base.target
                status=coder.nullcopy(int32(0));
                if isequal(obj.SendSimulationInputTo,'Output port')
                    varargout{1}=varargin{1};
                else
                    stepImpl@ioplayback.SinkSystem(obj,varargin{1});
                end
            else
                if isequal(obj.NetworkRole,'Client')
                    status=isClientConnected(obj);
                    if~isequal(status,int32(0))
                        status=connectToServer(obj);
                    end

                    if isequal(status,int32(0))
                        status=write(obj,varargin{1},class(varargin{1}));
                    end
                else
                    status=write(obj,varargin{1},class(varargin{1}));
                end

                if isequal(obj.SendSimulationInputTo,'Output port')
                    varargout{1}=coder.nullcopy(varargin{1});
                end
            end

            if isequal(obj.SendSimulationInputTo,'Output port')
                if nargout>1
                    varargout{2}=status;
                end
            else
                if nargout>0
                    varargout{1}=status;
                end
            end
        end

        function releaseImpl(obj)
            if ioplayback.base.target
                releaseImpl@ioplayback.SinkSystem(obj);
            else
                close(obj);
            end
        end

        function validatePropertiesImpl(obj)
            if isequal(obj.NetworkRole,'Server')
                validateattributes(obj.LocalPort,{'numeric'},{'nonnegative','nonempty','finite','nonnan','>',0,'<=',65535},'','Local port');
            end
        end

        function flag=isInputSizeMutableImpl(~,~)
            flag=true;
        end

        function flag=isInputComplexityMutableImpl(~,~)
            flag=false;
        end

        function flag=isInputDataTypeMutableImpl(~,~)
            flag=false;
        end

        function flag=isInactivePropertyImpl(obj,prop)
            flag=isInactivePropertyImpl@ioplayback.SinkSystem(obj,prop);
            switch prop
            case 'RemoteAddress'
                if isequal(obj.NetworkRole,'Server')
                    flag=true;
                end
            case 'RemotePort'
                if isequal(obj.NetworkRole,'Server')
                    flag=true;
                end
            case 'LocalAddress'
                flag=true;
            case 'OutputStatus'
                flag=true;
            case 'NetworkRole'

            end
        end

        function validateInputsImpl(~,varargin)
            validateattributes(varargin{1},{'numeric','embedded.fi'},{'vector'},'','Data input');
        end

        function num=getNumOutputsImpl(obj)
            if isequal(obj.SendSimulationInputTo,'Output port')
                num=1;
            else
                num=0;
            end

            if obj.OutputStatus
                num=num+1;
            end
        end

        function varargout=getOutputNamesImpl(obj)
            if isequal(obj.SendSimulationInputTo,'Output port')
                varargout{1}='';
            end

            if obj.OutputStatus
                varargout{nargout}='status';
            end
        end

        function varargout=getOutputSizeImpl(obj)
            if isequal(obj.SendSimulationInputTo,'Output port')
                varargout{1}=propagatedInputSize(obj,1);
            end

            if obj.OutputStatus
                varargout{nargout}=[1,1];
            end
        end

        function varargout=getOutputDataTypeImpl(obj)
            if isequal(obj.SendSimulationInputTo,'Output port')
                varargout{1}=propagatedInputDataType(obj,1);
            end

            if obj.OutputStatus
                varargout{nargout}='int32';
            end
        end

        function varargout=isOutputComplexImpl(obj)
            if isequal(obj.SendSimulationInputTo,'Output port')
                varargout{1}=false;
            end

            if obj.OutputStatus
                varargout{nargout}=false;
            end
        end

        function varargout=isOutputFixedSizeImpl(obj)
            if isequal(obj.SendSimulationInputTo,'Output port')
                varargout{1}=propagatedInputFixedSize(obj,1);
            end

            if obj.OutputStatus
                varargout{nargout}=true;
            end
        end

        function num=getNumInputsImpl(~)
            num=1;
        end

        function varargout=getInputNamesImpl(~)
            varargout{1}='';
        end
    end

    methods(Access=protected)
        function maskDisplayCmds=getMaskDisplayImpl(obj)
            inport_label=[];
            num=getNumInputsImpl(obj);
            if num>0
                inputs=cell(1,num);
                [inputs{1:num}]=getInputNamesImpl(obj);
                for i=1:num
                    inport_label=[inport_label,'port_label(''input'',',num2str(i),',''',inputs{i},''');',newline];%#ok<AGROW>
                end
            end

            outport_label=[];
            num=getNumOutputsImpl(obj);
            if num>0
                outputs=cell(1,num);
                [outputs{1:num}]=getOutputNamesImpl(obj);
                for i=1:num
                    outport_label=[outport_label,'port_label(''output'',',num2str(i),',''',outputs{i},''');',newline];%#ok<AGROW>
                end
            end

            tcpname=['sprintf(''%s'',''',obj.NetworkRole,''')'];

            if isequal(obj.NetworkRole,'Client')
                remotename=['sprintf(''Addr: %s'',''',obj.RemoteAddress,''')'];
                remotename=['text(50, 30,','[',remotename,'],''texmode'',''off'',''horizontalAlignment'',''center'',''verticalAlignment'',''middle'');',newline];

                portname=['sprintf(''Port: %s'',''',num2str(obj.RemotePort),''')'];
                portname=['text(50, 15,','[',portname,'],''texmode'',''on'',''horizontalAlignment'',''center'',''verticalAlignment'',''middle'');',newline];
            else
                portname=['sprintf(''Port: %s'',''',num2str(obj.LocalPort),''')'];
                portname=['text(50, 30,','[',portname,'],''texmode'',''on'',''horizontalAlignment'',''center'',''verticalAlignment'',''middle'');',newline];
                remotename=[];
            end

            maskDisplayCmds=[...
            ['color(''white'');',newline]...
            ,['plot([100,100,100,100],[100,100,100,100]);',newline]...
            ,['plot([0,0,0,0],[0,0,0,0]);',newline]...
            ,['color(''blue'');',newline]...
            ,['text(99, 92, ''',obj.Logo,''', ''horizontalAlignment'', ''right'');',newline]...
            ,['color(''black'');',newline]...
            ,['text(50, 100,','[',tcpname,'],''texmode'',''off'',''horizontalAlignment'',''center'',''verticalAlignment'',''top'');',newline],...
            remotename,...
            portname,...
            inport_label,...
            outport_label,...
            ];
        end
    end

    methods(Static,Access=protected)
        function simMode=getSimulateUsingImpl

            simMode="Interpreted execution";
        end

        function flag=showSimulateUsingImpl

            flag=false;
        end

        function header=getHeaderImpl()
            header=matlab.system.display.Header(mfilename('class'),...
            'ShowSourceLink',false,...
            'Title','TCP/IP Send',...
            'Text',['Send TCP/IP packets to another TCP/IP host on an Internet network.',newline,newline...
            ,'The block accepts a one-dimensional array of type single, double, int8, int16, int32, uint8, uint16, or uint32.',newline,newline...
            ,'You can set the Network role parameter to Server or Client. In Server role, set the Local port parameter to the listening port of the local TCP/IP server.',newline,newline...
            ,'In Client role, set the Remote address and Remote port parameters to the IP address and port number of the receiving TCP/IP server on the same network.',newline...
            ,'Set the Local port parameter to the port number from which the receiving TCP host expects to receive packets. The default value, -1, sets the local port number to a random available port number and uses that port to send the packets.']);
        end

        function[groups,PropertyList]=getPropertyGroupsImpl

            NetworkRoleProp=matlab.system.display.internal.Property('NetworkRole','Description','Network role');

            LocalAddressProp=matlab.system.display.internal.Property('LocalAddress','Description','Local address');

            LocalPortProp=matlab.system.display.internal.Property('LocalPort','Description','Local port');

            RemoteAddressProp=matlab.system.display.internal.Property('RemoteAddress','Description','Remote address');

            RemotePortProp=matlab.system.display.internal.Property('RemotePort','Description','Remote port');

            SendBufferSizeProp=matlab.system.display.internal.Property('SendBufferSize','Description','Send buffer size (bytes)');

            ByteOrderProp=matlab.system.display.internal.Property('ByteOrder','Description','Byte order');

            OutputStatusProp=matlab.system.display.internal.Property('OutputStatus','Description','Enable status output port');


            PropertyListOut{1}=NetworkRoleProp;
            PropertyListOut{end+1}=RemoteAddressProp;
            PropertyListOut{end+1}=RemotePortProp;
            PropertyListOut{end+1}=LocalAddressProp;
            PropertyListOut{end+1}=LocalPortProp;
            PropertyListOut{end+1}=SendBufferSizeProp;
            PropertyListOut{end+1}=ByteOrderProp;
            PropertyListOut{end+1}=OutputStatusProp;


            Group=matlab.system.display.SectionGroup(...
            'Title','Main',...
            'PropertyList',PropertyListOut);


            SimPropertyList=ioplayback.SinkSystem.getPropertyGroupsList;
            groups=[Group,SimPropertyList];


            if nargout>1
                PropertyList=PropertyListOut;
            end
        end
    end
end


