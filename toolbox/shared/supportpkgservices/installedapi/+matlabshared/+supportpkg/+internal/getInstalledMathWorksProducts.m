function out=getInstalledMathWorksProducts(root)

    out=[];
    if isempty(root)
        return;
    end

    out=matlab.internal.getInstalledMathWorksProducts(root);
end
