classdef tcpip<handle







%#codegen

    properties(Access=protected)
        Hw=[];
        MW_TCP_HANDLE;

    end

    properties(Access=private)

        ServerAddress='';

        ServerPort=25000;

        ClientAddress='';

        ClientPort=25001;

        NetworkByteOrder='BigEndian';
    end



    properties(Access=private)
        SocketOpened=false;
        NetworkRoleServer=false;
        ClientOfServer=false;
    end

    properties(Access=protected)
        RxBufferSize=8192;
        TxBufferSize=8192;
        TimeOut=0;
    end

    methods(Hidden)
        function setNetworkByteOrder(obj,ByteOrder)
            coder.internal.errorIf(obj.SocketOpened,'ioplayback:svd:PortAlreadyOpened');
            coder.internal.prefer_const(ByteOrder);

            obj.NetworkByteOrder=validatestring(ByteOrder,{'BigEndian','LittleEndian'},'','Byte order');
        end
        function setServerAddress(obj,ServerAddress)
            coder.internal.errorIf(obj.SocketOpened,'ioplayback:svd:PortAlreadyOpened');
            coder.internal.prefer_const(ServerAddress);
            obj.ServerAddress=ServerAddress;
        end

        function setNetworkRole(obj,NetworkRole)
            coder.internal.errorIf(obj.SocketOpened,'ioplayback:svd:PortAlreadyOpened');
            coder.internal.prefer_const(NetworkRole);

            if isequal(NetworkRole,'Server')||isequal(NetworkRole,'server')||isequal(NetworkRole,'SERVER')
                obj.NetworkRoleServer=true;
            else
                obj.NetworkRoleServer=false;
            end
        end

        function setServerPort(obj,ServerPort)
            coder.internal.errorIf(obj.SocketOpened,'ioplayback:svd:PortAlreadyOpened');
            coder.internal.prefer_const(ServerPort);

            validateattributes(ServerPort,{'numeric'},{'nonnegative','nonnan','finite','scalar','nonempty','>',0,'<=',65535},'','ServerPort');

            obj.ServerPort=ServerPort;
        end

        function setClientAddress(obj,ClientAddress)
            coder.internal.errorIf(obj.SocketOpened,'ioplayback:svd:PortAlreadyOpened');
            coder.internal.prefer_const(ClientAddress);
            obj.ClientAddress=ClientAddress;
        end

        function setClientPort(obj,ClientPort)
            coder.internal.errorIf(obj.SocketOpened,'ioplayback:svd:PortAlreadyOpened');
            coder.internal.prefer_const(ClientPort);


            validateattributes(ClientPort,{'numeric'},{'integer','nonnan','finite','scalar','nonempty','>=',-1,'<=',65535},'','ClientPort');

            coder.internal.errorIf((ClientPort==0),'ioplayback:svd:InvalidPort','Invalid port number');

            obj.ClientPort=ClientPort;
        end

        function setReceiveBufferSize(obj,BufferSize)
            coder.internal.errorIf(obj.SocketOpened,'ioplayback:svd:PortAlreadyOpened');
            validateattributes(BufferSize,{'numeric'},{'integer','nonnan','nonempty','scalar','finite','>=',-1},'setReceiveBufferSize','Receive buffer size (bytes)');

            obj.RxBufferSize=BufferSize;
        end

        function setTransmitBufferSize(obj,BufferSize)
            coder.internal.errorIf(obj.SocketOpened,'ioplayback:svd:PortAlreadyOpened');
            validateattributes(BufferSize,{'numeric'},{'integer','nonnan','nonempty','scalar','finite','>=',-1},'setTransmitBufferSize','Tranmsit buffer size (bytes)');

            obj.TxBufferSize=BufferSize;
        end

        function initTimeOut(obj,TimeOut)
            coder.internal.errorIf(obj.SocketOpened,'ioplayback:svd:PortAlreadyOpened');
            validateattributes(TimeOut,{'numeric'},{'nonnan','nonempty','scalar','>=',-1},'setTimeOut','Time out (secs)');

            obj.TimeOut=TimeOut;
        end

        function OldTimeout=changeTimeOut(obj,TimeOut)
            validateattributes(TimeOut,{'numeric'},{'nonnan','nonempty','scalar','>=',-1},'setTimeOut','Time out (secs)');

            OldTimeout=coder.nullcopy(obj.TimeOut);

            if ioplayback.base.target
            else
                if TimeOut<0
                    TimeOutLoc=int32(-1);
                else
                    TimeOutLoc=int32(TimeOut*1000);
                end

                OldTimeoutLoc=coder.ceval('MW_TCP_SetTimeOut',obj.MW_TCP_HANDLE,TimeOutLoc);
                if nargout>0
                    OldTimeout=double(OldTimeoutLoc/1000);
                end
            end

            obj.TimeOut=TimeOut;
        end

        function ret=getNetworkByteOrder(obj)
            ret=obj.NetworkByteOrder;
        end

        function ret=getServerAddress(obj)
            ret=obj.ServerAddress;
        end

        function ret=getServerPort(obj)
            ret=obj.ServerPort;
        end

        function ret=getClientAddress(obj)
            ret=obj.ClientAddress;
        end

        function ret=getClientPort(obj)
            ret=obj.ClientPort;
        end

        function BufferSize=getReceiveBufferSize(obj)
            BufferSize=obj.RxBufferSize;
        end

        function BufferSize=getTransmitBufferSize(obj)
            BufferSize=obj.TxBufferSize;
        end

        function TimeOut=getTimeOut(obj)
            TimeOut=obj.TimeOut;
        end

        function NetworkRole=getNetworkRole(obj)
            if obj.NetworkRoleServer
                NetworkRole='Server';
            else
                NetworkRole='Client';
            end
        end
    end

    methods
        function set.ServerPort(obj,ServerPort)
            validateattributes(ServerPort,{'numeric'},{'nonnegative','nonnan','finite','nonempty','>',0,'<=',65535},'','ServerPort');

            obj.ServerPort=ServerPort;
        end

        function set.ServerAddress(obj,value)
            if isempty(value)
                obj.ServerAddress='';
            else
                validateattributes(value,{'char'},{'nonempty','vector'},'','Server address');
                obj.ServerAddress=value;
            end
        end

        function set.ClientPort(obj,ClientPort)

            validateattributes(ClientPort,{'numeric'},{'integer','nonnan','finite','nonempty','>=',-1,'<=',65535},'','ClientPort');

            coder.internal.errorIf((ClientPort==0),'ioplayback:svd:InvalidPort','Invalid port number');

            obj.ClientPort=ClientPort;
        end

        function set.ClientAddress(obj,value)
            if isempty(value)
                obj.ClientAddress='';
            else
                validateattributes(value,{'char'},{'nonempty','vector'},'','Client address');
                obj.ClientAddress=value;
            end
        end

        function obj=tcpip(varargin)
            coder.allowpcode('plain');
            coder.cinclude('mw_tcp.h');

            coder.internal.prefer_const(nargin);
            coder.internal.prefer_const(varargin{:});


            for ii=coder.unroll(1:2:numel(varargin))
                if isequal(varargin{ii},'NetworkRole')
                    if isequal(varargin{ii},'Server')||isequal(varargin{ii},'server')
                        obj.NetworkRoleServer=true;
                    else
                        obj.NetworkRoleServer=false;
                    end
                end
            end
        end

        function ret=isClient(obj)
            if isequal(obj.NetworkRoleServer,false)
                ret=true;
            else
                ret=false;
            end
        end







        function status=open(obj,varargin)
            coder.internal.errorIf(obj.SocketOpened,'ioplayback:svd:PortAlreadyOpened');

            coder.internal.prefer_const(nargin);

            hwobj=obj.Hw;
            if nargin==3
                if ischar(varargin{1})&&isequal(varargin{1},'NetworkRole')&&...
                    (isequal(varargin{2},'Server')||isequal(varargin{2},'server')||isequal(varargin{2},'SERVER'))

                    if~isempty(hwobj)
                        obj.NetworkRoleServer=true;
                        RemotePort=coder.const(-1);
                        RemoteAddress=coder.const('Any');
                        LocalAddress=coder.const(getLocalAddress(hwobj));
                        LocalPort=coder.const(getTCPServerPort(hwobj));
                    else
                        error('Hardware object is not defined.  For this option, object should be associated with an hardware.');
                    end
                else
                    obj.NetworkRoleServer=false;
                    RemotePort=coder.const(varargin{1});
                    RemoteAddress=coder.const(varargin{2});
                    LocalAddress=coder.const('Any');
                    LocalPort=coder.const(-1);
                end
            elseif nargin==4
                obj.NetworkRoleServer=false;
                RemotePort=coder.const(varargin{1});
                RemoteAddress=coder.const(varargin{2});
                LocalPort=coder.const(varargin{3});
                LocalAddress=coder.const('Any');
            elseif nargin==2
                obj.NetworkRoleServer=true;
                LocalPort=coder.const(varargin{1});
                LocalAddress=coder.const('Any');
                RemotePort=coder.const(-1);
                RemoteAddress=coder.const('Any');
            elseif nargin==5

                if~isequal(varargin{3},'NetworkRole')
                    coder.internal.error('Invalid arguments.');
                end
                if isequal(varargin{4},'Server')||isequal(varargin{4},'server')||isequal(varargin{4},'SERVER')
                    obj.NetworkRoleServer=true;
                    LocalPort=coder.const(varargin{1});
                    LocalAddress=coder.const(varargin{2});
                    RemotePort=coder.const(-1);
                    RemoteAddress=coder.const('Any');
                else
                    obj.NetworkRoleServer=false;
                    RemotePort=coder.const(varargin{1});
                    RemoteAddress=coder.const(varargin{2});
                    LocalPort=coder.const(-1);
                    LocalAddress=coder.const('Any');
                end
            elseif nargin==1
                if obj.NetworkRoleServer
                    LocalPort=coder.const(obj.ServerPort);
                    LocalAddress=coder.const(obj.ServerAddress);
                    RemotePort=coder.const(-1);
                    RemoteAddress=coder.const('Any');
                else
                    RemotePort=coder.const(obj.ServerPort);
                    RemoteAddress=coder.const(obj.ServerAddress);
                    LocalPort=coder.const(obj.ClientPort);
                    LocalAddress=coder.const(obj.ClientAddress);
                end
            else
                coder.internal.error('Invalid arguments.');
            end

            if obj.NetworkRoleServer
                setServerAddress(obj,LocalAddress);
                setServerPort(obj,LocalPort);
                setClientAddress(obj,RemoteAddress);
                setClientPort(obj,RemotePort);
            else
                setClientAddress(obj,LocalAddress);
                setClientPort(obj,LocalPort);
                setServerAddress(obj,RemoteAddress);
                setServerPort(obj,RemotePort);
            end


            status=coder.nullcopy(int32(0));

            if ioplayback.base.target

                obj.MW_TCP_HANDLE=uint32(0);

            else


                if isempty(LocalAddress)||isequal(LocalAddress,'Any')||isequal(LocalAddress,'ANY')||isequal(LocalAddress,'any')||isequal(LocalAddress,'IPADDRESS_ANY')
                    LocalAddressPtrLoc=coder.opaque('char_T *','NULL');
                else
                    LocalAddressLoc=coder.const(@obj.getIPAddress,LocalAddress);
                    LocalAddressPtrLoc=coder.opaque('char_T *');
                    LocalAddressPtrLoc=coder.ceval('(char_T *)',coder.rref(LocalAddressLoc));
                end


                if isempty(RemoteAddress)||isequal(RemoteAddress,'Any')||isequal(RemoteAddress,'ANY')||isequal(RemoteAddress,'any')||isequal(RemoteAddress,'IPADDRESS_ANY')
                    RemoteAddressPtrLoc=coder.opaque('char_T *','NULL');
                else
                    RemoteAddressLoc=coder.const(@obj.getIPAddress,RemoteAddress);
                    RemoteAddressPtrLoc=coder.opaque('char_T *');
                    RemoteAddressPtrLoc=coder.ceval('(char_T *)',coder.rref(RemoteAddressLoc));
                end



                if~isempty(hwobj)
                    if isempty(getMACAddress(hwobj))
                        MACAddressPtrLoc=coder.opaque('char_T *','NULL');
                    else
                        MACAddressLoc=coder.const(@obj.getIPAddress,getMACAddress(hwobj));
                        MACAddressPtrLoc=coder.opaque('char_T *');
                        MACAddressPtrLoc=coder.ceval('(char_T *)',coder.rref(MACAddressLoc));
                    end
                    coder.ceval('MW_Ethernet_InterfaceInit',MACAddressPtrLoc,LocalAddressPtrLoc,logical(getResolveAddressWithDHCP(hwobj)));
                end

                NetworkRoleLoc=coder.const(@obj.getNetWorkRoleEnum,obj.NetworkRoleServer);
                NetworkRoleLoc=coder.opaque('MW_TCP_NetworkRole_T',NetworkRoleLoc);



                obj.MW_TCP_HANDLE=coder.opaque('MW_VoidPtr_T','HeaderFile','mw_driver_basetypes.h');
                if obj.TimeOut<0
                    TimeOutLoc=int32(-1);
                else
                    TimeOutLoc=int32(obj.TimeOut*1000);
                end
                obj.MW_TCP_HANDLE=coder.ceval('MW_TCP_Open',LocalAddressPtrLoc,int32(LocalPort),RemoteAddressPtrLoc,int32(RemotePort),NetworkRoleLoc,int32(obj.RxBufferSize),int32(obj.TxBufferSize),TimeOutLoc,coder.wref(status));
            end

            if isequal(status,int32(0))
                obj.SocketOpened=true;
            else
                obj.SocketOpened=false;
            end

            if obj.SocketOpened
                if isClient(obj)
                    status=connectToServer(obj,RemoteAddress,RemotePort);
                else
                    status=configureForServer(obj,1,1);
                end
            end
        end


        function status=isClientConnected(obj)
            coder.internal.errorIf(~isClient(obj),'ioplayback:svd:NotAClient');

            status=coder.nullcopy(int32(0));

            if ioplayback.base.target

            else
                status=coder.ceval('MW_TCP_IsConnected',obj.MW_TCP_HANDLE);
            end
        end


        function[NumberOfData,varargout]=checkNumberOfAvailableData(obj,ExpectedNumberOfData,DataType)


            if nargin>2
                ioplayback.base.ByteOrder.allowedDataType(DataType);
            else
                DataType='uint8';
            end

            validateattributes(ExpectedNumberOfData,{'numeric'},{'nonnegative','integer','nonnan','nonempty','finite','>',0},'checkNumberOfAvailableData','Expected number of data');

            status=coder.nullcopy(int32(0));
            NumberOfData=coder.nullcopy(uint32(ExpectedNumberOfData));
            if ioplayback.base.target

            else
                if nargout==1
                    StatusPtrLoc=coder.opaque('MW_TCP_Status_T *','NULL');
                else
                    StatusPtrLoc=coder.wref(status);
                end
                NumberOfData=coder.ceval('MW_TCP_CheckNumberOfAvailableBytes',obj.MW_TCP_HANDLE,uint32(ExpectedNumberOfData*ioplayback.base.ByteOrder.getNumberOfBytes(DataType)),StatusPtrLoc);
                NumberOfData=(NumberOfData-mod(NumberOfData,uint32(ioplayback.base.ByteOrder.getNumberOfBytes(DataType))))/uint32(ioplayback.base.ByteOrder.getNumberOfBytes(DataType));
            end

            if nargout>1
                varargout{1}=status;
            end
        end


        function[NumberOfData,varargout]=getNumberOfAvailableBytesClientWithServer(obj,ClientAddress,ClientPort)
            coder.internal.errorIf(isClient(obj),'ioplayback:svd:NotAServer');

            status=coder.nullcopy(int32(0));
            NumberOfData=coder.nullcopy(uint32(0));
            if ioplayback.base.target

            else
                if isempty(ClientAddress)||isequal(ClientAddress,'Any')||isequal(ClientAddress,'ANY')||isequal(ClientAddress,'any')||isequal(ClientAddress,'IPADDRESS_ANY')
                    ClientAddressPtrLoc=coder.opaque('char_T *','NULL');
                else
                    ClientAddressLoc=coder.const(@obj.getIPAddress,ClientAddress);
                    ClientAddressPtrLoc=coder.opaque('char_T *');
                    ClientAddressPtrLoc=coder.ceval('(char_T *)',coder.rref(ClientAddressLoc));
                end

                status=coder.ceval('MW_TCP_GetNumberOfAvailableBytesClient',obj.MW_TCP_HANDLE,ClientAddressPtrLoc,uint32(ClientPort),coder.wref(NumberOfData));
            end

            if nargin>1
                varargout{1}=status;
            end
        end


        function status=write(obj,TxData,DataType)
            if nargin>2
                ioplayback.base.ByteOrder.allowedDataType(DataType);
            else
                DataType='uint8';
            end

            status=coder.nullcopy(int32(0));


            if isequal(class(TxData),'int8')||isequal(class(TxData),'uint8')
                TxDataLoc=TxData;
            else
                TxDataLoc=cast(TxData,DataType);
            end


            if isequal(obj.NetworkByteOrder,'BigEndian')
                TxDataLocChar=ioplayback.base.ByteOrder.getSwappedBytes(TxDataLoc);
            else
                TxDataLocChar=ioplayback.base.ByteOrder.concatenateBytes(TxDataLoc,'uint8');
            end

            if ioplayback.base.target

            else
                status=coder.ceval('MW_TCP_Write',obj.MW_TCP_HANDLE,coder.rref(TxDataLocChar),uint32(numel(TxDataLocChar)));
            end
        end

        function[RxData,varargout]=read(obj,NumberOfElements,DataType)
            if nargin>2
                ioplayback.base.ByteOrder.allowedDataType(DataType);
            else
                DataType='uint8';
            end

            validateattributes(NumberOfElements,{'numeric'},{'nonempty','nonnan','finite','positive'},'read','Number of elements');

            RxDataLoc=coder.nullcopy(uint8(zeros(NumberOfElements*ioplayback.base.ByteOrder.getNumberOfBytes(DataType),1)));
            status=coder.nullcopy(int32(0));
            if ioplayback.base.target

            else
                status=coder.ceval('MW_TCP_Read',obj.MW_TCP_HANDLE,coder.ref(RxDataLoc),uint32(NumberOfElements*ioplayback.base.ByteOrder.getNumberOfBytes(DataType)));
            end


            if isequal(obj.NetworkByteOrder,'BigEndian')
                RxData=ioplayback.base.ByteOrder.changeByteOrder(RxDataLoc,DataType);
            else
                RxData=ioplayback.base.ByteOrder.concatenateBytes(RxDataLoc,DataType);
            end

            if nargout>1
                varargout{1}=status;
            end
        end



        function status=close(obj)
            status=coder.nullcopy(int32(0));

            if obj.SocketOpened
                if ioplayback.base.target

                else
                    status=coder.ceval('MW_TCP_Close',obj.MW_TCP_HANDLE);
                end

                if isequal(status,int32(0))
                    obj.SocketOpened=false;
                end
            end
        end






    end

    methods(Access=private,Hidden)






































        function status=isClientConnectedWithServer(obj,RemoteAddress,RemotePort)
            coder.internal.errorIf(isClient(obj),'ioplayback:svd:NotAServer');

            status=coder.nullcopy(int32(0));

            if ioplayback.base.target

            else
                RemoteAddressLoc=coder.const(@obj.getIPAddress,RemoteAddress);
                RemoteAddressPtrLoc=coder.opaque('char_T *');
                RemoteAddressPtrLoc=coder.ceval('(char_T *)',coder.rref(RemoteAddressLoc));
                status=coder.ceval('MW_TCP_IsClientConnectedWithServer',obj.MW_TCP_HANDLE,RemoteAddressPtrLoc,int32(RemotePort));
            end
        end
        function status=writeToClient(obj,RemoteAddress,RemotePort,TxData,DataType)
            if nargin>4
                ioplayback.base.ByteOrder.allowedDataType(DataType);
            else
                DataType='uint8';
            end

            status=isClientConnectedWithServer(obj,RemoteAddress,RemotePort);

            if isequal(status,int32(0))

                if isequal(class(TxData),'int8')||isequal(class(TxData),'uint8')
                    TxDataLoc=TxData;
                else
                    TxDataLoc=cast(TxData,DataType);
                end


                if isequal(obj.NetworkByteOrder,'BigEndian')
                    TxDataLocChar=ioplayback.base.ByteOrder.getSwappedBytes(TxDataLoc);
                else
                    TxDataLocChar=ioplayback.base.ByteOrder.concatenateBytes(TxDataLoc,'uint8');
                end

                if ioplayback.base.target

                else
                    status=coder.ceval('MW_TCP_TransmitToClient',obj.MW_TCP_HANDLE,RemoteAddress,RemotePort,coder.rref(TxDataLocChar),uint32(numel(TxDataLocChar)));
                end
            end
        end

        function[RxData,varargout]=readFromClient(obj,RemoteAddress,RemotePort,NumberOfElements,DataType)
            if nargin>4
                ioplayback.base.ByteOrder.allowedDataType(DataType);
            else
                DataType='uint8';
            end

            validateattributes(NumberOfElements,{'numeric'},{'nonempty','nonnan','finite','positive'},'read','Number of elements');

            status=isClientConnectedWithServer(obj,RemoteAddress,RemotePort);
            if isequal(status,int32(0))
                RxDataLoc=coder.nullcopy(zeros(1,NumberOfElements*ioplayback.base.ByteOrder.getNumberOfBytes(DataType)));

                if ioplayback.base.target

                else
                    status=coder.ceval('MW_TCP_ReceiveFromClient',obj.MW_TCP_HANDLE,coder.wref(RxDataLoc),NumberOfElements*ioplayback.base.ByteOrder.getNumberOfBytes(DataType));
                end


                if isequal(obj.NetworkByteOrder,'BigEndian')
                    RxData=ioplayback.base.ByteOrder.changeByteOrder(RxDataLoc,DataType);
                else
                    RxData=ioplayback.base.ByteOrder.concatenateBytes(RxDataLoc,DataType);
                end
            end

            if nargout>1
                varargout{1}=status;
            end
        end
        function status=closeClientWithServer(obj,RemoteAddress,RemotePort)
            status=isClientConnectedWithServer(obj,RemoteAddress,RemotePort);

            if isequal(status,int32(0))
                if ioplayback.base.target

                else
                    status=coder.ceval('MW_TCP_CloseClientWithServer',obj.MW_TCP_HANDLE,RemoteAddress,RemotePort);
                end
            end
        end
    end

    methods

        function status=configureForServer(obj,QueueLength,MaxAllowedClients)
            coder.internal.errorIf(isClient(obj),'ioplayback:svd:NotAServer');

            validateattributes(QueueLength,{'numeric'},{'nonempty','nonnan','finite','positive','scalar'},'configureForServer','Queue length');
            validateattributes(MaxAllowedClients,{'numeric'},{'nonempty','nonnan','finite','positive','scalar'},'configureForServer','Maximum allowed clients');

            status=coder.nullcopy(int32(0));

            if ioplayback.base.target

            else

                status=coder.ceval('MW_TCP_ConfigureForServerAndStart',obj.MW_TCP_HANDLE,int32(QueueLength),int32(MaxAllowedClients));
            end
        end


        function status=connectToServer(obj,RemoteIPAddress,RemotePort)
            coder.internal.errorIf(~isClient(obj),'ioplayback:svd:NotAClient');

            status=coder.nullcopy(int32(0));
            if nargin==1
                RemoteIPAddress=getServerAddress(obj);
                RemotePort=getServerPort(obj);
            end
            if ioplayback.base.target

            else

                RemoteAddressLoc=coder.const(@obj.getIPAddress,RemoteIPAddress);
                RemoteAddressPtrLoc=coder.opaque('char_T *');
                RemoteAddressPtrLoc=coder.ceval('(char_T *)',coder.rref(RemoteAddressLoc));
                status=coder.ceval('MW_TCP_ConnectToServer',obj.MW_TCP_HANDLE,RemoteAddressPtrLoc,uint32(RemotePort));
            end
        end
    end


    methods(Static,Access=protected)
        function ret=getNetWorkRoleEnum(NetworkRole)
            coder.inline('always');
            if isequal(NetworkRole,'Server')||isequal(NetworkRole,'server')||isequal(NetworkRole,true)
                ret='MW_TCP_SERVER';
            else
                ret='MW_TCP_CLIENT';
            end
        end

        function ret=getIPAddress(IPAddress)
            coder.inline('always');
            ret=[IPAddress,char(0)];
        end
    end

    methods(Access=private)
        function pvParse(obj,varargin)
            if nargin>1
                if~isempty(varargin)
                    if rem(length(varargin),2)
                        matlab.system.internal.error('MATLAB:system:invalidPVPairs');
                    end


                    for ii=1:2:numel(varargin)
                        obj.(varargin{ii})=varargin{ii+1};
                    end
                end
            end
        end
    end

    methods(Access=public,Static)
        function props=matlabCodegenNontunableProperties(~)
            props={'NetworkRoleServer','ServerAddress','ServerPort','ClientAddress','ClientPort','RxBufferSize','TxBufferSize','TimeOut','NetworkByteOrder'};
        end
    end
end

