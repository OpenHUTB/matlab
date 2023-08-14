function[stepCall,stepCode,stepCleanup]=sensitivitycodegenerator(step,model,steps,support)












    stepCode=readTemplate('runSensitivity.txt');


    stepCall='% Run simulation.';
    stepCall=appendCode(stepCall,'args = runSimulation(args);');


    [stepCode,stepCleanup]=SimBiology.web.commoncodegenerator('generateSimulationCode',stepCode,step,steps,model,support);


    stepCode=generateInputOutputCode(stepCode,step,model);


    stepCleanup{end+1}=readTemplate('restoreSensitivityAnalysis.txt');

end

function stepCode=generateInputOutputCode(stepCode,step,model)


    stepCode=strrep(stepCode,'$(NORMALIZATION)',step.normalization);


    outputList='outputs = [';
    outputPad='           ';
    firstOutput=true;

    inputList='inputs = [';
    inputPad='          ';
    firstInput=true;

    value=step.sensitivity;

    for i=1:length(value)
        if iscell(value)
            isInput=value{i}.input;
            isOutput=value{1}.output;
            sessionID=value{i}.sessionID;
        else
            isInput=value(i).input;
            isOutput=value(i).output;
            sessionID=value(i).sessionID;
        end


        obj=sbioselect(model,'SessionID',sessionID);
        if~isempty(obj)
            cmd=getObjectCommand(obj);
            cmd=['model.',cmd];%#ok<*AGROW>

            if isInput
                if firstInput
                    inputList=[inputList,cmd,',...',sprintf('\n')];%#ok<*SPRINTFN>
                else
                    inputList=[inputList,inputPad,cmd,',...',sprintf('\n')];
                end
                firstInput=false;
            end

            if isOutput
                if firstOutput
                    outputList=[outputList,cmd,',...',sprintf('\n')];
                else
                    outputList=[outputList,outputPad,cmd,',...',sprintf('\n')];
                end
                firstOutput=false;
            end
        end
    end


    if strcmp(inputList(end),sprintf('\n'))
        inputList=inputList(1:end-5);
    end
    inputList=[inputList,'];'];

    if strcmp(outputList(end),sprintf('\n'))
        outputList=outputList(1:end-5);
    end
    outputList=[outputList,'];'];

    stepCode=strrep(stepCode,'$(INPUT_VALUES)',inputList);
    stepCode=strrep(stepCode,'$(OUTPUT_VALUES)',outputList);

end

function content=readTemplate(name)

    content=SimBiology.web.codegenerationutil('readTemplate',name);

end

function out=getObjectCommand(state)

    out=SimBiology.web.codegenerationutil('getObjectCommand',state);

end

function code=appendCode(code,newCode)

    code=SimBiology.web.codegenerationutil('appendCode',code,newCode);

end
