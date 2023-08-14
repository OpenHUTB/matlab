function dumpDetails(this,options)




    if length(this.cvstruct.system)==1&&...
        options.elimFullCov&&this.cvstruct.system(1).flags.fullCoverage
        return;
    end

    if(~isempty(this.waitbarH))
        this.waitbarH.setLabelText(getString(message('Slvnv:simcoverage:cvhtml:ReportingStructuralCoverage')));
        this.waitbarH.setValue(0);
    end

    msgId='Slvnv:simcoverage:cvhtml:Details';
    htmlTag=cvi.ReportScript.convertNameToHtmlTag(msgId);
    printIt(this,'<a name="%s"></a><h2>%s</h2>\n',htmlTag,getString(message(msgId)));


    newSysCnt=length(this.cvstruct.system);
    inReport=true;
    for i=1:newSysCnt
        sysEntry=this.cvstruct.system(i);

        dumpSubsystemSummary(this,sysEntry,i,inReport,options)
        dumpSubsystemDetails(this,sysEntry,inReport,options)
        if(~isempty(this.waitbarH))
            this.waitbarH.setValue(i/newSysCnt*100);
        end
    end
