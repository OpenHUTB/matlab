function par=getParent(obj)













    par=[];

    if isa(obj,'Stateflow.Object')
        par=up(obj);
        if isa(par,'Simulink.SubSystem')


            par=get(par,'Parent');
        elseif isa(par,'Simulink.Object')
            par=par.getFullName;
        elseif isa(par,'Stateflow.Object')

            par=obj.Path;
        end
    elseif isa(obj,'Simulink.BlockDiagram')||isa(obj,'Stateflow.Root')||isa(obj,'Simulink.Root')
        par=[];
    elseif ischar(obj)||isstring(obj)
        par=get_param(obj,'Parent');
    elseif ishandle(obj)
        obj=slreportgen.utils.getSlSfObject(obj);
        objPath=string(obj.Path);
        objName=string(obj.Name);
        if(objPath==objName)

            diagFullPath=regexprep(objPath,"\s"," ");
        else
            diagFullPath=slreportgen.utils.pathJoin(objPath,objName);
        end

        try
            par=get_param(diagFullPath,"Parent");
        catch
            par=obj.Path;
        end
    end
