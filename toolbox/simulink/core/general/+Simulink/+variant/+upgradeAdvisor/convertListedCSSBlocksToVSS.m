function result=convertListedCSSBlocksToVSS(taskobj)




    mdladvObj=taskobj.MAObj;
    mdladvObj.setActionEnable(false);

    ch_result=mdladvObj.getCheckResult(taskobj.MAC);
    cssTempBlks=ch_result{1}.ListObj;
    convStat={};
    for i=1:length(cssTempBlks)
        blkPth=cssTempBlks{i};
        mdlName=bdroot(blkPth);
        load_system(mdlName);
        try
            if strcmpi(get_param(blkPth,'TemplateBlock'),'self')
                Simulink.VariantManager.convertToVariant(blkPth);

                convStat{end+1}=DAStudio.message('Simulink:tools:MAResultCheckStatusPass',blkPth);
            else
                convStat{end+1}=DAStudio.message('Simulink:tools:MAResultCheckStatusFail',blkPth);
            end

        catch
            convStat{end+1}=DAStudio.message('Simulink:tools:MAResultCheckStatusFail',blkPth);
        end
    end

    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.setSubBar(0);
    ft.setInformation(DAStudio.message('Simulink:tools:MAResultCheckStatusTitle'));
    ft.setListObj(convStat);
    result=ft;
