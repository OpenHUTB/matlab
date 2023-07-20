function varargout=generateBlockConstraintsDataFile(filename,varargin)



    if slfeature("ConstraintFixIts")==1

        if nargin>0
            filename=convertStringsToChars(filename);
        end

        if nargin>1
            [varargin{:}]=convertStringsToChars(varargin{:});
        end

        status=-1;%#ok<NASGU>

        ipParser=parseinputs(varargin);
        opts.ConstraintArray=ipParser.Results.Constraints;


        dataFile=Advisor.authoring.DataFile(filename);
        doc=dataFile.getXMLDoc();

        status=Advisor.authoring.parseConstraintsArray(doc,dataFile,opts);

        if status~=0
            return;
        end

        if~ipParser.Results.GenerateString

            [~,val]=fileattrib(filename);
            if(isstruct(val)&&~val.UserWrite)
                DAStudio.error('Advisor:engine:ReadOnlyDataFile',filename);
            end

            try
                dataFile.write();
            catch E
                DAStudio.error('sledittimecheck:edittimecheck:CreateConstraintDataFileError',pwd);
            end

        else
            varargout{1}=dataFile.getXMLString();
        end
    else
        if nargin>0
            filename=convertStringsToChars(filename);
        end

        if nargin>1
            [varargin{:}]=convertStringsToChars(varargin{:});
        end

        status=-1;%#ok<NASGU>

        opts=parseinput(varargin{:});
        [~,val]=fileattrib(filename);
        if(isstruct(val)&&~val.UserWrite)
            DAStudio.error('Advisor:engine:ReadOnlyDataFile',filename);
        end


        dataFile=Advisor.authoring.DataFile(filename);
        doc=dataFile.getXMLDoc();

        status=generateDataFileFromBlockConstraints(doc,dataFile,opts);

        if status~=0
            return;
        end

        try
            dataFile.write();
        catch E
            DAStudio.error('sledittimecheck:edittimecheck:CreateConstraintDataFileError',pwd);
        end

    end
end


function ipParser=parseinputs(ipValues)
    ipParser=inputParser;
    addParameter(ipParser,'Constraints',@(x)iscell(x))
    addOptional(ipParser,'GenerateString',false,@(x)islogical(x))

    try
        parse(ipParser,ipValues{:});
    catch ME
        throw(ME);
    end
end


function status=generateDataFileFromBlockConstraints(doc,dataFile,opts)
    status=-1;%#ok<NASGU>


    CheckConstraintIds(opts.ConstraintArray);
    ConstraintsMap=getConstraintsMap(opts.ConstraintArray);

    if~isempty(ConstraintsMap)
        ConstraintsMap=Advisor.authoring.CustomCheck.verifyConstraintDependencies(ConstraintsMap);
    end

    rootConstraintIdArray=getRootConstraintIds(ConstraintsMap);
    ConstraintIdsFromComposites={};

    for i=1:numel(opts.ConstraintArray)
        if isa(opts.ConstraintArray{i},'Advisor.authoring.internal.Constraint')||isa(opts.ConstraintArray{i},'Advisor.authoring.ModelParameterConstraint')
            node=Advisor.authoring.internal.getXMLNode(opts.ConstraintArray{i},doc);
        elseif isa(opts.ConstraintArray{i},'Advisor.authoring.CompositeConstraint')
            opts.ConstraintArray(i)=...
            Advisor.authoring.CustomCheck.verifyCompositeConstraintDependencies(opts.ConstraintArray(i),ConstraintsMap);
            node=opts.ConstraintArray{i}.getXMLNode(doc);
            ConstraintIdsFromComposites=[ConstraintIdsFromComposites,opts.ConstraintArray{i}.getConstraintIDs];
        end
        dataFile.appendConstraintNode(node);


        lb=doc.createTextNode(newline);
        dataFile.appendConstraintNode(lb);
    end


    constraintsToBeAddedToComposites=setdiff(rootConstraintIdArray,ConstraintIdsFromComposites);



    if~isempty(constraintsToBeAddedToComposites)
        newComposite=Advisor.authoring.CompositeConstraint();
        newComposite.setConstraintIDs(constraintsToBeAddedToComposites);
        newComposite.CompositeOperator='and';

        node=newComposite.getXMLNode(doc);

        dataFile.appendConstraintNode(node);


        lb=doc.createTextNode(newline);
        dataFile.appendConstraintNode(lb);
    end


    status=0;
end

function map=getConstraintsMap(constraintArray)
    map=containers.Map();

    for i=1:numel(constraintArray)
        checkIncompleteConstraintObject(constraintArray{i});
        if~isa(constraintArray{i},'Advisor.authoring.CompositeConstraint')
            map(constraintArray{i}.ID)=constraintArray{i};
        end
    end

end




function checkIncompleteConstraintObject(constraint)
    fields=setdiff(fieldnames(constraint),...
    {'ID','PreRequisiteConstraintHandles',...
    'PreRequisiteConstraintIDs',...
    'Description'});

    for i=1:numel(fields)
        if isempty(constraint.(fields{i}))
            DAStudio.error('Advisor:engine:EmptyFielsInConstraint',fields{i},class(constraint));
        end
    end

end

function CheckConstraintIds(ConstraintArray)
    constraintIdArray={};

    for i=1:numel(ConstraintArray)
        if~isa(ConstraintArray{i},'Advisor.authoring.CompositeConstraint')
            IDString=ConstraintArray{i}.ID;
            if isempty(IDString)
                IDString=char(matlab.lang.internal.uuid);
                ConstraintArray{i}.ID=IDString;
            end

            if(any(strcmp(constraintIdArray,IDString)))
                DAStudio.error('Advisor:engine:CCConstraintIDNotUnique',IDString);
            else
                constraintIdArray=[constraintIdArray,IDString];
            end
        end
    end
end

function constraintIdArray=getRootConstraintIds(ConstraintMAP)
    constraintIdArray={};
    ids=ConstraintMAP.keys;

    for i=1:numel(ids)
        currConst=ConstraintMAP(ids{i});
        if(currConst.IsRootConstraint)
            if isa(currConst,'Advisor.authoring.ModelParameterConstraint')
                DAStudio.error('sledittimecheck:edittimecheck:InvalidConstraintPassed');
            else
                constraintIdArray=[constraintIdArray,ids{i}];
            end
        end
    end
end

function opts=parseinput(varargin)


    opts.ConstraintArray=[];
    opts.FixValues=false;

    if rem(length(varargin),2)~=0
        DAStudio.error('Advisor:engine:invalidArgPairing','generateBlockConstraintsCheck');
    end

    for n=1:2:length(varargin)
        if~ischar(varargin{n})
            DAStudio.error('Advisor:engine:NonStringPropertyName');
        end

        switch varargin{n}
        case{'Constraints','constraints'}
            if~iscell(varargin{n+1})
                DAStudio.error('Advisor:engine:CCUnsupportedInput');
            end
            opts.ConstraintArray=varargin{n+1};
        case{'FixValues','fixvalues','fixValues','Fixvalues'}
            if~islogical(varargin{n+1})
                DAStudio.error('Advisor:engine:CCUnsupportedInput');
            end
            opts.FixValues=varargin{n+1};
        otherwise
            DAStudio.error('Advisor:engine:UnknownProperty',varargin{n});
        end
    end
end

