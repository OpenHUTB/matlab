function[output]=allchildren(handle,testFcn)




    output=loc_all(handle,testFcn);
end

function[output]=loc_all(handle,testFcn)
    if testFcn(handle)
        output={handle};
    else
        output={};
    end
    if ismethod(handle,'children')
        children=handle.children();
        for i=1:length(children)
            output=[output,loc_all(children(i),testFcn)];%#ok
        end
    end
end

