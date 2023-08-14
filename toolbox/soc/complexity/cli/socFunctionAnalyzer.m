function[report,varargout]=socFunctionAnalyzer(functionName,varargin)



























































































    try
        report=struct;
        varargout={};


        if~builtin('license','checkout','SoC_Blockset')
            error(message('soc:utils:NoLicense'));
        end

        currentDir=pwd;
        dirCleanup=onCleanup(@()cd(currentDir));
        currentPath=path();
        pathCleanup=onCleanup(@()path(currentPath));
        addpath(pwd);


        origWarn(1)=warning('query','MATLAB:xlswrite:AddSheet');
        warningCleanup=onCleanup(@()warning(origWarn));
        warning('off','MATLAB:xlswrite:AddSheet');


        p=inputParser;

        addParameter(p,'AnalysisMethod','dynamic',@(x)validatestringopt(x,{'static','dynamic'}));
        addParameter(p,'FunctionInputs',{});
        addParameter(p,'IncludeFunction',{},@(x)validatecellstr(x));
        addParameter(p,'ExcludeFunction',{},@(x)validatecellstr(x));
        addParameter(p,'IncludeOperator',{},@(x)validatecellstr(x));
        addParameter(p,'ExcludeOperator',{},@(x)validatecellstr(x));
        addParameter(p,'Folder','',@(x)validateattributes(x,{'char','string'},{'nonempty'}));
        addParameter(p,'Verbose','off',@(x)validatestringopt(x,{'on','off','quiet'}));

        addParameter(p,'ExcludeInternalLibraries',false,@(x)validateattributes(x,{'logical'},{'nonempty'}));
        addParameter(p,'CGIRInstrumentationLevel',1,@(x)validateattributes(x,{'numeric'},{'scalar','integer','nonnegative'}));

        parse(p,varargin{:});

        method=p.Results.AnalysisMethod;
        input_arg=p.Results.FunctionInputs;
        incl_func=p.Results.IncludeFunction;
        excl_func=p.Results.ExcludeFunction;
        incl_op=p.Results.IncludeOperator;
        excl_op=p.Results.ExcludeOperator;
        output_dir=p.Results.Folder;
        verbose=p.Results.Verbose;

        excl_internal=p.Results.ExcludeInternalLibraries;
        inst_level=p.Results.CGIRInstrumentationLevel;

        if~iscell(input_arg)
            input_arg={input_arg};
        end

        if~iscell(incl_op)
            incl_op={incl_op};
        end

        if~iscell(excl_op)
            excl_op={excl_op};
        end

        if~iscell(incl_func)
            incl_func={incl_func};
        end

        if~iscell(excl_func)
            excl_func={excl_func};
        end

        incl_path=incl_func;
        excl_path=excl_func;

        if excl_internal
            excl_path=[excl_path,fullfile(matlabroot,'toolbox','eml')];
        end

        fullname=which(functionName);
        if isempty(fullname)
            error(message('soc:complexity:NotFound',functionName));
        end

        [input_path,input_name,input_ext]=fileparts(fullname);
        if isempty(input_ext)
            error(message('soc:complexity:NotAFile',fullname));
        end

        if~strcmp(input_ext,'.m')
            error(message('soc:complexity:NotML',fullname));
        end

        if isempty(output_dir)
            output_dir=pwd;
        end

        if~strcmp(verbose,'quiet')
            msg=message('soc:complexity:Start',fullname);
            disp(msg.getString);
        end

        obj=matlabshared.opcount.internal.opcountbase(method,input_path,input_name,input_ext,input_arg,output_dir,incl_op,excl_op,incl_path,excl_path,inst_level,verbose);
        objCleanup=onCleanup(@()delete(obj));

        obj.exec_generation();

        varargout=cell(1,obj.noutput_arg);
        [varargout{1:end}]=obj.db_generation();

        obj.db_postprocessing();
        report=obj.report_generation();

        if~strcmp(verbose,'quiet')
            msg=message('soc:complexity:Done');
            disp(msg.getString);
        end

    catch ME
        rethrow(ME);
    end

end

function validatecellstr(x)
    validateattributes(x,{'cell','char'},{'nonempty'});
    if iscell(x)
        cellfun(@(y)validateattributes(y,{'char'},{'nonempty'}),x);
    end
end

function validatestringopt(x,valid)
    validateattributes(x,{'char','string'},{'scalartext'});
    validatestring(x,valid);
end

