


function[bResult,result]=modelAdvisorCheck_ModelVersionInfo(system,xlateTagPrefix)



    result=[];
    bResult=false;
    model=bdroot(system);
    ft=ModelAdvisor.FormatTemplate('TableTemplate');
    ft.setCheckText(DAStudio.message([xlateTagPrefix,'ModelVersionInfoTip']));
    ft.setSubBar(0);
    ft.setColTitles({DAStudio.message([xlateTagPrefix,'ModelVersionColumnOneTitle']),DAStudio.message([xlateTagPrefix,'ModelVersionColumnTwoTitle'])});
    ft.setTableTitle(DAStudio.message([xlateTagPrefix,'ModelVersionTableTitle']));

    if strcmp(system,model)==false



        ft.setInformation({DAStudio.message([xlateTagPrefix,'AbnormalContextMsg'])});
    end

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdlver=ModelAdvisor.Text(DAStudio.message([xlateTagPrefix,'ModelChecksumErrorVersion']),{'fail'});
    mdlver=mdlver.emitHTML;
    mdlauthor=ModelAdvisor.Text(DAStudio.message([xlateTagPrefix,'ModelChecksumErrorAuthor']),{'fail'});
    mdlauthor=mdlauthor.emitHTML;
    mdldate=ModelAdvisor.Text(DAStudio.message([xlateTagPrefix,'ModelChecksumErrorDate']),{'fail'});
    mdldate=mdldate.emitHTML;
    mdlsum=ModelAdvisor.Text(DAStudio.message([xlateTagPrefix,'ModelChecksumErrorChecksum']),{'fail'});
    mdlsum=mdlsum.emitHTML;
    try
        mdlver=get_param(model,'ModelVersion');
        mdlauthor=get_param(model,'LastModifiedBy');
        mdldate=get_param(model,'LastModifiedDate');
        mdlsum=get_param(model,'ModelChecksum');
        mdlsum=[num2str(mdlsum(1)),' ',num2str(mdlsum(2)),' ',num2str(mdlsum(3)),' ',num2str(mdlsum(4))];
        mdlsum=['<!-- mdladv_ignore_start -->',mdlsum,'<!-- mdladv_ignore_finish -->'];
        mdladvObj.setCheckResultStatus(true);
        bResult=true;

    catch err
        mdladvObj.setCheckResultStatus(false);
        bResult=false;
        result{end+1}=err.message;
    end;


    info{1,1}=DAStudio.message([xlateTagPrefix,'ModelChecksumVersion']);
    info{1,2}=mdlver;
    info{2,1}=DAStudio.message([xlateTagPrefix,'ModelChecksumAuthor']);
    info{2,2}=mdlauthor;
    info{3,1}=DAStudio.message([xlateTagPrefix,'ModelChecksumDate']);
    info{3,2}=mdldate;
    info{4,1}=DAStudio.message([xlateTagPrefix,'ModelChecksumChecksum']);
    info{4,2}=mdlsum;
    ft.setTableInfo(info);
    result{end+1}=ft;