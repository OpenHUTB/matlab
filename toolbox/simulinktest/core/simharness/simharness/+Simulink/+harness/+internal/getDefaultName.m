function defaultName=getDefaultName(mdlName,component,currentName)

    if~exist('currentName','var')
        currentName='';
    end

    origMdlName=mdlName;
    if length(mdlName)>47
        mdlName=mdlName(1:47);
    end

    id=1;
    while id>=1
        defaultName=[mdlName,'_Harness',num2str(id)];


        if strcmp(defaultName,currentName)
            break;
        end

        defaultName=Simulink.harness.internal.getUniqueName(origMdlName,defaultName);


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
