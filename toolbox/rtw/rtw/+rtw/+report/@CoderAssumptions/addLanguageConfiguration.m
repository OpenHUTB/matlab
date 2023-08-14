function addLanguageConfiguration(obj,assumptions)




    useHost=false;
    table=obj.getLanguageConfigWordLengths(assumptions,useHost);
    pTarget=Advisor.Paragraph;
    pTarget.addItem(table);

    pTarget.addItem(Advisor.LineBreak);

    data=obj.getLanguageConfigOther(assumptions,useHost);
    table=Advisor.Table(size(data,1),size(data,2));
    table.setStyle('AltRow');
    table.setEntries(data);
    pTarget.addItem(table);
    obj.addSection('sec_target_hardware',DAStudio.message('RTW:report:CoderAssumptionsLanguageConfigTgt',...
    obj.getTargetLang,assumptions.CoderConfig.HWDeviceType),'',pTarget);

    if assumptions.CoderConfig.PortableWordSizes

        useHost=true;
        table=obj.getLanguageConfigWordLengths(assumptions,useHost);
        pHost=Advisor.Paragraph;
        pHost.addItem(table);

        pHost.addItem(Advisor.LineBreak);

        data=obj.getLanguageConfigOther(assumptions,useHost);
        table=Advisor.Table(size(data,1),size(data,2));
        table.setStyle('AltRow');
        table.setEntries(data);
        pHost.addItem(table);

        summary=Advisor.Text(DAStudio.message('RTW:report:CoderAssumptionsLanguageConfigHostInfo'));
        pSummary=Advisor.Paragraph;
        pSummary.addItem(summary);
        obj.addSection('sec_dev_computer',DAStudio.message('RTW:report:CoderAssumptionsLanguageConfigHost',obj.getTargetLang),'',...
        [pSummary;pHost]);
    end

end


