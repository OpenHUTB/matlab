

function selectionRows=getSignalRowsInSelection(selectionHandles,varargin)




    if(nargin==2)
        onlyTestpointedSignals=varargin{1};
    else
        onlyTestpointedSignals=false;
    end
    blockHandles=[];
    portHandles=[];
    for idx=1:numel(selectionHandles)
        if(selectionHandles(idx)==0)
            continue;
        end
        type=get_param(selectionHandles(idx),'Type');
        if(strcmp(type,'port'))
            if(onlyTestpointedSignals)
                if(strcmp(get_param(selectionHandles(idx),'DataLogging'),'on')||...
                    strcmp(get_param(selectionHandles(idx),'Testpoint'),'on'))
                    portHandles(end+1)=selectionHandles(idx);
                end
            else
                portHandles(end+1)=selectionHandles(idx);
            end
        elseif(strcmp(type,'block'))
            blockHandles(end+1)=selectionHandles(idx);
        end
    end

    segHs=utils.getSignalsForSelectedBlocks(num2cell(blockHandles));
    segHs(segHs==-1)=[];
    portHs=arrayfun(@(x)get_param(x,'SrcPortHandle'),segHs);
    if(onlyTestpointedSignals)
        portHs=portHs(or(strcmp(get_param(portHs,'DataLogging'),'on'),...
        strcmp(get_param(portHs,'Testpoint'),'on')));
    end
    allPortHandles=union(portHandles,portHs);
    selectionRows=cell(1,numel(allPortHandles));
    for idx=1:numel(allPortHandles)
        connectStatus=false;
        bindableType=BindMode.BindableTypeEnum.SLSIGNAL;
        bindableName=get_param(allPortHandles(idx),'Name');
        sourceBlockPath=getfullname(get_param(get_param(allPortHandles(idx),'Parent'),'Handle'));
        outportNumber=get_param(allPortHandles(idx),'PortNumber');
        bindableMetaData=BindMode.SLSignalMetaData(bindableName,sourceBlockPath,outportNumber);
        selectionRows{idx}=BindMode.BindableRow(connectStatus,bindableType,bindableName,bindableMetaData);
    end
    selectionRows=selectionRows(~cellfun('isempty',selectionRows));
end