function deleteHGWidgets(h)



    if isstruct(h)
        fn=fieldnames(h);
        for i=1:numel(fn)
            deleteHGWidgets(h.(fn{i}));
        end
    elseif iscell(h)
        for i=1:numel(h)
            if ishghandle(h{i})
                deleteHGWidgets(h{i});
            end
        end
    else
        for i=1:numel(h)
            if ishghandle(h(i))
                delete(h(i));
            end
        end
    end

end
