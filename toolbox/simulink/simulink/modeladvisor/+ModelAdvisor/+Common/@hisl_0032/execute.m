






function execute(this)

    globalStatus=true;
    isSomethingChecked=false;
    ftHeader=ModelAdvisor.FormatTemplate('ListTemplate');
    ftHeader.setCheckText(this.getText('Hisl0032_CheckText'));
    ftHeader.setSubBar(false);





    [localStatus,ftFlaggedSettings]=this.validateCheckParameter();
    if~localStatus
        this.status=false;
        this.result={...
        ftHeader,...
        ftFlaggedSettings};
        return;
    end

    checkedObjectTypes={};
    if~strcmp(this.conventionBlockNames,'None')
        checkedObjectTypes{end+1}=this.getText('Hisl0032_CheckedObjectBlock');
    end
    if~strcmp(this.conventionSignalNames,'None')
        checkedObjectTypes{end+1}=this.getText('Hisl0032_CheckedObjectSignal');
    end
    if~strcmp(this.conventionParameterNames,'None')
        checkedObjectTypes{end+1}=this.getText('Hisl0032_CheckedObjectParameter');
    end
    if~strcmp(this.conventionBusNames,'None')
        checkedObjectTypes{end+1}=this.getText('Hisl0032_CheckedObjectBus');
    end
    if~strcmp(this.conventionStateflowNames,'None')
        checkedObjectTypes{end+1}=this.getText('Hisl0032_CheckedObjectStateflow');
    end
    ftHeader.setListObj(checkedObjectTypes);

    ftResult=outputResult(this);
    ftAction=outputAction(this);

    msgCatalogTagPrefix=[this.prefix,'Hisl0032'];





    if~strcmp(this.conventionBlockNames,'None')
        isSomethingChecked=true;
        [localStatus,ftFlaggedBlockNames,vBlocks]=Advisor.Utils.Naming.checkBlockNames(this.system,this.regexpBlockNames,...
        msgCatalogTagPrefix,this.reservedNames,this.conventionBlockNames);
        globalStatus=globalStatus&&localStatus;
    else
        ftFlaggedBlockNames=[];
        vBlocks=[];
    end





    if~strcmp(this.conventionSignalNames,'None')
        isSomethingChecked=true;
        [localStatus,ftFlaggedSignalNames,vSignals]=Advisor.Utils.Naming.checkSignalNames(...
        this.system,this.regexpSignalNames,...
        msgCatalogTagPrefix,this.reservedNames,...
        'on','all',this.conventionSignalNames);
        globalStatus=globalStatus&&localStatus;
    else
        ftFlaggedSignalNames=[];
        vSignals=[];
    end





    if~strcmp(this.conventionParameterNames,'None')
        isSomethingChecked=true;
        [localStatus,ftFlaggedParameterNames,vParam]=Advisor.Utils.Naming.checkParameterNames(this.system,this.regexpParameterNames,...
        msgCatalogTagPrefix,this.reservedNames,this.conventionParameterNames);
        globalStatus=globalStatus&&localStatus;
    else
        ftFlaggedParameterNames=[];
        vParam=[];
    end





    if~strcmp(this.conventionBusNames,'None')
        isSomethingChecked=true;
        [localStatus,ftFlaggedBusNames,vBus]=Advisor.Utils.Naming.checkBusNames(this.system,this.regexpBusNames,...
        msgCatalogTagPrefix,this.reservedNames,this.conventionBusNames);
        globalStatus=globalStatus&&localStatus;
    else
        ftFlaggedBusNames=[];
        vBus=[];
    end





    if~strcmp(this.conventionStateflowNames,'None')
        isSomethingChecked=true;
        [localStatus,ftFlaggedStateflowNames,vSF]=Advisor.Utils.Naming.checkStateflowNames(this.system,this.regexpStateflowNames,...
        msgCatalogTagPrefix,this.reservedNames,this.conventionStateflowNames);
        globalStatus=globalStatus&&localStatus;
    else
        ftFlaggedStateflowNames=[];
        vSF=[];
    end





    if globalStatus
        if isSomethingChecked
            ftResult.setSubResultStatus('Pass');
            ftResult.setSubResultStatusText(this.getText('Hisl0032_PassMessage'));
        else
            ftResult.setSubResultStatus('Pass');
            ftResult.setSubResultStatusText(this.getText('Hisl0032_PassMessageNoCheck'));
        end
    else
        ftResult.setSubResultStatus('Warn');
        ftResult.setSubResultStatusText(this.getText('Hisl0032_WarnMessage'));
        ftAction.setRecAction(this.getText('Hisl0032_ActionMessage'));
    end





    globalResult={...
    ftHeader,...
    ftResult,...
    ftFlaggedBlockNames,...
    ftFlaggedSignalNames,...
    ftFlaggedParameterNames,...
    ftFlaggedBusNames,...
    ftFlaggedStateflowNames,...
    ftAction};

    this.status=globalStatus;
    this.result=globalResult;
    this.violations=[vBlocks;vSignals;vParam;vBus;vSF];

end

function ftResult=outputResult(this)%#ok<INUSD>
    ftResult=ModelAdvisor.FormatTemplate('TableTemplate');
    ftResult.setSubBar(false);
end

function ftAction=outputAction(this)%#ok<INUSD>
    ftAction=ModelAdvisor.FormatTemplate('TableTemplate');
    ftAction.setSubBar(false);
end

