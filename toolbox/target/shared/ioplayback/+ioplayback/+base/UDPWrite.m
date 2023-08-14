classdef UDPWrite<ioplayback.base.udp&ioplayback.SinkSystem










%#codegen


    properties(Nontunable)

        RemoteAddress='127.0.0.1';

        RemotePort=25000;

        LocalPort=-1;

        SendBufferSize=-1;

        ByteOrder='LittleEndian';
        DataTypeWarningasError=0;


        OutputStatus(1,1)logical=false;
    end

    properties(Transient,Hidden)
        ByteOrderSet=matlab.system.StringSet({'BigEndian','LittleEndian'});%#ok<STRSET>
    end

    properties(Nontunable,Hidden)
        Logo='Generic';
    end

    methods
        function obj=UDPWrite(varargin)
            coder.allowpcode('plain');
            obj@ioplayback.base.udp(varargin{:});
            setProperties(obj,nargin,varargin{:});

            obj.DataFileFormat='TimeStamp';
        end

        function set.SendBufferSize(obj,value)
            if value~=-1
                validateattributes(value,{'numeric'},...
                {'scalar','integer','>=',128,'<=',intmax('int32')},'','Send buffer size (bytes)');
            end
            obj.SendBufferSize=value;
        end



        function set.LocalPort(obj,value)


            validateattributes(value,{'numeric'},{'integer','nonnan','finite','nonempty','scalar','>=',-1,'<=',65535},'','Local Port');

            coder.internal.errorIf((value==0),'ioplayback:svd:ZeroPortNumber','Local');

            obj.LocalPort=value;
        end



        function set.RemotePort(obj,value)

            validateattributes(value,{'numeric'},{'integer','nonnan','finite','nonempty','scalar','>',0,'<=',65535},'','Remote Port');

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
                obj.SignalInfo.Name='UDPWrite';
                obj.SignalInfo.Dimensions=[numel(data),1];
                obj.SignalInfo.DataType=class(data);
                obj.SignalInfo.IsComplex=false;
                setupImpl@ioplayback.SinkSystem(obj,data);
            else
                setReceiveBufferSize(obj,-1);
                setTransmitBufferSize(obj,obj.SendBufferSize);
                setNetworkByteOrder(obj,obj.ByteOrder);
                initTimeOut(obj,Inf);


                open(obj,obj.LocalPort);

                setRemoteConnectionDetails(obj,obj.RemoteAddress,obj.RemotePort);
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
                status=write(obj,varargin{1},class(varargin{1}));
            end

            if isequal(obj.SendSimulationInputTo,'Output port')
                varargout{1}=coder.nullcopy(varargin{1});
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

        function validatePropertiesImpl(~)

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
            case 'OutputStatus'
                flag=true;
            end
        end

        function validateInputsImpl(obj,varargin)%#ok<INUSL>
            coder.internal.errorIf(numel(varargin{1})>floor(65507/ioplayback.base.ByteOrder.getNumberOfBytes(class(varargin{1}))),...
            'ioplayback:general:UDPIncorrectNumel',numel(varargin{1}),class(varargin{1}));
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

            remotename=['sprintf(''Addr: %s'',''',obj.RemoteAddress,''')'];
            portname=['sprintf(''Port: %s'',''',num2str(obj.RemotePort),''')'];

            maskDisplayCmds=[...
            ['color(''white'');',newline]...
            ,['plot([100,100,100,100],[100,100,100,100]);',newline]...
            ,['plot([0,0,0,0],[0,0,0,0]);',newline]...
            ,['color(''blue'');',newline]...
            ,['text(99, 92, ''',obj.Logo,''', ''horizontalAlignment'', ''right'');',newline]...
            ,['color(''black'');',newline]...
            ,['text(50, 30, ','[',remotename,'],''texmode'',''off'',''horizontalAlignment'',''center'',''verticalAlignment'',''middle'');',newline],...
            ['text(50, 15,','[',portname,'],''texmode'',''off'',''horizontalAlignment'',''center'',''verticalAlignment'',''middle'');',newline],...
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
            'Title','UDP Send',...
            'Text',['Send UDP packets to another UDP host on an Internet network.',newline,newline...
            ,'The block accepts a one-dimensional array of type uint8, int8, uint16, int16, uint32, int32, single, or double.',newline,newline...
            ,'Set the Remote address and Remote port parameters to the IP address and port number of the receiving UDP host.',newline,newline...
            ,'Set the Local port parameter to the port number from which the receiving UDP host expects to receive packets. The default value, -1, sets the local port number to a random available port number and uses that port to send the packets.',newline]);
        end

        function[groups,PropertyList]=getPropertyGroupsImpl

            RemoteAddressProp=matlab.system.display.internal.Property('RemoteAddress','Description','Remote IP address (255.255.255.255 for broadcast)');

            RemotePortProp=matlab.system.display.internal.Property('RemotePort','Description','Remote port');

            LocalPortProp=matlab.system.display.internal.Property('LocalPort','Description','Local port');

            SendBufferSizeProp=matlab.system.display.internal.Property('SendBufferSize','Description','Send buffer size (bytes)');

            ByteOrderProp=matlab.system.display.internal.Property('ByteOrder','Description','Byte order');

            OutputStatusProp=matlab.system.display.internal.Property('OutputStatus','Description','Enable status output port');


            PropertyListOut{1}=RemoteAddressProp;
            PropertyListOut{end+1}=RemotePortProp;
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


