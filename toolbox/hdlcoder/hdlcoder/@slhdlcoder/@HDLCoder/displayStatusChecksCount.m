function displayStatusChecksCount(this,mdlName,tbCatalog)



    narginchk(3,3);
    if tbCatalog
        checksCatalog=this.TestbenchChecksCatalog;
    else
        checksCatalog=this.ChecksCatalog;
    end

    checks=checksCatalog(mdlName);
    [errorCount,warningCount,messageCount,~,~,~]=this.statusCount(checks);
    if tbCatalog
        msg=message('hdlcoder:hdldisp:FinishTB',mdlName,...
        sprintf('%d',errorCount),...
        sprintf('%d',warningCount),...
        sprintf('%d',messageCount));
    else
        msg=message('hdlcoder:hdldisp:FinishCheck',mdlName,...
        sprintf('%d',errorCount),...
        sprintf('%d',warningCount),...
        sprintf('%d',messageCount));
    end
    hdldisp(msg);
end
