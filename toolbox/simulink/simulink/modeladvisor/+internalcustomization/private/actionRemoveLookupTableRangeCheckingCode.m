function result=actionRemoveLookupTableRangeCheckingCode(taskobj)




    mdladvObj=taskobj.MAObj;
    model=getfullname(mdladvObj.System);

    blkList=getLookupTableBlocks(model);

    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.setSubBar(0);
    ft.setInformation(DAStudio.message('Simulink:tools:MALookupTableRangeRemoveActionResult'));

    tmpBlocks=[];

    for i=1:length(blkList)
        blk=blkList{i};
        if strcmp(get_param(blk,'BlockType'),'Interpolation_n-D')
            set_param(blk,'RemoveProtectionIndex','on');
        else
            set_param(blk,'RemoveProtectionInput','on');
        end
        if strcmp(get_param(blk,'DiagnosticForOutOfRangeInput'),'None')
            set_param(blk,'DiagnosticForOutOfRangeInput','Warning');
        end
        tmpBlocks{end+1}=blk;
    end

    searchResult=tmpBlocks;

    ft.setListObj(searchResult);


    result=ft;

    mdladvObj.setActionResultStatus(true);
    mdladvObj.setActionEnable(false);
