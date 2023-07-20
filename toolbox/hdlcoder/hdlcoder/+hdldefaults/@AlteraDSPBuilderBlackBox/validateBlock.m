function v=validateBlock(this,hC)






    v=hdlvalidatestruct;

    v(end+1)=hdlvalidatestruct(1,...
    message('hdlcoder:validate:AlteraBlackboxDeprecation'));

    bfp=hC.SimulinkHandle;
    phan=get_param(bfp,'PortHandles');



    ain1=find_system(bfp,'SearchDepth',1,'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'ReferenceBlock','allblocks_alteradspbuilder2/Input');
    ain2=find_system(bfp,'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'ReferenceBlock','allblocks_alteradspbuilder2/Input');
    aout1=find_system(bfp,'SearchDepth',1,'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'ReferenceBlock','allblocks_alteradspbuilder2/Output');
    aout2=find_system(bfp,'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'ReferenceBlock','allblocks_alteradspbuilder2/Output');


    if(length(ain1)~=length(ain2))||(length(aout1)~=length(aout2))
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:nontoplvlioblk'));
    end


    if(length(ain1)~=length(phan.Inport))||(length(aout1)~=length(phan.Outport))
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:unbalancediopairs'));
    end





