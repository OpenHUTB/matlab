function addFloatingPointNumbers(obj,assumptions)



    if~assumptions.CoderConfig.PurelyIntegerCode

        dazStatus=obj.logicalToTFString(assumptions.Assumptions.DenormalAsZero);
        ftzStatus=obj.logicalToTFString(assumptions.Assumptions.DenormalFlushToZero);


        summary=Advisor.Text(DAStudio.message('RTW:report:CoderAssumptionsFloatNumsSummary'));
        pSummary=Advisor.Paragraph;
        pSummary.addItem(summary);


        data={...
        DAStudio.message('RTW:report:CoderAssumptionsFloatNumsFTZ'),ftzStatus;...
        DAStudio.message('RTW:report:CoderAssumptionsFloatNumsDAZ'),dazStatus;...
        };
        table=Advisor.Table(size(data,1),size(data,2));
        table.setStyle('AltRow');
        table.setEntries(data);
        pTable=Advisor.Paragraph;
        pTable.addItem(table);


        infoMsg=Advisor.Text(DAStudio.message('RTW:report:CoderAssumptionsFloatNumsInfo'));
        pInfoMsg=Advisor.Paragraph;
        pInfoMsg.addItem(infoMsg);

        obj.addSection('sec_floating_point_num',DAStudio.message('RTW:report:CoderAssumptionsFloatNums'),'',...
        [pSummary;pTable;pInfoMsg]);
    end

end


