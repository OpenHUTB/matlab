classdef EthernetReceive<matlab.System&coder.ExternalDependency





%#codegen


    properties(Nontunable)
        InterfaceName(1,:){mustBeText,mustBeNonempty}='wm0'
        DataWidth(1,1){mustBeInteger,mustBeGreaterThan(DataWidth,13),mustBeLessThan(DataWidth,1515)}=64;
        MessageOut(1,1)logical=false;
        MaxMessagesPerStep(1,1){mustBePositive,mustBeInteger}=1;
        SampleTime(1,1)=-1;
        FilterString(1,:)char
        MaxWidth(1,1)=0;
    end

    properties(Access=protected)
BPFDevicePtr
OutputData
OutputLength
    end

    methods

        function obj=EthernetReceive(varargin)
            coder.allowpcode('plain');

            setProperties(obj,nargin,varargin{:})
        end
    end

    methods(Access=protected)

        function interface=getInterfaceImpl(obj)

            import matlab.system.interface.*;%#ok<EMIMP>
            if obj.MessageOut
                interface=Output("out1",Message);
                slrealtime.createEthernetPacketBusObj(obj.DataWidth);
            else
                interface=[Output("out1",Data),...
                Output("out2",Data)];
            end
        end

        function varargout=getOutputNamesImpl(obj)
            if obj.MessageOut
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
            obj.OutputData=zeros(obj.DataWidth,1,'uint8');
            obj.OutputLength=uint16(0);
        end

        function resetImpl(obj)
            if coder.target('MATLAB')
                return;
            end

            coder.cinclude("rawEth.hpp");
            if coder.target('rtw')

                interface=[obj.InterfaceName,0];
                filterString=[obj.FilterString,0];



                obj.BPFDevicePtr=coder.ceval("initializeRawEth",...
                coder.ref(interface),...
                true,...
                obj.DataWidth,...
                coder.ref(filterString));
            end
        end

        function varargout=stepImpl(obj)
            if nargout==1
                varargout{1}=stepImplM(obj);
            else
                [varargout{1},varargout{2}]=stepImplS(obj);
            end
        end

        function outData=stepImplM(obj)
            if coder.target('MATLAB')
                outData=struct('Data',{},'Length',{});
                return;
            end

            OutputPacket=struct(...
            'Data',zeros(obj.MaxWidth,1,'uint8'),...
            'Length',uint16(0));

            coder.cinclude("rawEth.hpp");
            outData=[];
            if coder.target('rtw')
                for iMsg=1:obj.MaxMessagesPerStep
                    OutputPacket.Length=uint16(0);
                    coder.ceval("readRawEth",obj.BPFDevicePtr,coder.ref(OutputPacket.Data),coder.ref(OutputPacket.Length));

                    if OutputPacket.Length>0
                        outData=[outData,OutputPacket];%#ok<AGROW>
                    else
                        break;
                    end
                end
            end
        end

        function[outData,outLength]=stepImplS(obj)
            data=zeros(obj.DataWidth,1,'uint8');
            obj.OutputLength=uint16(0);

            if coder.target('MATLAB')
                outData=data;
                outLength=0;
                return;
            end

            coder.ceval("readRawEth",obj.BPFDevicePtr,coder.ref(data),coder.ref(obj.OutputLength));
            if(obj.OutputLength>0)
                obj.OutputData=data;
            end
            outData=obj.OutputData;
            outLength=double(obj.OutputLength);
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



        function numOut=getNumOutputsImpl(obj)
            if obj.MessageOut
                numOut=1;
            else
                numOut=2;
            end
        end

        function varargout=getOutputSizeImpl(obj)
            if obj.MessageOut
                varargout{1}=[1,1];
            else
                varargout{1}=[obj.DataWidth,1];
                varargout{2}=[1,1];
            end
        end

        function varargout=getOutputDataTypeImpl(obj)
            if obj.MessageOut
                varargout{1}='Ethernet_Packet';
            else
                varargout{1}='uint8';
                varargout{2}='double';
            end
        end

        function varargout=isOutputComplexImpl(obj)
            if obj.MessageOut
                varargout{1}=false;
            else
                varargout{1}=false;
                varargout{2}=false;
            end
        end

        function varargout=isOutputFixedSizeImpl(obj)
            if obj.MessageOut
                varargout{1}=true;
            else
                varargout{1}=true;
                varargout{2}=true;
            end
        end

        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            switch prop
            case 'MaxMessagesPerStep'
                if~obj.MessageOut
                    flag=true;
                end
            end
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

            icon=getString(message('slrealtime:Ethernet:ReceiveMaskIcon',obj.InterfaceName));

        end
    end

    methods(Static,Access=protected)


        function header=getHeaderImpl

            header=matlab.system.display.Header(mfilename("class"),...
            'ShowSourceLink',false,...
            'Title',getString(message('slrealtime:Ethernet:ReceiveTitle')),...
            'Text',getString(message('slrealtime:Ethernet:ReceiveDesc')));
        end

        function group=getPropertyGroupsImpl


            InterfaceNameProp=matlab.system.display.internal.Property('InterfaceName','Description',...
            getString(message('slrealtime:Ethernet:InterfaceName')));
            DataWidthProp=matlab.system.display.internal.Property('DataWidth','Description',...
            getString(message('slrealtime:Ethernet:DataWidth')));
            MessageOutProp=matlab.system.display.internal.Property('MessageOut','Description',...
            getString(message('slrealtime:Ethernet:EnableMessages')));
            MaxMessagesPerStepProp=matlab.system.display.internal.Property('MaxMessagesPerStep',...
            'Description',getString(message('slrealtime:Ethernet:MaxMessagesPerStep')));
            SampleTimeProp=matlab.system.display.internal.Property('SampleTime','Description',...
            getString(message('slrealtime:Ethernet:SampleTime')));
            FilterStringProp=matlab.system.display.internal.Property('FilterString',...
            'Description',getString(message('slrealtime:Ethernet:FilterString')));
            MaxWidthProp=matlab.system.display.internal.Property('MaxWidth',...
            'Description','Max Width','IsGraphical',false);

            group=matlab.system.display.Section('Title','Parameters',...
            'PropertyList',{...
            InterfaceNameProp,...
            DataWidthProp,...
            MessageOutProp,...
            MaxMessagesPerStepProp,...
            FilterStringProp,...
            SampleTimeProp,...
MaxWidthProp
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
