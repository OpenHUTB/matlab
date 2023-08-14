function outStr=fixGetReported(inStr)























    outStr=strrep(inStr,'RptgenSL.getReportedModel()','rptModelName');
    outStr=strrep(outStr,'RptgenSL.getReportedSystem()','rptSystemHandle');
    outStr=strrep(outStr,'RptgenSL.getReportedBlock()','rptBlockHandle');
end

