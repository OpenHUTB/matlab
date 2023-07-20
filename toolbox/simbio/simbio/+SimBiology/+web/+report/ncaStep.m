function out=ncaStep(action,varargin)











    out=[];

    switch(action)
    case 'generateHTML'
        out=generateHTML(varargin{:});
    case 'generateResultsHTML'
        out=generateResultsHTML(varargin{:});
    end


    function out=generateHTML(html,step,steps,input)


        simulationStep=getStepByType(steps,'Simulation');
        heading='NCA Step';
        if~isempty(simulationStep)
            heading='Post Processing: NCA Step';
        end


        if~isempty(step)&&input.includeProgramStepDescription
            html=buildBlackSectionHeader(html,heading,step.description);
        else
            html=buildBlackSectionHeader(html,heading,'');
        end

        dataType=step.dataType;
        switch(dataType)
        case 'externalTableData'
            html=generateNCAExternalDataHTML(html,step);
        case 'programData'

            html=generateNCAProgramDataHTML(html,step);
        case 'savedProgramData'


            html=generateNCASavedProgramDataHTML(html,step);
        case 'savedProgramDataNoSetup'


            html=generateNCASavedProgramDataHTML(html,step);
        case 'externalSimData'


            html=generateNCASavedProgramDataHTML(html,step);
        end


        out.html=html;


        function html=generateNCAExternalDataHTML(html,step)


            rowNumber={};
            classification={};
            columnName={};
            count=1;
            idDataColumn='';


            for i=1:length(step.definition)
                switch(step.definition(i).classification)
                case 'Group'
                    column=step.definition(i).column;
                case 'ID'
                    column=step.definition(i).column;
                    idDataColumn=deblank(column);
                case 'Time'
                    column=step.definition(i).column;
                case 'Concentration'
                    column=step.definition(i).column;
                case 'IV Bolus Dose'
                    column=step.definition(i).column;
                case 'Extravascular Dose'
                    column=step.definition(i).column;
                end

                if strcmp(column,' ')
                    column='';
                end

                if~isempty(column)
                    rowNumber{end+1}=count;%#ok<*AGROW>
                    classification{end+1}=step.definition(i).classification;
                    columnName{end+1}=column;
                    count=count+1;
                end
            end

            data=[rowNumber;classification;columnName]';
            headers={' ','Classification','Column Name'};
            styles={'style="width:30px"','style="width:100px"','style="width:auto"'};
            ncaTable=buildTable(headers,data,styles,'Data Classification');
            html=appendLine(html,ncaTable);


            loq=step.loq;

            lambdaTimeRange=step.lambdaTimeRange;
            if isempty(lambdaTimeRange)
                lambdaTimeRange='[NaN NaN]';
            end

            cmaxTimeRange=step.cmaxTimeRange;
            if isempty(cmaxTimeRange)
                cmaxTimeRange='[]';
            end

            partialAUC=step.partialAUC;
            if isempty(partialAUC)
                partialAUC='[]';
            end

            sparseSampling='';
            if~isempty(idDataColumn)&&isfield(step,'sparseSampling')
                sparseSampling=step.sparseSampling;
                if isempty(sparseSampling)
                    sparseSampling='false';
                end
            end

            props={'Lower Limit of Quantization','Lambda Time Range','CMax Time Range','Partial AUC'};
            values={loq,lambdaTimeRange,cmaxTimeRange,partialAUC};

            if~isempty(sparseSampling)
                props=['Sparse Sampling',props];
                values=[sparseSampling,values];
            end

            html=buildSectionHeader(html,'Options','');
            tableHTML=buildPropertyValueTable(props,values);
            html=appendLine(html,tableHTML);


            function html=generateNCAProgramDataHTML(html,step)

                responseTable=generateResponseTableHTML(step);
                html=appendLine(html,responseTable);


                function html=generateNCASavedProgramDataHTML(html,step)

                    doseTable=generateDoseTableHTML(step);
                    if~isempty(doseTable)
                        html=appendLine(html,doseTable);
                    end

                    responseTable=generateResponseTableHTML(step);
                    html=appendLine(html,responseTable);


                    function html=generateResponseTableHTML(step)


                        responses=step.responses;
                        responseNames={};
                        rowNumber={};
                        count=1;

                        for i=1:length(responses)
                            if responses(i).use
                                rowNumber{i}=count;
                                responseNames{end+1}=responses(i).name;
                                count=count+1;
                            end
                        end

                        data=[rowNumber;responseNames]';
                        headers={' ','Name'};
                        styles={'style="width:30px"','style="width:auto"'};
                        html=buildTable(headers,data,styles,'Responses');


                        function html=generateDoseTableHTML(step)


                            dose=step.dose;
                            time=zeros(1,numel(dose));
                            amount=zeros(1,numel(dose));
                            rate=zeros(1,numel(dose));

                            for i=1:numel(dose)
                                nextTime=dose(i).time;
                                nextAmount=dose(i).amount;
                                nextRate=dose(i).rate;

                                if ischar(nextTime)
                                    nextTime=str2double(nextTime);
                                end

                                if ischar(nextAmount)
                                    nextAmount=str2double(nextAmount);
                                end

                                if ischar(nextRate)
                                    nextRate=str2double(nextRate);
                                end

                                time(i)=nextTime;
                                amount(i)=nextAmount;
                                rate(i)=nextRate;
                            end

                            if isempty(time)
                                html='';
                                return;
                            end

                            headers={'Time','Amount'};
                            styles={'style="width:100px"','style="width:auto"'};

                            if~isempty(step.timeUnits)
                                headers{1}=['Time (',step.timeUnits,')'];
                            end

                            if~isempty(step.amountUnits)
                                headers{2}=['Amount (',step.amountUnits,')'];
                            end

                            numRows=numel(amount);
                            times=cell(1,numRows);
                            amounts=cell(1,numRows);
                            rates=cell(1,numRows);

                            for i=1:numRows
                                amounts{i}=amount(i);
                                times{i}=time(i);
                                rates{i}=rate(i);
                            end


                            data=[times;amounts]';
                            if areValuesDefined(rates)&&sum([rates{:}])>0
                                data=[data,rates'];
                                headers=[headers,'Rate'];
                                styles=[styles,'style="width:auto"'];
                                styles{2}='style="width:100px"';

                                if~isempty(step.rateUnits)
                                    headers{3}=['Rate (',step.rateUnits,')'];
                                end
                            end

                            html=buildTable(headers,data,styles,'Dose');


                            function out=generateResultsHTML(html,data,steps)

                                out=[];


                                if isfield(data,'ncaresults')
                                    data=data.ncaresults;
                                elseif isfield(data,'results')
                                    data=data.results;
                                end

                                if isa(data,'table')

                                    simulationStep=getStepByType(steps,'Simulation');
                                    heading='NCA Step';
                                    if~isempty(simulationStep)
                                        heading='Post Processing: NCA Step';
                                    end

                                    html=buildBlackSectionHeader(html,heading,'');

                                    if size(data,1)==1
                                        headingHTML=buildSectionHeader(out,'NCA Results','');
                                        tableHTML=generateScalarTableResults(data);
                                        tableHTML=appendLine(headingHTML,tableHTML);
                                    else
                                        tableHTML=generateVectorTableResults(data);
                                    end

                                    html=appendLine(html,tableHTML);
                                    out.html=html;
                                end


                                function html=generateScalarTableResults(data)

                                    props=data.Properties.VariableNames;
                                    values=cell(1,numel(props));

                                    for i=1:numel(props)
                                        values{i}=data.(props{i});
                                    end

                                    html=buildPropertyValueTable(props,values);


                                    function html=generateVectorTableResults(results)

                                        props=results.Properties.VariableNames;
                                        firstTableCount=ceil(numel(props)/2);


                                        data=results(:,1:firstTableCount);
                                        headers=props(1:firstTableCount);
                                        tableData=[];
                                        styles=cell(1,numel(headers));
                                        styleValue=100/numel(headers);

                                        for i=1:numel(headers)
                                            next=data.(headers{i});
                                            if iscategorical(next)
                                                next=cat2cell(next);
                                            elseif isnumeric(next)
                                                next=numeric2cell(next);
                                            end

                                            tableData=[tableData,next];
                                            styles{i}=['style="width:',num2str(styleValue),'%"'];
                                        end

                                        html1=buildTable(headers,tableData,styles,'NCA Results (Table 1)');


                                        data=results(:,[1,firstTableCount+1:end]);
                                        headers=props([1,firstTableCount+1:end]);
                                        tableData=[];
                                        styles=cell(1,numel(headers));
                                        styleValue=100/numel(headers);

                                        for i=1:numel(headers)
                                            next=data.(headers{i});
                                            if iscategorical(next)
                                                next=cat2cell(next);
                                            elseif isnumeric(next)
                                                next=numeric2cell(next);
                                            end

                                            tableData=[tableData,next];
                                            styles{i}=['style="width:',num2str(styleValue),'%"'];
                                        end

                                        html2=buildTable(headers,tableData,styles,'NCA Results (Table 2)');


                                        html=html1;
                                        html=appendLine(html,html2);


                                        function out=cat2cell(data)

                                            out=cell(numel(data),1);
                                            for i=1:length(data)
                                                out{i}=char(data(i));
                                            end


                                            function out=numeric2cell(data)

                                                out=SimBiology.web.report.utilhandler('numeric2cell',data);


                                                function out=areValuesDefined(list)

                                                    out=SimBiology.web.report.utilhandler('areValuesDefined',list);


                                                    function code=appendLine(code,newLine)

                                                        code=SimBiology.web.report.utilhandler('appendLine',code,newLine);


                                                        function code=buildBlackSectionHeader(out,header,description)

                                                            code=SimBiology.web.report.utilhandler('buildBlackSectionHeader',out,header,description);


                                                            function code=buildPropertyValueTable(props,values)

                                                                code=SimBiology.web.report.utilhandler('buildPropertyValueTable',props,values);


                                                                function code=buildSectionHeader(out,header,description)

                                                                    code=SimBiology.web.report.utilhandler('buildSectionHeader',out,header,description);


                                                                    function code=buildTable(headers,contentInfo,styles,caption)

                                                                        code=SimBiology.web.report.utilhandler('buildTable',headers,contentInfo,styles,caption);


                                                                        function step=getStepByType(steps,type)

                                                                            step=SimBiology.web.codegenerationutil('getStepByType',steps,type);
