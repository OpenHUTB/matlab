
function publishValidationModelLink(~,w,valModel)



    table=w.createTable(1,2);
    table.createEntry(1,1,DAStudio.message('hdlcoder:report:validationModel'));
    driver=hdlmodeldriver(valModel);
    genModel=driver.CoverifyModelName;
    alink=Simulink.report.ReportInfo.getMatlabCallHyperlink(sprintf('matlab:coder.internal.code2model(''%s'')',genModel));
    table.createEntry(1,2,[alink{1},genModel,alink{2}]);
    w.commitTable(table);
end
