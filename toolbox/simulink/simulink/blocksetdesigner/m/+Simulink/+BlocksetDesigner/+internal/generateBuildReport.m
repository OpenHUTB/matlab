function generateBuildReport(report,blockName,status,details,compiler)

    import mlreportgen.dom.*;

    timestamp=char(datetime);
    os=computer('arch');

    p=Paragraph();
    append(p,LinkTarget('top'));
    append(report,p);

    headingobj=Heading(3,['Build Report for ',blockName]);
    headingobj.Bold=true;
    headingobj.HAlign='center';
    headingobj.Color='#890c29';
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
    text=Text(version('-release'),'colorText');
    append(pa,text);
    append(te,pa);
    append(row,te);

    te=TableEntry();
    pa=Paragraph();
    headingobj1=Text('MEX Compiler: ');
    headingobj1.Style={Bold};
    append(pa,headingobj1);
    text=Text(compiler,'colorText');
    append(pa,text);
    te.Style={HAlign('right'),OuterMargin('0pt','0pt','1pt','1pt'),InnerMargin('0pt','0pt','1pt','1pt')};
    append(te,pa);
    append(row,te);

    append(headerTable,row);

    append(report,headerTable);


    hr=HorizontalRule();
    hr.Border='solid';
    hr.BorderColor='green';
    append(report,hr);



    h3=Heading(5,LinkTarget(blockName));
    append(h3,['S-Function:',blockName]);
    append(report,h3);


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


    row=TableRow;
    para=Paragraph();
    text=Text('MEX Compile');
    append(para,text);
    te1=TableEntry();
    append(te1,para);
    te1.Style={Width('2cm'),HAlign('center')};
    append(row,te1);
    te2=TableEntry(status);
    te2.Style={HAlign('center')};
    append(row,te2);
    if(~isempty(details))
        detailTable=Simulink.sfunction.analyzer.internal.addDetailTable(details,...
        Simulink.sfunction.analyzer.internal.geti18nMessage(Simulink.sfunction.analyzer.internal.ComplianceCheck.SOURCE_CODE_CHECK),...
        'MEX Compile',status,compiler);

        te3=TableEntry(detailTable);
        te3.Style={HAlign('center')};
    else

        te3=TableEntry();
    end
    append(row,te3);
    append(compileTable,row);


    append(report,compileTable);
    html=HTML('<br/>');
    append(report,html);



    append(report,InternalLink('top','Return to top'));

    hr=HorizontalRule();
    hr.Border='solid';
    hr.BorderColor='green';
    append(report,hr);



    html=HTML('<br/>');
    append(report,html);
end