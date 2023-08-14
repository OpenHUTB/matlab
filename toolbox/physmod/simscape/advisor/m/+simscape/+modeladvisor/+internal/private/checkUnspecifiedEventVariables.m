function obj=checkUnspecifiedEventVariables(objType)





    checkId='checkUnspecifiedEventVariables';


    obj=simscape.modeladvisor.internal.create_basic_check(...
    objType,checkId,...
    @checkCallback,...
    context='PostCompile',...
    checkedByDefault=false);
end



function ResultDescription=checkCallback(model)
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(model);

    ft=ModelAdvisor.FormatTemplate('TableTemplate');
    ft.setColTitles({lGetMsg('TableCol1'),...
    lGetMsg('TableCol2'),...
    lGetMsg('TableCol3'),...
    lGetMsg('TableCol4')});
    ft.setSubBar(false);

    vars=lGetVariables(model);

    if isempty(vars)
        ft.setSubResultStatus('Pass');
        ft.setSubResultStatusText(lGetMsg('PassStatus'));
    else

        ft.setSubResultStatus('Warn');
        status=ModelAdvisor.Paragraph;
        status.addItem(lGetMsg('WarnStatus1'));
        actions=ModelAdvisor.List();
        actions.setType('Bulleted');
        actions.addItem(lGetMsg('WarnAction1'));
        actions.addItem(lGetMsg('WarnAction2'));
        status.addItem(actions);

        status.addItem([lGetMsg('WarnStatus2'),' ']);
        docLink1=ModelAdvisor.Text(lGetMsg('WarnLink1'));
        docLink1.Hyperlink='matlab:helpview(''simscape'', ''BlockLevelVariableInit'')';
        status.addItem(docLink1);
        status.addItem(ModelAdvisor.LineBreak);

        status.addItem([lGetMsg('WarnStatus3'),' ']);
        docLink2=ModelAdvisor.Text(lGetMsg('WarnLink2'));
        docLink2.Hyperlink='matlab:helpview(''simscape'', ''variablesSyntax'')';
        status.addItem(docLink2);

        ft.setSubResultStatusText(status);

        for i=1:length(vars)
            eqnLocs=ModelAdvisor.List();
            eqnLocs.setType('Bulleted');
            eqnLocs.addItem(vars(i).eqnloc);
            addRow(ft,{vars(i).object,vars(i).name,vars(i).declloc,eqnLocs});
        end
    end

    ResultDescription={ft};


    mdladvObj.setCheckResultStatus(strcmp(ft.SubResultStatus,'Pass'));
end

function vars=lGetVariables(model)

    [sf,ins,outs]=simscape.compiler.sli.componentModel(model,false);
    if~iscell(sf)
        sf={sf};
        ins={ins};
        outs={outs};
    end

    vars=cellfun(@lGetVariablesFromSf,sf,ins,outs,'UniformOutput',false);
    vars=vertcat(vars{:});
end

function vars=lGetVariablesFromSf(sf,ins,outs)
    sf=simscape.xform(sf,containers.Map,ins);
    mf=simscape.sf2mfbundle(sf,'FilteredInputs',ins,'FilteredOutputs',outs);
    vars=simscape.internal.CheckUnspecifiedDiscrete(mf);
end

function msg=lGetMsg(id)

    messageCatalog=...
    'physmod:simscape:advisor:modeladvisor:checkUnspecifiedEventVariables';
    msg=DAStudio.message([messageCatalog,':',id]);
end