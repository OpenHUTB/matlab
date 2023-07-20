classdef EthernetSend<matlab.System&coder.ExternalDependency





%#codegen


    properties(Nontunable)
        InterfaceName(1,:)char
        OverwriteSrcMACAddress(1,1)logical
        MessageIn(1,1)logical=false;
        SampleTime(1,1)=-1;
    end

    properties(Access=private)
        BPFDevicePtr=uint64(0);
    end

    methods

        function obj=EthernetSend(varargin)
            coder.allowpcode('plain');

            setProperties(obj,nargin,varargin{:})
        end
    end

    methods(Access=protected)

        function interface=getInterfaceImpl(obj)
            import matlab.system.interface.*;%#ok<EMIMP>
            if obj.MessageIn
                interface=Input("in1",Message);
            else
                interface=[Input("in1",Data),...
                Input("in2",Data)];
            end
        end

        function num=getNumInputsImpl(obj)
            if obj.MessageIn
                num=1;
            else
                num=2;
            end
        end

        function flag=isInputSizeMutableImpl(~,~)
            flag=false;
        end

        function flag=isInputComplexityMutableImpl(~,~)
            flag=false;
        end

        function flag=isInputDataTypeMutableImpl(~,~)
            flag=false;
        end

        function varargout=getInputNamesImpl(obj)
            if obj.MessageIn
                varargout{1}='';
            else
                varargout{1}=getString(message('slrealtime:Ethernet:Data'));
                varargout{2}=getString(message('slrealtime:Ethernet:Length'));
            end
        end

        function setupImpl(obj)
            if coder.target('MATLAB')
                return;
            end
            obj.BPFDevicePtr=uint64(0);
        end

        function resetImpl(obj)
            if coder.target('MATLAB')
                return;
            end

            coder.cinclude("rawEth.hpp");
            if coder.target('rtw')

                interface=[obj.InterfaceName,0];



                obj.BPFDevicePtr=coder.ceval("initializeRawEth",...
                coder.ref(interface),...
                obj.OverwriteSrcMACAddress,...
                0,...
                coder.opaque('char *','NULL'));
            end
        end

        function stepImpl(obj,varargin)
            if coder.target('MATLAB')
                return;
            end

            if obj.MessageIn
                stepImplM(obj,varargin{1});
            else
                stepImplS(obj,varargin{1},varargin{2});
            end
        end

        function stepImplM(obj,msg)
            if~isfield(msg,'Length')||~isfield(msg,'Data')
                coder.internal.assert(false,'slrealtime:Ethernet:InvalidInputType')
            end


            nMsg=numel(msg);
            for iMsg=1:nMsg

                length=msg(iMsg).Length;
                coder.internal.assert(isa(length,'uint16'),'slrealtime:Ethernet:InputNotPacket')
                coder.internal.assert(isscalar(length),'slrealtime:Ethernet:InputNotPacket')

                data=msg(iMsg).Data;
                coder.internal.assert(isa(data,'uint8'),'slrealtime:Ethernet:InputNotPacket')
                dataWidth=numel(data);
                coder.internal.assert(dataWidth>13&&dataWidth<1515,'slrealtime:Ethernet:IncorrectDataInputSize')

                if length<uint16(14)
                    length=uint16(14);
                end

                if length>dataWidth
                    length=uint16(dataWidth);
                end

                sendEthernetData(obj,data,length);
            end
        end

        function stepImplS(obj,data,length)

            coder.internal.assert(isa(length,'double'),'slrealtime:Ethernet:InputNotDouble')
            coder.internal.assert(isscalar(length),'slrealtime:Ethernet:IncorrectLengthInputSize')

            coder.internal.assert(isa(data,'uint8'),'slrealtime:Ethernet:InputNotUint8')
            dataWidth=numel(data);
            coder.internal.assert(dataWidth>13&&dataWidth<1515,'slrealtime:Ethernet:IncorrectDataInputSize')

            if length<14
                length=14;
            end

            if length>dataWidth
                length=dataWidth;
            end

            sendEthernetData(obj,data,length);
        end

        function sendEthernetData(obj,data,length)
            coder.cinclude("rawEth.hpp");
            if coder.target('rtw')
                coder.ceval("writeRawEth",obj.BPFDevicePtr,coder.rref(data),length);
            end
        end

        function releaseImpl(obj)
            if coder.target('MATLAB')
                return;
            end

            coder.cinclude("rawEth.hpp");
            if coder.target('rtw')
                coder.ceval("terminateRawEth",obj.BPFDevicePtr);
            end
        end


        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);
        end

        function loadObjectImpl(obj,s,wasLocked)

            loadObjectImpl@matlab.System(obj,s,wasLocked);
        end



        function sts=getSampleTimeImpl(obj)
            if obj.SampleTime==-1
                sts=createSampleTime(obj,'ErrorOnPropagation','Controllable');
            else
                sts=obj.createSampleTime("Type","Discrete",...
                "SampleTime",obj.SampleTime);
            end
        end

        function icon=getIconImpl(obj)

            icon=getString(message('slrealtime:Ethernet:SendMaskIcon',obj.InterfaceName));
        end
    end

    methods(Static,Access=protected)


        function header=getHeaderImpl

            header=matlab.system.display.Header(mfilename("class"),...
            'ShowSourceLink',false,...
            'Title',getString(message('slrealtime:Ethernet:SendTitle')),...
            'Text',getString(message('slrealtime:Ethernet:SendDesc')));
        end

        function group=getPropertyGroupsImpl


            InterfaceNameProp=matlab.system.display.internal.Property('InterfaceName','Description',...
            getString(message('slrealtime:Ethernet:InterfaceName')));
            OverwriteSrcMACAddressProp=matlab.system.display.internal.Property('OverwriteSrcMACAddress',...
            'Description',getString(message('slrealtime:Ethernet:OverwriteSrcMACAddress')));
            MessageInProp=matlab.system.display.internal.Property('MessageIn','Description',...
            getString(message('slrealtime:Ethernet:EnableMessages')));
            SampleTimeProp=matlab.system.display.internal.Property('SampleTime','Description',...
            getString(message('slrealtime:Ethernet:SampleTime')));

            group=matlab.system.display.Section('Title','Parameters',...
            'PropertyList',{...
            InterfaceNameProp,...
            OverwriteSrcMACAddressProp,...
            MessageInProp,...
SampleTimeProp
            });
        end

        function simMode=getSimulateUsingImpl
            simMode="Interpreted execution";
        end

        function flag=showSimulateUsingImpl
            flag=false;
        end
    end

    methods(Static)

        function extname=getDescriptiveName(~)
            extname='';
        end

        function tf=isSupportedContext(~)
            tf=false;
        end

        function updateBuildInfo(buildInfo,buildContext)


            if~strcmp(get_param(buildContext.ConfigData,'SystemTargetFile'),'slrealtime.tlc')
                error(message('slrealtime:Ethernet:CodeGenOnly'));
            end

            if buildContext.isCodeGenTarget('rtw')

                hdrFilePath=fullfile(matlabroot,"extern","include","slrealtime","libsrc","IP");
                buildInfo.addIncludePaths(hdrFilePath);


                linkFile={'libslrealtime_libsrc_ip_slrt_x64.a'};
                libDir=fullfile(matlabroot,"toolbox","slrealtime","simulink","blocks","dist",computer('arch'),'lib');

                buildInfo.addLinkObjects(linkFile,libDir,1000,false,true);
            end
        end
    end
end
