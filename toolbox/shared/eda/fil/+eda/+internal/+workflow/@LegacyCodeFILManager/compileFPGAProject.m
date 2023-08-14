function compileFPGAProject(h)






    if h.BuildOpt.FinalProcess.Run


        h.mProjMgr.initialize;
        h.mProjMgr.openProject;

        runCmd=sprintf('run%s',h.BuildOpt.FinalProcess.Cmd);
        h.mProjMgr.(runCmd);

        genbit=strcmpi(h.BuildOpt.FinalProcess.Cmd,'BitGeneration');
        if genbit
            h.mProjMgr.getTimingResult('timing_err');
        end
        h.mProjMgr.closeProject;





        if genbit
            h.printBitGenSummary;
        end

        [buildErr,~]=h.mProjMgr.build('BlockingBuild',false,...
        'ProjectStatusDisplay','Off',...
        'TclScriptName','compileproject.tcl');

        if buildErr

        else
            procName=h.BuildOpt.FinalProcess.Name;
            l_dispAndLog(h,...
            sprintf('Running %s outside MATLAB.',procName),'\n%s');
            l_dispAndLog(h,...
            sprintf('Check external shell for %s progress.',procName),'%s');

            if strcmpi(h.BuildOpt.FinalProcess.Cmd,'BitGeneration')
                h.LogMsg=[h.LogMsg,dispFpgaMsg(...
                'Programming file location (when process is completed):')];
                h.LogMsg=[h.LogMsg,dispFpgaMsg(h.BitFile.FullPath,2)];
            end
        end
    end

    function l_dispAndLog(h,str,fmt)
        h.displayStatus(str,fmt);
        h.LogMsg=[h.LogMsg,sprintf(fmt,dispFpgaMsg(str))];
