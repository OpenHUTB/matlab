function out=intraLinkMenus(in)







    persistent currentSelection;

    if ischar(in)&&strcmp(in,'get')
        if~isempty(currentSelection)&&isStillValidSelection()
            out=currentSelection;
        else
            out=[];
        end

    elseif iscell(in)
        if~isempty(currentSelection)
            currentSelection=[];
            action_highlight('clear');
        end
        for j=1:length(in)
            inH=in{j};
            updateSelectionHighlighting(inH,'reqHere');
            currentSelection=[currentSelection,inH];%#ok<AGROW>
        end
        out=length(in);

    else
        object=in;
        out{1}={@intraLinkStartSchema,{object}};
        out{2}={@intraLinkCreateSchema,{object}};
    end



    function schema=intraLinkStartSchema(callbackInfo)
        obj=callbackInfo.userdata{1};
        objH=objectsToHandles(obj);
        schema=DAStudio.ActionSchema;
        schema.label=getString(message('Slvnv:rmisl:menus_rmi_object:SelectForLinkingSimulink'));
        schema.tag='Simulink:IntraLink:start';
        schema.userdata=[{objH},'start'];
        schema.callback=@intraLink_callback;
        schema.autoDisableWhen='Busy';
    end

    function schema=intraLinkCreateSchema(callbackInfo)
        obj=callbackInfo.userdata{1};
        objH=objectsToHandles(obj);
        schema=DAStudio.ActionSchema;
        if isempty(currentSelection)||~isStillValidSelection()
            schema.label=getString(message('Slvnv:rmisl:menus_rmi_object:AddLinkToObjects'));
            schema.state='Disabled';
        elseif length(currentSelection)==1
            schema.label=getString(message('Slvnv:rmisl:menus_rmi_object:AddLinkToObject'));
        else
            objCntStr=num2str(length(currentSelection));
            schema.label=getString(message('Slvnv:rmisl:menus_rmi_object:AddLinkToNObjects',objCntStr));
        end
        schema.tag='Simulink:IntraLink:create';
        schema.userdata=[{objH},'create'];
        schema.callback=@intraLink_callback;
        schema.autoDisableWhen='Busy';
    end

    function tf=isStillValidSelection()
        try
            for i=1:length(currentSelection)
                [isSf,objH]=rmi.resolveobj(currentSelection(i));
                if isSf
                    sfRoot=Stateflow.Root;
                    objFromID=Simulink.ID.getSID(sfRoot.idToHandle(objH));
                elseif rmifa.isFaultInfoObj(objH)
                    objFromID=objH;
                else
                    objFromID=Simulink.ID.getSID(objH);
                end
                if isempty(objFromID)
                    tf=false;
                    return;
                end
            end
            tf=true;
        catch ME %#ok<NASGU>
            tf=false;
        end
    end

    function handles=objectsToHandles(objects)
        totalObjects=length(objects);
        handles=zeros(1,totalObjects);
        for i=1:totalObjects
            obj=objects(i);
            type=strtok(class(obj),'.');
            switch type
            case 'Simulink'
                handles(i)=obj.Handle;
            case 'Stateflow'
                handles(i)=obj.Id;
            case 'double'
                handles(i)=obj;


            case 'sl'








                if(sysarch.isSysArchObject(obj))
                    handles(i)=-1;
                end
            otherwise
                error(message('Slvnv:reqmgt:rmi:InvalidObject',type));
            end
        end
    end

    function intraLink_callback(callbackInfo)
        if~license_checkout_slvnv()
            return;
        end

        obj=callbackInfo.userdata{1};
        action=callbackInfo.userdata{2};
        switch action
        case 'start'
            if~isempty(currentSelection)
                action_highlight('clear');
                currentSelection=[];
            end
            if isempty(get_param(rmisl.getmodelh(obj(1)),'FileName'))
                errordlg(...
                getString(message('Slvnv:rmisl:menus_rmi_deprecated:NeedToSave')),...
                getString(message('Slvnv:rmisl:menus_rmi_deprecated:UnsavedModel')));
                return;
            end
            for i=1:length(obj)
                objH=obj(i);
                if~rmifa.isFaultInfoObj(objH)
                    updateSelectionHighlighting(objH,'reqHere');
                end
                currentSelection=[currentSelection,objH];%#ok<AGROW>
            end
        case 'create'
            action_highlight('clear');
            if rmi.settings_mgr('get','linkSettings','twoWayLink')...
                &&~isempty(get_param(rmisl.getmodelh(obj(1)),'FileName'))
                ok=rmisl.intraLink(currentSelection,obj);
            else
                ok=true;
            end
            if ok
                rmisl.intraLink(obj,currentSelection);
                rmiut.hiliteAndFade(obj);
            end
            currentSelection=[];
        otherwise
            disp(['ERROR: Action ''',action,''' not supported']);
        end
    end

    function updateSelectionHighlighting(objH,slMode)
        if ceil(objH)==objH
            action_highlight_sf('req',objH);
            isSf=true;
        else
            action_highlight(slMode,objH);
            isSf=false;
        end

        [rootBD,obj]=getRootBd(objH,isSf);
        if~isempty(Simulink.harness.find(rootBD,'OpenOnly','on'))
            harnessObjH=getHarnessObjHandle(obj,isSf);
            if~isempty(harnessObjH)
                if isSf
                    action_highlight_sf('req',harnessObjH);
                else
                    action_highlight(slMode,harnessObjH);
                end
            end
        end
    end

    function[rootBD,obj]=getRootBd(objH,isSf)
        obj=rmisl.getObject(objH,isSf);
        rootBD=strtok(obj.Path,'/');
    end

    function harnessObj=getHarnessObjHandle(ownerObj,isSf)
        harnessObj=Simulink.harness.internal.sidmap.getOwnerObjectSIDInHarness(ownerObj);
        if~isempty(harnessObj)
            harnessObj=Simulink.ID.getHandle(harnessObj);
            if isSf
                harnessObj=harnessObj.Id;
            end
        end
    end

end

function success=license_checkout_slvnv()
    invalid=builtin('_license_checkout','Simulink_Requirements','quiet');
    success=~invalid;
    if invalid
        rmi.licenseErrorDlg();
    end
end

