function v=validateBlock(this,hC)






    v=hdlvalidatestruct;

    v(end+1)=hdlvalidatestruct(1,...
    message('hdlcoder:validate:XilinxBlackboxDeprecation'));

    bfp=hC.SimulinkHandle;
    phan=get_param(bfp,'PortHandles');

    xin1=find_system(bfp,'SearchDepth',1,'LookUnderMasks','all',...
    'block_type','gatewayin');


    xin2=find_system(bfp,'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'block_type','gatewayin');
    xout1=find_system(bfp,'SearchDepth',1,'LookUnderMasks','all',...
    'block_type','gatewayout');
    xout2=find_system(bfp,'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'block_type','gatewayout');


    if(length(xin1)~=length(xin2))||(length(xout1)~=length(xout2))
        v(end+1)=hdlvalidatestruct(1,...
        'All Gateway blocks must be in the top level of the Xilinx subsystem.',...
        'hdlcoder:validate:nontoplvlgateway');
    end


    if(length(xin1)~=length(phan.Inport))||(length(xout1)~=length(phan.Outport))
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:unbalancedioandgateway'));
    end


    if~isempty(find_system(bfp,'SearchDepth',1,'LookUnderMasks','all',...
        'block_type','gatewayout','hdl_port','off'))
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:virtualoutput'));
    end




