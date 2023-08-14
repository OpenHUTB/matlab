function dumpSubsystemSummary(this,sysEntry,idx,inReport,options)




    if options.elimFullCov&&sysEntry.flags.fullCoverage
        return;
    end
    if inReport
        printIt(this,'%s<h3>%d. %s</h3>\n',...
        cvi.ReportUtils.obj_anchor(sysEntry.cvId,''),...
        idx,...
        cvi.ReportScript.object_titleStr_and_link(sysEntry.cvId));
    end
    printIt(this,'<table> <tr> <td width="25"> </td> <td>\n');

    dumpBlockFilteringTable(this,sysEntry,options);
    dumpRequirementTable(this,sysEntry,options);

    if inReport
        produce_navigation_table(this,sysEntry,this.uncovIdArray,options);
        printIt(this,'<br/>\n\n');
    end
    skipComplexity=chekcHasOnlyBlockCoverageMetric(this,sysEntry);
    produce_summary_table(this,sysEntry,this.sysSummaryScript,options,skipComplexity);


    tEFCD=options.elimFullCovDetails;
    options.elimFullCovDetails=false;
    reportMetricDetails(this,sysEntry,inReport,options);
    options.elimFullCovDetails=tEFCD;

    printIt(this,'</td> </tr> </table>\n');
    printIt(this,'<br/>\n');

    sf('LoadDLL');
    if(Stateflow.internal.Version.toNumeric()>5.100e7)

        if cv('get',sysEntry.cvId,'.origin')==2
            try
                sfId=cv('get',sysEntry.cvId,'.handle');
                if(sf('get',sfId,'.isa')==sf('get','default','state.isa'))
                    is_a_truth_table=sf('get',sfId,'.truthTable.isTruthTable');
                else
                    is_a_truth_table=0;
                end
            catch MEx %#ok<NASGU>
                is_a_truth_table=0;
            end
        else
            is_a_truth_table=0;
        end
    else
        is_a_truth_table=0;
    end


    if is_a_truth_table
        tableStr=cvprivate('truth_table_html_cov',sysEntry.cvId,sysEntry,this.allTests{this.totalIdx},[]);
        printIt(this,'%s\n',tableStr);

    end

