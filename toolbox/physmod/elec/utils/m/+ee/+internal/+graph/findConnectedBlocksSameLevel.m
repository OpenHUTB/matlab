function blockList=findConnectedBlocksSameLevel(block,portType)








    temp=struct2cell(get_param(block,'PortConnectivity'));
    blockHandleList=[];
    for idx=1:size(temp,2)
        if exist('portType','var')
            if strcmp(portType,temp{1,idx})
                blockHandleList=[blockHandleList,temp{5,idx}];
            end
        elseif~isempty([strfind(temp{1,idx},'RConn'),strfind(temp{1,idx},'LConn')])
            blockHandleList=[blockHandleList,temp{5,idx}];
        end
    end


    blockList={};
    for idx=1:numel(blockHandleList)
        h=blockHandleList(idx);
        blockList{idx}=getfullname(h);
    end
    blockList=unique(blockList);


    idxFind=find(ismember(blockList,{block}));
    if~isempty(idxFind)
        blockList(idxFind)=[];
    end

    blockList=blockList';
end