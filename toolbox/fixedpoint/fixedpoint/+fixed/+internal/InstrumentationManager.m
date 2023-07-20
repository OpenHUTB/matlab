classdef InstrumentationManager<handle




    properties(GetAccess=private,Constant)
        sInstrumentationManagerInstance=fixed.internal.InstrumentationManager;
    end

    properties(Access=private)
        LogMap=struct('key',{},'name',{});
    end

    methods(Access=protected)
        function obj=InstrumentationManager
        end
    end

    methods(Access=private)
        function key_index=keyIndex(obj,key)
            key_index=[];
            for i=1:length(obj.LogMap)
                if strcmp(obj.LogMap(i).key,key)
                    key_index=i;
                    break
                end
            end
        end

        function mfile_key_index=mfileKeyIndex(obj,key)


            mfile_key_index=[];
            for i=1:length(obj.LogMap)
                if strcmp(obj.LogMap(i).name,key)
                    mfile_key_index(end+1)=i;%#ok<AGROW>
                end
            end
        end

        function addLogEntry(obj,key,coder_report)
            key_index=obj.keyIndex(key);
            if isempty(key_index)
                n=length(obj.LogMap)+1;
                obj.LogMap(n).key=key;
                obj.LogMap(n).name=coder_report.summary.name;
            end
        end
        function throwInstructiveKeyNotFoundMessage(obj,key,action,warn_err_fun)
            instrumented_version=fixed.internal.getInstrumentedMexFunctionVersion(which(key));
            if~isempty(instrumented_version)
                if isequal(instrumented_version,...
                    fixed.internal.InstrumentationManager.Version())
                    warn_err_fun(message('fixed:instrumentation:emptyLoggedData',key,key));
                    return;
                else
                    warn_err_fun(message('fixed:instrumentation:invalidVersion',key,key));
                    return;
                end
            end
            mfile_key_index=mfileKeyIndex(obj,key);
            if isempty(mfile_key_index)
                switch exist(key)%#ok<EXIST>
                case 0

                    warn_err_fun(message('fixed:instrumentation:keyDoesNotExist',key,key));
                    return
                case 2





                    which_key=which(key);
                    [~,~,ext]=fileparts(which_key);
                    if isequal(ext,'.m')

                        warn_err_fun(message('fixed:instrumentation:matlabFunctionFound',key,action));
                        return
                    else

                        warn_err_fun(message('fixed:instrumentation:ordinaryFileFound',key,action));
                        return
                    end
                case 3


                    warn_err_fun(message('fixed:instrumentation:uninstrumentedMexFound',key,action));
                    return
                case 5

                    warn_err_fun(message('fixed:instrumentation:builtinMATLABFunctionFound',key,action));
                    return
                case 6

                    warn_err_fun(message('fixed:instrumentation:pFileFound',key,action));
                    return
                otherwise
                    warn_err_fun(message('fixed:instrumentation:instrumentedMexNotFound',key,action));
                    return;
                end
            else
                matches=cell(length(mfile_key_index),1);
                for i=1:length(mfile_key_index)
                    matches{i}=obj.LogMap(mfile_key_index(i)).key;
                end
                matches_str=sprintf('\n%s(''%s'')',action,matches{1});
                for i=2:length(matches)
                    matches_str=sprintf('%s, or\n%s(''%s'')',...
                    matches_str,action,matches{i});
                end
                warn_err_fun(message('fixed:instrumentation:ambiguousKeyFound',key,action,matches_str));
                return
            end
        end
        function validateResults(obj,key,action,results)
            if isempty(results)
                obj.throwInstructiveKeyNotFoundMessage(key,action,@error);
            else
                r=fixed.internal.pullLog(which(key),'-pullCompReportFromMexFunction');
                if isempty(r)&&exist(key)==3 %#ok<EXIST>
                    warning(message('fixed:instrumentation:staleLog',key,key,key));
                end
            end
        end

    end

    methods(Static)
        function v=Version()


            v=2;
        end
        function setCoderReport(key,coder_report)
            obj=fixed.internal.InstrumentationManager.sInstrumentationManagerInstance;
            obj.addLogEntry(key,coder_report);
        end
        function coder_report=getCoderReport(key)



            r=fixed.internal.pullLog(which(key),'-pullCompReportFromMexFunction');
            if isempty(r)
                coder_report=r;
            else
                coder_report=r.CompilationReport;
            end
        end
        function[results,mex_path]=getResults(key,action)
            if nargin<2
                action='';
            end
            obj=fixed.internal.InstrumentationManager.sInstrumentationManagerInstance;
            if~ischar(key)
                error(message('fixed:instrumentation:keyMustBeChar',action));
            end
            results=fixed.internal.pullLog(key);
            mex_path=fileparts(which(key));
            if isempty(mex_path)
                mex_path=pwd;
            end
            obj.validateResults(key,action,results);
        end
        function showResults(key,args,opts)
            license_checkout_flag=builtin('license','checkout','Fixed_Point_Toolbox');
            if~license_checkout_flag
                error(message('fixed:fi:licenseCheckoutFailed'));
            end
            [results,mex_path]=fixed.internal.InstrumentationManager.getResults(key,...
            'showInstrumentationResults');
            coder_report=fixed.internal.processInstrumentedMxInfoLocations(results,opts);
            coder_report.summary.codingTarget='MEX';
            coder_report.summary.directory=fullfile(mex_path,'instrumentation',key);
            coder_report.summary.mainhtml=fullfile(mex_path,'instrumentation',key,'html','index.html');

            mainhtml=codergui.evalprivate('genInstrumentationReport',coder_report);
            [htmlpath,~,~]=fileparts(mainhtml);
            printablehtml=fullfile(htmlpath,'printable.html');
            fixed.internal.printableInstrumentationReport(key,printablehtml,args,coder_report);
            if(opts.doPrintable)
                web('-browser',printablehtml);
            end
            emlcprivate('emcOpenReport',mainhtml);
        end
        function clearResults(key)


            obj=fixed.internal.InstrumentationManager.sInstrumentationManagerInstance;
            action='clearInstrumentationResults';
            if~ischar(key)
                error(message('fixed:instrumentation:keyMustBeChar',action));
            elseif strcmpi(key,'all')
                c=fixed.internal.listLogs;
                for i=1:length(c)
                    fixed.internal.clearLog(c{i});
                end
                log_was_cleared=true;
            else
                log_was_cleared=fixed.internal.clearLog(key);
            end
            if~log_was_cleared
                obj.throwInstructiveKeyNotFoundMessage(key,action,@warning);
            end
        end
        function c=listMex()

            obj=fixed.internal.InstrumentationManager.sInstrumentationManagerInstance;
            c={obj.LogMap(:).key};
        end
    end

end


