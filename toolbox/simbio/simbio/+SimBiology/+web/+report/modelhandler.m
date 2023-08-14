function out=modelhandler(action,varargin)











    out=[];

    switch(action)
    case 'buildModelHTML'
        out=buildModelHTML(varargin{:});
    case 'buildModelEquationsHTML'
        out=buildModelEquationsHTML(varargin{:});
    case 'buildAssignmentTable'
        out=buildAssignmentTable(varargin{:});
    case 'buildEquationsTable'
        out=buildEquationsTable(varargin{:});
    case 'buildEventsTable'
        out=buildEventsTable(varargin{:});
    case 'buildObservableTable'
        out=buildObservableTable(varargin{:});
    case 'buildQuantityTable'
        out=buildQuantityTable(varargin{:});
    case 'buildQuantityMultipleTables'
        out=buildQuantityMultipleTables(varargin{:});
    case 'buildReactionTable'
        out=buildReactionTable(varargin{:});
    case 'buildRepeatDoseTable'
        out=buildRepeatDoseTable(varargin{:});
    case 'buildRuleTable'
        out=buildRuleTable(varargin{:});
    case 'buildVariantTables'
        out=buildVariantTables(varargin{:});
    case 'buildSingleVariantTable'
        out=buildSingleVariantTable(varargin{:});
    case 'buildScheduleDoseTables'
        out=buildScheduleDoseTables(varargin{:});
    case 'createDiagramExporter'
        out=createDiagramExporter(varargin{:});
    case 'exportDiagram'
        exportDiagram(varargin{:});
    case 'exportDiagramOnly'
        exportDiagramOnly(varargin{:});
    case 'generateDiagramHTML'
        out=generateDiagramHTML(varargin{:});
    end

end

function exporter=createDiagramExporter(model)

    syntax=model.getDiagramSyntax;
    appIndex='/toolbox/simbio/web/modelingapp/index.html';
    exporter=diagram.editor.print.Exporter(syntax,'AppIndex',appIndex,'IndexParams','export=1');

end

function exportDiagram(exporter,filename,inputs)



    if exist(filename,'file')
        deleteFile(filename);
    end

    exportDiagramInternal(exporter,filename,diagram.editor.print.ExportFormat.JPG,inputs);

end

function exportDiagramOnly(exporter,filename,inputs)



    if exist(filename,'file')
        copyfile(filename,[filename,'.bak'],'f');
        deleteFile(filename);
    end

    switch(inputs.diagramFileFormat)
    case 'jpg'
        exportFormat=diagram.editor.print.ExportFormat.JPG;
    case 'pdf'
        exportFormat=diagram.editor.print.ExportFormat.PDF;
    case 'png'
        exportFormat=diagram.editor.print.ExportFormat.PNG;
    case 'tiff'
        exportFormat=diagram.editor.print.ExportFormat.TIFF;
    case 'bmp'
        exportFormat=diagram.editor.print.ExportFormat.BMP;
    case 'hdf'
        exportFormat=diagram.editor.print.ExportFormat.HDF;
    case 'ras'
        exportFormat=diagram.editor.print.ExportFormat.RAS;
    otherwise
        exportFormat=diagram.editor.print.ExportFormat.JPG;
    end

    exportDiagramInternal(exporter,filename,exportFormat,inputs);

    count=1;
    while~exist(filename,'file')&&count<50
        pause(0.4);
        count=count+1;
    end

end

function exportDiagramInternal(exporter,filename,exportFormat,inputs)

    if inputs.autoDiagramSize
        exporter.export(filename,'Format',exportFormat);
    else
        dpi=get(0,'ScreenPixelsPerInch');
        width=str2double(inputs.diagramWidth)*dpi;
        height=str2double(inputs.diagramHeight)*dpi;
        exporter.export(filename,'Format',exportFormat,'Size',[width,height]);
    end

end

function html=generateDiagramHTML(filename)

    count=1;
    while~exist(filename,'file')&&count<50
        pause(0.4);
        count=count+1;
    end

    if exist(filename,'file')
        html=createHeaderLine('h1','Model Diagram',0);
        html=appendLineWithPad(html,'<div class="horizontal_border"></div>',1);
        imgInfo=SimBiology.web.diagram.utilhandler('getImageData',filename);
        img=['<img src="',imgInfo.imageData,'" alt="Diagram" style="padding-bottom:10px;">'];
        html=appendLineWithPad(html,'<div style="text-align:center;padding-bottom:30px">',2);
        html=appendLineWithPad(html,img,3);
        html=appendLineWithPad(html,'</div>',2);
        deleteFile(filename);
    else
        html='';
    end

end

function out=buildModelHTML(model,inputs)

    html='';
    if inputs.includeModelNotes&&~isempty(model.Notes)
        html=appendLineWithPad(html,'<div style="margin-top:4px;">',1);
        html=appendLineWithPad(html,model.Notes,1);
        html=appendLineWithPad(html,'</div>',1);
    end


    if isfield(inputs,'showModelTables')&&~inputs.showModelTables
        out=struct;
        out.html=html;
        out.initialValuesMsg='';
        return;
    end


    includeNotes=inputs.includeModelComponentNotes;
    if inputs.buildSingleQuantityTable
        out=buildQuantityTable(model,inputs);
    else
        out=buildQuantityMultipleTables(model,inputs);
    end

    html=appendLine(html,out.html);
    initialValues=out.initialValues;
    initialValuesMsg=out.initialValuesMsg;


    ia=sbioselect(model,'RuleType','initialAssignment');
    tableHTML=buildAssignmentTable('Initial Assignments',ia,initialValues,includeNotes);
    if~isempty(tableHTML)
        html=appendLine(html,tableHTML);
    end


    ra=sbioselect(model,'RuleType','repeatedAssignment');
    tableHTML=buildAssignmentTable('Repeated Assignments',ra,initialValues,includeNotes);
    if~isempty(tableHTML)
        html=appendLine(html,tableHTML);
    end


    tableHTML=buildReactionTable(model.Reactions,includeNotes);
    if~isempty(tableHTML)
        html=appendLine(html,tableHTML);
    end


    rateRules=sbioselect(model,'RuleType','rate');
    tableHTML=buildRuleTable('Rate Rules',rateRules,includeNotes);
    if~isempty(tableHTML)
        html=appendLine(html,tableHTML);
    end


    algRules=sbioselect(model,'RuleType','algebraic');
    tableHTML=buildRuleTable('Algebraic Rules',algRules,includeNotes);
    if~isempty(tableHTML)
        html=appendLine(html,tableHTML);
    end


    tableHTML=buildEventsTable(model.Events,includeNotes);
    if~isempty(tableHTML)
        html=appendLine(html,tableHTML);
    end


    tableHTML=buildObservableTable(model.Observables,includeNotes);
    if~isempty(tableHTML)
        html=appendLine(html,tableHTML);
    end


    if inputs.showVariants
        variants=getvariant(model);
        if inputs.buildSingleVariantTable
            tableHTML=buildSingleVariantTable(variants);
        else
            tableHTML=buildVariantTables(variants);
        end

        if~isempty(tableHTML)
            html=appendLine(html,tableHTML);
        end
    end


    if inputs.showDoses
        repeatDose=sbioselect(model,'Type','repeatdose');
        tableHTML=buildRepeatDoseTable(repeatDose);
        if~isempty(tableHTML)
            html=appendLine(html,tableHTML);
        end


        scheduleDose=sbioselect(model,'Type','scheduledose');
        tableHTML=buildScheduleDoseTables(scheduleDose);
        if~isempty(tableHTML)
            html=appendLine(html,tableHTML);
        end
    end

    out=struct;
    out.html=html;
    out.initialValuesMsg=initialValuesMsg;

end

function out=buildModelEquationsHTML(model,info,inputs)

    html='';
    if inputs.includeModelNotes&&~isempty(model.Notes)
        html=appendLineWithPad(html,'<div style="margin-top:4px;">',1);
        html=appendLineWithPad(html,model.Notes,1);
        html=appendLineWithPad(html,'</div>',1);
    end


    tableHTML=buildEquationsTable('Fluxes',info.fluxes,'Fluxes');
    if~isempty(tableHTML)
        html=appendLine(html,tableHTML);
    end


    tableHTML=buildEquationsTable('ODEs',info.odes,'ODEs');
    if~isempty(tableHTML)
        html=appendLine(html,tableHTML);
    end


    out=struct;
    out.html=html;
    out.initialValuesMsg='';

end

function out=buildAssignmentTable(header,assignments,initialValues,includeNotes)

    out='';
    if isempty(assignments)
        return;
    end

    headingLabel='Repeated Assignments';
    if strcmp(assignments(1).RuleType,'initialAssignment')
        headingLabel='Initial Assignments';
    end

    className='assignment';
    headers={' ',header};
    styles={};

    rowNums=cell(1,length(assignments));
    rules=cell(1,length(assignments));
    values=cell(1,length(assignments));
    notes=cell(1,length(assignments));
    count=1;

    for i=1:numel(assignments)
        rowNums{i}=count;
        rules{i}=assignments(i).Rule;
        notes{i}=assignments(i).Notes;

        if~isempty(initialValues)
            values{i}=getInitialValue(initialValues,assignments(i));
        end

        count=count+1;
    end

    data=[rowNums;rules]';
    if~isempty(initialValues)
        data=[data,values'];
        headers=[headers,'Initial Value'];
    end

    if includeNotes&&areValuesDefined(notes)
        data=[data,notes'];
        headers=[headers,'Notes'];
    end

    out=buildTable(headers,data,styles,headingLabel,className);

end

function out=buildCompartmentTable(model,initialValues,includeNotes)

    out=buildQuantityIndividualTable(model.Compartments,'Compartment Name',initialValues,'Compartments',includeNotes);

end

function out=buildEquationsTable(header,equations,headingLabel)

    out='';
    if isempty(equations)
        return;
    end

    rowNums=cell(1,length(equations));
    values=cell(1,length(equations));
    count=1;

    for i=1:numel(equations)
        rowNums{i}=count;
        values{i}=equations{i};
        count=count+1;
    end

    data=[rowNums;values]';
    out=buildTable({' ',header},data,{},headingLabel,'equations');

end

function out=buildEventsTable(events,includeNotes)

    out='';
    if isempty(events)
        return;
    end

    headingLabel='Events';
    rowNums={};
    values={};
    notes={};
    rowStyles={};

    for i=1:numel(events)
        eventFcns=events(i).EventFcns;
        rowNums{end+1}=i;%#ok<*AGROW>
        values{end+1}=events(i).Trigger;
        notes{end+1}=events(i).Notes;

        if~isempty(eventFcns)
            rowStyles{end+1}='eventNotLast';
        else
            rowStyles{end+1}='';
        end

        for j=1:numel(eventFcns)
            rowNums{end+1}='';
            values{end+1}=eventFcns{j};
            notes{end+1}='';

            if j~=numel(eventFcns)
                rowStyles{end+1}='eventNotLast eventFcn';
            else
                rowStyles{end+1}='eventFcn';
            end
        end
    end

    data=[rowNums;values]';
    headings={' ','Events'};

    if includeNotes&&areValuesDefined(notes)
        data=[data,notes'];
        headings=[headings,'Notes'];
    end

    out=buildTable(headings,data,{},headingLabel,'events',rowStyles);

end

function out=buildObservableTable(observables,includeNotes)

    out='';
    if isempty(observables)
        return;
    end

    headingLabel='Observables';
    rowNums=cell(1,length(observables));
    values=cell(1,length(observables));
    notes=cell(1,length(observables));
    units=cell(1,length(observables));

    for i=1:numel(observables)
        name=observables(i).Name;
        if~isvarname(name)
            name=['[',name,']'];
        end

        rowNums{i}=i;
        values{i}=[name,' = ',observables(i).Expression];
        notes{i}=observables(i).Notes;
        units{i}=observables(i).Units;
    end

    data=[rowNums;values]';
    headers={' ','Observables'};

    if areValuesDefined(units)
        data=[data,units'];
        headers=[headers,'Units'];
    end

    if includeNotes&&areValuesDefined(notes)
        data=[data,notes'];
        headers=[headers,'Notes'];
    end

    out=buildTable(headers,data,{},headingLabel,'observables');

end

function out=buildParameterTable(model,initialValues,includeNotes)

    params=model.Parameters;
    rParams=sbioselect(model.Reactions,'Type','parameter');
    params=[params;rParams];
    out=buildQuantityIndividualTable(params,'Parameter Name',initialValues,'Model Scoped and Reaction Scoped Parameters',includeNotes);

end

function out=buildQuantityTable(model,inputs)

    initialValues={};
    initialValuesMsg='';

    if inputs.showInitialValue
        initialValues=getInitialValues(model.SessionID,inputs);


        if~isempty(initialValues.icMessage)
            initialValuesMsg=sprintf('Initial Values were not calculated. %s.',initialValues.icMessage);
        end
    end

    className='';
    headingLabel='Quantities';
    styles={};

    comps=model.Compartments;
    species=sbioselect(model,'Type','species');
    params=sbioselect(model,'Type','parameter');
    total=length(comps)+length(species)+length(params);

    rowNums=cell(1,total);
    names=cell(1,total);
    types=cell(1,total);
    scopes=cell(1,total);
    values=cell(1,total);
    initial=cell(1,total);
    units=cell(1,total);
    notes=cell(1,total);
    count=1;

    for i=1:numel(comps)
        rowNums{count}=count;
        names{count}=comps(i).Name;
        types{count}=comps(i).Type;
        scopes{count}=comps(i).Scope;
        values{count}=comps(i).Value;
        units{count}=comps(i).Units;
        notes{count}=comps(i).Notes;

        if~isempty(initialValues)
            initial{count}=getInitialValue(initialValues,comps(i));
        end

        count=count+1;


        species=comps(i).Species;
        for j=1:numel(species)
            rowNums{count}=count;
            names{count}=species(j).Name;
            types{count}=species(j).Type;
            scopes{count}=species(j).Scope;
            values{count}=species(j).Value;
            units{count}=species(j).Units;
            notes{count}=species(j).Notes;

            if~isempty(initialValues)
                initial{count}=getInitialValue(initialValues,species(j));
            end

            count=count+1;
        end
    end


    params=model.Parameters;
    rParams=sbioselect(model.Reactions,'Type','parameter');
    params=[params;rParams];

    for i=1:numel(params)
        rowNums{count}=count;
        names{count}=params(i).Name;
        types{count}=params(i).Type;
        scopes{count}=params(i).Scope;
        values{count}=params(i).Value;
        units{count}=params(i).Units;
        notes{count}=params(i).Notes;

        if~isempty(initialValues)
            initial{count}=getInitialValue(initialValues,params(i));
        end

        count=count+1;
    end

    data=[rowNums;names;types;scopes;values;]';
    headers={'','Quantity Name','Type','Scope','Value'};

    if~isempty(initialValues)
        data=[data,initial'];
        headers=[headers,'Initial Value'];
    end

    if areValuesDefined(units)
        data=[data,units'];
        headers=[headers,'Units'];
    end

    if inputs.includeModelComponentNotes&&areValuesDefined(notes)
        data=[data,notes'];
        headers=[headers,'Notes'];
    end

    html=buildTable(headers,data,styles,headingLabel,className);

    out.html=html;
    out.initialValues=initialValues;
    out.initialValuesMsg=initialValuesMsg;

end

function out=buildQuantityIndividualTable(objs,heading,initialValues,headingLabel,includeNotes)

    out='';
    if isempty(objs)
        return;
    end

    className='';
    styles={};
    rowNums=cell(1,length(objs));
    names=cell(1,length(objs));
    scopes=cell(1,length(objs));
    values=cell(1,length(objs));
    initial=cell(1,length(objs));
    units=cell(1,length(objs));
    notes=cell(1,length(objs));

    for i=1:numel(objs)
        rowNums{i}=i;
        names{i}=objs(i).Name;
        scopes{i}=objs(i).Scope;
        values{i}=objs(i).Value;
        units{i}=objs(i).Units;
        notes{i}=objs(i).Notes;

        if isa(objs(i),'SimBiology.Parameter')
            names{i}=objs(i).PartiallyQualifiedName;
        end

        if~isempty(initialValues)
            initial{i}=getInitialValue(initialValues,objs(i));
        end
    end

    if isa(objs,'SimBiology.Compartment')
        data=[rowNums;names;scopes;values;]';
        headers={'',heading,'Scope','Value'};
    else
        data=[rowNums;names;values;]';
        headers={'',heading,'Value'};
    end

    if~isempty(initialValues)
        data=[data,initial'];
        headers=[headers,'Initial Value'];
    end

    if areValuesDefined(units)
        data=[data,units'];
        headers=[headers,'Units'];
    end

    if includeNotes&&areValuesDefined(notes)
        data=[data,notes'];
        headers=[headers,'Notes'];
    end

    out=buildTable(headers,data,styles,headingLabel,className);

end

function out=buildQuantityMultipleTables(model,inputs)

    initialValues={};
    initialValuesMsg='';

    if inputs.showInitialValue
        initialValues=getInitialValues(model.SessionID,inputs);


        if~isempty(initialValues.icMessage)
            initialValuesMsg=sprintf('Initial Values were not calculated. %s.',initialValues.icMessage);
        end
    end

    html=buildCompartmentTable(model,initialValues,inputs.includeModelComponentNotes);
    comps=model.Compartments;

    for i=1:numel(comps)
        tableHTML=buildSpeciesTable(comps(i),initialValues,inputs.includeModelComponentNotes);
        if~isempty(tableHTML)
            html=appendLine(html,tableHTML);
        end
    end

    tableHTML=buildParameterTable(model,initialValues,inputs.includeModelComponentNotes);
    if~isempty(tableHTML)
        html=appendLine(html,tableHTML);
    end

    out.html=html;
    out.initialValues=initialValues;
    out.initialValuesMsg=initialValuesMsg;

end

function out=buildReactionTable(reactions,includeNotes)

    out='';
    if isempty(reactions)
        return;
    end

    headingLabel='Reactions';
    rowNums=cell(1,length(reactions)*2);
    values=cell(1,length(reactions)*2);
    notes=cell(1,length(reactions)*2);
    rowStyles=cell(1,length(reactions)*2);
    count=1;

    for i=1:numel(reactions)
        rowNums{count}=i;
        notes{count}=reactions(i).Notes;
        values{count}=reactions(i).Reaction;
        rowStyles{count}='reaction';
        count=count+1;

        rowNums{count}='';
        notes{count}='';
        values{count}=reactions(i).ReactionRate;
        rowStyles{count}='reactionRate';
        count=count+1;

    end

    if includeNotes&&areValuesDefined(notes)
        data=[rowNums;values;notes]';
        headings={' ','Reactions','Notes'};
    else
        data=[rowNums;values]';
        headings={' ','Reactions'};
    end

    out=buildTable(headings,data,{},headingLabel,'reactions',rowStyles);

end

function out=buildRepeatDoseTable(doses)

    out='';
    if isempty(doses)
        return;
    end

    headingLabel='Repeat Doses';
    headers={' ','TargetName','Amount','Rate','StartTime','RepeatCount','Interval','Name'};

    rowNums=cell(1,length(doses));
    target=cell(1,length(doses));
    amount=cell(1,length(doses));
    rate=cell(1,length(doses));
    startTime=cell(1,length(doses));
    repeatCount=cell(1,length(doses));
    interval=cell(1,length(doses));
    names=cell(1,length(doses));

    for i=1:numel(doses)
        rowNums{i}=i;
        target{i}=doses(i).TargetName;
        names{i}=doses(i).Name;

        if isstruct(doses(i))
            amount{i}=doses(i).Table.Amount;
            rate{i}=doses(i).Table.Rate;
            startTime{i}=doses(i).Table.StartTime;
            repeatCount{i}=doses(i).Table.RepeatCount;
            interval{i}=doses(i).Table.Interval;
        else
            amount{i}=doses(i).Amount;
            rate{i}=doses(i).Rate;
            startTime{i}=doses(i).StartTime;
            repeatCount{i}=doses(i).RepeatCount;
            interval{i}=doses(i).Interval;
        end

        if~isempty(doses(i).AmountUnits)&&isnumeric(amount{i})
            amount{i}=[num2str(amount{i}),' (',doses(i).AmountUnits,')'];
        end

        if~isempty(doses(i).RateUnits)&&isnumeric(rate{i})
            rate{i}=[num2str(rate{i}),' (',doses(i).RateUnits,')'];
        end

        if~isempty(doses(i).TimeUnits)&&isnumeric(startTime{i})
            startTime{i}=[num2str(startTime{i}),' (',doses(i).TimeUnits,')'];
        end
    end

    styles=repmat({'style="width:100px"'},1,length(headers));
    styles{1}='';
    styles{end}='style="width:auto"';
    data=[rowNums;target;amount;rate;startTime;repeatCount;interval;names]';
    out=buildTable(headers,data,styles,headingLabel,'repeatdose');

end

function out=buildRuleTable(header,rules,includeNotes)

    out='';
    if isempty(rules)
        return;
    end

    headingLabel='Algebraic Rules';
    if strcmp(rules(1).RuleType,'rate')
        headingLabel='Rate Rules';
    end

    rowNums=cell(1,length(rules));
    values=cell(1,length(rules));
    notes=cell(1,length(rules));

    for i=1:numel(rules)
        rowNums{i}=i;
        values{i}=rules(i).Rule;
        notes{i}=rules(i).Notes;
    end

    data=[rowNums;values]';
    headings={' ',header};

    if includeNotes&&areValuesDefined(notes)
        data=[data,notes'];
        headings=[headings,'Notes'];
    end

    out=buildTable(headings,data,{},headingLabel,rules(1).Type);

end

function out=buildSpeciesTable(comp,initialValues,includeNotes)

    out=buildQuantityIndividualTable(comp.Species,'Species Name',initialValues,['Species in ',comp.Name],includeNotes);

end

function html=buildSingleVariantTable(variants,varargin)

    headingLabel='Variants';
    if nargin==2
        headingLabel=varargin{1};
    end

    html='';
    if~isempty(variants)
        names={};
        types={};
        values={};
        if isstruct(variants)
            vnames={variants.Name};
        else
            vnames=get(variants,{'Name'});
        end

        for i=1:numel(variants)
            content=variants(i).Content;
            for j=1:numel(content)
                next=content{j};
                name=next{2};
                type=next{1};
                idx=findVariantRow(type,name,types,names);

                if isempty(idx)
                    nextValue=repmat({''},1,numel(variants));
                    nextValue{i}=next{4};
                    values{end+1}=nextValue;
                    names{end+1}=name;
                    types{end+1}=type;
                else
                    nextValue=values{idx};
                    nextValue{i}=next{4};
                    values{idx}=nextValue;
                end
            end
        end

        rownums=cell(1,numel(names));
        for i=1:numel(names)
            rownums{i}=i;
        end

        if size(vnames,1)~=1
            vnames=vnames';
        end

        className='variant';
        headers=[{' ','Type','Name'},vnames];
        styles=repmat({'style="width:100px"'},1,length(headers));
        styles{1}='';
        styles{end}='style="width:auto"';

        values=reshape([values{:}],numel(vnames),numel(names));
        data=[rownums;types;names;values]';

        html=buildTable(headers,data,styles,headingLabel,className);
    end

end

function out=findVariantRow(type,name,types,names)

    out=[];
    idx=find(strcmp(name,names));
    for i=1:length(idx)
        if strcmp(types{idx(i)},type)
            out=idx(i);
            break;
        end
    end

end

function html=buildVariantTables(variants)

    html='';
    if~isempty(variants)
        for i=1:numel(variants)
            html=buildIndividualVariantTable(html,variants(i));
        end
    end

end

function html=buildIndividualVariantTable(html,variant)

    className='variant';
    headers={' ','Type','Name','Value'};
    headingLabel=sprintf('Variant: %s',variant.Name);
    styles={' ','style="width:100px"','style="width:200px"','style="width:auto"'};

    content=variant.Content;
    rowNums=cell(1,numel(content));
    names=cell(1,numel(content));
    types=cell(1,numel(content));
    values=cell(1,numel(content));

    for i=1:numel(content)
        next=content{i};
        rowNums{i}=i;
        names{i}=next{2};
        types{i}=next{1};
        values{i}=next{4};
    end

    data=[rowNums;types;names;values]';

    tableHTML=buildTable(headers,data,styles,headingLabel,className);
    if~isempty(tableHTML)
        html=appendLine(html,tableHTML);
    end

end

function html=buildScheduleDoseTables(doses)

    html='';
    if~isempty(doses)
        for i=1:numel(doses)
            html=buildIndividualScheduleDoseTable(html,doses(i));
        end
    end

end

function html=buildIndividualScheduleDoseTable(html,dose)

    className='scheduledose';
    headers={'Time','Amount'};
    headingLabel=sprintf('Schedule Dose: %s (Target: %s)',dose.Name,dose.TargetName);
    styles={'style="width:100px"','style="width:auto"'};

    if~isempty(dose.TimeUnits)
        headers{1}=['Time (',dose.TimeUnits,')'];
    end

    if~isempty(dose.AmountUnits)
        headers{2}=['Amount (',dose.AmountUnits,')'];
    end

    if isstruct(dose)
        value=dose.Table;
        props=value.Properties.VariableNames;
        time=[];
        amount=[];
        rate=[];

        if any(strcmp('Time',props))
            time=value.Time;
        end

        if any(strcmp('Amount',props))
            amount=value.Amount;
        end

        if any(strcmp('Rate',props))
            rate=value.Rate;
        end
    else
        time=dose.Time;
        amount=dose.Amount;
        rate=dose.Rate;
    end

    numRows=max(max(length(amount),length(rate)),length(time));
    times=cell(1,numRows);
    amounts=cell(1,numRows);
    rates=cell(1,numRows);

    for i=1:numRows
        if length(amount)>=i
            amounts{i}=amount(i);
        else
            amounts{i}='';
        end

        if length(time)>=i
            times{i}=time(i);
        else
            times{i}='';
        end

        if length(rate)>=i
            rates{i}=rate(i);
        else
            rates{i}='';
        end
    end


    data=[times;amounts]';
    if areValuesDefined(rates)
        data=[data,rates'];
        headers=[headers,'Rate'];
        styles=[styles,'style="width:auto"'];
        styles{2}='style="width:100px"';

        if~isempty(dose.RateUnits)
            headers{3}=['Rate (',dose.RateUnits,')'];
        end
    end

    tableHTML=buildTable(headers,data,styles,headingLabel,className);
    if~isempty(tableHTML)
        html=appendLine(html,tableHTML);
    end

end

function out=getInitialValue(initialValues,obj)

    out='';
    if strcmp(obj.Type,'rule')

        lhs=parserule(obj);


        if~isempty(lhs)
            obj=resolveobject(obj,lhs{1});
        end
    end

    if~isempty(obj)
        out=initialValues.values(initialValues.sessionID==obj.SessionID);
        if isempty(out)
            out=obj.Value;
        else
            out=out{1};
        end

        idx=(initialValues.targets==obj.SessionID);
        if any(idx)
            out=[num2str(out),' + ',num2str(sum(initialValues.doseValues(idx)))];
        end
    end

end

function out=getInitialValues(sessionID,input)

    args=struct;
    args.sessionID=sessionID;
    args.variants=input.variants;
    args.doses=input.doses;
    out=SimBiology.web.equationshandler('getInitialConditions',args);

end

function code=appendLine(code,newLine)

    code=SimBiology.web.report.utilhandler('appendLine',code,newLine);

end

function code=appendLineWithPad(code,newLine,numTabs)

    code=SimBiology.web.report.utilhandler('appendLineWithPad',code,newLine,numTabs);

end

function out=buildTable(headers,data,styles,caption,className,varargin)

    out=SimBiology.web.report.utilhandler('buildTable',headers,data,styles,caption,className,varargin{:});

end

function out=areValuesDefined(list)

    out=SimBiology.web.report.utilhandler('areValuesDefined',list);

end

function out=createHeaderLine(header,text,numTabs)

    out=SimBiology.web.report.utilhandler('createHeaderLine',header,text,numTabs);

end

function deleteFile(name)

    oldState=recycle;
    recycle('off');
    delete(name)
    recycle(oldState);
end
