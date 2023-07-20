function forwardingTable(obj)









    modelName=obj.modelName;
    verobj=obj.ver;

    if isR2011bOrEarlier(verobj)
        forwardingTableData=get_param(modelName,'ForwardingTable');
        if(~isempty(forwardingTableData))
            for i=size(forwardingTableData,2):-1:1
                eachEntry=forwardingTableData{1,i};
                if(length(eachEntry)~=2)
                    forwardingTableData(i)=[];
                end
            end
            set_param(modelName,'ForwardingTable',forwardingTableData);
        end
    end


