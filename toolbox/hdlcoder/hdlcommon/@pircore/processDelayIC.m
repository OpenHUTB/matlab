function[isReset,initValScalarExpandable,ic,preserveInitValDimensions]=processDelayIC(ic)


















    initValScalarExpandable=false;
    preserveInitValDimensions=false;
    if isempty(ic)
        isReset=true;
    else
        isReset=false;
        if all(ic(:)==ic(1))
            if numel(ic)>1
                preserveInitValDimensions=true;
            end
            ic=ic(1);
            if ic==0
                isReset=true;
            end
            initValScalarExpandable=true;
        end
    end
end
