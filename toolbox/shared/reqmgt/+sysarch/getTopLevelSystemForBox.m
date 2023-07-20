function sys=getTopLevelSystemForBox(box)
    if isa(box,'sysarch.syntax.architecture.System')
        if~isempty(box.parent)
            sys=sysarch.getTopLevelSystemForBox(box.parent);
        else
            sys=box;
        end
    else
        sys=box.parent;
        if~isempty(sys)&&~isempty(sys.parent)

            sys=sysarch.getTopLevelSystemForBox(sys.parent);
        end
    end
end

