function varargout=dbg_block_fcn(fcn,block)

    if nargout>0
        varargout=feval(fcn,block);
    else
        feval(fcn,block);
    end


    function OpenFcn(block)%#ok<*DEFNU>

        modelname=bdroot(block);
        sim_status=get_param(modelname,'SimulationStatus');


        if~strcmpi(sim_status,'Running')&&~strcmpi(sim_status,'Paused')&&...
            ~strcmpi(sim_status,'Paused-in-debugger')
            open_system(block,'Mask');
            return;
        end


        dastudio_root=DAStudio.ToolRoot;
        open_dialogs=dastudio_root.getOpenDialogs();

        expected_dialog_tag=['simevents_debugger_dialog_',modelname];
        found=false;

        for idx=1:length(open_dialogs)
            if strcmp(open_dialogs(idx).dialogTag,expected_dialog_tag)
                found=true;
                open_dialogs(idx).show();
                break;
            end
        end


        if~found
            dbg_obj=get_param(block,'UserData');
            if~isempty(dbg_obj)&&isa(dbg_obj,'simevents.Debugger')
                DAStudio.Dialog(dbg_obj);
            end
        end


        function is=IsActive(block)



            is={strcmp(get_param(block,'EnableDebugger'),'on')&&...
            ~bdIsLibrary(bdroot(block))};


            function InitFcn(block)

                en=get_param(block,'EnableDebugger');
                if strcmpi(en,'on')
                    dbg_obj=simevents.Debugger(bdroot(block));
                    set_param(block,'UserData',dbg_obj);
                end


                function StopFcn(block)

                    ud=get_param(block,'UserData');
                    if~isempty(ud)&&isa(ud,'simevents.Debugger')
                        delete(ud);
                        set_param(block,'UserData',[]);
                    end
