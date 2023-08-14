function groupObj=genIterationSettingTable(reportObj,result)












    p=inputParser;
    addRequired(p,'reportObj',...
    @(x)validateattributes(x,{'sltest.testmanager.TestResultReport',...
    'sltest.internal.TestResultReport'},{}));
    addRequired(p,'result',...
    @(x)validateattributes(x,{'sltest.testmanager.ReportUtility.ReportResultData'},{}));
    p.parse(reportObj,result);

    import mlreportgen.dom.*;
    groupObj=Group();
    resultObj=result.Data;

    showSimIndex=false;
    testCaseType=sltest.testmanager.ReportUtility.getTestTypeOfResult(resultObj);
    if(testCaseType==sltest.testmanager.TestCaseTypes.Equivalence)
        showSimIndex=true;
    end

    hasIterationSettings=(~isempty(resultObj.IterationSettings.modelParameters)||...
    ~isempty(resultObj.IterationSettings.testParameters)||...
    ~isempty(resultObj.IterationSettings.variableParameters));

    if(hasIterationSettings)
        str=getString(message('stm:general:IterationSettings'));
        text=Text(str);
        sltest.testmanager.ReportUtility.setTextStyle(text,reportObj.BodyFontName,reportObj.BodyFontSize,reportObj.BodyFontColor,true,false);
        para=sltest.testmanager.ReportUtility.genParaDefaultStyle(text);
        para.Style=[para.Style,{OuterMargin(reportObj.ChapterIndentL2,'0mm','0mm',reportObj.SectionSpacing)}];
        groupObj.append(para);
    end

    if(~isempty(resultObj.IterationSettings.modelParameters))
        str=getString(message('stm:objects:ModelOverrides'));
        text=Text(str);
        sltest.testmanager.ReportUtility.setTextStyle(text,reportObj.BodyFontName,reportObj.BodyFontSize,reportObj.BodyFontColor,true,false);
        para=sltest.testmanager.ReportUtility.genParaDefaultStyle(text);
        para.Style=[para.Style,{OuterMargin(reportObj.ChapterIndentL3,'0mm','0mm','0mm')}];
        groupObj.append(para);

        nParams=length(resultObj.IterationSettings.modelParameters);
        modelParameters=cell(nParams,1);
        for paramIdx=1:nParams
            if(showSimIndex)
                tmp={...
                resultObj.IterationSettings.modelParameters(paramIdx).systemHandle,...
                resultObj.IterationSettings.modelParameters(paramIdx).parameterName,...
                resultObj.IterationSettings.modelParameters(paramIdx).displayValue,...
                resultObj.IterationSettings.modelParameters(paramIdx).simulationIndex};
            else
                tmp={...
                resultObj.IterationSettings.modelParameters(paramIdx).systemHandle,...
                resultObj.IterationSettings.modelParameters(paramIdx).parameterName,...
                resultObj.IterationSettings.modelParameters(paramIdx).displayValue};
            end
            modelParameters{paramIdx}=tmp;
        end

        colSpecGroup=[{'4cm'},{'4cm'},{'8cm'}];
        headFields={...
        getString(message('stm:objects:System')),...
        getString(message('stm:objects:ParameterName')),...
        getString(message('stm:ResultsTree:Value'))};

        if(showSimIndex)
            colSpecGroup=[{'4cm'},{'4cm'},{'4cm'},{'4cm'}];
            headFields=[headFields,{getString(message('stm:objects:SimulationIndex'))}];
        end
        table=sltest.testmanager.ReportUtility.genTable(reportObj,modelParameters,headFields,colSpecGroup);
        setTableStyle(table);
        table.Style=[table.Style,{OuterMargin(reportObj.ChapterIndentL3,'0mm','0mm',reportObj.SectionSpacing)}];
        groupObj.append(table);

        append(groupObj,sltest.testmanager.ReportUtility.vspace(reportObj.SectionSpacing));
    end

    if(~isempty(resultObj.IterationSettings.testParameters))
        str=getString(message('stm:objects:TestOverrides'));
        text=Text(str);
        sltest.testmanager.ReportUtility.setTextStyle(text,reportObj.BodyFontName,reportObj.BodyFontSize,reportObj.BodyFontColor,true,false);
        para=sltest.testmanager.ReportUtility.genParaDefaultStyle(text);
        para.Style=[para.Style,{OuterMargin(reportObj.ChapterIndentL3,'0mm','0mm','0mm')}];
        groupObj.append(para);

        nParams=length(resultObj.IterationSettings.testParameters);
        testParameters=cell(nParams,1);
        for paramIdx=1:nParams

            valueStr=resultObj.IterationSettings.testParameters(paramIdx).parameterSource;
            if(isempty(valueStr))
                valueStr=resultObj.IterationSettings.testParameters(paramIdx).displayValue;
            end
            if(showSimIndex)
                tmp={...
                resultObj.IterationSettings.testParameters(paramIdx).parameterName,...
                valueStr,...
                resultObj.IterationSettings.testParameters(paramIdx).simulationIndex};
            else
                tmp={...
                resultObj.IterationSettings.testParameters(paramIdx).parameterName,...
                valueStr};
            end
            testParameters{paramIdx}=tmp;
        end

        colSpecGroup=[{'4cm'},{'8cm'}];
        headFields={
        getString(message('stm:objects:ParameterName')),...
        getString(message('stm:ResultsTree:Value'))};
        if(showSimIndex)
            colSpecGroup=[{'4cm'},{'4cm'},{'8cm'}];
            headFields=[headFields,{getString(message('stm:objects:SimulationIndex'))}];
        end
        table=sltest.testmanager.ReportUtility.genTable(reportObj,testParameters,headFields,colSpecGroup);
        setTableStyle(table);
        table.Style=[table.Style,{OuterMargin(reportObj.ChapterIndentL3,'0mm','0mm',reportObj.SectionSpacing)}];
        groupObj.append(table);
        append(groupObj,sltest.testmanager.ReportUtility.vspace(reportObj.SectionSpacing));
    end

    if(~isempty(resultObj.IterationSettings.variableParameters))
        str=getString(message('stm:objects:WorkspaceVariableOverrides'));
        text=Text(str);
        sltest.testmanager.ReportUtility.setTextStyle(text,reportObj.BodyFontName,reportObj.BodyFontSize,reportObj.BodyFontColor,true,false);
        para=sltest.testmanager.ReportUtility.genParaDefaultStyle(text);
        para.Style=[para.Style,{OuterMargin(reportObj.ChapterIndentL3,'0mm','0mm','0mm')}];
        groupObj.append(para);

        nParams=length(resultObj.IterationSettings.variableParameters);
        variableParameters=cell(nParams,1);
        for paramIdx=1:nParams
            if(showSimIndex)
                tmp={...
                resultObj.IterationSettings.variableParameters(paramIdx).parameterName,...
                resultObj.IterationSettings.variableParameters(paramIdx).source,...
                resultObj.IterationSettings.variableParameters(paramIdx).displayValue,...
                resultObj.IterationSettings.variableParameters(paramIdx).simulationIndex};
            else
                tmp={...
                resultObj.IterationSettings.variableParameters(paramIdx).parameterName,...
                resultObj.IterationSettings.variableParameters(paramIdx).source,...
                resultObj.IterationSettings.variableParameters(paramIdx).displayValue};
            end
            variableParameters{paramIdx}=tmp;
        end

        colSpecGroup=[{'4cm'},{'4cm'},{'8cm'}];
        headFields={
        getString(message('stm:objects:ParameterName')),...
        getString(message('stm:Parameters:Source')),...
        getString(message('stm:ResultsTree:Value'))};
        if(showSimIndex)
            colSpecGroup=[{'4cm'},{'4cm'},{'4cm'},{'4cm'}];
            headFields=[headFields,{getString(message('stm:objects:SimulationIndex'))}];
        end
        table=sltest.testmanager.ReportUtility.genTable(reportObj,variableParameters,headFields,colSpecGroup);
        setTableStyle(table);
        table.Style=[table.Style,{OuterMargin(reportObj.ChapterIndentL3,'0mm','0mm',reportObj.SectionSpacing)}];
        groupObj.append(table);
        append(groupObj,sltest.testmanager.ReportUtility.vspace(reportObj.SectionSpacing));
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