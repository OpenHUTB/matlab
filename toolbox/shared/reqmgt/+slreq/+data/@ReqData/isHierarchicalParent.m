function tf=isHierarchicalParent(~,first,second)






    while true
        if isempty(second.parent)
            break;
        elseif second.parent==first
            tf=true;
            return;
        else
            second=second.parent;
        end
    end

    tf=false;
end
