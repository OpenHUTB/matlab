function networkBlocks=utilSimscapeNetworkGraph(block,networkBlocks)




    if~strcmp(get_param(block,'BlockType'),'SimscapeBlock')

        if strcmp(get_param(block,'BlockType'),'PMIOPort')

            if~any(cellfun(@(x)isequal(x,block),networkBlocks))

                networkBlocks{end+1}=block;
            end

        elseif strcmp(get_param(block,'BlockType'),'ConnectionLabel')

            if~any(cellfun(@(x)isequal(x,block),networkBlocks))

                networkBlocks{end+1}=block;
            end

        elseif strcmp(get_param(block,'BlockType'),'SubSystem')&&isempty(get_param(block,'ReferenceBlock'))

            if~any(cellfun(@(x)isequal(x,block),networkBlocks))

                networkBlocks{end+1}=block;
            end

        elseif strcmp(get_param(block,'BlockType'),'Outport')||strcmp(get_param(block,'BlockType'),'Inport')

            connectedBlockInfo=get_param(block,'PortConnectivity');

            for i=1:numel(connectedBlockInfo)

                destBlocks=num2cell(connectedBlockInfo(i).DstBlock);

                for j=1:numel(destBlocks)

                    if~any(cellfun(@(x)isequal(x,destBlocks{j}),networkBlocks))

                        networkBlocks{end+1}=destBlocks{j};%#ok<*AGROW>
                        networkBlocks=utilSimscapeNetworkGraph(destBlocks{j},networkBlocks);
                    end
                end
            end

        elseif strcmp(get_param(block,'SubClassName'),'ps_output')||strcmp(get_param(block,'SubClassName'),'ps_input')

            if~any(cellfun(@(x)isequal(x,block),networkBlocks))

                networkBlocks{end+1}=block;
            end

        elseif strcmp(get_param(block,'SubClassName'),'solver')

            connectedBlockInfo=get_param(block,'PortConnectivity');
            destBlocks=num2cell(connectedBlockInfo.DstBlock);

            for k=1:numel(destBlocks)

                if~any(cellfun(@(x)isequal(x,destBlocks{k}),networkBlocks))

                    networkBlocks{end+1}=destBlocks{k};
                    networkBlocks=utilSimscapeNetworkGraph(destBlocks{k},networkBlocks);
                end
            end
        end

    else
        connectedBlockInfo=get_param(block,'PortConnectivity');

        for i=1:numel(connectedBlockInfo)

            destBlocks=num2cell(connectedBlockInfo(i).DstBlock);

            for j=1:numel(destBlocks)

                if~any(cellfun(@(x)isequal(x,destBlocks{j}),networkBlocks))

                    networkBlocks{end+1}=destBlocks{j};
                    networkBlocks=utilSimscapeNetworkGraph(destBlocks{j},networkBlocks);
                end
            end
        end
    end
end



