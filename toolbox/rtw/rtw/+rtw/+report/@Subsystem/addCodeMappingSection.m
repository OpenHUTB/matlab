function addCodeMappingSection(obj)




    p=Advisor.Paragraph;
    p.addItem([DAStudio.message('RTW:report:CodeMappingIntro'),' <br />']);
    l=Advisor.List;
    l.setType('Bulleted');
    l.addItem(DAStudio.message('RTW:report:CodeMappingBullet1'));
    l.addItem(DAStudio.message('RTW:report:CodeMappingBullet2'));
    p.addItem(l);
    diagInfo=obj.getDiagInfo;
    if isempty(diagInfo)
        contents=Advisor.Text(DAStudio.message('RTW:report:CodeMappingNoNonVirtual'),{'bold'});
    else
        table=Advisor.Table(size(diagInfo,1),size(diagInfo,2));
        table.setEntries(diagInfo);
        table.setStyle('AltRow');
        table.setColHeading(1,DAStudio.message('RTW:report:CodeMappingTableColumnSubsystem'));
        table.setColHeading(2,DAStudio.message('RTW:report:CodeMappingTableColumnReuseSetting'));
        table.setColHeading(3,DAStudio.message('RTW:report:CodeMappingTableColumnReuseOutcome'));
        table.setColHeading(4,DAStudio.message('RTW:report:CodeMappingTableColumnOutcomeDiagnostic'));
        contents=table;
    end
    obj.addSection('sec_code_mapping',DAStudio.message('RTW:report:CodeMappingTitle'),p,contents)
end


