function modelClearAll(obj,silent)



    ok=true;
    if ischar(obj)
        [~,obj,~]=rmi.resolveobj(obj);
    elseif length(obj)>1
        ok=false;
    end
    if ok
        model=rmisl.getmodelh(obj);
        if model~=obj
            ok=false;
        end
    end
    if~ok
        errordlg(...
        getString(message('Slvnv:rmi:clearAll:OptionDeepOnlyForModels')),...
        getString(message('Slvnv:rmi:clearAll:RequirementsClearAll')),'modal');
        return;
    end

    objs=rmisl.getObjWithReqs(model);
    if isempty(objs)
        return;
    end

    if nargin<2
        silent=false;
    end

    if silent

        isLibrary=strcmpi(get_param(model,'BlockDiagramType'),'library');
        if isLibrary
            wasLocked=strcmp(get_param(model,'lock'),'on');
            if wasLocked
                set_param(model,'lock','off');
            end
        end
    end

    rmi.clearAll(objs,silent);


    if silent&&isLibrary&&wasLocked
        set_param(model,'lock','on');
    end
end
