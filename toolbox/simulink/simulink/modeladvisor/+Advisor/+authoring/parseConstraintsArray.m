function status=parseConstraintsArray(doc,dataFile,opts)




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
