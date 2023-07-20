classdef udp<handle







%#codegen


    properties

    end

    properties(Access=protected)
        Hw=[];
        MW_UDP_HANDLE;
    end

    properties(Access=private)

        NetworkByteOrder='BigEndian';
    end



    properties(Access=private)
        SocketOpened=false;
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

                OldTimeoutLoc=coder.ceval('MW_UDP_SetTimeOut',obj.MW_UDP_HANDLE,TimeOutLoc);
                if nargout>0
                    OldTimeout=double(OldTimeoutLoc/1000);
                end
            end

            obj.TimeOut=TimeOut;
        end

        function ret=getNetworkByteOrder(obj)
            ret=obj.NetworkByteOrder;
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
    end

    methods
        function obj=udp(varargin)
            coder.allowpcode('plain');
            coder.cinclude('mw_udp.h');

            coder.internal.prefer_const(nargin);
            coder.internal.prefer_const(varargin{:});

            pvParse(obj,varargin{:});
        end





        function status=open(obj,varargin)
            coder.internal.errorIf(obj.SocketOpened,'ioplayback:svd:PortAlreadyOpened');
            narginchk(1,3);

            coder.internal.prefer_const(nargin);

            hwobj=obj.Hw;
            if nargin==3
                LocalAddress=coder.const(varargin{2});
                LocalPort=coder.const(varargin{1});
            elseif nargin==2
                LocalPort=coder.const(varargin{1});
                LocalAddress=coder.const('Any');
            else
                LocalAddress=coder.const('Any');
                LocalPort=coder.const(-1);
            end


            status=coder.nullcopy(int32(0));

            if ioplayback.base.target

                obj.MW_UDP_HANDLE=uint32(0);
            else


                if isempty(LocalAddress)||isequal(LocalAddress,'Any')||isequal(LocalAddress,'ANY')||isequal(LocalAddress,'any')||isequal(LocalAddress,'IPADDRESS_ANY')
                    LocalAddressPtrLoc=coder.opaque('char_T *','NULL');
                else
                    LocalAddressLoc=coder.const(@obj.getIPAddress,LocalAddress);
                    LocalAddressPtrLoc=coder.opaque('char_T *');
                    LocalAddressPtrLoc=coder.ceval('(char_T *)',coder.rref(LocalAddressLoc));
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


                obj.MW_UDP_HANDLE=coder.opaque('MW_VoidPtr_T','HeaderFile','mw_driver_basetypes.h');
                if obj.TimeOut<0
                    TimeOutLoc=int32(-1);
                else
                    TimeOutLoc=int32(obj.TimeOut*1000);
                end
                obj.MW_UDP_HANDLE=coder.ceval('MW_UDP_Open',LocalAddressPtrLoc,int32(LocalPort),int32(obj.RxBufferSize),int32(obj.TxBufferSize),TimeOutLoc,coder.wref(status));
            end

            if isequal(status,int32(0))
                obj.SocketOpened=true;
            else
                obj.SocketOpened=false;
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
            NumberOfData=coder.nullcopy(uint32(0));
            if ioplayback.base.target
                NumberOfData=coder.nullcopy(uint32(ExpectedNumberOfData));
            else
                if nargout==1
                    StatusPtrLoc=coder.opaque('MW_UDP_Status_T *','NULL');
                else
                    StatusPtrLoc=coder.wref(status);
                end
                NumberOfData=coder.ceval('MW_UDP_CheckNumberOfAvailableBytes',obj.MW_UDP_HANDLE,uint32(ExpectedNumberOfData*ioplayback.base.ByteOrder.getNumberOfBytes(DataType)),StatusPtrLoc);
                NumberOfData=(NumberOfData-mod(NumberOfData,uint32(ioplayback.base.ByteOrder.getNumberOfBytes(DataType))))/uint32(ioplayback.base.ByteOrder.getNumberOfBytes(DataType));
            end

            if nargout>1
                varargout{1}=status;
            end
        end


        function status=write(obj,TxData,DataType)
            if nargin>2
                ioplayback.base.ByteOrder.allowedDataType(DataType);
            else
                DataType='uint8';
            end

            validateattributes(numel(TxData),{'numeric'},...
            {'nonnan','finite','nonempty','scalar','positive','integer','<=',floor(65507/ioplayback.base.ByteOrder.getNumberOfBytes(DataType))},'',['Transmit data size of type ',DataType]);

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
                status=coder.ceval('MW_UDP_Write',obj.MW_UDP_HANDLE,coder.rref(TxDataLocChar),uint32(numel(TxDataLocChar)));
            end
        end

        function[RxData,varargout]=read(obj,NumberOfElements,DataType)
            if nargin>2
                ioplayback.base.ByteOrder.allowedDataType(DataType);
            else
                DataType='uint8';
            end

            validateattributes(NumberOfElements,{'numeric'},{'nonempty','nonnan','finite','positive','scalar','integer'},'read','Number of elements');
            validateattributes(NumberOfElements,{'numeric'},...
            {'nonnan','finite','<=',floor(65507/ioplayback.base.ByteOrder.getNumberOfBytes(DataType))},'',['Number of elements to read of type ',DataType]);
            RxDataLoc=coder.nullcopy(uint8(zeros(NumberOfElements*ioplayback.base.ByteOrder.getNumberOfBytes(DataType),1)));
            status=coder.nullcopy(int32(0));
            if ioplayback.base.target

            else
                status=coder.ceval('MW_UDP_Read',obj.MW_UDP_HANDLE,coder.ref(RxDataLoc),uint32(NumberOfElements*ioplayback.base.ByteOrder.getNumberOfBytes(DataType)));
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

        function status=writeToRemote(obj,RemoteAddress,RemotePort,TxData,DataType)
            if nargin>4
                ioplayback.base.ByteOrder.allowedDataType(DataType);
            else
                DataType='uint8';
            end
            status=coder.nullcopy(int32(0));

            validateattributes(RemotePort,{'numeric'},{'nonempty','finite','nonnan','scalar','positive','integer','<=',65535},'writeToRemote','Remort port');
            validateattributes(numel(TxData),{'numeric'},...
            {'nonnan','finite','nonempty','scalar','positive','integer','<=',floor(65507/ioplayback.base.ByteOrder.getNumberOfBytes(DataType))},'',['Transmit data size of type ',DataType]);


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
                if isempty(RemoteAddress)
                    RemoteAddressPtrLoc=coder.opaque('char_T *','NULL');
                else
                    RemoteAddressLoc=coder.const(@obj.getIPAddress,RemoteAddress);
                    RemoteAddressPtrLoc=coder.opaque('char_T *');
                    RemoteAddressPtrLoc=coder.ceval('(char_T *)',coder.rref(RemoteAddressLoc));
                end

                status=coder.ceval('MW_UDP_WriteToRemote',obj.MW_UDP_HANDLE,RemoteAddressPtrLoc,uint16(RemotePort),coder.rref(TxDataLocChar),uint32(numel(TxDataLocChar)));
            end
        end

        function[RxData,varargout]=readFromRemote(obj,RemoteAddress,RemotePort,NumberOfElements,DataType)
            if nargin>4
                ioplayback.base.ByteOrder.allowedDataType(DataType);
            else
                DataType='uint8';
            end

            validateattributes(NumberOfElements,{'numeric'},{'nonempty','nonnan','finite','positive','integer','scalar'},'readFromRemote','Number of elements');
            validateattributes(RemotePort,{'numeric'},{'nonempty','finite','nonnan','scalar','positive','integer','<=',65535},'readFromRemote','Remort port');
            validateattributes(NumberOfElements,{'numeric'},...
            {'nonnan','finite','<=',floor(65507/ioplayback.base.ByteOrder.getNumberOfBytes(DataType))},'',['Number of elements to read of type ',DataType]);
            status=coder.nullcopy(int32(0));

            RxDataLoc=coder.nullcopy(zeros(1,NumberOfElements*ioplayback.base.ByteOrder.getNumberOfBytes(DataType),'uint8'));

            if ioplayback.base.target

            else
                if isempty(RemoteAddress)
                    RemoteAddressPtrLoc=coder.opaque('char_T *','NULL');
                else
                    RemoteAddressLoc=coder.const(@obj.getIPAddress,RemoteAddress);
                    RemoteAddressPtrLoc=coder.opaque('char_T *');
                    RemoteAddressPtrLoc=coder.ceval('(char_T *)',coder.rref(RemoteAddressLoc));
                end

                status=coder.ceval('MW_UDP_ReadFromRemote',obj.MW_UDP_HANDLE,RemoteAddressPtrLoc,uint16(RemotePort),coder.wref(RxDataLoc),NumberOfElements*ioplayback.base.ByteOrder.getNumberOfBytes(DataType));
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

        function status=setRemoteConnectionDetails(obj,RemoteAddress,RemotePort)
            validateattributes(RemotePort,{'numeric'},{'nonempty','finite','nonnan','scalar','positive','integer','<=',65535},'readFromRemote','Remort port');

            status=coder.nullcopy(int32(0));

            if ioplayback.base.target

            else
                if isempty(RemoteAddress)
                    RemoteAddressPtrLoc=coder.opaque('char_T *','NULL');
                else
                    RemoteAddressLoc=coder.const(@obj.getIPAddress,RemoteAddress);
                    RemoteAddressPtrLoc=coder.opaque('char_T *');
                    RemoteAddressPtrLoc=coder.ceval('(char_T *)',coder.rref(RemoteAddressLoc));
                end
                status=coder.opaque('MW_UDP_Status_T');
                status=coder.ceval('MW_UDP_ConnectToRemote',obj.MW_UDP_HANDLE,RemoteAddressPtrLoc,uint16(RemotePort));
            end
        end

        function status=close(obj)
            status=coder.nullcopy(int32(0));

            if obj.SocketOpened
                if ioplayback.base.target

                else
                    status=coder.ceval('MW_UDP_Close',obj.MW_UDP_HANDLE);
                end

                if isequal(status,int32(0))
                    obj.SocketOpened=false;
                end
            end
        end




    end


    methods(Static,Access=protected)
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

