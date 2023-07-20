function[resultsTable,errorInfo]=evaluateExpressions(expressions,tableData,units)





















































    narginchk(2,3);

    expressions=convertStringsToChars(expressions);
    if ischar(expressions)
        expressions={expressions};
    end


    assert(iscellstr(expressions));%#ok<ISCLSTR>
    assert(istable(tableData));
    unitConversion=nargin==3;
    if unitConversion
        units=convertStringsToChars(units);
        if ischar(units)
            units={units};
        end
        assert(iscellstr(units));%#ok<ISCLSTR>
        assert(numel(expressions)==numel(units));
    end

    dataNames=tableData.Properties.VariableNames';


    numExpressions=numel(expressions);
    allRhsTokens=cell(1,numExpressions);
    lhsStrings=cell(numExpressions,1);
    rhsStrings=cell(1,numExpressions);
    for i=1:numExpressions
        [~,allRhsTokens{i},lhsStrings{i},rhsStrings{i}]=...
        SimBiology.internal.parseExpression(expressions{i},[dataNames;lhsStrings(1:i-1)]);

        if isempty(lhsStrings{i})||isempty(rhsStrings{i})
            error(message('SimBiology:evaluateExpressions:InvalidExpression'));
        end
    end
    allRhsTokens=unique(vertcat(allRhsTokens{:}));

    if any(ismember(lhsStrings,dataNames))

        error(message('SimBiology:evaluateExpressions:AmbiguousLhsTableToken'));
    end



    for i=1:numExpressions-1
        [~,tokens]=SimBiology.internal.parseExpression(expressions{i},[allRhsTokens;lhsStrings]);
        if any(ismember(tokens,lhsStrings(i+1:end)))
            error(message('SimBiology:evaluateExpressions:InvalidExpressionOrder',expressions{i}));
        end
    end


    validRhsTokens=[dataNames;lhsStrings];

    tableHeight=height(tableData);
    tableWidth=width(tableData);



    VARNAME='SIMBIOLOGY_DATA_VARIABLE';


    errorInfoTemplate=struct('Expression',[],'Message','');
    errorInfo=errorInfoTemplate([]);


    if unitConversion

        tableUnits=tableData.Properties.VariableUnits;
        if isempty(tableUnits)
            tableUnits=repmat({''},1,tableWidth);
        end
        rhsUnits=[tableUnits,units];

        tfEmptyUnits=cellfun(@isempty,rhsUnits);
        if any(tfEmptyUnits)
            error(message('SimBiology:evaluateExpressions:MissingUnits',strjoin(validRhsTokens(tfEmptyUnits),', ')));
        end

        isSpecies=false(size(validRhsTokens));
        defaultSpeciesDim=false;




        [tfInvalidUnits,tfValidDA]=SimBiology.internal.observableDimensionalAnalysis(lhsStrings,rhsStrings,validRhsTokens,rhsUnits,isSpecies,unitConversion,defaultSpeciesDim);

        if any(tfInvalidUnits)
            error(message('SimBiology:evaluateExpressions:InvalidUnits',strjoin(validRhsTokens(tfInvalidUnits),', ')));
        end
        if any(~tfValidDA)
            msg=getString(message('SimBiology:evaluateExpressions:DimensionalAnalysisError'));
            for j=reshape(find(~tfValidDA),1,[])
                errorInfo(end+1)=errorInfoTemplate;%#ok<AGROW>
                errorInfo(end).Expression=j;
                errorInfo(end).Message=msg;
            end
        end


        ucm=SimBiology.internal.createUnitConversionFactors(rhsUnits);
    end


    values=cell(1,tableWidth+numel(expressions));


    for j=1:tableWidth
        if unitConversion
            values{j}=tableData{:,j}.*ucm(j);
        else
            values{j}=tableData{:,j};
        end
    end


    values(tableWidth+1:end)=repmat({nan(tableHeight,1)},1,numel(expressions));


    newRhsTokens=cell(size(validRhsTokens));
    for j=1:numel(validRhsTokens)
        newRhsTokens{j}=sprintf('%s{%d}',VARNAME,j);
    end

    for j=1:numExpressions

        if unitConversion&&~tfValidDA(j)
            continue
        end


        newExpression=SimBiology.internal.Utils.Parser.traverseSubstitute(...
        rhsStrings{j},validRhsTokens,newRhsTokens);



        validValue=false;
        if~isempty(regexp(newExpression,'\[.*\]','once'))
            errorInfo(end+1)=errorInfoTemplate;%#ok<AGROW>
            errorInfo(end).Expression=j;
            errorInfo(end).Message=getString(message('SimBiology:evaluateExpressions:InvalidToken'));
        else
            fcn=str2funcHelper(['@(',VARNAME,') ',newExpression]);
            try
                value=feval(fcn,values);
                validValue=true;
                if isrow(value)
                    value=value.';
                end
                if islogical(value)
                    value=double(value);
                end
            catch me
                validValue=false;
                errorInfo(end+1)=errorInfoTemplate;%#ok<AGROW>
                errorInfo(end).Expression=j;
                errorInfo(end).Message=me.message;
            end
        end



        if validValue
            if numel(value)~=tableHeight
                validValue=false;
                errorInfo(end+1)=errorInfoTemplate;%#ok<AGROW>
                errorInfo(end).Expression=j;
                errorInfo(end).Message=getString(message('SimBiology:evaluateExpressions:InvalidSize'));
            end
            if~isvector(value)
                validValue=false;
                errorInfo(end+1)=errorInfoTemplate;%#ok<AGROW>
                errorInfo(end).Expression=j;
                errorInfo(end).Message=getString(message('SimBiology:evaluateExpressions:InvalidDimension'));
            end
            if~isnumeric(value)
                validValue=false;
                errorInfo(end+1)=errorInfoTemplate;%#ok<AGROW>
                errorInfo(end).Expression=j;
                errorInfo(end).Message=getString(message('SimBiology:evaluateExpressions:InvalidType'));
            end
        end

        if validValue
            values{end-numExpressions+j}=value;
        end

    end


    maxVarNameLength=45-ceil(log10(numExpressions));

    for i=1:numExpressions
        if length(lhsStrings{i})>maxVarNameLength
            lhsStrings{i}=[lhsStrings{i}(1:maxVarNameLength),'...'];
        end
    end

    varNames=lhsStrings;
    for i=1:numExpressions
        if sum(strcmp(lhsStrings{i},lhsStrings))>1
            varNames{i}=[varNames{i},sprintf(' (Expression %d)',i)];
        end
    end


    out=values(tableWidth+1:end);
    if unitConversion
        for i=1:numExpressions
            out{i}=out{i}./ucm(tableWidth+i);
        end
    end

    resultsTable=table(out{:},'VariableNames',varNames);
    resultsTable.Properties.DimensionNames={'evaluation','expression'};
    resultsTable.Properties.UserData=rhsStrings;
end




function fcn=str2funcHelper(code)
    fcn=str2func(code);
end
