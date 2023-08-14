function ports=getSrcPortsOfSelectedSegments(cbinfo)





    selection=cbinfo.selection;
    ports=-1*ones(1,selection.size);

    for i=1:selection.size
        if~isa(selection.at(i),'SLM3I.Segment')
            continue;
        end

        ports(i)=get_param(selection.at(i).handle,'SrcPortHandle');
    end

    ports=unique(ports);
    ports=ports(ports~=-1);
end
