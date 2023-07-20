function update(this,event)






    methodName=mfilename;
    pmsl_superclassmethod(this,class(this),methodName,event);


    bd=this.getBlockDiagram;
    clients=this.getClientClasses;

    for idx=1:length(clients)
        if any(strcmp(methodName,methods(clients{idx})))
            eval([clients{idx},'.',methodName,'( event , bd );']);
        end

    end



