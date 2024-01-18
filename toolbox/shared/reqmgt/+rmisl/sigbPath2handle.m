function[blockHandle,groupIndex]=sigbPath2handle(pathName)

    blockHandle=-1;
    groupIndex=-1;


    tokens=regexp(pathName,'([^/]|(//)+)*','match');
    count=length(tokens);

    if count>=2

        blockName=tokens{1};
        for i=2:length(tokens)
            try
                testBlock=[blockName,'/',tokens{i}];
                get_param(testBlock,'Handle');
                blockName=testBlock;
            catch Mex %#ok<NASGU>

            end
        end
        groupName=pathName(length(blockName)+2:end);

        if rmisl.is_signal_builder_block(blockName)

            [~,~,~,grouplabels]=signalbuilder(blockName);
            index=find(strcmp(grouplabels(:),groupName));
            if~isempty(index)
                blockHandle=get_param(blockName,'handle');
                groupIndex=index;
            end
        end
    end
