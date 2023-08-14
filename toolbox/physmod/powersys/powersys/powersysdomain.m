function varargout=powersysdomain(arg)%#ok








    if(nargin==0)
        return
    end

    switch(class(arg))
    case 'Simulink.SlDomainInfo'
        i_RegisterPOWER(arg);
    case 'struct'
        [Netlist]=powersysdomain_netlist('get');
        if isempty(Netlist)



            VerifyAppendBlocks(arg)
        end
        powersysdomain_netlist('compile',arg);
    case 'string'
        i_StopPOWER(arg);
    end

    function i_RegisterPOWER(domaininfo)
        domaininfo.name='powersysdomain';
        domaininfo.version='0';
        domaininfo.lineBranching='on';
        domaininfo.compileFcn='powersysdomain';
        domaininfo.stopFcn='powersysdomain';
        domaininfo.initFcn='powersysdomain_init';
        domaininfo.startFcn='powersysdomain_append';
        domaininfo.key='83009589e36abee57bc2937f16f9745ae7b6864d31edffae39e3991cfd2f2553';
        port=domaininfo.addPortType('p1');
        port.icon=domaininfo.getDomainImage('electric.png');
        port.setConnectivity(port);
        domaininfo.locked='on';

        function i_StopPOWER(blockdiagram)
            disp(['Stopping ',blockdiagram])

            function VerifyAppendBlocks(arg)
                system=getfullname(bdroot(arg.BlockHandles(1)));
                Neutrals=find_system(system,'LookUnderMasks','on','FollowLinks','on',...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'MaskType','Neutral');
                MMeters=find_system(system,'LookUnderMasks','on','FollowLinks','on',...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'MaskType','Multimeter');
                if~isempty(Neutrals)



                    Powerguis=find_system(system,'LookUnderMasks','on',...
                    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                    'FollowLinks','on','MaskType','PSB option menu block');
                    if length(Powerguis)>1

                        error(message('physmod:powersys:library:NeutralMultiplePowerguis'));
                    else
                        powersysdomain_netlist('Append');
                    end
                elseif~isempty(MMeters)

                    Powerguis=find_system(system,'LookUnderMasks','on','FollowLinks','on',...
                    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                    'MaskType','PSB option menu block');
                    if length(Powerguis)>1

                        error(message('physmod:powersys:library:MultimeterMultiplePowerguis'));
                    else
                        powersysdomain_netlist('Append');
                    end
                end