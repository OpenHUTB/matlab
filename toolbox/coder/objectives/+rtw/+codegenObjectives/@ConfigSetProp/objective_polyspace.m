function objective=objective_polyspace(~)




    file.filename='objective_polyspace.m';
    file.objectivename='Polyspace';
    file.order='8';

    paramsTable={

    'SolverType','Fixed-step',''
    'ZeroExternalMemoryAtStartup','off',''
    'InitFltsAndDblsToZero','on',''
    'MatFileLogging','off',''
    'DefaultParameterBehavior','Inlined',''
    'GenerateReport','on',''
    'GenerateComments','on',''
    'IncludeHyperlinkInReport','on',''
    'GenerateSampleERTMain','off',''
    };
    params=cell2struct(paramsTable,{'name','setting','target'},2);


    check={
'mathworks.codegen.CodeGenSanity'
    };



    allChecks=coder.advisor.internal.CGOFixedCheck;
    value=double(ismember(allChecks.checkID,check));

    checklist=struct('id',num2cell(1:length(value)),'value',num2cell(value));

    objective.params=arrayfun(@(x)x,transpose(params),'UniformOutput',false);
    objective.checklist=arrayfun(@(x)x,checklist,'UniformOutput',false);
    objective.len=length(params);
    objective.checklen=length(checklist);
    objective.file=file;
    objective.error=0;

end


