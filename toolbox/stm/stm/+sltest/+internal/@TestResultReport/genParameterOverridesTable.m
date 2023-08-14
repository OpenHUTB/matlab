function overridesTable=genParameterOverridesTable(obj,resultObj,simIndex)













    p=inputParser;
    addRequired(p,'obj',...
    @(x)validateattributes(x,{'sltest.testmanager.TestResultReport',...
    'sltest.internal.TestResultReport'},{}));
    addRequired(p,'resultObj',...
    @(x)validateattributes(x,{'sltest.testmanager.TestResult'},{}));
    addRequired(p,'simIndex',...
    @(x)validateattributes(x,{'double'},{'integer','scalar','>=',1,'<=',2}));
    p.parse(obj,resultObj,simIndex);

    import mlreportgen.dom.*;

    parameterSet=resultObj.ParameterSet(simIndex);

    numColumns=4;
    overridesTable=FormalTable(numColumns);
    setTableStyle(overridesTable);
    overridesTable.TableEntriesStyle={OuterMargin('0mm')};
    overridesTable.Style=[overridesTable.Style,{ResizeToFitContents(true),...
    OuterMargin(obj.ChapterIndentL2,'0mm','0mm',obj.SectionSpacing)}];

    groups=sltest.testmanager.ReportUtility.genTableColSpecGroup([{'4cm'},{'4cm'},{'4cm'},{'6cm'}]);
    overridesTable.ColSpecGroups=groups;

    headrow=TableRow();
    fieldNames=cell(1,numColumns);
    fieldNames{1}=getString(message('stm:Parameters:Variable'));
    fieldNames{2}=getString(message('stm:ResultsTree:Value'));
    fieldNames{3}=getString(message('stm:Parameters:Source'));
    fieldNames{4}=getString(message('stm:Parameters:ModelElement'));
    for k=1:length(fieldNames)
        text=Text(fieldNames{k});
        text.Style={FontSize(obj.BodyFontSize),Color(obj.BodyFontColor)};
        text.Bold=true;
        entry=TableEntry(text);
        headrow.append(entry);
    end
    overridesTable.append(headrow);


    onerow=TableRow();
    onerow.Style={OuterMargin('0px','0px','3px','3px')};
    if(isempty(parameterSet.ParameterSetPath))

        text=Text(parameterSet.ParameterSetName);
        sltest.testmanager.ReportUtility.setTextStyle(text,obj.BodyFontName,obj.BodyFontSize,obj.BodyFontColor,false,false);
        entry=TableEntry(text);
        entry.ColSpan=numColumns;
        onerow.append(entry);
    else

        text=Text(parameterSet.ParameterSetPath);
        sltest.testmanager.ReportUtility.setTextStyle(text,obj.BodyFontName,obj.BodyFontSize,'Indigo',false,true);
        entry=TableEntry(text);
        entry.ColSpan=numColumns;
        onerow.append(entry);
    end
    entry.Style={VAlign('middle')};
    overridesTable.append(onerow);

    for k=1:length(parameterSet.ParameterOverrides)
        onerow=TableRow();
        onerow.Style={OuterMargin('0px','0px','3px','3px')};


        text=Text(parameterSet.ParameterOverrides(k).Variable);
        sltest.testmanager.ReportUtility.setTextStyle(text,obj.BodyFontName,obj.BodyFontSize,obj.BodyFontColor,false,false);
        entry=TableEntry(text);

        entry.Style={OuterMargin('30px','0px','0px','0px'),VAlign('middle')};
        onerow.append(entry);


        tmpValue=parameterSet.ParameterOverrides(k).Value;
        if(ischar(tmpValue))
            text=Text(tmpValue);
        else
            [~,valueClass,dataType]=stm.internal.util.getDisplayValue(tmpValue);
            if(isa(tmpValue,'Simulink.Parameter'))
                if(isscalar(tmpValue)&&isnumeric(tmpValue.Value))
                    [~,valueStr]=stm.internal.util.getDisplayValue(tmpValue.Value);
                    tmpStr=[valueStr,' (',dataType,')'];
                    text=Text(tmpStr);
                else
                    text=Text(valueClass);
                end
            else
                text=Text(valueClass);
            end
        end
        if(parameterSet.ParameterOverrides(k).IsDerived)
            sltest.testmanager.ReportUtility.setTextStyle(text,obj.BodyFontName,obj.BodyFontSize,'Indigo',false,true);
        else
            sltest.testmanager.ReportUtility.setTextStyle(text,obj.BodyFontName,obj.BodyFontSize,obj.BodyFontColor,false,false);
        end
        entry=TableEntry(text);
        entry.Style={OuterMargin('4px','0px','0px','0px'),VAlign('middle')};
        onerow.append(entry);


        text=Text(parameterSet.ParameterOverrides(k).Source);
        sltest.testmanager.ReportUtility.setTextStyle(text,obj.BodyFontName,obj.BodyFontSize,obj.BodyFontColor,false,false);
        entry=TableEntry(text);
        entry.Style={OuterMargin('4px','4px','0px','0px'),VAlign('middle')};
        onerow.append(entry);


        text=Text(parameterSet.ParameterOverrides(k).ModelElements);
        sltest.testmanager.ReportUtility.setTextStyle(text,obj.BodyFontName,obj.BodyFontSize,obj.BodyFontColor,false,false);
        entry=TableEntry(text);
        entry.Style={OuterMargin('4px','4px','0px','0px'),VAlign('middle')};
        onerow.append(entry);

        overridesTable.append(onerow);
    end
end

function setTableStyle(table)
    import mlreportgen.dom.*;

    border='solid';
    color='Gray';
    width='1pt';
    table.Border=border;
    table.BorderWidth=width;
    table.BorderColor=color;
    table.RowSep=border;
    table.RowSepColor=color;
    table.RowSepWidth=width;
    table.ColSep=border;
    table.ColSepColor=color;
    table.ColSepWidth=width;
end
