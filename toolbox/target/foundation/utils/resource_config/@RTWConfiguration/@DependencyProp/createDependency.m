function h=createDependency(this,propertyName)



    h=RTWConfiguration.Dependency(propertyName);
    i_addDependency(this,h);
    return;

    function i_addDependency(this,dependency)

        tempDependencies=this.Dependencies;
        if(isempty(tempDependencies))

            tempDependencies=[dependency];
        else
            tempDependencies(length(tempDependencies)+1)=dependency;
        end;
        this.Dependencies=tempDependencies;
        return;
