

classdef StateflowConverter



    methods(Static)

        function symbolData=getSymbolData(allData,dataPaths,chart)


            symbolData(1,length(allData))=learning.stateflow.SymbolData();
            for i=1:length(allData)
                symbolData(i).Name=allData(i).Name;
                symbolData(i).InitialValue=allData(i).Props.InitialValue;
                symbolData(i).Scope=allData(i).Scope;
                symbolData(i).Port=allData(i).Port;
                if isnan(symbolData(i).Port)
                    symbolData(i).Port='';
                end
                symbolData(i).Origin=getOrigin(dataPaths{i},chart);
            end
        end

        function[defaultTransitions,transitions]=getTransitions(allTransitions)





            defaultTransitions(1,length(allTransitions))=learning.stateflow.DefaultTransition();
            DTIdx=1;
            transitions(1,length(allTransitions))=learning.stateflow.Transition();
            TIdx=1;



            for i=1:length(allTransitions)
                isDefaultTransition=isempty(allTransitions(i).Source);
                if isDefaultTransition
                    defaultTransitions(DTIdx).LabelString=strrep(strrep(allTransitions(i).LabelString,' ',''),['...',newline],'');


                    commentIdx=strfind(defaultTransitions(DTIdx).LabelString,'%');
                    if~isempty(commentIdx)
                        newLineIdx=strfind(defaultTransitions(DTIdx).LabelString,newline);
                        if isempty(newLineIdx)&&isequal(commentIdx,1)



                            defaultTransitions(DTIdx).LabelString='';
                            commentIdx=[];
                        end
                        while~isempty(commentIdx)
                            newLineIdx=strfind(defaultTransitions(DTIdx).LabelString,newline);
                            afterFirstCommentIndex=newLineIdx>commentIdx(1);
                            newLineIdx=newLineIdx(afterFirstCommentIndex);
                            if isempty(newLineIdx)
                                defaultTransitions(DTIdx).LabelString(commentIdx:end)='';
                            else
                                newLineIdx=newLineIdx(1);
                                defaultTransitions(DTIdx).LabelString(commentIdx:newLineIdx)='';
                            end
                            commentIdx=strfind(defaultTransitions(DTIdx).LabelString,'%');
                        end
                    end

                    defaultTransitions(DTIdx).ExecutionOrder=allTransitions(i).ExecutionOrder;
                    defaultTransitions(DTIdx).Destination=allTransitions(i).Destination;
                    DTIdx=DTIdx+1;
                else
                    transitions(TIdx).LabelString=strrep(strrep(allTransitions(i).LabelString,' ',''),['...',newline],'');
                    transitions(TIdx).ExecutionOrder=allTransitions(i).ExecutionOrder;
                    transitions(TIdx).Source=allTransitions(i).Source;
                    transitions(TIdx).Destination=allTransitions(i).Destination;
                    TIdx=TIdx+1;
                end
            end




            import learning.stateflow.StateflowConverter;
            defaultTransitions=StateflowConverter.clearEmptyTransitions(defaultTransitions);
            transitions=StateflowConverter.clearEmptyTransitions(transitions);
        end

        function states=getStates(allStates,defaultTransitions,transitions)



            narginchk(3,3);
            states(1,length(allStates))=learning.stateflow.State();
            for i=1:length(allStates)

                states(i).Name=allStates(i).Name;
                states(i).LabelString=allStates(i).LabelString;




                for j=1:length(transitions)


                    if isequal('Stateflow.State',class(transitions(j).Source))&&...
                        isequal(allStates(i).Name,transitions(j).Source.Name)
                        states(i).Outputs=[states(i).Outputs,{transitions(j)}];
                    end
                    if isequal('Stateflow.State',class(transitions(j).Destination))&&...
                        isequal(allStates(i).Name,transitions(j).Destination.Name)
                        states(i).Inputs=[states(i).Inputs,{transitions(j)}];
                    end
                end
                for j=1:length(defaultTransitions)


                    if isequal('Stateflow.State',class(defaultTransitions(j).Destination))&&...
                        isequal(allStates(i).Name,defaultTransitions(j).Destination.Name)
                        states(i).Inputs=[states(i).Inputs,{defaultTransitions(j)}];
                    end
                end
            end
        end

        function junctions=getJunctions(allJunctions,defaultTransitions,transitions)



            narginchk(3,3);
            junctions(1,length(allJunctions))=learning.stateflow.Junction();



            for i=1:length(allJunctions)





                for j=1:length(transitions)


                    if isequal(allJunctions(i),transitions(j).Source)
                        junctions(i).Outputs=[junctions(i).Outputs,{transitions(j)}];
                    end


                    if isequal(allJunctions(i),transitions(j).Destination)
                        junctions(i).Inputs=[junctions(i).Inputs,{transitions(j)}];
                    end
                end

                for j=1:length(defaultTransitions)


                    if isequal(allJunctions(i),defaultTransitions(j).Destination)
                        junctions(i).Inputs=[junctions(i).Inputs,{defaultTransitions(j)}];
                    end
                end

            end
        end

        function cleanArray=clearEmptyTransitions(inputArray)





            idx=length(inputArray);
            import learning.stateflow.StateflowConverter;
            while idx>0&&StateflowConverter.isTransitionEmpty(inputArray(idx))



                inputArray(idx)=[];
                idx=idx-1;
            end
            if isempty(inputArray)


                cleanArray=[];
            else
                cleanArray=inputArray;
            end
        end

        function isTransitionEmpty=isTransitionEmpty(array)

            isTransitionEmpty=isempty(array.LabelString)&&isempty(array.ExecutionOrder)&&...
            isempty(array.Source)&&isempty(array.Destination);
        end

        function states=cleanStates(states)



            clearThis=['...',newline];

            for i=1:numel(states)

                stateActions=states(i).LabelString;
                while(isequal(stateActions(end),newline))
                    stateActions(end)=[];
                end


                if~isequal(stateActions(end),';')
                    stateActions=[stateActions,';'];
                end


                stateActions=[stateActions,newline];

                stateActions=strrep(stateActions,' ','');
                stateActions=strrep(stateActions,clearThis,'');
                stateActions=strrep(stateActions,states(i).Name,'');
                stateActions=stateActions(2:end);


                semiColIdx=strfind(stateActions,';');
                newlineIdx=strfind(stateActions,newline);

                startIdx=1;
                if~contains(stateActions,':')


                    defaultDuringIdx=[semiColIdx,newlineIdx];
                    defaultDuringIdx=sort(defaultDuringIdx);

                    for j=1:numel(defaultDuringIdx)



                        endIdx=defaultDuringIdx(j);

                        if j>1&&isequal(defaultDuringIdx(j),defaultDuringIdx(j-1)+1)



                            continue;
                        end




                        states(i).During{end+1}=stateActions(startIdx:endIdx-1);
                        states(i).Entry{end+1}=stateActions(startIdx:endIdx-1);
                        startIdx=endIdx+1;
                        if startIdx<length(stateActions)&&...
                            isequal(stateActions(startIdx),newline)




                            startIdx=startIdx+1;
                        end
                    end
                    continue;
                end

                colIdx=strfind(stateActions,':');
                if isempty(colIdx)



                    colIdx=length(stateActions);
                end

                defaultDuringIdx=[];
                if(~isempty(semiColIdx)&&semiColIdx(1)<colIdx(1))||...
                    (~isempty(newlineIdx)&&newlineIdx(1)<colIdx(1))






                    defaultDuringIdx=[newlineIdx(newlineIdx<colIdx(1)),semiColIdx(semiColIdx<colIdx(1))];
                    defaultDuringIdx=sort(defaultDuringIdx);

                    for j=1:numel(defaultDuringIdx)



                        endIdx=defaultDuringIdx(j);

                        if endIdx>colIdx(1)


                            break;
                        end

                        if j>1&&isequal(defaultDuringIdx(j),defaultDuringIdx(j-1)+1)



                            continue;
                        end




                        states(i).During{end+1}=stateActions(startIdx:endIdx-1);
                        states(i).Entry{end+1}=stateActions(startIdx:endIdx-1);
                        startIdx=endIdx+1;
                        if isequal(stateActions(startIdx),newline)




                            startIdx=startIdx+1;
                        end
                    end

                end

                if~isempty(defaultDuringIdx)


                    stateActions(1:defaultDuringIdx(end))=[];
                end




                colIdx=strfind(stateActions,':');
                if isempty(colIdx)
                    continue;
                end




                while~isempty(colIdx)
                    semiColIdx=strfind(stateActions,';');
                    newlineIdx=strfind(stateActions,newline);
                    startIdx=1;




                    finalIdx=length(stateActions);
                    if numel(colIdx)>1
                        finalIdx=colIdx(2);
                    end



                    currentStateLabelIdx=[newlineIdx(newlineIdx<=finalIdx),semiColIdx(semiColIdx<finalIdx)];
                    currentStateLabelIdx=sort(currentStateLabelIdx);
                    if isempty(newlineIdx)&&isempty(semiColIdx)
                        currentStateLabelIdx=length(stateActions);
                    end



                    switch lower(stateActions(startIdx:colIdx(1)-1))
                    case{'entry','en'}
                        startIdx=colIdx(1)+1;
                        for k=1:length(currentStateLabelIdx)
                            if startIdx>=length(stateActions)


                                break;
                            end
                            if isequal(stateActions(startIdx),newline)




                                startIdx=startIdx+1;
                                continue;
                            end
                            states(i).Entry{end+1}=stateActions(startIdx:currentStateLabelIdx(k)-1);
                            startIdx=currentStateLabelIdx(k)+1;
                        end

                    case{'during','du'}
                        startIdx=colIdx(1)+1;
                        for k=1:length(currentStateLabelIdx)
                            if isequal(currentStateLabelIdx(k),length(stateActions))


                                break;
                            end
                            if isequal(stateActions(startIdx),newline)




                                startIdx=startIdx+1;
                                continue;
                            end
                            states(i).During{end+1}=stateActions(startIdx:currentStateLabelIdx(k)-1);
                            startIdx=currentStateLabelIdx(k)+1;
                        end

                    case{'exit','ex'}
                        startIdx=colIdx(1)+1;
                        for k=1:length(currentStateLabelIdx)
                            if isequal(currentStateLabelIdx(k),length(stateActions))


                                break;
                            end
                            if isequal(stateActions(startIdx),newline)




                                startIdx=startIdx+1;
                                continue;
                            end
                            states(i).Exit{end+1}=stateActions(startIdx:currentStateLabelIdx(k)-1);
                            startIdx=currentStateLabelIdx(k)+1;
                        end
                    end

                    stateActions(1:currentStateLabelIdx(end))=[];
                    colIdx=strfind(stateActions,':');
                end
            end
        end

        function[transitionConditions,transitionActions]=splitTransitionString(labelString)
            transitionConditions={};
            transitionActions={};
            if isempty(labelString)
                return;
            end
            conditionString='';
            conditionStringIdx=[strfind(labelString,'['),strfind(labelString,']')];
            if~isempty(conditionStringIdx)
                conditionString=labelString(conditionStringIdx(1):conditionStringIdx(2));


                conditionString=strrep(conditionString,'&&','&');
                conditionString=strrep(conditionString,'||','|');
                labelString(conditionStringIdx(1):conditionStringIdx(2))=[];
            end

            if isempty(labelString)

                transitionConditions={conditionString};
                return;
            end
            labelString=strrep(labelString,'{','');
            labelString=strrep(labelString,'}','');


            labelString=strrep(labelString,['...',newline],newline);


            while(isequal(labelString(1),newline))
                labelString(1)=[];
            end


            if~isequal(labelString(end),';')

                labelString(end+1)=';';
            end
            newLineIdx=strfind(labelString,newline);
            if isempty(newLineIdx)&&numel(strfind(labelString,';'))==1

                if~isempty(conditionString)


                    transitionConditions={conditionString};
                end
                transitionActions={labelString};
                return;
            end

            for i=1:length(newLineIdx)


                if~isequal(labelString(newLineIdx(i)-1),';')
                    labelString=[labelString(1:newLineIdx(i)-1),';',labelString(newLineIdx(i):end)];
                    newLineIdx=strfind(labelString,newline);
                end
            end


            labelString=strrep(labelString,newline,'');


            colIdx=strfind(labelString,';');
            actionString=cell(1,length(colIdx));
            startIdx=1;
            for i=1:length(colIdx)
                actionString{i}=labelString(startIdx:colIdx(i));
                startIdx=colIdx(i)+1;
            end
            transitionConditions={conditionString};
            transitionActions=actionString;
        end

        function graphicalFunctions=getGraphicalFunctions(allGraphicalFunctions)


            graphicalFunctions(1,length(allGraphicalFunctions))=learning.stateflow.GraphicalFunction();
            for i=1:length(allGraphicalFunctions)
                graphicalFunctions(i).Name=allGraphicalFunctions(i).Name;

                [functionInputs,functionOutputs]=getVarsFromLabelString(allGraphicalFunctions(i).LabelString);
                graphicalFunctions(i).Outputs=functionOutputs;
                graphicalFunctions(i).Inputs=functionInputs;
            end
        end

        function MATLABFunctions=getMATLABFunctions(allMLFunctions)


            MATLABFunctions(1,length(allMLFunctions))=learning.stateflow.MATLABFunction();
            for i=1:length(allMLFunctions)
                MATLABFunctions(i).Name=allMLFunctions(i).Name;
                labelString=allMLFunctions(i).LabelString;
                [functionInputs,functionOutputs]=getVarsFromLabelString(allMLFunctions(i).labelString);
                MATLABFunctions(i).Outputs=functionOutputs;
                MATLABFunctions(i).Inputs=functionInputs;

                script=allMLFunctions(i).Script;


                pattern='(^|\n)function ';
                [startIdx,endIdx]=regexp(script,pattern);
                script=[script(1:startIdx-1),script(endIdx+1:end)];

                script=strrep(script,' ','');


                labelString=strrep(labelString,' ','');
                script=strrep(script,labelString,'');

                while(~isempty(script)&&contains(script,[newline,newline]))

                    script=strrep(script,[newline,newline],newline);
                end

                while(~isempty(script)&&isequal(script(1),newline))


                    script(1)=[];
                end

                pattern='end$';
                startIdx=regexp(script,pattern);
                if~isempty(startIdx)
                    script=script(1:startIdx-1);
                end

                MATLABFunctions(i).Function=script;
            end
        end
    end
end

function[inputs,outputs]=getVarsFromLabelString(labelString)

    functionCall=strrep(labelString,' ','');
    functionCall=strrep(functionCall,newline,'');
    functionCall=strrep(functionCall,'...','');

    outputs=strsplit(functionCall,'=');
    if isequal(numel(outputs),1)
        inputs=outputs{1};
        outputs=[];
    else
        inputs=outputs{2};
        outputs=outputs{1};
        outputs=strrep(outputs,'[','');
        outputs=strrep(outputs,']','');
        outputs=strsplit(outputs,',');
    end

    idx=[strfind(inputs,'('),strfind(inputs,')')];
    inputs=inputs(idx(1):idx(2));
    inputs=strrep(inputs,'(','');
    inputs=strrep(inputs,')','');
    inputs=strsplit(inputs,',');
end

function origin=getOrigin(dataPath,chart)


    if isequal(dataPath,chart.Path)
        origin='Chart';
        return
    end


    functionName=strrep(dataPath,chart.Path,'');
    functionName=strrep(functionName,'/','');
    currentFunction=chart.find('Name',functionName);
    if numel(currentFunction)>1
        for i=1:length(currentFunction)
            if isequal(currentFunction(i).Path,chart.Path)

                currentFunction=currentFunction(i);
                break
            end
        end
    end

    if isequal(class(currentFunction),'Stateflow.EMFunction')
        origin='MATLABFunction';
    elseif isequal(class(currentFunction),'Stateflow.Function')
        origin='GraphicalFunction';
    else
        origin=[];
    end
end