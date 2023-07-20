
function tableExec_details(this,blkEntry,cvstruct,options)





    if options.elimFullCovDetails&&...
        ~isempty(blkEntry.tableExec)&&all(blkEntry.tableExec.flags.fullCoverage)
        return;
    end




    tableData=[];
    if(~isempty(blkEntry.tableExec)&&isfield(blkEntry.tableExec,'tableIdx')&&...
        ~isempty(blkEntry.tableExec.tableIdx))
        if~options.elimFullCov||blkEntry.tableExec.localHits(end)~=blkEntry.tableExec.localCnt
            tableData=cvstruct.tables(blkEntry.tableExec.tableIdx);
        end
    end

    if~isempty(tableData)

        tableData.isJustified=all(tableData.isJustified(:));
        if numel(tableData.testData(end).execCnt)>400
            if isempty(this.tableDataCache)
                tableIdx=1;
            else
                [rows,~]=size(this.tableDataCache);
                tableIdx=rows+1;
            end
            printIt(this,'\n<br/> %s\n<br/>',getString(message('Slvnv:simcoverage:cvhtml:TableMapNotGenerated')));
            if~options.isDockedReport
                printIt(this,'<a href="matlab:cvi.ReportScript.generate_table(%d)">%s</a>\n',tableIdx,getString(message('Slvnv:simcoverage:cvhtml:ForceMapGeneration')));
            else
                printIt(this,'%s\n<br/>',getString(message('Slvnv:simcoverage:cvhtml:ForceMapGenerationReference')));
            end
            if(tableIdx>1)
                this.tableDataCache(tableIdx,:)={'',blkEntry.cvId,tableData.testData(end).execCnt,...
                tableData.breakPtValues,...
                tableData.testData(end).breakPtEquality,...
                tableData.isJustified,...
                tableData.testData(end).executedIn...
                };
            else
                this.tableDataCache={'',blkEntry.cvId,tableData.testData(end).execCnt,...
                tableData.breakPtValues,...
                tableData.testData(end).breakPtEquality,...
                tableData.isJustified,...
                tableData.testData(end).executedIn...
                };
            end

        else
            printIt(this,['\n<br/> &#160; <b> ',getString(message('Slvnv:simcoverage:cvhtml:LookupTableDetails')),' </b> <br/>\n']);
            printIt(this,'<table cellpadding="8" border="0"> <tr> <td>\n');


            [fileNames,cntThresh]=cvi.ReportScript.prepare_table_mapping_output(tableData.testData(end).execCnt,options,tableData.isJustified);

            outStr=cvprivate('table_map',tableData.testData(end).execCnt,...
            tableData.breakPtValues,...
            tableData.testData(end).breakPtEquality,...
            options.imageSubDirectory,...
            fileNames,...
            cntThresh,...
            tableData.isJustified,...
            tableData.testData(end).executedIn);

            printIt(this,'%s',outStr);

            printIt(this,'\n</td><td>\n');


            printIt(this,'%s',cvi.ReportScript.make_table_map_legend(fileNames,cntThresh,tableData.isJustified));

            printIt(this,'\n</td></tr> </table>\n');

        end
    end


