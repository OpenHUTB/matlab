function isChild=isChildNode(h,obj,parent)





    children=parent.getHierarchicalChildren;
    isChild=false;
    if ismember(obj,children)||isequal(obj,parent)
        isChild=true;
    else
        for i=1:length(children)
            if isChildNode(h,obj,children(i))
                isChild=true;
                break;
            end
        end
    end

    function tf=ismember(obj,array)
        tf=false;
        for ii=1:length(array)
            if obj==array(ii)
                tf=true;
                return;
            end
        end
    end
end