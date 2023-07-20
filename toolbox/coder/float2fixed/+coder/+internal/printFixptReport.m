function launch=printFixptReport(fcnNames,typeProposalSettings,fcnInfoRegistry,proposedTypesCustomizations,outFileName,isFixPtReport,includeSimCoverage,hasBeenSimulated)




    if nargin<8
        hasBeenSimulated=true;
    end

    if nargin<7
        includeSimCoverage=false;
        hasBeenSimulated=true;
    end

    fileName=outFileName;

    fid=coder.internal.safefopen(fileName,'w','n','utf-8');
    if fid==-1
        error(message('Coder:FXPCONV:cannotopenfile',fileName));
    end

    writeHeader(fid,fcnNames,includeSimCoverage,typeProposalSettings);

    writeProlog(fid,typeProposalSettings);

    funcs=fcnInfoRegistry.getAllFunctionTypeInfos();
    for i=1:length(funcs)
        fcnInfo=funcs{i};
        varNames=fcnInfo.getAllVarNames();
        vars=coder.internal.VarTypeInfo.empty();
        for ii=1:length(varNames)
            varName=varNames{ii};
            varInfos=fcnInfo.getVarInfosByName(varName);
            if~isempty(varInfos)
                if~varInfos{1}.isSpecialized
                    vars(end+1)=varInfos{1};


                    if numel(varInfos)>1&&varInfos{1}.isVarInSrcCppSystemObj()&&isempty(varInfos{1}.SimMin)
                        vars(end)=varInfos{2};
                    end
                else

                    specs={};
                    for kk=1:numel(varInfos)
                        specs{varInfos{kk}.SpecializationId}=varInfos{kk};
                    end
                    vars=[vars,specs{:}];
                end
            end
        end
        fcnName=fcnInfo.getNameInInferenceReport();
        [signatureIndent,sameLine]=fcnInfo.tree.getOriginalIndentString();
        if sameLine

        end
        writeFunctionCode(fid,fcnName,[signatureIndent,fcnInfo.tree.tree2str(0,1)],includeSimCoverage,fcnInfo,typeProposalSettings);

        functionAnnotations=[];
        if(~isempty(proposedTypesCustomizations))
            if(proposedTypesCustomizations.isKey(fcnInfo.uniqueId))
                functionAnnotations=proposedTypesCustomizations(fcnInfo.uniqueId);
            end
        end
        showRatioOfRange=fcnInfo.hasScaledDoubles();
        createFixptReportSummaryTable(fid,typeProposalSettings,vars,functionAnnotations,showRatioOfRange,isFixPtReport,hasBeenSimulated);
        fprintf(fid,'\n');
    end

    createLegend(fid,typeProposalSettings);
    endBody(fid);
    createFooter(fid,fcnName);
    fclose(fid);
    launch=fileName;
end

function createLegend(fid,typeProposalSettings)
    safetyMargin=typeProposalSettings.safetyMargin;

    if safetyMargin~=0
        fprintf(fid,'%s',message('Coder:FxpConvReport:FXPCONVREPORT:createLegendSafetyMargin',num2str(safetyMargin)).getString);
    end
end


function writeHeader(fid,fcnNames,includeSimCoverage,typeProposalSettings)
    fprintf(fid,'<!DOCTYPE HTML>\n');
    fprintf(fid,'<html xmlns="http://www.w3.org/1999/xhtml">\n');
    fprintf(fid,'<head>\n');
    if typeProposalSettings.DoubleToSingle
        fprintf(fid,'<title>%s</title>\n',message('Coder:FxpConvReport:FXPCONVREPORT:createHeaderTitle_DTS',strjoin(fcnNames,', ')).getString);
    else
        fprintf(fid,'<title>%s</title>\n',message('Coder:FxpConvReport:FXPCONVREPORT:createHeaderTitle',strjoin(fcnNames,', ')).getString);
    end
    fprintf(fid,'<meta http-equiv="Content-Type" content="text/html; charset=utf-8">\n');
    writeStyles(fid,includeSimCoverage);
    fprintf(fid,'</head>\n');
end


function writeStyles(fid,includeSimCoverage)
    fprintf(fid,'<style>\n');
    fprintf(fid,'\tbody { font-family: monospace; }\n');
    fprintf(fid,'\th2 { font-family: Arial, Helvetica, sans-serif; color: #990000; margin-top: 50px; }\n');
    fprintf(fid,'\ttable,th,td { border: 1px solid black; }\n');
    fprintf(fid,'\ttable { margin-top: 30px; }\n');
    fprintf(fid,'\tth { align: center; font-weight: bold; }\n');
    fprintf(fid,'\ttr.h { background-color: #99CCFF; }\n');
    fprintf(fid,'\ttr.a { background-color: #EEEEFF; }\n');
    fprintf(fid,'\ttr.b { background-color: #FFFFFF; }\n');
    fprintf(fid,'\ttr.c { background-color: #FFA500; }\n');
    fprintf(fid,'\ttr.a td, tr.b td { border-style: none; }\n');
    fprintf(fid,'\ttd.left { text-align: left; }\n');
    fprintf(fid,'\ttd.right { text-align: right; }\n');
    fprintf(fid,'\ttd.center { text-align: center; }\n');
    fprintf(fid,'\ttd.bold { font-weight: bold; }\n');
    fprintf(fid,'\tpre { padding: 0px; margin: 0px; }\n');
    fprintf(fid,'\tspan { font-style: italic; }\n');

    if includeSimCoverage
        fprintf(fid,'\t.code, .code tr, .code th, .code td { border: none; border-collapse: collapse; }\n');
        fprintf(fid,'\t.padd { padding-left: 5px; }\n');
        fprintf(fid,'\ttd.cov, th.cov { width: 50px; height: 20px; text-align: center; font-weight: bold; border-right: 2px solid black; cell-spacing: 0px; }\n');
        fprintf(fid,'\ttd.cov { vertical-align: top; }\n');
        fprintf(fid,'\ttd.black { color: #000000; font-weight: bold; padding-top: 4px; }\n');
        fprintf(fid,'\ttd.white { color: #FFFFFF; font-weight: bold; padding-top: 4px; }\n');
        fprintf(fid,'\t.code th { font-weight: bold; border-bottom: 2px solid black; }\n');
    end

    fprintf(fid,'</style>\n');
end


function createFooter(fid,~)

    fprintf(fid,'</html>\n');

end


function writeProlog(fid,typeProposalSettings)
    fprintf(fid,'<body>\n');
    fprintf(fid,'<h3>%s</h3>\n',message('Coder:FxpConvReport:FXPCONVREPORT:beginBodyGenDate',datestr(now,31)).getString);
    if typeProposalSettings.DoubleToSingle
        fprintf(fid,'<p>%s</p>\n',message('Coder:FxpConvReport:FXPCONVREPORT:beginBodyInstrumTable_DTS').getString);
    else
        fprintf(fid,'<p>%s</p>\n',message('Coder:FxpConvReport:FXPCONVREPORT:beginBodyInstrumTable').getString);
    end
end


function writeFunctionCode(fid,fcnName,scriptText,includeSimCoverage,fcnInfo,typeProposalSettings)

    if typeProposalSettings.DoubleToSingle
        fprintf(fid,'<h2>%s <span>%s<span></h2>\n',message('Coder:FxpConvReport:FXPCONVREPORT:beginBodyReportTitle_DTS').getString,fcnName);
    else
        fprintf(fid,'<h2>%s <span>%s<span></h2>\n',message('Coder:FxpConvReport:FXPCONVREPORT:beginBodyReportTitle').getString,fcnName);
    end

    if includeSimCoverage
        writeFunctionCoverageTable(fid,scriptText,fcnInfo);
    else
        fprintf(fid,'<pre>');
        fprintf(fid,'%s',escapeHTMLFromMatlabCode(scriptText));
        fprintf(fid,'</pre>');
    end

    function text=escapeHTMLFromMatlabCode(text)


        text=regexprep(text,...
        {'&','<','>'},...
        {'&amp;','&lt;','&gt;'});
    end

    function writeFunctionCoverageTable(fid,code,fcnInfo)
        fprintf(fid,'<TABLE class="code">\n');


        fprintf(fid,'<TR>\n<TH class="cov padd">Simulation Coverage</TH>\n<TH>Code</TH>\n</TR>\n');

        if fcnInfo.isDead
            writeTableRow(fid,code,0);
        elseif fcnInfo.isConstantFolded
            writeTableRow(fid,code,-2);
        else


            blocks=generateBlocks(fcnInfo.tree.Body,fcnInfo.treeAttributes(fcnInfo.tree).HitOrCallCount,1,1);

            if isempty(blocks)
                if fcnInfo.treeAttributes(fcnInfo.tree).HitOrCallCount==0
                    writeTableRow(fid,code,0);
                else
                    writeTableRow(fid,code,100);
                end
            else
                fullBlocks=generateFullBlocks(blocks,code);
                finalBlocks=generateFinalBlocks(fullBlocks);

                for fB=1:length(finalBlocks)
                    writeTableRow(fid,finalBlocks{fB}('code'),finalBlocks{fB}('percent'));
                end
            end
        end

        fprintf(fid,'</TABLE>\n');

        function blocks=generateBlocks(node,parentHits,factor,level)
            blocks=containers.Map;
            if isempty(node)
                return;
            end

            possKinds={'IFHEAD','ELSEIF','ELSE','SWITCH','CASE','OTHERWISE','FOR','WHILE'};

            if ismember(node.kind,possKinds)
                [indentStr,~]=node.getOriginalIndentString();
                blocks('code')=[indentStr,strtrim(fcnInfo.treeAttributes(node).FormattedCode)];
                hits=fcnInfo.treeAttributes(node).HitOrCallCount;
                if strcmp(node.kind,'FOR')
                    if hits>0
                        hits=parentHits*factor;
                    end
                    parentHits=parentHits*factor;
                    fac=factor/hits;
                elseif strcmp(node.kind,'WHILE')
                    fac=hits;
                else
                    fac=1;
                end



                blocks('hits')=hits;
                blocks('parentHits')=parentHits;
                blocks('level')=level;

                if strcmp(node.kind,'SWITCH')
                    caseBlocks=generateBlocks(node.Body,hits,factor,level+1);
                    blocks=handleInternalCode(blocks,caseBlocks);
                elseif~strcmp(node.kind,'EXPR')
                    nestedNode=getNextNested(node.Body,{possKinds{1:end},'IF'});
                    if~isempty(nestedNode)
                        if strcmp(nestedNode.kind,'EXPR')
                            nestedBlocks=generateBlocks(nestedNode,parentHits,fac,level);
                        else
                            nestedBlocks=generateBlocks(nestedNode,hits,fac,level+1);
                        end

                        blocks=handleInternalCode(blocks,nestedBlocks);
                    end
                end

                nextBlocks=generateBlocks(node.Next,parentHits,factor,level);
                if~isempty(nextBlocks)
                    if ismember(node.kind,{'IFHEAD','ELSEIF'})
                        blocks=handleInternalCode(blocks,nextBlocks);
                    else
                        blocks=handleNextCode(blocks,nextBlocks);
                    end
                end
            elseif strcmp(node.kind,'IF')
                blocks=generateBlocks(node.Arg,parentHits,factor,level);

                nextBlocks=generateBlocks(node.Next,parentHits,factor,level);
                if~isempty(nextBlocks)
                    blocks=handleNextCode(blocks,nextBlocks);
                end
            elseif strcmp(node.kind,'EXPR')&&...
                parentHits>0&&...
                fcnInfo.treeAttributes(node).HitOrCallCount==0



                [indentStr,~]=node.getOriginalIndentString();
                fc=strtrim(fcnInfo.treeAttributes(node).FormattedCode);
                if~isempty(fc)
                    blocks('code')=[indentStr,fc];
                    blocks('hits')=0;
                    blocks('parentHits')=parentHits;
                    blocks('level')=level;
                end

                nextBlocks=generateBlocks(node.Next,parentHits,factor,level);

                if~isempty(nextBlocks)
                    if iscell(nextBlocks)
                        blocks={blocks,nextBlocks{1:end}};
                    else
                        blocks={blocks,nextBlocks};
                    end
                end
            else
                blocks=generateBlocks(node.Next,parentHits,factor,level);
            end

            function node=getNextNested(node,kinds)
                while~isempty(node)&&~ismember(node.kind,kinds)
                    node=node.Next;
                end
            end

            function blocks=handleNextCode(blocks,nextBlocks)
                if iscell(nextBlocks)
                    if iscell(blocks)
                        blocks={blocks{1:end},nextBlocks{1:end}};
                    else
                        blocks={blocks,nextBlocks{1:end}};
                    end
                elseif iscell(blocks)
                    blocks={blocks{1:end},nextBlocks};
                else
                    blocks={blocks,nextBlocks};
                end
            end

            function blocks=handleInternalCode(blocks,internalBlocks)
                if~iscell(blocks)
                    blocks={blocks};
                end
                if~iscell(internalBlocks)
                    internalBlocks={internalBlocks};
                end

                for j=1:length(internalBlocks)
                    if isempty(internalBlocks{j})
                        continue;
                    end
                    leng=length(internalBlocks{j}('code'));
                    ind=strfind(blocks{end}('code'),internalBlocks{j}('code'));
                    if length(ind)>1
                        ind=ind(1);
                    elseif~ind
                        disp 'printFixptReport.handleInternalCode: code to remove not found in block!';
                    end

                    c=blocks{end}('code');
                    pre=c(1:ind-1);
                    post=c(ind+leng:end);

                    if isempty(pre)&&isempty(post)

                        continue;
                    end

                    nonWhite=regexp(pre,'[^\s]','once');


                    if isempty(nonWhite)
                        k=blocks{end}('hits');
                        ph=blocks{end}('parentHits');
                        lev=blocks{end}('level');

                        blocks={blocks{1:end-1},internalBlocks{j}};

                        if~isempty(post)
                            if j<length(internalBlocks)&&...
                                ~isempty(internalBlocks{j+1})&&...
                                ~isempty(regexp(post,internalBlocks{j+1}('code'),'once'))
                                continue;
                            else
                                blocks{end+1}=containers.Map;
                                blocks{end}('code')=post;
                                blocks{end}('hits')=k;
                                blocks{end}('parentHits')=ph;
                                blocks{end}('level')=lev;
                            end
                        end
                    else
                        k=length(blocks);
                        blocks{end}('code')=pre;

                        blocks={blocks{1:end},internalBlocks{j}};

                        if~isempty(post)
                            if j<length(internalBlocks)&&...
                                ~isempty(internalBlocks{j+1})&&...
                                ~isempty(regexp(post,internalBlocks{j+1}('code'),'once'))
                                continue;
                            else
                                blocks{end+1}=containers.Map;
                                blocks{end}('code')=post;
                                blocks{end}('hits')=blocks{k}('hits');
                                blocks{end}('parentHits')=blocks{k}('parentHits');
                                blocks{end}('level')=blocks{k}('level');
                            end
                        end
                    end
                end
            end
        end

        function fullBlocks=generateFullBlocks(blocks,code)



            if~iscell(blocks)
                blocks={blocks};
            end

            fullBlocks={};
            otherCode='';
            blockToFull=zeros(1,length(blocks));
            for i=1:length(blocks)
                if isempty(blocks{i})
                    continue
                end

                len=length(blocks{i}('code'));
                index=strfind(code,blocks{i}('code'));
                if length(index)>1
                    index=index(1);
                elseif isempty(index)
                    disp 'printFixptReport.generateFullBlocks: block not found in code!';
                end

                otherCode{1}=code(1:index-1);
                otherCode{2}=code(index+len:end);

                if~isempty(otherCode{1})
                    if strcmp(otherCode{1},newline)
                        fullBlocks{end}('code')=[fullBlocks{end}('code'),newline];
                    else
                        fullBlocks{end+1}=containers.Map;
                        fullBlocks{end}('code')=otherCode{1};

                        if length(fullBlocks)==1
                            fullBlocks{end}('level')=0;
                        else
                            fullBlocks{end}('level')=fullBlocks{end-1}('level');
                        end
                        fullBlocks{end}('percent')=calculatePercent(2,2,i,fullBlocks{end}('level'));
                    end
                end

                code=otherCode{2};

                fullBlocks{end+1}=containers.Map;
                fullBlocks{end}('code')=blocks{i}('code');
                level=blocks{i}('level');
                fullBlocks{end}('level')=level;

                fullBlocks{end}('percent')=calculatePercent(blocks{i}('hits'),blocks{i}('parentHits'),i,level);

                blockToFull(i)=length(fullBlocks);
            end

            if~isempty(otherCode{2})
                fullBlocks{end+1}=containers.Map;
                fullBlocks{end}('code')=otherCode{2};
                fullBlocks{end}('percent')=100;
                if length(fullBlocks)==1
                    fullBlocks{end}('level')=0;
                else
                    fullBlocks{end}('level')=fullBlocks{end-1}('level');
                end
            end

            function percent=calculatePercent(hits,pHits,start,currLev)
                if hits==1
                    percent=-1;
                elseif hits==0
                    percent=0;
                else
                    percent=round(hits/pHits*100);
                end

                j=start-1;
                while currLev>1
                    currLev=currLev-1;
                    while(blocks{j}('level')>currLev)
                        j=j-1;
                    end
                    percent=round(percent*(fullBlocks{blockToFull(j)}('percent')/100));
                    j=j-1;
                end
            end
        end

        function finalBlocks=generateFinalBlocks(fullBlocks)


            finalBlocks={};
            lastPercent=-100;
            for i=1:length(fullBlocks)
                percent=fullBlocks{i}('percent');
                if percent~=lastPercent
                    finalBlocks{end+1}=containers.Map;
                    finalBlocks{end}('code')=fullBlocks{i}('code');
                    finalBlocks{end}('percent')=percent;
                    lastPercent=percent;
                else
                    finalBlocks{end}('code')=[finalBlocks{end}('code'),fullBlocks{i}('code')];
                end
            end
        end

        function writeTableRow(fid,code,percent)
            if percent==0||percent>50
                colorClass='white';
            else
                colorClass='black';
            end
            percentStr=generatePercentStr(percent);
            [red,green,blue]=generateHitColor(percent);

            fprintf(fid,sprintf('<TR>\n<TD class="cov %s" style="background-color: rgb(%d,%d,%d);">%s</TD>\n',colorClass,red,green,blue,percentStr));


            fprintf(fid,'<TD class="padd"><pre>');
            fprintf(fid,'%s',escapeHTMLFromMatlabCode(code));


            fprintf(fid,'</pre></TD>\n</TR>\n');

            function percentStr=generatePercentStr(newPercent)
                if newPercent==-1
                    percentStr='Once';
                elseif newPercent==-2
                    percentStr='Constant Folded';
                else
                    percentStr=sprintf('%d%%%%',newPercent);
                end
            end

            function[r,g,b]=generateHitColor(percent)
                switch percent
                case 0
                    r=157;
                    g=38;
                    b=35;
                case-1
                    r=255;
                    g=160;
                    b=118;
                case-2
                    r=180;
                    g=180;
                    b=180;
                case 100
                    r=5;
                    g=112;
                    b=9;
                otherwise
                    diff=100-percent;
                    r=5+round(diff*2.3);
                    g=112+round(diff*1.3);
                    b=9+round(diff*2.2);
                end
            end
        end
    end
end



function endBody(fid)

    fprintf(fid,'</body>\n');

end


function createFixptReportSummaryTable(fid,typeProposalSettings,vars,functionAnnotations,showRatioOfRange,isFixPtReport,hasBeenSimulated)

    createTable();

    function createTable()
        fprintf(fid,'%s','<TABLE>');

        createHeaderRow();
        createTableBody()

        fprintf(fid,'</TABLE>\n');

        function createHeaderRow()
            fprintf(fid,'<TR class="h">');
            fprintf(fid,'<th>%s</th>',message('Coder:FxpConvReport:FXPCONVREPORT:createFixptReportSummaryTableVarName').getString);
            fprintf(fid,'<th>Type</th>');
            if hasBeenSimulated
                fprintf(fid,'<th>Sim Min</th>');
                fprintf(fid,'<th>Sim Max</th>');
            end
            if~isFixPtReport
                if~typeProposalSettings.DoubleToSingle
                    fprintf(fid,'<th>Static Min</th>');
                    fprintf(fid,'<th>Static Max</th>');
                end
                if hasBeenSimulated
                    fprintf(fid,'<th>Whole Number</th>');
                end
            end
            if showRatioOfRange
                fprintf(fid,'<th>Percent Of Current Range</th>');
            end

            if~typeProposalSettings.DoubleToSingle
                if typeProposalSettings.proposeFLForDefWL
                    settingStr=sprintf('(%s WL = %d)',message('Coder:FxpConvReport:FXPCONVREPORT:createFixptReportSummaryTableBestFor').getString,typeProposalSettings.defaultWL);
                elseif typeProposalSettings.proposeWLForDefFL
                    settingStr=sprintf('(%s FL = %d)',message('Coder:FxpConvReport:FXPCONVREPORT:createFixptReportSummaryTableBestFor').getString,typeProposalSettings.defaultFL);
                else
                    settingStr='(Best Type...)';
                end
            else
                settingStr='';
            end

            if~isFixPtReport
                fprintf(fid,sprintf('<th>%s <BR /> %s</th>',message('Coder:FxpConvReport:FXPCONVREPORT:createFixptReportSummaryTableProposedType').getString,settingStr));
            end

            fprintf(fid,'</TR>');
        end

        function createTableBody()

            for n=1:length(vars)
                entry=vars(n);

                if~entry.isSupportedVar
                    continue;
                end

                if(entry.isStruct()||entry.isVarInSrcCppSystemObj())
                    if entry.isStruct()



                        rI.varName=entry.SymbolName;
                        rI.SimMin=[];
                        rI.SimMax=[];
                        rI.StaticMin=[];
                        rI.StaticMax=[];
                        rI.InferredType=entry.inferred_Type;
                        rI.IsAlwaysInteger=[];
                        rI.annotated_Type=[];
                        rI.fimath=[];
                        rI.RatioOfRange=[];
                        writeRow(fid,rI,n,functionAnnotations,showRatioOfRange);
                    end
                    for ii=1:length(entry.loggedFields)
                        rI.varName=char(entry.loggedFields(ii));
                        if~isempty(entry.SimMin)
                            rI.SimMin=entry.SimMin(ii);
                        else
                            rI.SimMin=[];
                        end
                        if~isempty(entry.SimMax)
                            rI.SimMax=entry.SimMax(ii);
                        else
                            rI.SimMax=[];
                        end
                        [rI.StaticMin,rI.StaticMax]=getStaticMinMax(entry,ii);
                        rI.InferredType=entry.loggedFieldsInferred_Types{ii};
                        if~isempty(entry.IsAlwaysInteger)
                            rI.IsAlwaysInteger=entry.IsAlwaysInteger(ii);
                        else
                            rI.IsAlwaysInteger=[];
                        end

                        if length(entry.annotated_Type)>=ii
                            rI.annotated_Type=entry.annotated_Type{ii};
                        else
                            rI.annotated_Type=[];
                        end
                        rI.fimath=entry.getFimathForStructField(ii);
                        if ii<=length(entry.RatioOfRange)
                            rI.RatioOfRange=entry.RatioOfRange{ii};
                        end

                        writeRow(fid,rI,n,functionAnnotations,showRatioOfRange);
                    end
                else
                    if entry.isSpecialized
                        rI.varName=sprintf('%s > %d',entry.SymbolName,entry.SpecializationId);
                    else
                        rI.varName=entry.SymbolName;
                    end
                    rI.SimMin=entry.SimMin;
                    rI.SimMax=entry.SimMax;
                    [rI.StaticMin,rI.StaticMax]=getStaticMinMax(entry,1);
                    rI.InferredType=entry.inferred_Type;
                    rI.IsAlwaysInteger=entry.IsAlwaysInteger;
                    rI.annotated_Type=entry.annotated_Type;
                    fm=entry.getFimath();
                    rI.fimath=fm;
                    rI.RatioOfRange=entry.RatioOfRange{1};


                    writeRow(fid,rI,n,functionAnnotations,showRatioOfRange);
                end
            end


            function writeRow(fid,rI,rowNum,functionAnnotations,showRatioOfRange)

                [columns,highlightRow]=constructColumns(rI,getVarAnnotation(rI.varName,functionAnnotations),showRatioOfRange);


                if(highlightRow)

                    fprintf(fid,'<TR class="c">\n');
                elseif mod(rowNum,2)==0
                    fprintf(fid,'<TR class="b">\n');
                else
                    fprintf(fid,'<TR class="a">\n');
                end

                fprintf(fid,columns);

                fprintf(fid,'</TR>\n');


                function[columns,highlightRow]=constructColumns(rI,variableAnnotations,showRatioOfRange)
                    columns='';
                    highlightRow=false;
                    if~isempty(variableAnnotations)
                        columns=strcat(columns,sprintf('<TD class="left bold">%s*</TD>\n',rI.varName));
                    else
                        columns=strcat(columns,sprintf('<TD class="left">%s</TD>\n',rI.varName));
                    end

                    columns=strcat(columns,sprintf('<TD class="left">%s</TD>\n',toUniqueString(rI.InferredType)));

                    [rI.SimMin,rI.SimMax]=coder.internal.VarTypeInfo.ResetImposibleSimData(rI.SimMin,rI.SimMax);

                    if hasBeenSimulated
                        if(~isempty(variableAnnotations)&&variableAnnotations.isKey('1'))
                            columns=strcat(columns,sprintf('<TD class="right bold">%s</TD>\n',coder.internal.compactButAccurateNum2Str(variableAnnotations('1'))));
                        else
                            if ischar(rI.SimMin)&&strcmp(coder.internal.VarTypeInfo.UNKNOWN_STR,rI.SimMin)
                                simMinStr=rI.SimMin;
                            else
                                simMinStr=coder.internal.compactButAccurateNum2Str(rI.SimMin);
                            end
                            columns=strcat(columns,sprintf('<TD class="right">%s</TD>\n',simMinStr));
                        end
                        if(~isempty(variableAnnotations)&&variableAnnotations.isKey('2'))
                            columns=strcat(columns,sprintf('<TD class="right bold">%s</TD>\n',coder.internal.compactButAccurateNum2Str(variableAnnotations('2'))));
                        else
                            if ischar(rI.SimMax)&&strcmp(coder.internal.VarTypeInfo.UNKNOWN_STR,rI.SimMax)
                                simMaxStr=rI.SimMax;
                            else
                                simMaxStr=coder.internal.compactButAccurateNum2Str(rI.SimMax);
                            end
                            columns=strcat(columns,sprintf('<TD class="right">%s</TD>\n',simMaxStr));
                        end
                    end

                    if~isFixPtReport
                        if~typeProposalSettings.DoubleToSingle

                            columns=strcat(columns,sprintf('<TD class="right">%s</TD>\n',coder.internal.compactButAccurateNum2Str(rI.StaticMin)));
                            columns=strcat(columns,sprintf('<TD class="right">%s</TD>\n',coder.internal.compactButAccurateNum2Str(rI.StaticMax)));
                        end


                        if hasBeenSimulated
                            if(~isempty(variableAnnotations)&&variableAnnotations.isKey('3'))
                                columns=strcat(columns,sprintf('<TD class="left bold">%s</TD>\n',coder.internal.convertBoolToYesNo(variableAnnotations('3'))));
                            elseif isempty(rI.IsAlwaysInteger)
                                columns=strcat(columns,sprintf('<TD class="left">%s</TD>\n',''));
                            else
                                columns=strcat(columns,sprintf('<TD class="left">%s</TD>\n',coder.internal.convertBoolToYesNo(rI.IsAlwaysInteger)));
                            end
                        end
                    end

                    if showRatioOfRange
                        columns=strcat(columns,sprintf('<TD class="center">%s</TD>\n',coder.internal.compactButAccurateNum2Str(ceil(rI.RatioOfRange*100))));
                    end

                    if~isFixPtReport
                        if(~isempty(variableAnnotations)&&variableAnnotations.isKey('4'))
                            columns=strcat(columns,sprintf('<TD class="center bold">%s</TD>\n',variableAnnotations('4')));
                        else



                            T=rI.annotated_Type;


                            if isnumerictype(T)
                                if(T.FractionLength<0)
                                    highlightRow=true;
                                end
                                columns=strcat(columns,sprintf('<TD class="left">%s</TD>\n',toString(T)));
                            elseif ischar(T)



                                columns=strcat(columns,sprintf('<TD class="left">%s</TD>\n',T));
                            else
                                columns=strcat(columns,sprintf('<TD class="left">%s</TD>\n',''));
                            end
                        end
                    end
                end
            end
        end
    end

    function[staticMin,staticMax]=getStaticMinMax(varInfo,idx)
        if~isempty(varInfo.DesignMin)&&idx<=length(varInfo.DesignMin)&&varInfo.DesignRangeSpecified
            staticMin=varInfo.DesignMin(idx);
        elseif~isempty(varInfo.DerivedMin)&&idx<=length(varInfo.DerivedMin)&&varInfo.DerivedMinMaxComputed
            staticMin=varInfo.DerivedMin(idx);
        else
            staticMin=[];
        end

        if~isempty(varInfo.DesignMax)&&idx<=length(varInfo.DesignMax)&&varInfo.DesignRangeSpecified
            staticMax=varInfo.DesignMax(idx);
        elseif~isempty(varInfo.DerivedMax)&&idx<=length(varInfo.DerivedMax)&&varInfo.DerivedMinMaxComputed
            staticMax=varInfo.DerivedMax(idx);
        else
            staticMax=[];
        end
    end
end

function variableAnnotations=getVarAnnotation(varName,functionAnnotations)
    variableAnnotations=[];
    if(~isempty(functionAnnotations))
        if(functionAnnotations.isKey(varName))
            variableAnnotations=functionAnnotations(varName);
        end
    end
end


function typeName=toUniqueString(inferredType)
    dimension=char('');
    for ii=1:length(inferredType.Size)
        if(ii<length(inferredType.SizeDynamic)&&inferredType.SizeDynamic(ii))
            dimension=[dimension,':'];
        end

        if(inferredType.Size(ii)==-1)
            dimension=[dimension,'Inf'];%#ok<*AGROW>
        else
            dimension=[dimension,num2str(inferredType.Size(ii))];
        end

        if(ii<length(inferredType.Size))
            dimension=[dimension,' x '];
        end
    end

    typeName=inferredType.Class;
    if strcmp(inferredType.Class,'embedded.fi')
        typeName=toString(inferredType.NumericType);
    end

    if~strcmp(dimension,'1 x 1')
        typeName=[typeName,' ',dimension,' '];
    end

    if inferredType.Complex
        typeName=[typeName,'complex '];
    end
end

function str=toString(NT)
    if NT.Signed
        sign='1';
    else
        sign='0';
    end
    str=['numerictype(',sign,', ',num2str(NT.WordLength),', ',num2str(NT.FractionLength),')'];
end



