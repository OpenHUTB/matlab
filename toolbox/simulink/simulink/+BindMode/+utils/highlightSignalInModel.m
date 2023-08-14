

function highlightSignalInModel(model,blockHandle,portNum)
    lineHandle=utils.getLineHandle(blockHandle,portNum);
    if lineHandle~=-1
        segHandles=lineHandle;
        processed=[];
        while(~isempty(segHandles))
            currentSegment=segHandles(1);
            children=get_param(currentSegment,'LineChildren');
            processed(end+1)=currentSegment;
            segHandles(1)=[];
            for idx=1:numel(children)




                if(ismember(children(idx),processed))
                    children(idx)=-1;
                end
            end
            children=children(children~=-1);
            segHandles=[segHandles,children'];%#ok<AGROW>
        end

        modelHandle=get_param(model,'Handle');
        if ishandle(modelHandle)
            studios=BindMode.utils.getAllStudiosForModel(modelHandle);
            for idx=1:numel(studios)
                if(~isempty(studios(idx).App))
                    for i=1:numel(processed)
                        studios(idx).App.hiliteAndFadeObject(diagram.resolver.resolve(processed(i)),1000);
                    end
                end
            end
        end
    end
end