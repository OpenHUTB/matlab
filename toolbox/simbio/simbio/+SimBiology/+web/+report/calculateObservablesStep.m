function out=calculateObservablesStep(action,varargin)











    out=[];

    switch(action)
    case 'generateHTML'
        out=generateHTML(varargin{:});
    case 'generateResultsHTML'
        out=generateResultsHTML(varargin{:});
    end

end

function out=generateHTML(html,step,input)


    tableData=step.statistics;
    if iscell(tableData)
        tableData=[tableData{:}];
    end

    if~isempty(tableData)
        tableData=tableData([tableData.use]);
        tableData=tableData(cellfun('isempty',{tableData.matlabError}));

        if~isempty(tableData)
            heading='Calculate Observables Step';
            if step.internal.isSetup
                heading='Post Processing: Calculate Observables Step';
            end

            if input.includeProgramStepDescription
                html=buildBlackSectionHeader(html,heading,step.description);
            else
                html=buildBlackSectionHeader(html,heading,'');
            end

            rowNumber=cell(1,numel(tableData));
            values=cell(1,numel(tableData));
            units=cell(1,numel(tableData));

            for i=1:length(tableData)
                rowNumber{i}=i;
                name=tableData(i).name;
                expression=tableData(i).expression;
                values{i}=[name,' = ',expression];
                units{i}=tableData(i).units;
            end

            data=[rowNumber;values]';
            headers={' ','Expression'};
            styles={'style="width:30px"','style="width:auto"'};

            if areValuesDefined(units)
                data=[data,units'];
                headers=[headers,'Units'];
                styles=[styles,'style="width:100px"'];
            end

            obsTable=buildTable(headers,data,styles,'Observables to Calculate');
            html=appendLine(html,obsTable);
        end
    end


    out.html=html;

end

function out=generateResultsHTML(html,data,step,steps)

    fitStep=getStepByType(steps,'Fit');
    results=[];

    if~isempty(fitStep)&&isfield(data,'simdataI')
        results=data.simdataI;
    elseif isfield(data,'results')
        results=data.results;
    end

    if~isempty(results)&&isa(results,'SimData')
        scalarObservables=SimBiology.web.datahandler('getSimdataScalarObservables',results);
        if~isempty(scalarObservables)

            heading='Calculate Observables Step';
            if step.internal.isSetup
                heading='Post Processing: Calculate Observables Step';
            end

            html=buildBlackSectionHeader(html,heading,'');


            tableData=step.statistics;
            if iscell(tableData)
                tableData=[tableData{:}];
            end
            tableData=tableData([tableData.use]);
            tableData=tableData(cellfun('isempty',{tableData.matlabError}));
            mapNameToExpression=containers.Map('KeyType','char','ValueType','char');

            for i=1:length(tableData)
                name=tableData(i).name;
                expression=tableData(i).expression;
                mapNameToExpression(name)=expression;
            end


            names=scalarObservables.Properties.VariableNames;
            varUnits=scalarObservables.Properties.VariableUnits;

            startIndex=1;
            numColumns=numel(names);
            if strcmp(names{1},'SimDataRun')
                startIndex=2;
                numColumns=numColumns-1;
            end

            data=[];
            headers={};
            styles={};

            groupColumnNames=cell(1,numColumns+1);
            groupColumnSpans=ones(1,numColumns+1);
            groupColumnNames{1}=' ';
            count=2;

            if size(scalarObservables,1)==1
                rowNumber=cell(1,numel(names));
                expr=cell(1,numel(names));
                value=cell(1,numel(names));
                units=cell(1,numel(names));

                for i=1:length(names)
                    rowNumber{i}=i;
                    name=names{i};
                    expression=mapNameToExpression(name);
                    expr{i}=[name,' = ',expression];
                    value{i}=scalarObservables.(name);

                    if length(varUnits)>=i
                        units{i}=varUnits(i);
                    else
                        units{i}='';
                    end
                end

                data=[rowNumber;expr;value]';
                headers={' ','Expression','Value'};
                styles={'style="width:30px"','style="width:auto"','style="width:auto"'};

                if areValuesDefined(units)
                    data=[data,units'];
                    headers=[headers,'Units'];
                    styles=[styles,'style="width:100px"'];
                end

                obsTable=buildTable(headers,data,styles,'Scalar Observables Calculated');
            else
                for i=startIndex:length(names)
                    nextData=numeric2cell(scalarObservables.(names{i}));
                    nextHeading=names{i};
                    nextExpression=mapNameToExpression(names{i});
                    if~isempty(varUnits)&&~isempty(varUnits{i})
                        nextHeading=[nextHeading,' (',varUnits{i},')'];
                    end

                    groupColumnNames{count}=nextHeading;
                    data=[data,nextData];%#ok<*AGROW> 
                    headers=[headers,nextExpression];
                    styles=[styles,'style="width:auto"'];
                    count=count+1;
                end


                numRows=numel(scalarObservables.(names{1}));
                rowNumber=numeric2cell(1:numRows);
                data=[rowNumber,data];
                headers=['Run',headers];
                styles=['style="width:30px"',styles];

                groupHeader.columnNames=groupColumnNames;
                groupHeader.spans=groupColumnSpans;


                obsTable=buildTableWithGroupHeader(groupHeader,headers,data,styles,'Scalar Observables Calculated');
            end

            html=appendLine(html,obsTable);
        end
    end


    out.html=html;

end

function out=numeric2cell(data)

    out=SimBiology.web.report.utilhandler('numeric2cell',data);

end

function code=appendLine(code,newLine)

    code=SimBiology.web.report.utilhandler('appendLine',code,newLine);

end

function out=areValuesDefined(list)

    out=SimBiology.web.report.utilhandler('areValuesDefined',list);

end

function html=buildTable(headers,contentInfo,styles,caption)

    html=SimBiology.web.report.utilhandler('buildTable',headers,contentInfo,styles,caption);

end

function html=buildTableWithGroupHeader(groupHeader,headers,data,styles,caption)

    html=SimBiology.web.report.utilhandler('buildTableWithGroupHeader',groupHeader,headers,data,styles,caption);

end

function code=buildBlackSectionHeader(out,header,description)

    code=SimBiology.web.report.utilhandler('buildBlackSectionHeader',out,header,description);

end

function step=getStepByType(steps,type)

    step=SimBiology.web.codegenerationutil('getStepByType',steps,type);
end
