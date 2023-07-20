function configSLDVCompatibleHarness(origModelH,harnessH)











    fOpts=Simulink.FindOptions("SearchDepth",1);
    schedulerH=Simulink.findBlocksOfType(harnessH,'SubSystem','Tag','__SLT_FCN_CALL__',fOpts);
    if~isempty(schedulerH)
        set_param(schedulerH,'Name','_SldvExportFcnScheduler');
        set_param(schedulerH,'DisableCoverage','on');
    end



    stubFcnH=Simulink.findBlocksOfType(harnessH,'SubSystem','Tag','_Harness_SLFunc_Stub_',fOpts);
    if~isempty(stubFcnH)

        for idx=1:numel(stubFcnH)
            set_param(stubFcnH(idx),'DisableCoverage','on');
        end





        blkSID=[get_param(harnessH,'Name'),':1'];
        blockType=get_param(blkSID,'BlockType');
        if strcmp(blockType,'ModelReference')
            refMdlName=get_param(blkSID,'ModelName');
            if strcmp(get_param(refMdlName,'AutosarCompliant'),'on')||...
                Simulink.CodeMapping.isMappedToAutosarComponent(refMdlName)


                mdlBlockH=get_param(blkSID,'Handle');
                set_param(mdlBlockH,'CodeInterface','Top model');
            end
        end
    end





    fOpts=Simulink.FindOptions("SearchDepth",-1);
    fcnCallGenH=Simulink.findBlocksOfType(harnessH,'SubSystem','Tag','_SLT_FCN_CALL_GEN_BLK_',fOpts);
    if~isempty(fcnCallGenH)&&...
        contains(get_param(fcnCallGenH,'Name'),'SLDV Fcn Call Generator')

        parentSubSys=get_param(fcnCallGenH,'Parent');
        origPermissions=get_param(parentSubSys,'Permissions');
        set_param(parentSubSys,'Permissions','ReadWrite');



        set_param(fcnCallGenH,'DisableCoverage','on');


        set_param(parentSubSys,'Permissions',origPermissions);
    end

    if(~isempty(get_param(origModelH,'SimUserIncludeDirs')))


        sldv.code.slcc.internal.fixReplacementCustomCodeSettings(origModelH,harnessH);
    end

end

