classdef(Hidden=true)Transports





    enumeration
        None('none','noextcomm','Level1')
        TCP('tcpip','ext_comm','Level1')
        Serial('serial','ext_serial_win32_comm','Level1')
        SharedMem('sharedmem','sldrtext','Level1')
        XCPTCP('XCP on TCP/IP','ext_xcp','Level2 - Open')
        XCPSerial('XCP on Serial','ext_xcp','Level2 - Open')
        SLRTXCP('XCP','slrealtime_extmode','Level2 - Open')
        XCPCAN('XCP on CAN','ext_xcp','Level2 - Open')
    end

    properties
Transport
Mex
Interface
    end

    methods
        function obj=Transports(transport,mex,interface)
            obj.Transport=transport;
            obj.Mex=mex;
            obj.Interface=interface;
        end

        function[transports,mexfiles,interfaces]=toCell(enumValues)


            numValues=length(enumValues);
            transports=cell(1,numValues);
            mexfiles=cell(1,numValues);
            interfaces=cell(1,numValues);
            for i=1:numValues
                transports{i}=enumValues(i).Transport;
                mexfiles{i}=enumValues(i).Mex;
                interfaces{i}=enumValues(i).Interface;
            end
        end
    end

    methods(Static)







        function extModeTransportIndex=getExtModeTransportIndex(cs,transportName)
            transports=extmode_transports(cs);

            extModeTransportIndex=find(strcmp(transports,transportName))-1;
        end












        function[transport,mexfile,interface,isValid]=getExtModeTransport(cs,extModeTransportIndex)
            transport=[];
            mexfile=[];
            interface=[];
            isValid=true;

            transportIndex=extModeTransportIndex+1;
            [transports,mexfiles,interfaces]=extmode_transports(cs);
            if(transportIndex<=0)||(transportIndex>length(transports))


                if nargout==4

                    isValid=false;
                    return;
                else
                    error(message('Simulink:Extmode:ExtModeTransportOutOfRange',extModeTransportIndex));
                end
            end
            transport=transports{transportIndex};
            mexfile=mexfiles{transportIndex};
            interface=interfaces{transportIndex};
        end



        function validateExtModeTransport(cs)

            if~Simulink.ExtMode.Transports.isTransportValidationSupported(cs)
                return;
            end


            extModeTransport=get_param(cs,'ExtModeTransport');
            [transport,mexfile,interface]=...
            Simulink.ExtMode.Transports.getExtModeTransport(cs,extModeTransport);


            transportValues={mexfile,interface};
            paramNames={'ExtModeMexFile','ExtModeIntrfLevel'};
            for i=1:length(transportValues)
                param=paramNames{i};
                transportValue=transportValues{i};
                csValue=get_param(cs,param);
                if~strcmp(csValue,transportValue)
                    error(message('Simulink:Extmode:ExtModeInconsistentTransportSettings',...
                    param,...
                    csValue,...
                    transportValue,...
                    transport,...
                    extModeTransport,...
                    param));
                end
            end
        end

        function resetExtModeTransport(cs)








            if coder.internal.connectivity.featureOn('ExtModeTargetFramework')&&...
                Simulink.ExtMode.Transports.isTransportValidationSupported(cs)




                transportVal=get_param(cs,'ExtModeTransport');
                [~,mexfile,interface,isValid]=Simulink.ExtMode.Transports.getExtModeTransport(cs,transportVal);
                if isValid


                    needReset=~strcmp(mexfile,get_param(cs,'ExtModeMexFile'))||...
                    ~strcmp(interface,get_param(cs,'ExtModeIntrfLevel'));
                else
                    needReset=true;
                end

                if needReset

                    transportVal=0;
                    set_param(cs,'ExtModeTransport',transportVal);

                    [~,mexfile,interface]=Simulink.ExtMode.Transports.getExtModeTransport(cs,transportVal);
                    set_param(cs,'ExtModeMexFile',mexfile);
                    set_param(cs,'ExtModeIntrfLevel',interface);
                end
            end
        end
    end

    methods(Static,Access=private)



        function isTransportValidationSupported=isTransportValidationSupported(cs)


            isTransportValidationSupported=true;





            filteredSTFs={'slrtert.tlc',...
            'xpctargetert.tlc',...
            'slrealtime.tlc'};
            if ismember(get_param(cs,'SystemTargetFile'),filteredSTFs)
                isTransportValidationSupported=false;
                return;
            end



            if strcmp(get_param(cs,'ExtModeMexFile'),'ext_open_testing_intrf')
                isTransportValidationSupported=false;
                return;
            end


            isGRTERT=strcmp(get_param(cs,'IsERTTarget'),'on')||...
            Simulink.ExtMode.Transports.isGRTTarget(cs);
            if isGRTERT
                assert(cs.isValidParam('ExtModeTransport'),...
                'Expected the target to define ExtModeTransport parameter!');
            else
                isTransportValidationSupported=false;
                return;
            end
        end






        function isGRTTarget=isGRTTarget(cs)


            if isa(cs,'Simulink.ConfigSetRef')
                cs=cs.getRefConfigSet;
            end
            isGRTTarget=...
            cs.getComponent('Code Generation').getComponent('Target').isGRTTarget;
        end
    end
end
