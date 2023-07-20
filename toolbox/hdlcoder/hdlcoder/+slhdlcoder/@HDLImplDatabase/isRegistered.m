function found=isRegistered(this,slBlockPath,implementationName)








    found=0;

    if(canSupportAnyBlock(this,implementationName))
        found=1;
    else
        descriptions=this.getDescriptionsFromBlock(slBlockPath);
        if~isempty(descriptions)
            for ii=1:length(descriptions)
                current=descriptions{ii};
                found=strcmpi(implementationName,current.ArchitectureNames);
                if any(found)
                    found=1;
                    return;
                end
            end
        end
    end
end


function anyBlock=canSupportAnyBlock(this,implementationName)
    if strcmpi(implementationName,'default')
        anyBlock=1;
    else

        anyBlock=isAbstractBaseClass(this,implementationName);
    end
end
