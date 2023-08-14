function result=RefactorModel(candidatesInfo)




    result='';
    if~slfeature('BusPortsXformEditTimeCheck')
        return;
    end
    modelHandle=get_param(bdroot,'handle');

    model2modelObj=slEnginePir.m2m_RefactorBusPorts(bdroot);
    model2modelObj.fPrefix='backup_';
    model2modelObj.fXformDir=['backup_',bdroot,'/'];
    model2modelObj.createBackupModel();

    res=Simulink.ModelRefactor.BusPortsTransform.refactor(modelHandle,candidatesInfo);
    busPortsXformResult={};
    ss={};
    for idx=1:length(res)
        blkPair=res{idx};
        fromBlkHandle=Simulink.ID.getHandle([bdroot,':',num2str(blkPair{1})]);
        fromName=get_param(fromBlkHandle,'Name');

        toBlkHandle=Simulink.ID.getHandle([bdroot,':',num2str(blkPair{2})]);
        toName=get_param(toBlkHandle,'Name');
        busPortsXformResult{end+1}={fromName,toName};


        ssParent=get_param(fromBlkHandle,'Parent');
        ssGrantParent=get_param(ssParent,'Parent');
        ss{end+1}=ssParent;
        if~isempty(ssGrantParent)
            ss{end+1}=ssGrantParent;
        end
    end
    ss=unique(ss);
    for idx=1:length(ss)
        warning('off','diagram_autolayout:autolayout:layoutRejectedCommandLine');
        Simulink.BlockDiagram.arrangeSystem(ss{idx});
    end
end





