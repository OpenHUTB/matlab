

function[incorrectChecks]=assess(model1,model2,flags)



    incorrectChecks=cell(1,length(flags));
    for i=1:length(flags)
        switch flags{i}


        case 'existStates'




            if existStates(model1,model2)
                incorrectChecks{i}='existStates';
            else
                incorrectChecks{i}='';
            end
        case 'existTransitions'


        case 'existDefTransitions'

            if existDefTransitions(model1,model2)
                incorrectChecks{i}='existDefTransitions';
            else
                incorrectChecks{i}='';
            end
        case 'existJunctions'


        case 'transitionExOrder'






            if transitionExOrder(model1,model2)
                incorrectChecks{i}='transitionExOrder';
            else
                incorrectChecks{i}='';
            end
        case 'defaultTransitionExOrder'


        case 'conditionTransitions'





            if conditionTransitions(model1,model2)
                incorrectChecks{i}='conditionTransitions';
            else
                incorrectChecks{i}='';
            end
        case 'conditionActions'


        case 'stateActions'








            if stateActions(model1,model2)
                incorrectChecks{i}='stateActions';
            else
                incorrectChecks{i}='';
            end
        case 'defTransitionsLocation'








            if defTransitionsLocation(model1,model2)
                incorrectChecks{i}='defTransitionsLocation';
            else
                incorrectChecks{i}='';
            end
        case 'verifyChartData'




            if verifyChartData(model1,model2)
                incorrectChecks{i}='verifyChartData';
            else
                incorrectChecks{i}='';
            end
        case 'verifyGraphicalFcns'


            if verifyGraphicalFcns(model1,model2)||defTransitionsLocation(model1,model2)
                incorrectChecks{i}='verifyGraphicalFcns';
            else
                incorrectChecks{i}='';
            end
        case 'verifyMLFcns'


            if verifyMLFcns(model1,model2)
                incorrectChecks{i}='verifyMLFcns';
            else
                incorrectChecks{i}='';
            end
        case 'overallStructure'

            if existStates(model1,model2)||transitionExOrder(model1,model2)||...
                conditionTransitions(model1,model2)||stateActions(model1,model2)||...
                defTransitionsLocation(model1,model2)||verifyChartData(model1,model2)||...
                verifyGraphicalFcns(model1,model2)||verifyMLFcns(model1,model2)
                incorrectChecks{i}='overallStructure';
            else
                incorrectChecks{i}='';
            end
        otherwise
            error('this is not a valid flag');
        end
    end

    function criteriaViolated=existStates(model1,model2)
        criteriaViolated=false;

        if~isequal(numel(model1.States),numel(model2.States))
            criteriaViolated=true;
            return
        end

        for idx=1:numel(model1.States)



            if~any(strcmp(model1.States(idx).Name,{model2.States.Name}))
                criteriaViolated=true;
                return
            end
        end
    end

    function criteriaViolated=existTransitions(model1,model2)


    end

    function criteriaViolated=transitionExOrder(model1,model2)
        criteriaViolated=false;
        if~isequal(numel(model1.Transitions),numel(model2.Transitions))
            criteriaViolated=true;
            return
        end

        for idx=1:numel(model1.Transitions)





            if isempty(model1.Transitions(idx).LabelString)


                matchingIndex=findMatchingTransition(model1.Transitions(idx),model2.Transitions,model1,model2);
            else
                matchingIndex=getMatchingIndex(model1.Transitions(idx),model2.Transitions,model1,model2);
            end
            if isequal(matchingIndex,-1)||~isequal(model1.Transitions(idx).ExecutionOrder,model2.Transitions(matchingIndex).ExecutionOrder)
                criteriaViolated=true;
                return
            end
        end
    end

    function criteriaViolated=conditionTransitions(model1,model2)
        criteriaViolated=false;
        if~isequal(numel(model1.Transitions),numel(model2.Transitions))
            criteriaViolated=true;
            return
        end

        for idx=1:numel(model1.Transitions)







            if~isempty(model1.Transitions(idx).LabelString)


                matchingIndex=getMatchingIndex(model1.Transitions(idx),...
                model2.Transitions,model1,model2);
                if isequal(matchingIndex,-1)
                    criteriaViolated=true;
                    return
                end
            end
        end
    end

    function criteriaViolated=conditionActions(model1,model2)


    end

    function criteriaViolated=stateActions(model1,model2)


        criteriaViolated=false;



        if~isequal(length(model1.States),length(model2.States))
            criteriaViolated=true;
            return;
        end

        for j=1:length(model1.States)



            model2State=[];


            for k=1:length(model2.States)
                if isequal(model1.States(j).Name,model2.States(k).Name)
                    model2State=model2.States(k);
                    break;
                end
            end

            if isempty(model2State)


                criteriaViolated=true;
                return;
            end



            if~isequal(length(model1.States(j).Entry),length(model2State.Entry))||...
                ~isequal(length(model1.States(j).During),length(model2State.During))||...
                ~isequal(length(model1.States(j).Exit),length(model2State.Exit))
                criteriaViolated=true;
                return;
            end



            for k=1:length(model1.States(j).Entry)
                if~any(contains(model2State.Entry,model1.States(j).Entry(k)))
                    criteriaViolated=true;
                    return;
                end
                if~any(contains(model1.States(j).Entry,model2State.Entry(k)))
                    criteriaViolated=true;
                    return;
                end
            end
            for k=1:length(model1.States(j).During)
                if~any(contains(model2State.During,model1.States(j).During(k)))
                    criteriaViolated=true;
                    return;
                end
                if~any(contains(model1.States(j).During,model2State.During(k)))
                    criteriaViolated=true;
                    return;
                end
            end
            for k=1:length(model1.States(j).Exit)
                if~any(contains(model2State.Exit,model1.States(j).Exit(k)))
                    criteriaViolated=true;
                    return;
                end
                if~any(contains(model1.States(j).Exit,model2State.Exit(k)))
                    criteriaViolated=true;
                    return;
                end
            end
        end
    end

    function criteriaViolated=defTransitionsLocation(model1,model2)


        criteriaViolated=false;



        if~isequal(numel(model1.DefaultTransitions),numel(model2.DefaultTransitions))
            criteriaViolated=true;
            return
        end






        for idx=1:length(model1.DefaultTransitions)
            if~isempty(model1.DefaultTransitions(idx).LabelString)
                matchingIndex=getMatchingIndex(model1.DefaultTransitions(idx),model2.DefaultTransitions,model1,model2);
                if isequal(matchingIndex,-1)
                    criteriaViolated=true;
                    return
                end
                continue
            end
            [~,anyMatches]=findMatchingTransition(model1.DefaultTransitions(idx),model2.DefaultTransitions,model1,model2);
            if isequal(anyMatches,-1)
                criteriaViolated=true;
                return
            end
        end
    end

    function criteriaViolated=verifyChartData(model1,model2)








        if~isequal(numel(model1.SymbolData),numel(model2.SymbolData))
            criteriaViolated=true;
            return
        end



        for j=1:numel(model1.SymbolData)

            if isequal(model1.SymbolData(j).Name,model2.SymbolData(j).Name)
                continue;
            end



            for k=j:numel(model1.SymbolData)
                if~isequal(model1.SymbolData(j).Name,model2.SymbolData(k).Name)
                    continue;
                end
                tempVar=model2.SymbolData(j);
                model2.SymbolData(j)=model2.SymbolData(k);
                model2.SymbolData(k)=tempVar;
                break;
            end
        end


        criteriaViolated=~isequal(model1.SymbolData,model2.SymbolData);
    end

    function matchingIndex=getMatchingIndex(searchStruct,structArray,model1,model2)




        matchingIndex=-1;

        currentTransitionSrc=searchStruct.Source;
        currentTransitionDest=searchStruct.Destination;

        for idx=1:length(structArray)
            currentStruct=structArray(idx);


            firstIdx=[];
            secondIdx=[];

            if conditionsMatch(searchStruct.LabelString,currentStruct.LabelString,model1,model2)


                if~isequal(class(currentTransitionSrc),class(currentStruct.Source))||...
                    ~isequal(class(currentTransitionDest),class(currentStruct.Destination))


                    continue
                end

                if~isempty(currentTransitionSrc)


                    switch class(currentTransitionSrc)


                    case 'learning.stateflow.State'
                        if isequal(currentTransitionSrc.Name,currentStruct.Source.Name)
                            firstIdx=idx;
                        end
                    case 'learning.stateflow.Junction'

                        if isequal(numel(currentTransitionSrc.Inputs),numel(currentStruct.Source.Inputs))
                            firstIdx=idx;
                        end
                    end
                end

                switch class(currentTransitionDest)


                case 'learning.stateflow.State'
                    if isequal(currentTransitionDest.Name,currentStruct.Destination.Name)
                        secondIdx=idx;
                    end
                case 'learning.stateflow.Junction'
                    if isequal(numel(currentTransitionDest.Inputs),numel(currentStruct.Destination.Inputs))
                        secondIdx=idx;
                    end
                end

                if~isempty(firstIdx)&&~isempty(secondIdx)&&isequal(firstIdx,secondIdx)

                    matchingIndex=secondIdx;
                    return
                elseif isempty(currentTransitionSrc)&&~isempty(secondIdx)

                    matchingIndex=secondIdx;
                    return
                end
            end
        end
    end

    function[matchedIndexTrans,matchedIndexDefTrans]=findMatchingTransition(searchTransition,transitionStruct,model1,model2)


        matchedIndexTrans=-1;
        matchedIndexDefTrans=-1;
        if isempty(searchTransition.Source)

            for j=1:length(transitionStruct)
                if~isequal(class(searchTransition.Destination),class(transitionStruct(j).Destination))


                    continue;
                end
                if isequal(class(transitionStruct(j).Destination),'learning.stateflow.Junction')


                    if~isequal(numel(searchTransition.Destination.Inputs),numel(transitionStruct(j).Destination.Inputs))||...
                        ~isequal(numel(searchTransition.Destination.Outputs),numel(transitionStruct(j).Destination.Outputs))
                        continue;
                    end

                    if isequal(searchTransition.Destination.Inputs,transitionStruct(j).Destination.Inputs)&&...
                        isequal(searchTransition.Destination.Outputs,transitionStruct(j).Destination.Outputs)
                        matchedIndexDefTrans=j;
                        return;
                    end

                end

                if isequal(searchTransition.Destination.Name,transitionStruct(j).Destination.Name)&&...
                    ((~isempty(searchTransition.LabelString)&&conditionsMatch(searchTransition.LabelString,transitionStruct(j).LabelString,model1,model2))||...
                    isempty(searchTransition.LabelString)&&isempty(transitionStruct(j).LabelString))





                    matchedIndexDefTrans=j;
                    return;
                end
            end
        else

            for j=1:length(transitionStruct)
                if~isequal(class(searchTransition.Destination),class(transitionStruct(j).Destination))||...
                    ~isequal(class(searchTransition.Source),class(transitionStruct(j).Source))


                    continue;
                elseif~isempty(searchTransition.LabelString)

                    if conditionsMatch(searchTransition.LabelString,transitionStruct(j).LabelString,model1,model2)
                        if isequal(searchTransition.ExecutionOrder,transitionStruct(j).ExecutionOrder)&&...
                            sourcesAndDestinationsMatch(searchTransition,transitionStruct(j))
                            matchedIndexTrans=j;
                            return;
                        end
                    else
                        continue;
                    end
                else
                    if isempty(transitionStruct(j).LabelString)
                        if isequal(searchTransition.ExecutionOrder,transitionStruct(j).ExecutionOrder)&&...
                            sourcesAndDestinationsMatch(searchTransition,transitionStruct(j))
                            matchedIndexTrans=j;
                            return;
                        end
                    else
                        continue;
                    end
                end
            end
        end
    end

    function matched=sourcesAndDestinationsMatch(transition1,transition2)


        matched=true;


        transition1Array={transition1.Source,transition1.Destination};
        transition2Array={transition2.Source,transition2.Destination};

        for k=1:length(transition1Array)
            switch class(transition1Array{k})
            case 'char'

                matched=isempty(transition2Array{k});
            case 'learning.stateflow.State'



                if~isequal(class(transition2Array{k}),'learning.stateflow.State')
                    matched=false;
                    continue;
                end

                matched=matched&&isequal(transition1Array{k}.Name,transition2Array{k}.Name)&&...
                isequal(transition1Array{k}.LabelString,transition2Array{k}.LabelString);


                for j=1:length(transition1Array{k}.Entry)
                    matched=matched&&isInArray(transition1Array{k}.Entry{j},...
                    transition2Array{k}.Entry);
                end
                for j=1:length(transition1Array{k}.During)
                    matched=matched&&isInArray(transition1Array{k}.During{j},...
                    transition2Array{k}.During);
                end
                for j=1:length(transition1Array{k}.Exit)
                    matched=matched&&isInArray(transition1Array{k}.Exit{j},...
                    transition2Array{k}.Exit);
                end


                for j=1:length(transition1Array{k}.Inputs)
                    matched=matched&&isInArray(transition1Array{k}.Inputs{j},...
                    transition2Array{k}.Inputs);
                end

                for j=1:length(transition1Array{k}.Outputs)
                    matched=matched&&isInArray(transition1Array{k}.Outputs{j},...
                    transition2Array{k}.Outputs);
                end
            case 'learning.stateflow.Junction'



                if~isequal(class(transition2Array{k}),'learning.stateflow.Junction')
                    matched=false;
                    continue;
                end


                for j=1:length(transition1Array{k}.Inputs)
                    matched=matched&&isInArray(transition1Array{k}.Inputs{j},...
                    transition2Array{k}.Inputs);
                end

                for j=1:length(transition1Array{k}.Outputs)
                    matched=matched&&isInArray(transition1Array{k}.Outputs{j},...
                    transition2Array{k}.Outputs);
                end
            end
        end
    end

    function conditionsMatch=conditionsMatch(labelString1,labelString2,model1,model2)
        if isempty(labelString2)



            conditionsMatch=0;
            return;
        elseif~any(numel(model1.SymbolData))&&~any(numel(model2.SymbolData))



            [transitionConditions1,transitionActions1]=learning.stateflow.StateflowConverter.splitTransitionString(labelString1);
            [transitionConditions2,transitionActions2]=learning.stateflow.StateflowConverter.splitTransitionString(labelString2);



            conditionsMatch=isequal(transitionConditions1,transitionConditions2)&&...
            isequal(numel(transitionActions1),numel(transitionActions2));
            if~isempty(transitionActions1)&&conditionsMatch



                for j=1:length(transitionActions1)
                    conditionsMatch=conditionsMatch&&isInArray(transitionActions1{j},transitionActions2);
                end
            end
            return;
        end


        evalArray=[-1,0,1,-10,100];



        for j=1:numel(model1.SymbolData)


            assignin('base',model1.SymbolData(j).Name,evalArray);
        end


        model1Eval={};
        model2Eval={};






        [transitionConditions1,transitionActions1]=learning.stateflow.StateflowConverter.splitTransitionString(labelString1);

        if~isempty(transitionConditions1)
            model1Eval=cell(1,length(transitionConditions1));

            for j=1:length(transitionConditions1)
                if isempty(transitionConditions1{j})
                    model1Eval{j}='';
                else
                    assignin('base','model1Eval',transitionConditions1{j});
                    model1Eval{j}=evalin('base','eval(model1Eval)');
                end
            end

            evalin('base','clear model1Eval');
        end
        evalin('base',['clear',sprintf(' %s',model1.SymbolData(:).Name)]);



        if isempty(model2.SymbolData)



            conditionsMatch=0;
            return;
        else
            for j=1:numel(model2.SymbolData)
                assignin('base',model2.SymbolData(j).Name,evalArray);
            end
        end

        [transitionConditions2,transitionActions2]=learning.stateflow.StateflowConverter.splitTransitionString(labelString2);
        if~isempty(transitionConditions2)
            model2Eval=cell(1,length(transitionConditions2));

            for j=1:length(transitionConditions2)
                if isempty(transitionConditions2{j})
                    model2Eval{j}='';
                else
                    assignin('base','model2Eval',transitionConditions2{j});
                    try



                        model2Eval{j}=evalin('base','eval(model2Eval)');
                    catch
                        model2Eval{j}=NaN;
                    end
                end
            end


            evalin('base','clear model2Eval');
        end
        evalin('base',['clear',sprintf(' %s',model2.SymbolData(:).Name)]);



        conditionsMatch=isequal(model1Eval,model2Eval)&&...
        isequal(numel(transitionActions1),numel(transitionActions2));
        if~isempty(transitionActions1)&&conditionsMatch



            for j=1:length(transitionActions1)
                conditionsMatch=conditionsMatch&&isInArray(transitionActions1{j},transitionActions2);
            end
        end
    end

    function criteriaViolated=verifyGraphicalFcns(model1,model2)
        criteriaViolated=false;

        if isempty(model1.GraphicalFunctions)&&isempty(model2.GraphicalFunctions)
            return
        end

        if~isequal(numel(model1.GraphicalFunctions),numel(model2.GraphicalFunctions))
            criteriaViolated=true;
            return
        end

        for j=1:numel(model1.GraphicalFunctions)

            idx=[];
            for k=1:numel(model2.GraphicalFunctions)

                if isequal(model1.GraphicalFunctions(j).Name,model2.GraphicalFunctions(k).Name)
                    idx=k;
                end
            end
            if isempty(idx)

                criteriaViolated=true;
                return
            end
            for k=1:numel(model1.GraphicalFunctions(j).Inputs)


                if~isInArray(model1.GraphicalFunctions(j).Inputs{k},model2.GraphicalFunctions(idx).Inputs)
                    criteriaViolated=true;
                    return
                end
            end
            for k=1:numel(model1.GraphicalFunctions(j).Outputs)


                if~isInArray(model1.GraphicalFunctions(j).Outputs{k},model2.GraphicalFunctions(idx).Outputs)
                    criteriaViolated=true;
                    return
                end
            end
        end
    end

    function criteriaViolated=verifyMLFcns(model1,model2)
        criteriaViolated=false;

        if isempty(model1.MATLABFunctions)&&isempty(model2.MATLABFunctions)
            return
        end

        if~isequal(numel(model1.MATLABFunctions),numel(model2.MATLABFunctions))
            criteriaViolated=true;
            return
        end

        for j=1:numel(model1.MATLABFunctions)

            idx=[];
            for k=1:numel(model2.MATLABFunctions)

                if isequal(model1.MATLABFunctions(j).Name,model2.MATLABFunctions(k).Name)
                    idx=k;
                end
            end
            if isempty(idx)

                criteriaViolated=true;
                return
            end
            for k=1:numel(model1.MATLABFunctions(j).Inputs)


                if~isInArray(model1.MATLABFunctions(j).Inputs{k},model2.MATLABFunctions(idx).Inputs)
                    criteriaViolated=true;
                    return
                end
            end
            for k=1:numel(model1.MATLABFunctions(j).Outputs)


                if~isInArray(model1.MATLABFunctions(j).Outputs{k},model2.MATLABFunctions(idx).Outputs)
                    criteriaViolated=true;
                    return
                end
            end



            if isempty(model1.MATLABFunctions(j).Function)||isempty(model2.MATLABFunctions(idx).Function)
                if isempty(model1.MATLABFunctions(j).Function)&&isempty(model2.MATLABFunctions(idx).Function)


                    return
                else
                    criteriaViolated=true;
                    return
                end
            end



            evalArray=[-1,0,1,-10,100];



            for k=1:numel(model1.MATLABFunctions(j).Inputs)


                assignin('base',model1.MATLABFunctions(j).Inputs{k},evalArray);
            end


            evalin('base',model1.MATLABFunctions(j).Function)

            model1OutputVars=cell(1,length(model1.MATLABFunctions(j).Outputs));
            model1OutputValues=cell(1,length(model1.MATLABFunctions(j).Outputs));
            for k=1:length(model1.MATLABFunctions(j).Outputs)
                model1OutputVars{k}=model1.MATLABFunctions(j).Outputs{k};
                model1OutputValues{k}=evalin('base',model1.MATLABFunctions(j).Outputs{k});
            end
            structArgs=[model1OutputVars;model1OutputValues];
            model1OutputStruc=struct(structArgs{:});



            evalin('base','clear all');


            for k=1:numel(model2.MATLABFunctions(idx).Inputs)
                assignin('base',model2.MATLABFunctions(idx).Inputs{k},evalArray);
            end


            evalin('base',model2.MATLABFunctions(idx).Function)

            model2OutputVars=cell(1,length(model2.MATLABFunctions(idx).Outputs));
            model2OutputValues=cell(1,length(model2.MATLABFunctions(idx).Outputs));
            for k=1:length(model2.MATLABFunctions(idx).Outputs)
                model2OutputVars{k}=model2.MATLABFunctions(idx).Outputs{k};
                model2OutputValues{k}=evalin('base',model2.MATLABFunctions(idx).Outputs{k});
            end
            structArgs=[model2OutputVars;model2OutputValues];
            model2OutputStruc=struct(structArgs{:});



            evalin('base','clear all');


            model1Fieldnames=fieldnames(model1OutputStruc);
            for k=1:length(model1Fieldnames)
                model1Val=model1OutputStruc.(model1Fieldnames{k});
                model2Val=model2OutputStruc.(model1Fieldnames{k});
                if~isequal(model1Val,model2Val)
                    criteriaViolated=true;
                    return
                end
            end
        end
    end
end

function isInArray=isInArray(input,searchArray)

    isInArray=false;
    for i=1:length(searchArray)
        if isequal(input,searchArray{i})
            isInArray=true;
            break;
        end
    end
end
