function dumpRequirementTable(this,blkEntry,options)




    if~options.showReqTable||...
        ~isfield(options.contextInfo,'Requirements')||...
        isempty(options.contextInfo.Requirements')
        return;
    end

    reqInfo=options.contextInfo.Requirements;

    [mdlItemInds,sid]=findReqModelItemIndices(reqInfo,blkEntry.cvId);
    if~isempty(mdlItemInds)
        [~,sidEnd]=strtok(sid,':');
        htmlTag=sprintf('ReqTstsTable%s',strrep(sidEnd,':','_'));
        reqTableTitle=getString(message('Slvnv:simcoverage:cvhtml:ReqTableTitle'));
        printIt(this,'<a name="%s"></a><h4>%s</h4>\n',htmlTag,reqTableTitle);

        genReqTable(this,reqInfo,mdlItemInds);
    end
end

function[mdlItemInds,sid]=findReqModelItemIndices(reqInfo,cvId)
    mdlItemInds=[];
    sid=cvi.TopModelCov.getSID(cvId);

    if reqInfo.modelItemMap.isKey(sid)
        mdlItemInds=reqInfo.modelItemMap(sid);
    end


    libSID=findReferencedLibSID(sid);
    if~isempty(libSID)&&reqInfo.modelItemMap.isKey(libSID)
        mdlItemInds=[mdlItemInds,reqInfo.modelItemMap(libSID)];
    end

    if isempty(mdlItemInds)


        sid=cvdata.mapFromHarnessBlockCvId(cvId);
        if~isempty(sid)&&reqInfo.modelItemMap.isKey(sid)
            mdlItemInds=reqInfo.modelItemMap(sid);
        end
    end
end

function libSID=findReferencedLibSID(instSID)


    try
        if(length(strfind(instSID,':'))>1)
            sfH=Simulink.ID.getHandle(instSID);
            libSID=Simulink.ID.getLibSID(sfH);
        else
            libSID=Simulink.ID.getLibSID(instSID);
        end

        if strcmp(libSID,instSID)
            libSID=[];
        end
    catch MEx %#ok<NASGU>
        libSID=[];
    end
end


function genReqTable(this,info,mdlItemInds)

    mdlItems=info.ModelItem(mdlItemInds);
    implInd=[mdlItems.ImplementedInd];
    implLinks=info.ImplementLink(implInd);
    reqInd=[implLinks.RequirementIdx];

    reqTblInfo=info.Requirement(reqInd);
    reqCnt=numel(reqTblInfo);

    for rIdx=1:reqCnt
        linkInd=reqTblInfo(rIdx).VerifyInd;
        links=info.VerifyLink(linkInd);
        testInfo=[];
        if~isempty(links)
            testInd=[links.TestIdx];
            testInfo=info.Test(testInd);
            for tstIdx=1:numel(testInfo)
                simInd=testInfo(tstIdx).SimulationInd;

                Simulations=info.Simulation(simInd);
                testInfo(tstIdx).Simulations=Simulations;
            end
        end
        reqTblInfo(rIdx).Tests=testInfo;
        reqTblInfo(rIdx).TestCnt=numel(testInfo);


        if isempty(reqTblInfo(rIdx).Label)
            reqTblInfo(rIdx).Label=reqTblInfo(rIdx).FullID;
        end
    end



    tableInfo.table='border="1" cellpadding="5"';
    tableInfo.cols(1)=struct('align','"left"','width',200);
    tableInfo.cols(2)=struct('align','"left"','width',200);
    tableInfo.cols(3)=struct('align','"left"','width',150);

    noTests=getString(message('Slvnv:simcoverage:cvhtml:ReqTableNoTests'));
    noRuns=getString(message('Slvnv:simcoverage:cvhtml:ReqTableNoRuns'));
    requirementsHeader=getString(message('Slvnv:simcoverage:cvhtml:ReqTableRequirementsHeader'));
    testsHeader=getString(message('Slvnv:simcoverage:cvhtml:ReqTableTestsHeader'));
    runsHeader=getString(message('Slvnv:simcoverage:cvhtml:ReqTableRunsHeader'));
    tblHeaders={['$<b>',requirementsHeader,'</b>'],...
    ['$<b>',testsHeader,'</b>'],...
    ['$<b>',runsHeader,'</b>'],...
    '\n'};

    data={'ForEach','#.'...
    ,{'RowSpan',{'&in_href','#Label','#URL'},'%Tests'},...
    {'If',{'&isempty','#Tests'},...
    ['$',noTests],['$',noRuns],'\n'...
    ,'Else',...
    {'ForEach','#Tests',...
    {'&in_href','#Label','#URL'},...
    {'If',{'&isempty','#Simulations'},['$',noRuns],...
    'Else',...
    {'Cat',{'ForEach','#Simulations',{'&in_href','#Label','#URL'},...
    {'If',{'RpnExpr','@1','%<Simulations','<'},'$, '}}}}...
    ,'\n'...
    }...
    }...
    };

    tableStr=cvprivate('html_table',reqTblInfo,[tblHeaders,{data}],tableInfo);
    printIt(this,'%s',tableStr);
    printIt(this,'<br/>\n');
end


