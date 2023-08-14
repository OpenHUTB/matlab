function socAlgorithmAnalyzerReport(reportFile)











    try

        if~builtin('license','checkout','SoC_Blockset')
            error(message('soc:utils:NoLicense'));
        end

        if~exist(reportFile,'file')
            error(message('soc:complexity:NotFound',reportFile));
        end

        origWarn(1)=warning('query','MATLAB:load:variableNotFound');
        warningCleanup=onCleanup(@()warning(origWarn));
        warning('error','MATLAB:load:variableNotFound');%#ok<CTPCT>

        try
            r=load(reportFile,'src_type','a_method','PathHierarchicalReport','OperatorHierarchicalReport');
        catch ME
            error(message('soc:complexity:LoadError',reportFile,ME.message));
        end

        try
            mode='';
            switch(r.src_type)
            case 'Function'
                mode=message('ComplexityApp:report:TSAlgView').getString();
            case 'Model'
                mode=message('ComplexityApp:report:TSMdlView').getString();
            otherwise
                assert(false);
            end

            tab_title='';
            switch(r.a_method)
            case{'static','Static'}
                tab_title=message('ComplexityApp:report:TSReportStatic').getString();
            case{'dynamic','Dynamic'}
                tab_title=message('ComplexityApp:report:TSReportDynamic').getString();
            otherwise
                assert(false);
            end
            fpathreport=matlabshared.opcount.internal.subtable.flatten_htable(r.PathHierarchicalReport);
            foperatorreport=matlabshared.opcount.internal.subtable.flatten_htable(r.OperatorHierarchicalReport);

            soc.ui.HTMLReport({fpathreport;foperatorreport},mode,tab_title).open;

        catch ME
            error(message('soc:complexity:ProcessError',reportFile,ME.message));
        end

    catch ME
        rethrow(ME);
    end

end


