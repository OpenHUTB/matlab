function convertToParam(name,object)




    owner=getParent(object);
    parent=getParent(owner);
    if isa(parent,"DAStudio.DAObjectProxy")
        parent=parent.getMCOSObjectReference;
    end

    try

        className=Simulink.data.getDefaultClassname('Parameter');
        obj=feval(className);


        if isa(parent,'Simulink.Root')
            obj.Value=evalin('base',name);
            assignin('base',name,obj);
        elseif isa(parent,'Simulink.BlockDiagram')
            hWS=parent.ModelWorkspace;
            previousFlag=hWS.valueSourceErrorCheckingInCommandLineAPI;




            if slfeature('MWSValueSource')>1
                vm=get_param(hWS.ownerName,'ValueManager');
                vm.backupParameterGroupMembership(name);
                hWS.valueSourceErrorCheckingInCommandLineAPI=false;
            end
            obj.Value=slprivate('modelWorkspaceGetVariableHelper',hWS,name);
            assignin(hWS,name,obj);
            if slfeature('MWSValueSource')>1
                vm.restoreParameterGroupMembership(name);
                hWS.valueSourceErrorCheckingInCommandLineAPI=previousFlag;
            end
        else
            assert(isa(owner,'Simulink.DataDictionaryScopeNode'));
            assert(isa(parent,'Simulink.DataDictionaryRootNode'));
            ddFileSpec=parent.getConnection.filespec;
            dd=Simulink.data.dictionary.open(ddFileSpec);
            section=getSection(dd,getSectionName(owner));
            entry=getEntry(section,name,'DataSource',getSourceName(object));
            obj.Value=getValue(entry);
            setValue(entry,obj);
        end
    catch me
        errordlg(me.message);
        me.throw();
    end


