
function publishGeneratedModelLink(~,w,genModel)



    section=w.createSectionTitle(DAStudio.message('hdlcoder:report:generatedModel'));
    w.commitSection(section);
    w.addBreak(2);
    table=w.createTable(1,2);
    table.createEntry(1,1,DAStudio.message('hdlcoder:report:genModelAfterTransformation'));

    alink=Simulink.report.ReportInfo.getMatlabCallHyperlink(sprintf('matlab:coder.internal.code2model(''%s'')',genModel));
    table.createEntry(1,2,[alink{1},genModel,alink{2}]);
    w.commitTable(table);
end
