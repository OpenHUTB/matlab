function out=filehandler(action,varargin)











    out={action};

    switch(action)
    case 'exportModelComponents'
        out=exportModelComponents(varargin{:});
    case 'getSheetNames'
        out=getSheetNames(varargin{:});
    case 'importModelComponents'
        out=importModelComponents(varargin{:});
    end

end

function out=exportModelComponents(input)

    model=getModelFromSessionID(input.sessionID);
    filename=input.filename;
    props=input.propertyMap;
    names=fieldnames(props);
    pvpairs=cell(1,length(names)*2);
    count=1;

    for i=1:length(names)
        pvpairs{count}=names{i};
        pvpairs{count+1}=props.(names{i});
        count=count+2;
    end

    SimBiology.web.internal.exportModelComponents(model,filename,input.header,input.singleVariant,input.singleDose,pvpairs{:});

    out.filepath=fileparts(input.filename);

end

function out=getSheetNames(inputs)

    out=inputs;
    out.sheetnames=sheetnames(inputs.filename);

end

function out=importModelComponents(input)

    modelObj=getModelFromSessionID(input.sessionID);
    filename=input.filename;
    props=input.propertyMap;
    sheetNames=input.sheetNames;
    names=fieldnames(props);
    pvpairs=cell(1,length(names)*2);
    count=1;

    for i=1:length(names)
        pvpairs{count}=names{i};
        pvpairs{count+1}=props.(names{i});
        pvpairs{count+2}=sheetNames.(names{i});
        count=count+3;
    end

    transaction=SimBiology.Transaction.create(modelObj);
    msgs=SimBiology.web.internal.importModelComponents(modelObj,filename,input.header,input.singleVariant,input.singleDose,input.overwrite,input.prefs,pvpairs{:});
    transaction.commit;

    out.filepath=fileparts(input.filename);
    out.errors=msgs.errors;
    out.warnings=msgs.warnings;
    out.infos={};

end

function model=getModelFromSessionID(sessionID)

    model=SimBiology.web.modelhandler('getModelFromSessionID',sessionID);
end
