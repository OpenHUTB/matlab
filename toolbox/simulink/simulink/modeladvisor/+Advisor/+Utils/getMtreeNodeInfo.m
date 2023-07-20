function[strings,links,begin_indices,end_indices]=getMtreeNodeInfo(sfObject,subTree,bCreateLinks)














    if nargin<3
        bCreateLinks=true;
    end

    strings=subTree.strings;
    begin_indices=abs(position(subTree)-1);
    end_indices=endposition(subTree);

    links=strings;

    if~bCreateLinks
        return;
    end

    switch class(sfObject)
    case{'Stateflow.EMChart','Stateflow.EMFunction'}
        sid=Simulink.ID.getSID(sfObject);
    case 'char'
        sid=sfObject;
    otherwise
        sid='unknown';
    end
    links=arrayfun(@(a,b,c)getMALink(sid,a,b,c),strings',begin_indices,end_indices,'UniformOutput',false);
end


function link=getMALink(sid,name,iBegin,iEnd)









    tbl=ModelAdvisor.FormatTemplate('TableTemplate');
    link=tbl.formatEntry(sprintf('%s:%d-%d',sid,iBegin,iEnd));
    link.Content=name{1};
end

