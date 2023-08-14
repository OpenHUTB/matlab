function line=getSingleSelectedLine(cbinfo)




    selection=cbinfo.selection;
    line={};
    if selection.size>0&&isa(selection.at(1),'SLM3I.Segment')
        line=selection.at(1).container;
        for iter=2:selection.size
            if~isa(selection.at(iter),'SLM3I.Segment')||selection.at(iter).container~=line
                line={};
                return
            end
        end
    end
end
