function[output_args]=generateComplianceReport(report,model,sfuncNames,...
    categories,checkResults,targetBlockMap,isTestharness)

    import mlreportgen.dom.*;


    ExemptedBlocks=checkResults.ExemptedBlocks;
    timestamp=checkResults.TimeGenerated;
    os=checkResults.Platform;
    release=checkResults.Release;
    data=checkResults.Data;
    version=checkResults.SimulinkVersion;
    if~isempty(checkResults.MexConfiguration)
        compiler=checkResults.MexConfiguration.ShortName;
    else
        compiler='';
    end
    p=Paragraph();
    append(p,LinkTarget('top'));
    append(report,p);

    headingobj=Heading(3,'S-Function Check Report - ');
    headingobj.Bold=true;
    headingobj.HAlign='center';

    tss1='matlab:open_and_hilite_system(''';
    tss=[tss1,model,''')'];
    el=ExternalLink(tss,model);
    el.Style={Color('#890c29')};
    append(headingobj,el);
    append(report,headingobj);


    headerTable=Table(2);
    headerTable.StyleName='AdvTableNoBorder';
    headerTable.Width='100%';

    row=TableRow;
    te=TableEntry();
    pa=Paragraph();
    headingobj1=Text('Time Generated: ');
    headingobj1.Style={Bold};
    append(pa,headingobj1);
    text=Text(timestamp,'colorText');
    append(pa,text);
    te.Style={HAlign('left'),OuterMargin('0pt','0pt','1pt','1pt'),InnerMargin('0pt','0pt','1pt','1pt')};
    append(te,pa);
    append(row,te);

    te=TableEntry();
    pa=Paragraph();
    headingobj1=Text('Platform: ');
    headingobj1.Style={Bold};
    append(pa,headingobj1);
    text=Text(os,'colorText');
    append(pa,text);
    te.Style={HAlign('right'),OuterMargin('0pt','0pt','1pt','1pt'),InnerMargin('0pt','0pt','1pt','1pt')};
    append(te,pa);
    append(row,te);
    append(headerTable,row);

    row=TableRow;
    te=TableEntry();
    te.Style={OuterMargin('0pt','0pt','1pt','1pt'),InnerMargin('0pt','0pt','1pt','1pt')};
    pa=Paragraph();
    headingobj1=Text('Release: ');
    headingobj1.Style={Bold};
    append(pa,headingobj1);
    text=Text(release,'colorText');
    append(pa,text);
    append(te,pa);
    append(row,te);

    te=TableEntry();
    pa=Paragraph();
    headingobj1=Text('Simulink Version: ');
    headingobj1.Style={Bold};
    append(pa,headingobj1);
    text=Text(version,'colorText');
    append(pa,text);
    te.Style={HAlign('right'),OuterMargin('0pt','0pt','1pt','1pt'),InnerMargin('0pt','0pt','1pt','1pt')};
    append(te,pa);
    append(row,te);
    append(headerTable,row);

    row=TableRow;
    te=TableEntry();
    pa=Paragraph();
    headingobj1=Text('MEX Compiler: ');
    headingobj1.Style={Bold};
    append(pa,headingobj1);
    text=Text(compiler,'colorText');
    append(pa,text);
    te.Style={HAlign('left'),OuterMargin('0pt','0pt','1pt','1pt'),InnerMargin('0pt','0pt','1pt','1pt')};
    append(te,pa);
    append(row,te);
    append(headerTable,row);

    append(report,headerTable);


    headingobj=Heading(5,'Check Summary');
    append(report,headingobj);


    [numberOfSfunctions,numberOfCategories]=size(data);
    if numberOfSfunctions==0
        pa=Paragraph();
        text=Text([DAStudio.message('Simulink:SFunctions:ComplianceCheckNoEligibleSfunction'),' ']);
        text.Bold=true;
        tss1='matlab:open_system(''';
        tss=[tss1,model,''')'];
        el=ExternalLink(tss,model);
        el.Style={Color('#890c29'),Bold()};
        append(pa,text);
        append(pa,el);
        append(report,pa);
    end
    table=Table(1+numberOfCategories);
    table.StyleName='AdvTable';
    table.Width='100%';

    row=TableRow;
    append(row,TableHeaderEntry('S-Function name'));
    for i=1:numberOfCategories
        pa=Paragraph();
        text=Text(Simulink.sfunction.analyzer.internal.geti18nMessage(categories{i}));
        append(pa,text);


        switch i
        case 1
            cateAnchor='EnvCheck';
        case 2
            cateAnchor='SrcCheck';
        case 3
            cateAnchor='MexFileCheck';
        case 4
            cateAnchor='RobustnessCheck';
        end
        tss1=['matlab:helpview(fullfile(docroot,''simulink'',''helptargets.map''),'''];
        tss2=[tss1,cateAnchor];
        tss=[tss2,''')'];
        link=ExternalLink(tss,'?');
        link.Style={VerticalAlign('superscript'),FontSize('9pt'),Underline('none')};
        append(pa,link);
        te=TableHeaderEntry();
        append(te,pa);
        append(row,te);
    end
    append(table,row);

    for j=1:numberOfSfunctions
        row=TableRow;
        te=TableEntry();
        te.Style={HAlign('center')};
        te.append(InternalLink(sfuncNames{j},sfuncNames{j}));
        append(row,te);
        for i=1:numberOfCategories
            result=data(j,i).SummaryResult;
            numberOfIssues=data(j,i).SummaryNumber;
            Simulink.sfunction.analyzer.internal.addSummaryTableEntry(row,sfuncNames{j},result,numberOfIssues,...
            data(j,i).CheckCategory);
        end
        append(table,row);
    end
    append(report,table);

    html=HTML('<br/>');
    append(report,html);
    if~isempty(ExemptedBlocks)
        il=InternalLink('ExemptionHead','Exempted Blocks for S-Function Checks');
        il.Style={FontSize('9pt')};
        append(report,il);
    end



    hr=HorizontalRule();
    hr.Border='solid';
    hr.BorderColor='green';
    append(report,hr);



    for k=1:numberOfSfunctions
        h3=Heading(5,LinkTarget(sfuncNames{k}));
        append(h3,['S-Function:',sfuncNames{k}]);
        append(report,h3);
        for i=1:numberOfCategories
            if((~strcmp(data(k,i).SummaryResult,...
                Simulink.sfunction.analyzer.internal.geti18nMessage(Simulink.sfunction.analyzer.internal.ComplianceCheck.NOTRUN))&...
                ~strcmp(data(k,i).SummaryResult,...
                Simulink.sfunction.analyzer.internal.geti18nMessage(Simulink.sfunction.analyzer.internal.ComplianceCheck.PASS)))||...
                (strcmp(data(k,i).SummaryResult,...
                Simulink.sfunction.analyzer.internal.geti18nMessage(Simulink.sfunction.analyzer.internal.ComplianceCheck.NOTRUN))&...
                data(k,i).SummaryNumber~=0))

                at=Heading(5,LinkTarget([sfuncNames{k},data(k,i).CheckCategory]));
                append(at,data(k,i).CheckCategory);
                at.Style={HAlign('center')};
                append(report,at);


                compileTable=Table(3);
                compileTable.StyleName='AdvTable';
                compileTable.Width='95%';
                compileTable.TableEntriesHAlign='left';

                row=TableRow;
                te1=TableHeaderEntry('Description');
                te1.Style={Bold(),FontSize('14pt'),Width('11cm'),HAlign('center'),VAlign('bottom')};
                te2=TableHeaderEntry('Result');
                te2.Style={Bold(),FontSize('14pt'),Width('2cm'),HAlign('center')};
                te3=TableHeaderEntry('Detail');
                te3.Style={Bold(),FontSize('14pt'),HAlign('center')};
                append(row,te1);
                append(row,te2);
                append(row,te3);
                append(compileTable,row);

                contents=data(k,i).Check;
                for j=1:numel(contents)
                    if strcmp(contents(j).Result,Simulink.sfunction.analyzer.internal.geti18nMessage(Simulink.sfunction.analyzer.internal.ComplianceCheck.PASS))
                        continue;
                    end
                    row=TableRow;
                    para=Paragraph();
                    text=Text(contents(j).Description);
                    append(para,text);

                    tss1=['matlab:helpview(fullfile(docroot,''simulink'',''helptargets.map''),'''];
                    if isequal(contents(j).Description,'MEX Setup Check')
                        anchorId='MexSetupCheck';
                    elseif isequal(contents(j).Description,'MEX Compile Check')
                        anchorId='MexCompileCheck';
                    else
                        anchorId=regexprep(contents(j).Description,'\s+','');
                    end
                    tss2=[tss1,anchorId];
                    tss=[tss2,''')'];
                    link=ExternalLink(tss,'?');

                    link.Style={VerticalAlign('superscript'),FontSize('9pt'),Underline('none')};
                    append(para,link);
                    te1=TableEntry();
                    append(te1,para);
                    te1.Style={Width('2cm'),HAlign('center')};
                    append(row,te1);
                    te2=TableEntry(contents(j).Result);
                    te2.Style={HAlign('center')};
                    append(row,te2);
                    details=contents(j).Detail;
                    if(~isempty(details))
                        if isTestharness&&isKey(targetBlockMap,sfuncNames{k})
                            detailTable=Simulink.sfunction.analyzer.internal.addDetailTable(details,data(k,i).CheckCategory,contents(j).Description,...
                            contents(j).Result,compiler,targetBlockMap(sfuncNames{k}));
                        else
                            detailTable=Simulink.sfunction.analyzer.internal.addDetailTable(details,data(k,i).CheckCategory,contents(j).Description,...
                            contents(j).Result,compiler);
                        end
                        te3=TableEntry(detailTable);
                        te3.Style={HAlign('center')};
                    else

                        te3=TableEntry();
                    end
                    append(row,te3);
                    append(compileTable,row);
                end
                append(report,compileTable);

                html=HTML('<br/>');
                append(report,html);
                html=HTML('<br/>');
                append(report,html);
            end
        end

        append(report,InternalLink('top','Return to top'));

        hr=HorizontalRule();
        hr.Border='solid';
        hr.BorderColor='green';
        append(report,hr);


    end
    if~isempty(ExemptedBlocks)
        at=Heading(5,LinkTarget('ExemptionHead'));
        append(at,'Exempted Blocks for S-Function Analyzer');
        append(report,at);

        list=OrderedList(ExemptedBlocks);
        append(report,list);
        append(report,InternalLink('top','Return to top'));
        hr=HorizontalRule();
        hr.Border='solid';
        hr.BorderColor='green';
        append(report,hr);
    end
end

