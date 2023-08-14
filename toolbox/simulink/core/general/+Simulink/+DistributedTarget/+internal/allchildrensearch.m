function[path]=allchildrensearch(handle,obj)




    path=loc_all(handle,obj);
end

function[path]=loc_all(handle,obj)
    path={};
    if handle==obj
        path={handle};
    else
        if ismethod(handle,'children')
            children=handle.children();
            for i=1:length(children)
                temppath=loc_all(children(i),obj);
                if~isempty(temppath)
                    path=[{handle},temppath];
                end
            end
        end
    end
end

