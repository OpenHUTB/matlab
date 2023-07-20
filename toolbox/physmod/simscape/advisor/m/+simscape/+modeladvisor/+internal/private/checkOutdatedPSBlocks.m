function obj=checkOutdatedPSBlocks(objType)





    checkId='checkOutdatedPSBlocks';


    obj=simscape.modeladvisor.internal.create_basic_check(...
    objType,checkId,...
    @checkCallback,...
    context='PostCompile',...
    checkedByDefault=false);
end



function ResultDescription=checkCallback(system)
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    ResultDescription={};
    ResultStatus=true;

    psdata=simscape.compiler.sli.internal.psUpgradeAdvisorData(system);


    ftUpgradeable=upgradeableClumps(psdata);
    ftFailed=failedClumps(psdata);

    if~strcmp(ftUpgradeable.SubResultStatus,'Pass')
        ResultStatus=false;
        ResultDescription{end+1}=ftUpgradeable;
    end

    if~strcmp(ftFailed.SubResultStatus,'Pass')
        ResultStatus=false;

        ftFailed.setSubBar(false);
        ResultDescription{end+1}=ftFailed;
    else

        ftUpgradeable.setSubBar(false);
    end

    if ResultStatus

        ResultDescription{end+1}=allPass();
    end


    mdladvObj.setCheckResultStatus(ResultStatus);

end


function ft1=failedClumps(psdata)
    ft1=ModelAdvisor.FormatTemplate('TableTemplate');
    ft1.setColTitles({lGetMsg('ManualTableCol1'),...
    lGetMsg('ManualTableCol2'),...
    lGetMsg('ManualTableCol3')});

    if isempty(psdata.failed)

        setSubResultStatus(ft1,'Pass');
        return;
    end


    setSubResultStatus(ft1,'Warn');

    statusPg=ModelAdvisor.Paragraph;

    statusPg.addItem(lGetMsg('ManualStatus1'));
    upgradeSteps=ModelAdvisor.List();
    upgradeSteps.setType('Numbered');
    upgradeSteps.addItem(lGetMsg('ManualListAction1'));
    upgradeSteps.addItem(lGetMsg('ManualListAction2'));
    statusPg.addItem(upgradeSteps);
    statusPg.addItem([lGetMsg('ManualStatus2'),' ']);
    docLink=ModelAdvisor.Text(lGetMsg('ManualStatusLink'));
    docLink.Hyperlink='matlab:helpview(''simscape'', ''UpgradeLegacyPSBlocks'')';
    statusPg.addItem(docLink);

    setSubResultStatusText(ft1,statusPg);

    for clump=1:numel(psdata.failed)

        blkList=ModelAdvisor.List();
        blkList.setType('Bulleted');
        blkList.addItem(psdata.failed(clump).objects);

        link=lUpgradeLink(psdata.failed(clump).objects,lGetMsg('ManualActionLink'));

        report=ModelAdvisor.Paragraph;
        for i=1:numel(psdata.failed(clump).exe)
            exeTxt=ModelAdvisor.Text(psdata.failed(clump).exe(i).getReport('extended','hyperlinks','on'));
            exeTxt.RetainReturn=true;
            exeTxt.ContentsContainHTML=true;
            if i>1
                report.addItem(ModelAdvisor.LineBreak);
                report.addItem(ModelAdvisor.LineBreak);
            end
            report.addItem(exeTxt);
        end


        addRow(ft1,{blkList,report,link});
    end
end


function ft2=upgradeableClumps(psdata)
    ft2=ModelAdvisor.FormatTemplate('ListTemplate');

    if isempty(psdata.upgradable)

        setSubResultStatus(ft2,'Pass');
        return;
    end


    setSubResultStatus(ft2,'Warn');
    setSubResultStatusText(ft2,lGetMsg('AutoStatus'));

    recActionTxt=lGetMsg('AutoRecAct');
    link=lUpgradeLink(psdata.upgradable,lGetMsg('AutoActionLink'));
    setRecAction(ft2,{recActionTxt,link});


    setListObj(ft2,psdata.upgradable);
end

function ft3=allPass()
    ft3=ModelAdvisor.FormatTemplate('ListTemplate');
    ft3.setSubResultStatus('Pass');
    ft3.setSubResultStatusText(lGetMsg('PassStatus'));
    ft3.setSubBar(false);
end

function link=lUpgradeLink(blkPths,upgradeTxt)



    undoTxt=lGetMsg('UndoLink');
    upgradeFcn='simscape.modeladvisor.internal.ps_upgrade_revert';
    upgradeAction='upgrade';
    revertAction='revert';



    sids=Simulink.ID.getSID(blkPths);

    href=@(action)['matlab:',upgradeFcn,'(''',action,''','...
    ,'{',sprintf('''%s'' ',sids{:}),'})'];



    onclick=['onClick="if(!this.IsUndo) '...
    ,'{'...
    ,'this.href =&quot;',href(upgradeAction),'&quot;;'...
    ,'this.IsUndo = true; '...
    ,'this.innerHTML=''',undoTxt,'''; '...
    ,'}'...
    ,' else '...
    ,'{'...
    ,'this.href =&quot;',href(revertAction),'&quot;;'...
    ,'this.IsUndo = false; '...
    ,'this.innerHTML=''',upgradeTxt,'''; '...
    ,'}" '];
    link=['<a href = "',href(upgradeAction),'" ',onclick,'>',upgradeTxt,'</a>'];
end

function msg=lGetMsg(id)

    messageCatalog='physmod:simscape:advisor:modeladvisor:checkOutdatedPSBlocks';

    msg=DAStudio.message([messageCatalog,':',id]);
end
