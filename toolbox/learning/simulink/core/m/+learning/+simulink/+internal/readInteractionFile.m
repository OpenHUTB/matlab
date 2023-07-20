function interactionStruct=readInteractionFile(interactionFilePath)

    [~,interactionFileName,ext]=fileparts(interactionFilePath);
    regexPattern='^interaction\d+.json$';
    assert(logical(regexp([interactionFileName,ext],regexPattern)),'Invalid file passed');

    optionalParameters={'keepConnected','maskParameters','assessmentParams','tasksToKeep','hasGenericAssessments','additionalModels'};
    optionalParametersDefaultValues={true,[],[],[],false,{}};
    optionalParamsMap=containers.Map(optionalParameters,optionalParametersDefaultValues);

    interactionStruct=jsondecode(fileread(interactionFilePath));





    if iscell(interactionStruct.simulinkInteraction.questions)

        questionFieldCells=cellfun(@fieldnames,interactionStruct.simulinkInteraction.questions,'UniformOutput',false);
        questionFieldnames=unique(cat(1,questionFieldCells{:}));
        questions=interactionStruct.simulinkInteraction.questions;
        newQuestionStructArray(length(questions))=struct();

        for i=1:length(questions)

            for j=1:length(questionFieldnames)


                if~isfield(questions{i},questionFieldnames{j})
                    newQuestionStructArray(i).(questionFieldnames{j})=optionalParamsMap(questionFieldnames{j});
                else
                    newQuestionStructArray(i).(questionFieldnames{j})=questions{i}.(questionFieldnames{j});
                end
            end
        end
        interactionStruct.simulinkInteraction.questions=newQuestionStructArray;
    end
end

