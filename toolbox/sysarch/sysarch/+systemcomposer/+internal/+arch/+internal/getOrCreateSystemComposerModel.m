function zcModel=getOrCreateSystemComposerModel(bd)







    dstDomain=get_param(bd,'SimulinkSubDomain');
    if strcmpi(dstDomain,'simulink')




        prevHasInfo=get_param(bd,'HasSystemComposerArchInfo');
        if strcmp(prevHasInfo,'off')

            dFlag=get_param(bd,'Dirty');
            set_param(bd,'HasSystemComposerArchInfo','on');
            set_param(bd,'HasSystemComposerArchInfo','off');
            set_param(bd,'Dirty',dFlag);
        end
    end

    zcModel=get_param(bd,'SystemComposerModel');

end
