function aTable=genConfigCheckReportTable(currentModelName,varargin)







    import mlreportgen.dom.*
    aTable=Table(2);
    if length(varargin)>=2&&~isempty(varargin{1})&&~isempty(varargin{2})

        fullModelName=varargin{1};
        subsystemName=varargin{2};
    else
        fullModelName=currentModelName;
        subsystemName=currentModelName;
    end

    checkResult=coder.internal.configCheckReportHelper('readModelAdvisorCheckReport',fullModelName,subsystemName);
    if length(checkResult.op)==1
        objectiveText='Code generation objective: ';
        validateText='Validation result: ';
    else
        objectiveText='Code generation objectives: ';
        validateText='Validation result: ';
    end
    row=TableRow();
    entry=TableEntry(objectiveText);
    row.append(entry);

    if isempty(checkResult.op)
        [resultText,resultColor]=coder.internal.configCheckReportHelper('xlateCheckResult','Unspecified');
        objectives=Text(resultText);
        objectives.Style={Color(resultColor)};
        entry=TableEntry(objectives);
    elseif(length(checkResult.op)==1)
        objectives=checkResult.op{1};
        entry=TableEntry(objectives);
    else
        objectives={};
        for i=1:length(checkResult.op)
            objectives=[objectives,checkResult.op{i}];%#ok<AGROW>
        end
        aList=OrderedList;
        for i=1:numel(objectives)
            aList.append(ListItem(Text(objectives{i})));
        end
        entry=TableEntry(aList);
    end
    row.append(entry);
    aTable.append(row);
    row=TableRow();
    entry=TableEntry(validateText);
    row.append(entry);
    entry=TableEntry(checkResult.result);
    row.append(entry);
    aTable.append(row);
    aTable.StyleName='TableStyleAltRowNormal';
end
