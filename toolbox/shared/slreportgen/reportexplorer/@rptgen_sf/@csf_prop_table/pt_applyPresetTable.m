function pt_applyPresetTable(c,tableName)






    defaultRender='N v';

    title='';
    singleVal=true;
    colWid=[.3,.7];

    switch lower(tableName)
    case 'default'
        pnames={
'%<Name>'
'%<Parent>'
'%<Description>'
'%<Document>'
        };
    case 'machine'
        colWid=[.3,.7,.3,.7];
        pnames={
        '%<Document>','%<FullFileName>'
        '%<Created>','%<Creator>'
        '%<Modified>','%<Version>'
        };
    case 'chart'
        pnames={
'%<Machine>'
'%<Document>'
'%<States>'
'%<Transitions>'
        };
    case 'state'
        pnames={
'%<Type>'
'%<Parent>'
'%<Label>'
'%<Description>'
'%<Document>'
'%<innerTransitions>'
'%<outerTransitions>'
'%<sourcedTransitions>'
'%<defaultTransitions>'
        };
    case 'transition'
        pnames={
'%<Parent>'
'%<Label>'
'%<Description>'
'%<Document>'
'%<Source>'
'%<Destination>'
'%<ExecutionOrder>'
        };
    case 'junction'
        pnames={
'%<Parent>'
'%<Label>'
'%<Description>'
'%<Document>'
'%<sourcedTransitions>'
        };
    case 'data'
        pnames={
'%<Parent>'
'%<Description>'
'%<Document>'
'%<Scope>'
'%<DataType>'
'%<Units>'
'%<Range>'
'%<InitValue>'
        };
    case 'event'
        pnames={
'%<Parent>'
'%<Description>'
'%<Document>'
'%<Scope>'
'%<Trigger>'
        };
    case 'target'
        pnames={
'%<Machine>'
'%<Description>'
'%<CustomCode>'
'%<Document>'
'%<UserSources>'
'%<UserIncludeDirs>'
'%<UserLibraries>'
        };
    case 'truthtable'
        pnames={
'%<Type>'
'%<Parent>'
'%<Label>'
'%<Description>'
'%<Document>'
'%<BadIntersection>'
'%<UnderSpecDiagnostic>'
'%<OverspecDiagnostic>'
        };
    case 'emfunction'
        pnames={
'%<LabelString>'
'%<Script>'
'%<Data>'
        };

    case 'slfunction'
        pnames={
'%<LabelString>'
'%<Parent>'
'%<SimulinkSubSystem>'
        };
    case 'port'
        pnames={
'%<Parent>'
'%<Label>'
'%<Description>'
'%<Document>'
'%<PortType>'
        };
    otherwise

        title='Title';
        singleVal=false;
        colWid=[1,1,1,1];
        [pnames{1:4,1:4}]=deal('');
    end




    c.setTableStrings(pnames,singleVal,title,defaultRender);
    c.ColWidths=colWid;