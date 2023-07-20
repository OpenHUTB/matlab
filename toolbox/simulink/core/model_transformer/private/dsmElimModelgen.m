function result=dsmElimModelgen(aTask)





    result={''};

    mdladvObj=aTask.MaObj;
    m2m_obj=mdladvObj.UserData;
    if isempty(m2m_obj)
        return;
    end

    if~m2m_obj.hasSelectedCandidates
        text=ModelAdvisor.Text('New model is not generated since no candidates are selected.');
        aTask.check.Action.Enable=false;
        result=ModelAdvisor.Paragraph;
        result.addItem(text);
        return
    end

    aTask.Check.ResultInHTML=mdladvObj.formatCheckCallbackOutput(aTask.Check,{aTask.Check.Result},{''},1,false);

    prefixParam=mdladvObj.getInputParameters;
    m2m_obj.fPrefix=prefixParam{1}.Value;

    ME=MException('','');

    wmsg=evalc('try m2m_obj.eliminate; m2m_obj.generateMdls; catch ME; end');
    if slfeature('GlobalDSMRwElim')>0
        ioXformObj=slEnginePir.m2m_IOPortsXform(m2m_obj.fXformedMdl);
        ioXformObj.performXformation();
    end
    if~isempty(ME.message)
        result=ME.message;
        return;
    else
        ft0=ModelAdvisor.FormatTemplate('ListTemplate');
        setSubTitle(ft0,DAStudio.message('sl_pir_cpp:creator:XformedModel'));
        setInformation(ft0,DAStudio.message('sl_pir_cpp:creator:HyperLinkToDSMXformedModel'));
        setListObj(ft0,{[m2m_obj.fPrefix,m2m_obj.fMdl]});
        result=ft0.emitContent;
    end
end


