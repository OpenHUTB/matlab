function usage=findPropertyUsage(this,requiredUsage)


    usage=[];

    if~isempty(this.specification)


        usage=this.specification.getPropertySet(requiredUsage.getName);
    end
end

