function result=actionChangeLogicBlockUseNonBooleanOutput(taskobj)




    mdladvObj=taskobj.MAObj;
    model=getfullname(mdladvObj.System);
    hScope=get_param(model,'Handle');

    [blkList,~]=getLogicBlockUseNonBooleanOutput(hScope,mdladvObj);

    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.setSubBar(0);
    ft.setInformation(DAStudio.message('ModelAdvisor:engine:ChangeLogicBlockUseNonBooleanOutputResult'));

    tmpBlocks=[];

    for i=1:length(blkList)
        blk=blkList{i};
        set_param(blk,'OutDataTypeStr','boolean');
        tmpBlocks{end+1}=blk;%#ok<AGROW>
    end

    searchResult=tmpBlocks;

    ft.setListObj(searchResult);


    result=ft;

    mdladvObj.setActionResultStatus(true);
    mdladvObj.setActionEnable(false);
