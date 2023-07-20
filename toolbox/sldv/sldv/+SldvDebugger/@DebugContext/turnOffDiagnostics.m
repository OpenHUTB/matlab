
function simIn=turnOffDiagnostics(~,simIn)






    refMdls=find_mdlrefs(simIn.ModelName,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);




    LookupBlkList=find_system(refMdls,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','on',...
    'FollowLinks','off',...
    'regexp','on',...
    'BlockType','Interpolation_n-D|Lookup_n-D|PreLookup|LookupNDDirect');


    for i=1:size(LookupBlkList,1)
        simIn=simIn.setBlockParameter(LookupBlkList{i},'DiagnosticForOutOfRangeInput','none');
    end


    simIn=simIn.setModelParameter('IntegerOverflowMsg','warning');
    simIn=simIn.setModelParameter('SignalInfNanChecking','warning');
    simIn=simIn.setModelParameter('SignalRangeChecking','warning');
    simIn=simIn.setModelParameter('ReadBeforeWriteMsg','EnableAllAsWarning');
    simIn=simIn.setModelParameter('WriteAfterReadMsg','EnableAllAsWarning');
    simIn=simIn.setModelParameter('WriteAfterWriteMsg','EnableAllAsWarning');

end
