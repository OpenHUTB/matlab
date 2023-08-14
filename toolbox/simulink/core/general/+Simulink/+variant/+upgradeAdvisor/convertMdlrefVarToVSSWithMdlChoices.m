function result=convertMdlrefVarToVSSWithMdlChoices(taskobj)








    mdladvObj=taskobj.MAObj;
    systemH=get_param(bdroot(mdladvObj.System),'Handle');


    mdlBlocks=num2cell(find_system(systemH,'LookUnderMasks','on','MatchFilter',@Simulink.match.allVariants,...
    'BlockType','ModelReference','Variant','on'));
    if numel(mdlBlocks)==1
        mdlBlocks={getfullname(mdlBlocks{:})};
    else
        mdlBlocks=getfullname(mdlBlocks);
    end


    mdlBlocks=mdladvObj.filterResultWithExclusion(mdlBlocks);


    isBdLibrary=bdIsLibrary(systemH);


    if isBdLibrary
        if strcmp('on',get_param(systemH,'Lock'))
            set_param(systemH,'Lock','off');
            restoreBdLockOnDelete=...
            onCleanup(@()set_param(systemH,'Lock','on'));
        end
    end

    result=convertToVSSWithMdlChoicesUtil(mdlBlocks);

    if isBdLibrary

        if~isempty(restoreBdLockOnDelete)
            restoreBdLockOnDelete.delete();
        end
    end
end

function isValid=isLibrary(libraryName)


    isValid=false;
    try
        mdlInfo=Simulink.MDLInfo(bdroot(libraryName));
    catch
        return;
    end
    if~mdlInfo.IsLibrary
        return;
    end

    isValid=true;
end

function ft=convertToVSSWithMdlChoicesUtil(mdlBlocks)














    ft=ModelAdvisor.FormatTemplate('TableTemplate');
    ft.setColTitles({DAStudio.message('Simulink:tools:MAColTitle1ConvertMdlrefVarToVSS'),DAStudio.message('Simulink:tools:MAColTitle2ConvertMdlrefVarToVSS')});
    ft.setSubBar(false);


    ft.setSubResultStatus('Pass');
    C2VErr='';
    for i=1:numel(mdlBlocks)
        try

            Simulink.VariantManager.convertToVariant(mdlBlocks{i});
        catch exception


            C2VErr=exception.message;
            ft.setSubResultStatus('Warn');
            ft.addRow({mdlBlocks{i},C2VErr});
            continue;
        end

        ft.addRow({mdlBlocks{i},DAStudio.message('Simulink:tools:MAColResultSuccessConvertMdlrefVarToVSS')});
    end

    if isempty(C2VErr)
        ft.setSubResultStatusText(DAStudio.message('Simulink:tools:MAResultActionForConvertMdlrefVarToVSSPass'));
    else
        ft.setSubResultStatusText(DAStudio.message('Simulink:tools:MAResultActionForConvertMdlrefVarToVSSWarn'));
    end

end


