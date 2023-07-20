function defaultName=getDefaultCCName(mdlName,componentName,currentName)




    if~exist('currentName','var')
        currentName='';
    end

    if~ischar(componentName)
        componentName=get_param(componentName,'Name');
    end

    componentName=matlab.lang.makeValidName(componentName);

    if length(componentName)>40
        componentName=componentName(1:40);
    end

    id=1;
    while id>=1
        defaultName=[componentName,'_CodeSpecification',num2str(id)];

        if strcmp(defaultName,currentName)
            break;
        end

        defaultName=Simulink.harness.internal.getUniqueName(mdlName,defaultName);


        nameIsShadowing=false;
        if~isempty(which(defaultName))
            nameIsShadowing=true;
        end
        if(nameIsShadowing==false)
            break;
        end
        id=id+1;
    end
end
