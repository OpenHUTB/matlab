function turnOffSignalLoggingForHDLCodegen(dut)























    allPortH=find_system(dut,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FindAll','on','FollowLinks','on','LookUnderMasks','on');


    allPortH=allPortH(strcmp(get_param(allPortH,'Type'),'port'));



    allPortH=allPortH(strcmp(get_param(allPortH,'PortType'),'outport'));


    allPortH=allPortH(strcmp(get_param(allPortH,'DataLogging'),'on'));


    for ii=1:length(allPortH)
        set_param(allPortH(ii),'DataLogging','off');
    end
end

