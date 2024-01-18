function outModelH=getOwnerModelFromHarness(inHandle)

    outModelH=[];
    try
        outModelH=get_param(bdroot(inHandle),'Handle');
        if isempty(outModelH)


            outModelH=[];
            return;
        end
        if strcmp(get_param(outModelH,'IsHarness'),'on')
            outModelH=get_param(Simulink.harness.internal.getHarnessOwnerBD(outModelH),'Handle');
        end
    catch ME %#ok<NASGU>

    end
end