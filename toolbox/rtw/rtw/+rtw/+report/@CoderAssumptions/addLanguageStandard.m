function addLanguageStandard(obj,assumptions)


    if obj.needGlobalMemoryZeroInit




        isZeroInitialized=assumptions.Assumptions.MemoryAtStartup==0;
        status=obj.logicalToTFString(isZeroInitialized);

        dynamicZeroInitialized=assumptions.Assumptions.DynamicMemoryAtStartup==0;
        dynamicStatus=obj.logicalToTFString(dynamicZeroInitialized);

        summary=Advisor.Text(DAStudio.message('RTW:report:CoderAssumptionsMemZeroInitSummary',obj.ModelName));
        pSummary=Advisor.Paragraph;
        pSummary.addItem(summary);

        data={...
        DAStudio.message('RTW:report:CoderAssumptionsGlobalMemZeroInit'),status;...
        DAStudio.message('RTW:report:CoderAssumptionsDynamicMemZeroInit'),dynamicStatus;...
        };

        pTable=Advisor.Paragraph;
        table=Advisor.Table(size(data,1),size(data,2));
        table.setStyle('AltRow');
        table.setEntries(data);
        pTable.addItem(table);

        infoMsg=Advisor.Text(DAStudio.message('RTW:report:CoderAssumptionsMemZeroInitInfo',obj.ModelName));
        pInfoMsg=Advisor.Paragraph;
        pInfoMsg.addItem(infoMsg);
        obj.addSection('sec_lang_standard',DAStudio.message('RTW:report:CoderAssumptionsLanguageStd',obj.getTargetLang),'',...
        [pSummary;pTable;pInfoMsg]);
    end

end


