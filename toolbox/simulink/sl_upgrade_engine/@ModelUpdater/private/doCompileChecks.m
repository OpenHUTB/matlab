function doCompileChecks(h)






%#ok<*NASGU>



    if isempty(h.CompileCheck)
        return;
    end


    h.clearAllCheckData();


    if h.CompileState==ModelUpdater.PRECOMPILE
        myCompile=true;
    else
        myCompile=false;
    end


    isLibrary=strcmp(get_param(h.MyModel,'BlockDiagramType'),'library');
    if isLibrary
        h.CompileState=ModelUpdater.NOT_COMPILABLE;
        myCompile=false;
    end


    if myCompile
        try
            mode=get_param(h.MyModel,'SimulationMode');
            if strcmp(mode,'accelerator')
                set_param(h.MyModel,'SimulationMode','normal');
                mess1=onCleanup(@()set_param(h.MyModel,'SimulationMode','accelerator'));
            end

            set_param(h.MyModel,'ModelUpgradeActive','on');
            mess2=onCleanup(@()set_param(h.MyModel,'ModelUpgradeActive','off'));

            feval(h.MyModel,[],[],[],'compile');
            h.CompileState=ModelUpdater.COMPILED;
        catch e
            h.CompileState=ModelUpdater.NOT_COMPILABLE;
        end
    end


    if h.CompileState==ModelUpdater.COMPILED
        for i=1:length(h.CompileCheck)
            check=h.CompileCheck(i);
            fH=check.dataCollectFH;
            if isa(fH,'function_handle')&&~isempty(fH)
                try
                    h.CompileCheck(i).data=fH(check.block,h);
                catch e
                    msgID='SimulinkUpgradeEngine:engine:problemUpdatingBlock';
                    msg=DAStudio.message(msgID,check.block);
                    appendTransaction(h,check.block,msg,{});

                    check.postCompileCheckFH=[];
                end
            end
        end
    end


    if myCompile&&h.CompileState==ModelUpdater.COMPILED
        try
            feval(h.MyModel,[],[],[],'term');
            h.CompileState=ModelUpdater.POSTCOMPILE;
        catch e
            assert(false);

        end
    end


    clear mess1 mess2;



    if(h.CompileState==ModelUpdater.NOT_COMPILABLE)

        if isLibrary
            NoCompileNoCheckMsg=DAStudio.message('SimulinkUpgradeEngine:engine:noCompileLibraryNoCheck',h.MyModel);
        else
            NoCompileNoCheckMsg=DAStudio.message('SimulinkUpgradeEngine:engine:noCompileNoCheck',h.MyModel);
        end
        for i=1:length(h.CompileCheck)
            check=h.CompileCheck(i);
            fH=check.fallbackFH;
            if isa(fH,'function_handle')&&~isempty(fH)
                try
                    fH(check.block,h);
                catch e
                    msgID='SimulinkUpgradeEngine:engine:problemUpdatingBlock';
                    msg=DAStudio.message(msgID,check.block);
                    appendTransaction(h,check.block,msg,{});
                end
            else
                appendTransaction(h,check.block,NoCompileNoCheckMsg,{});
            end
        end
    else

        for i=1:length(h.CompileCheck)
            check=h.CompileCheck(i);
            fH=check.postCompileCheckFH;
            try
                fH(check.block,h,check.data);
            catch e
                msgID='SimulinkUpgradeEngine:engine:problemUpdatingBlock';
                msg=DAStudio.message(msgID,check.block);
                appendTransaction(h,check.block,msg,{});
            end
        end
    end

end
