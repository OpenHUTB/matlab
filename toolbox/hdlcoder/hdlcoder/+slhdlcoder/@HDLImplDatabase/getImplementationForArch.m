function implementationClass=getImplementationForArch(this,blockLibPath,archName)


    found=[];
    implementationClass=[];

    descriptions=this.getDescriptionsFromBlock(blockLibPath);
    if~isempty(descriptions)
        for ii=1:length(descriptions)
            current=descriptions{ii};
            matched=strcmpi(archName,current.ArchitectureNames);
            if any(matched)
                found=current;
                break;
            end
        end
        if~isempty(found)
            implementationClass=found.ClassName;
        elseif(this.isAbstractBaseClass(archName))


            implementationClass=archName;
        end
    end

