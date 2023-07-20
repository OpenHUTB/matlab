function version=getTargetVersion(targetName,product)



    if nargin<2
        product='';
    end

    version=1;
    if ischar(targetName)
        targets=codertarget.target.getRegisteredTargets(product);
        for i=1:numel(targets)
            if strcmp(targetName,targets(i).Name)
                version=targets(i).TargetVersion;
                break
            end
        end
    end
end
