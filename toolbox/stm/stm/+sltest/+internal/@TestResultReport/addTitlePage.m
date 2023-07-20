function addTitlePage(obj)











    persistent matlabVer;
    import mlreportgen.dom.*;

    TitlePart=Group();

    table=Table(2);
    groups=sltest.testmanager.ReportUtility.genTableColSpecGroup([{'3cm'},{'10cm'}]);
    table.ColSpecGroups=groups;
    table.Style={ResizeToFitContents(true),Width('15cm')};

    strList1={getString(message('stm:ReportContent:Field_Title'))...
    ,getString(message('stm:ReportContent:Field_Author'))...
    ,getString(message('stm:ReportContent:Field_Date'))};

    strList2={obj.ReportTitle,obj.AuthorName,datestr(now())};
    for k=1:length(strList1)
        onerow=TableRow();
        label=Text(strList1{k});
        sltest.testmanager.ReportUtility.setTextStyle(label,obj.TitleFontName,obj.TitleFontSize,obj.TitleFontColor,true,false);
        para=sltest.testmanager.ReportUtility.genParaDefaultStyle(label);
        onerow.append(TableEntry(para));

        label=Text(strList2{k});
        sltest.testmanager.ReportUtility.setTextStyle(label,obj.TitleFontName,obj.TitleFontSize,obj.TitleFontColor,true,false);
        para=sltest.testmanager.ReportUtility.genParaDefaultStyle(label);
        onerow.append(TableEntry(para));
        onerow.Style={OuterMargin('0mm','0mm','0mm','2mm')};
        table.append(onerow);
    end
    append(TitlePart,table);
    append(obj.TitlePart,TitlePart);


    if(obj.IncludeMWVersion)
        envPart=Group();
        table=Table(2);
        groups=sltest.testmanager.ReportUtility.genTableColSpecGroup([{'3cm'},{'10cm'}]);
        table.ColSpecGroups=groups;

        onerow=TableRow();
        str=getString(message('stm:ReportContent:Label_TestEnvironment'));
        text=Text(str);
        text.Style={FontSize(obj.HeadingFontSize),Color(obj.HeadingFontColor)};
        text.Bold=true;
        entry=TableEntry(text);
        entry.ColSpan=2;
        onerow.append(entry);
        onerow.Style={RowHeight('0.40in')};
        table.append(onerow);

        strList1={};
        strList2={};

        strList1=[strList1,{getString(message('stm:ReportContent:Field_Platform'))}];
        strList2=[strList2,computer()];


        strList1=[strList1,{getString(message('stm:ReportContent:Field_MATLAB'))}];

        if isempty(matlabVer)
            matlabVer=ver('MATLAB');
        end
        strList2=[strList2,matlabVer.Release];

        for k=1:length(strList1)
            onerow=TableRow();
            label=Text(strList1{k});
            sltest.testmanager.ReportUtility.setTextStyle(label,obj.BodyFontName,obj.BodyFontSize,obj.BodyFontColor,false,false);
            para=sltest.testmanager.ReportUtility.genParaDefaultStyle(label);
            onerow.append(TableEntry(para));

            label=Text(strList2{k});
            sltest.testmanager.ReportUtility.setTextStyle(label,obj.BodyFontName,obj.BodyFontSize,obj.BodyFontColor,false,false);
            para=sltest.testmanager.ReportUtility.genParaDefaultStyle(label);
            onerow.append(TableEntry(para));
            table.append(onerow);
        end
        append(envPart,table);

        if(isempty(obj.CustomTemplateFile))
            append(obj.TitlePart,obj.lineSeparator);
        end
        append(obj.TitlePart,envPart);
    end
end
