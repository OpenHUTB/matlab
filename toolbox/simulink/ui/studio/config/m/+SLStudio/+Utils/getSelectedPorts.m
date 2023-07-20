function ports=getSelectedPorts(cbinfo)





    selection=cbinfo.selection;
    ports=-1*ones(1,selection.size);

    for i=1:selection.size
        if(isa(selection.at(i),'SLM3I.Port'))
            ports(i)=selection.at(i).handle;
        end
    end

end
