function ret=plc_mdl_check_matlab_fcn(origModelH,newModelH,errorExists)




    ret=errorExists;
    compile_mdl(newModelH);
    sf_list=plc_find_system(newModelH,'FollowLinks','on','LookUnderMasks','all','LookUnderReadProtectedSubsystems',...
    'on','MaskType','Stateflow','CompiledIsActive','on');

    eml_list=[];
    for i=1:length(sf_list)
        if sfprivate('is_eml_chart_block',sf_list(i))
            eml_list(end+1)=sf_list(i);%#ok<AGROW>
        end
    end

    if isempty(eml_list)
        return;
    end

    if plcfeature('CheckLibraryMATLABFunction')
        for i=1:length(eml_list)
            ret=check_library_matlab_fcn(origModelH,newModelH,eml_list(i),ret);
        end
    end

    if~PLCCoder.PLCCGMgr.getInstance.isRandFcnSupported
        for i=1:length(eml_list)
            ret=check_blk_matlab_fcn_rand(origModelH,newModelH,eml_list(i),ret);
        end
    end

    function[has_error,has_eml_chart,script_list,fcn_list]=get_matlab_report(origModelH,blockH)
        has_error=false;
        has_eml_chart=false;
        script_list=[];
        fcn_list=[];

        blockObj=get_param(blockH,'Object');
        emlChart=getChartObject(blockObj);
        if isempty(emlChart)
            return;
        end

        has_eml_chart=true;
        chartId=emlChart.Id;
        try
            ignoreErr=true;
            MATLABFunctionBlockSpecializationCheckSum=sf('SFunctionSpecialization',chartId,blockH,ignoreErr);
            [~,mainInfoName,~,~]=sfprivate('get_report_path',pwd,MATLABFunctionBlockSpecializationCheckSum,false);

            if~exist(mainInfoName,'file')

                sfprivate('eml_report_manager','report',chartId,blockH);
            end

            if~exist(mainInfoName,'file')

                modeldir=fileparts(emlChart.Machine.FullFileName);
                reportDir=fullfile(sfprivate('get_sf_proj',modeldir),...
                'EMLReport');
                mainInfoName=fullfile(reportDir,...
                [MATLABFunctionBlockSpecializationCheckSum,'.mat']);
            end

            load(mainInfoName,'report');
            plc_mlfcn_report=report;

            script_list=plc_mlfcn_report.inference.Scripts;
            fcn_list=plc_mlfcn_report.inference.Functions;

        catch ex %#ok<NASGU>
            has_error=true;
            errMsg='Cannot get MATLAB function compilation report';
            sldvshareprivate('avtcgirunsupcollect','push',origModelH,'plccoder',errMsg,...
            'PLCCoder:InvalidMATLABFcnReport');
        end

        function ret=check_blk_matlab_fcn_rand(origModelH,newModelH,blockH,errorExists)%#ok<INUSL>
            ret=errorExists;

            [has_error,has_eml_chart,script_list,fcn_list]=get_matlab_report(origModelH,blockH);

            if has_error
                ret=true;
                return;
            end

            if~has_eml_chart
                return;
            end

            for ii=1:length(fcn_list)
                fcn=fcn_list(ii);
                if fcn.ScriptID>0&&script_list(fcn.ScriptID).IsUserVisible
                    for jj=1:fcn.CallSiteCount
                        callSite=fcn.CallSites(jj);
                        cfcn=fcn_list(callSite.CalledFunctionID);
                        if strcmp(cfcn.FunctionName,'rand')&&~script_list(cfcn.ScriptID).IsUserVisible
                            ret=true;
                            origBlockH=PLCCoder.PLCCGMgr.getInstance.mapBlockHandle(blockH);
                            errMsg=sprintf('MATLAB function block ''$PATH$'' calls rand function. Rand function is not supported for the selected Target IDE.');
                            sldvshareprivate('avtcgirunsupcollect','push',origBlockH,'simulink',errMsg,'PLCCoder:MATLABRandFcnNotSupported');
                        end
                    end
                end
            end

            function chartObj=getChartObject(sfObj)
                chartObj=find(sfObj,'-depth',1,'Name',sfObj.Name,'-isa','Stateflow.EMChart');

                if isempty(chartObj)
                    chartObj=find(sfObj,'-depth',1,'Name',sfObj.Name,'-isa','Stateflow.LinkChart');%#ok<*GTARG>
                    if~isempty(chartObj)
                        chartPath=get_param(chartObj.Path,'ReferenceBlock');
                        chartObj=find(sfroot,'-isa','Stateflow.EMChart','Path',chartPath);
                    end
                end

                function compile_mdl(modelH)
                    originalMode=get_param(modelH,'SimulationMode');
                    if strcmpi(originalMode,'accelerator')

                        set_param(modelH,'SimulationMode','normal');
                        resetMode=onCleanup(@()set_param(modelH,'SimulationMode',originalMode));
                    end
                    modelName=get_param(modelH,'Name');
                    feval(modelName,[],[],[],'compile');
                    feval(modelName,[],[],[],'term');

                    function ret=check_library_matlab_fcn(origModelH,newModelH,blockH,errorExists)%#ok<INUSL>
                        ret=errorExists;

                        [has_error,has_eml_chart,script_list,fcn_list]=get_matlab_report(origModelH,blockH);

                        if has_error
                            ret=true;
                            return;
                        end

                        if~has_eml_chart
                            return;
                        end

                        libfcn_map=plc_libfcn_map();
                        matlab_prefix=[matlabroot,filesep];

                        for ii=1:length(fcn_list)
                            fcn=fcn_list(ii);
                            if fcn.ScriptID>0&&script_list(fcn.ScriptID).IsUserVisible
                                for jj=1:fcn.CallSiteCount
                                    callSite=fcn.CallSites(jj);
                                    cfcn=fcn_list(callSite.CalledFunctionID);
                                    if cfcn.ScriptID<=0
                                        continue;
                                    end
                                    cscript=script_list(cfcn.ScriptID);
                                    if~cscript.IsUserVisible
                                        check_fcn(fcn,cfcn,cscript,libfcn_map,matlab_prefix);
                                    end
                                end
                            end
                        end

                        function check_fcn(caller_fcn,callee_fcn,cscript,libfcn_map,matlab_prefix)
                            lib_path=cscript.ScriptPath;
                            if~startsWith(lib_path,matlab_prefix)
                                return;
                            end

                            if startsWith(lib_path,[matlab_prefix,'test'])
                                return;
                            end

                            [lib_dir,lib_fcn,lib_ext]=fileparts(strrep(lib_path,matlab_prefix,''));
                            lib_dir=strrep(lib_dir,'\','/');
                            lib_path=[lib_dir,'/',lib_fcn,lib_ext];
                            if libfcn_map.isKey(lib_dir)||libfcn_map.isKey(lib_path)
                                if libfcn_map.isKey(lib_dir)
                                    lib_fcn_list=libfcn_map(lib_dir);
                                else
                                    lib_fcn_list=libfcn_map(lib_path);
                                end
                                if any(strcmp(lib_fcn_list,'*'))||any(strcmp(lib_fcn_list,callee_fcn.FunctionName))
                                    return;
                                end
                            end

                            error(message('plccoder:plccg_ext:UnsupportedLibraryMATLABFunction',...
                            callee_fcn.FunctionName,lib_path,caller_fcn.FunctionName));


