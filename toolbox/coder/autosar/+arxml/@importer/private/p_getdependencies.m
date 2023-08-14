function dependencies=p_getdependencies(this)




    if isempty(this.dependencies)
        dependencies=[];

    else
        nbDep=numel(this.dependencies);

        if nbDep==1
            dependencies={this.dependencies(1).filename};

        else
            dependencies=cell(nbDep,1);
            for ii=1:nbDep
                dependencies{ii,1}=this.dependencies(ii).filename;
            end
        end
    end
