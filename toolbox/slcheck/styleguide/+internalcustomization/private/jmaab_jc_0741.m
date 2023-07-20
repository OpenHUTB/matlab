function jmaab_jc_0741

    rec=ModelAdvisor.Check('mathworks.jmaab.jc_0741');
    rec.Title=DAStudio.message('ModelAdvisor:jmaab:jc_0741_title');
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='jc_0741';
    rec.setCallbackFcn(@(system,checkObj)Advisor.Utils.genericCheckCallback(system,checkObj,'ModelAdvisor:jmaab:jc_0741',@hCheckAlgo),'None','DetailStyle');
    rec.TitleTips=DAStudio.message('ModelAdvisor:jmaab:jc_0741_tip');
    rec.setLicense({styleguide_license,'Stateflow'});
    rec.Value=true;
    rec.SupportHighlighting=true;
    rec.SupportLibrary=true;
    rec.SupportExclusion=true;
    rec.setInputParametersLayoutGrid([1,4]);

    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';
    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='graphical';

    rec.setInputParameters(inputParamList);
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});
end



function FailingObjs=hCheckAlgo(system)
    FailingObjs=[];
    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);

    flv=mdlAdvObj.getInputParameterByName('Follow links');
    lum=mdlAdvObj.getInputParameterByName('Look under masks');

    sfStates=Advisor.Utils.Stateflow.sfFindSys(system,flv.Value,lum.Value,{'-isa','Stateflow.State'});

    if isempty(sfStates)
        return;
    end

    sfStates=mdlAdvObj.filterResultWithExclusion(sfStates);

    flaggedStates=false(1,length(sfStates));

    if~isempty(sfStates)
        patternEnableBit=getPattern(true);
        patternDisableBit=getPattern(false);
    end

    for idxS=1:length(sfStates)

        if isempty(regexp(sfStates{idxS}.LabelString,'(du|during)\s*(\,).*(\:)|(du|during)\s*:','once'))
            continue;
        end

        if sfStates{idxS}.Chart.EnableBitOps
            pattern=patternEnableBit;
        else
            pattern=patternDisableBit;
        end

        myTransitionsVector=sfStates{idxS}.sourcedTransitions;
        visitedTransitions=[];
        while(~flaggedStates(idxS)&&numel(myTransitionsVector)>0)
            transition=myTransitionsVector(1);
            visitedTransitions=[visitedTransitions,transition];%#ok<AGROW>
            myTransitionsVector(1)=[];



            operands=regexprep(regexp(transition.LabelString,...
            ['((?<=[)\s*\w+\s*(?=',pattern,')|(?<=',pattern,')\s*\w+\s*(?=]))'],...
            'match'),'\s','');

            operands=[operands,getOperandsFunctionsAndArray(transition.LabelString)];%#ok<AGROW>
            if~isempty([operands{:}])

                fcnObjs=Advisor.Utils.Stateflow.sfFindSys(sfStates{idxS}.Chart.Path,flv.Value,lum.Value,{'-isa','Stateflow.Function','-or','-isa','Stateflow.EMFunction'});
                if~isempty(fcnObjs)
                    mlFcnMap=getFcnMap(fcnObjs);
                else
                    mlFcnMap={};
                end

                [ast,~]=Advisor.Utils.Stateflow.getAbstractSyntaxTree(sfStates{idxS});
                if~isempty(ast)
                    sections=ast.sections;
                    treeStart=[];
                    for ii=1:numel(sections)
                        if isa(sections{ii},'Stateflow.Ast.DuringSection')
                            roots=sections{ii}.roots;
                            if~isempty(roots)

                                if ismember(roots{1}.treeStart,treeStart)
                                    continue;
                                else
                                    treeStart=[treeStart;roots{1}.treeStart];%#ok<AGROW>
                                    for ij=1:numel(roots)
                                        if Advisor.Utils.Stateflow.isActionLanguageC(sfStates{idxS}.chart)
                                            flaggedStates(idxS)=checkCChart(roots{ij},operands,mlFcnMap,fcnObjs);
                                        elseif Advisor.Utils.Stateflow.isActionLanguageM(sfStates{idxS}.chart)
                                            flaggedStates(idxS)=checkMChart(roots{ij},operands,mlFcnMap,fcnObjs);
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end


            if~isempty(transition.Destination)&&isa(transition.Destination,'Stateflow.Junction')&&...
                strcmp(transition.Destination.Type,'CONNECTIVE')
                sourcedTxns=transition.Destination.sourcedTransitions;
                myTransitionsVector=[myTransitionsVector;sourcedTxns(~ismember(sourcedTxns,visitedTransitions))];%#ok<AGROW>
            end
        end
    end

    FailingObjs=sfStates(flaggedStates);
end

function pattern=getPattern(enableBit)

    if enableBit
        and_or='&&|\|\|';
    else


        and_or='&|\|';
    end

    pattern=['([!~=><]=|[><]|',and_or,')'];
end

function operands=getOperandsFunctionsAndArray(str)
    operands=[];
    if isempty(str)
        return;
    end
    expr='\w+\s*\((.*?)\)';
    tokens=regexp(str,expr,'tokens');
    if isempty(tokens)
        return;
    end
    tokens=tokens{1};
    C=strsplit(tokens{1},',');
    operands=cellfun(@(x)strtrim(x),C,'UniformOutput',false);
end

function res=checkCChart(astobj,operands,mlFcnMap,fcnObjs)
    res=false;
    string=astobj.sourceSnippet;
    if isempty(string)
        return;
    end




    assignOpr=cellfun(@(x)regexp(string,...
    ['(?<!\w)',x,'\s*=\s*'],'once'),operands,'UniformOutput',false);

    fcnCall=cellfun(@(x)regexp(string,'.*\(.*\).*','once'),operands,'UniformOutput',false);

    if isempty([assignOpr{:}])&&isempty([fcnCall{:}])
        return;

    elseif isempty([fcnCall{:}])
        res=true;
        return;
    end

    flag=cellfun(@(x)(isa(x,'Stateflow.Ast.UserFunction')||isa(x,'Stateflow.Ast.GraphicalFunction')),astobj.children);
    objs=astobj.children;
    astobj=objs(flag);
    if any(flag)
        for j=1:numel(astobj)
            fcnName=strtok(astobj{j}.sourceSnippet,'(');
            try
                fcnIdx=mlFcnMap(fcnName);
            catch

                continue;
            end
            fcn=fcnObjs{fcnIdx};







            if~isempty([assignOpr{:}])
                operands={regexprep(strtok(fcn.LabelString,'='),'\s*','')};
            end
            if isa(fcn,'Stateflow.EMFunction')
                flag=icheckEMFunction(fcn,operands);
            elseif isa(fcn,'Stateflow.Function')
                flag=icheckGraphicalFunction(fcn,operands);
            end
            if flag
                res=true;
                return;
            end
        end
    end
end

function res=checkMChart(astobj,operands,mlFcnMap,fcnObjs)
    res=false;
    string=astobj.sourceSnippet;
    if isempty(string)
        return;
    end
    treeObject=Advisor.Utils.Stateflow.createMtreeObject(astobj.sourceSnippet);



    equalTrees=treeObject.mtfind('Kind','EQUALS');
    for i=equalTrees.indices
        assign_exp=equalTrees.select(i);
        assign_exp=assign_exp.Right;
        fcncall=assign_exp.mtfind('Kind','CALL');
        assignOpr=cellfun(@(x)regexp(astobj.sourceSnippet,['(?<!\w)',x,'\s*=\s*'],'once'),operands,'UniformOutput',false);
        if isempty(fcncall)&&~isempty([assignOpr{:}])
            res=true;
            return;
        end
    end

    if~isempty(mlFcnMap)
        callTrees=treeObject.mtfind('Kind','CALL');
        for index=callTrees.indices
            thisCall=callTrees.select(index);
            fcnName=thisCall.Left.string;
            fcnIdx=mlFcnMap(fcnName);
            fcn=fcnObjs{fcnIdx};







            if~isempty([assignOpr{:}])
                operands={regexprep(strtok(fcn.LabelString,'='),'\s*','')};
            end
            if isa(fcn,'Stateflow.EMFunction')
                flag=icheckEMFunction(fcn,operands);
            elseif isa(fcn,'Stateflow.Function')
                flag=icheckGraphicalFunction(fcn,operands);
            end
            if flag
                res=true;
                return;
            end
        end


        children=astobj.children;
        for i=1:length(children)
            res=checkobjM(children{i},operands,mlFcnMap,fcnObjs);
        end
    end
end

function fcnMap=getFcnMap(obj)
    fcnname=cell(1,numel(obj));
    fcnIndex=cell(1,numel(obj));
    for fncnt=1:numel(obj)

        fcnname{fncnt}=obj{fncnt}.Name;
        fcnIndex{fncnt}=fncnt;
    end

    fcnMap=containers.Map(fcnname,fcnIndex);
end

function flag=icheckEMFunction(mlobj,operands)
    flag=false;
    fcnScript=mlobj.Script;
    assignOpr=cellfun(@(x)regexp(fcnScript,...
    ['(?<!\w)',x,'\s*=\s*'],'once'),operands,'UniformOutput',false);
    if~isempty([assignOpr{:}])
        flag=true;
    end
end

function flag=icheckGraphicalFunction(grfcnobj,operands)
    flag=false;
    transList=grfcnobj.findobj({'-isa','Stateflow.Transition'});
    for t=1:numel(transList)


        assignOpr=cellfun(@(x)regexp(transList(t).LabelString,['(?<!\w)',x,'\s*=\s*'],'once'),operands,'UniformOutput',false);%#ok<AGROW>
        if~isempty([assignOpr{:}])
            flag=true;
            return;
        end
    end
end