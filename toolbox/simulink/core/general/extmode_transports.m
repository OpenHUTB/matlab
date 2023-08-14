function[transports,mexfiles,interfaces]=extmode_transports(cs)
































































    transports={};
    mexfiles={};
    interfaces={};

    if coder.internal.connectivity.featureOn('ExtModeTargetFramework')



        [isTFTarget,board]=codertarget.utils.isTargetFrameworkTarget(get_param(cs,'HardwareBoard'));
        if isTFTarget
            protocolStacks=board.CommunicationProtocolStacks;
            for protocol=protocolStacks
                if isa(protocol,'target.internal.ExternalMode')
                    externalModeConectivities=protocol.Connectivities;
                    for connectivity=externalModeConectivities
                        transports{end+1}=connectivity.getTransport;%#ok<AGROW>
                        mexfiles{end+1}=connectivity.getMex;%#ok<AGROW>
                        interfaces{end+1}=connectivity.getInterface;%#ok<AGROW>
                    end
                end
            end
            if~isempty(transports)

                return;
            end
        end
    end

    sysTargFile='';
    if~isempty(cs)&&(isa(cs,'Simulink.ConfigSet')||isa(cs,'Simulink.ConfigSetRef'))&&...
        cs.isValidParam('SystemTargetFile')
        sysTargFile=get_param(cs,'SystemTargetFile');
    end




    if(strcmp(sysTargFile,'ert.tlc')&&codertarget.target.isCoderTarget(cs)&&...
        strcmpi(get_param(cs,'ProdHWDeviceType'),'Texas Instruments->C2000'))
        ccslink_registration_file='ccslink_extmode_registration.m';
        ccslink_registration_file_location=which(ccslink_registration_file);

        if(exist(ccslink_registration_file,'file'))&&...
            (strcmp(which(ccslink_registration_file),ccslink_registration_file_location))


            [transports,mexfiles,interfaces]=ccslink_extmode_registration(cs);
        else

            transports={};
            mexfiles={};
            interfaces={};
        end



    elseif(strcmp(sysTargFile,'ert.tlc')||...
        strcmp(sysTargFile,'grt.tlc')||...
        strcmp(sysTargFile,'grt_malloc.tlc'))

        if~coder.internal.xcp.isXCPTargetEnabled()
            transportsList=[Simulink.ExtMode.Transports.TCP,...
            Simulink.ExtMode.Transports.Serial];
        else
            transportsList=[Simulink.ExtMode.Transports.TCP,...
            Simulink.ExtMode.Transports.Serial,...
            Simulink.ExtMode.Transports.XCPTCP,...
            Simulink.ExtMode.Transports.XCPSerial];
        end

        [transports,mexfiles,interfaces]=transportsList.toCell;



    elseif(strcmp(sysTargFile,'rsim.tlc')||strcmp(sysTargFile,'raccel.tlc'))
        transportsList=[Simulink.ExtMode.Transports.TCP,...
        Simulink.ExtMode.Transports.Serial];

        [transports,mexfiles,interfaces]=transportsList.toCell;



    elseif strcmp(sysTargFile,'tornado.tlc')

        [transports,mexfiles,interfaces]=Simulink.ExtMode.Transports.TCP.toCell;



    elseif any(strcmp(sysTargFile,{'sldrt.tlc','sldrtert.tlc','rtwin.tlc','rtwinert.tlc'}))

        [transports,mexfiles,interfaces]=Simulink.ExtMode.Transports.SharedMem.toCell;





    elseif strcmp(get_param(cs,'IsSLRTTarget'),'on')
        [transports,mexfiles,interfaces]=Simulink.ExtMode.Transports.SLRTXCP.toCell;




    elseif any(strcmp(sysTargFile,{'ccslink_ert.tlc','ccslink_grt.tlc','idelink_ert.tlc','idelink_grt.tlc'}))

        ccslink_registration_file='ccslink_extmode_registration.m';
        ccslink_registration_file_location=which(ccslink_registration_file);

        if(exist(ccslink_registration_file,'file'))&&...
            (strcmp(which(ccslink_registration_file),ccslink_registration_file_location))


            [transports,mexfiles,interfaces]=ccslink_extmode_registration(cs);
        else

            transports={};
            mexfiles={};
            interfaces={};
        end
    end




    cm=DAStudio.CustomizationManager;


    if isprop(cm,'ExtModeTransports')

        ServHandle=DAServiceManager.OnDemandService;
        ServHandle.Start('ExtModeTransports');
        [custom_targets,custom_transports,custom_mexfiles,...
        custom_interfaces,requiresHardwareBoard]=...
        cm.ExtModeTransports.getInstance().get();

        if(~isempty(custom_transports))
            len=length(custom_transports);
            for i=1:len
                if strcmp(sysTargFile,custom_targets(i))

                    isHardwareBoard=~isempty(...
                    codertarget.target.getHardwareName(cs));
                    if~requiresHardwareBoard(i)||isHardwareBoard
                        transports{end+1}=char(custom_transports(i));%#ok<AGROW>
                        mexfiles{end+1}=char(custom_mexfiles(i));%#ok<AGROW>
                        interfaces{end+1}=char(custom_interfaces(i));%#ok<AGROW>
                    end
                end
            end
        end
    end




    if isempty(transports)

        [transports,mexfiles,interfaces]=Simulink.ExtMode.Transports.None.toCell;
    end







