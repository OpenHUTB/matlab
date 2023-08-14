function[name,path,selected,state,msg]=harnessSystemSelectorState(cbinfo,action)

    selection=cbinfo.getSelection();
    pinnedSystem=cbinfo.studio.App.getPinnedSystem(action.name);

    if~isempty(pinnedSystem)
        if~ishandle(pinnedSystem)

            cbinfo.studio.App.erasePinnedSystem('systemSelectorTestHarnessManagerAction');
            pinnedSystem=[];
        else
            fullPath=pinnedSystem.getFullName;
            if startsWith(fullPath,'built-in')


                cbinfo.studio.App.erasePinnedSystem('systemSelectorTestHarnessManagerAction');
                pinnedSystem=[];
            end
        end
    end

    if isempty(pinnedSystem)
        selected=false;

        if size(selection)==1
            if(~isprop(selection,'name')||isempty(selection.name))...
                &&(~isprop(selection,'Name')||isempty(selection.Name))
                obj=cbinfo.uiObject;
            else
                obj=selection;
            end
        else
            obj=cbinfo.uiObject;
        end
    else

        assert(ishandle(pinnedSystem));
        selected=true;
        obj=pinnedSystem;
    end

    assert(~isempty(obj));

    name=strrep(obj.name,newline,' ');
    path=obj.getFullName;

    if isa(obj,'Simulink.BlockDiagram')







        if Simulink.harness.isHarnessBD(obj.Name)
            state='nonsupported';
            msg=getString(message('simulinktest:toolstrip:HarnessWithinHarnessNotSupported'));
        elseif bdIsLibrary(obj.Name)
            state='nonsupported';
            msg=getString(message('simulinktest:toolstrip:LibMdlNotSupported'));
        elseif~strcmp(obj.Name,cbinfo.model.Name)




            state='nonsupported';
            msg=getString(message('simulinktest:toolstrip:OpenRefAsTopForHarnessSupport'));
        else
            state='supported';
            msg='';
        end
    else

        strs=split(obj.getFullName,'/');
        mdlName=strs{1};









        if~Simulink.harness.internal.isValidHarnessOwnerObject(obj)
            state='nonsupported';
            msg=getString(message('simulinktest:toolstrip:SelectionNotSupported'));
        elseif Simulink.harness.isHarnessBD(mdlName)
            state='nonsupported';
            msg=getString(message('simulinktest:toolstrip:HarnessWithinHarnessNotSupported'));
        elseif Simulink.harness.internal.isMathWorksLibrary(get_param(mdlName,'Handle'))
            state='nonsupported';
            msg=getString(message('simulinktest:toolstrip:HarnessForTMWLibComponentNotSupported'));
        else
            state='supported';
            msg='';
        end
    end
