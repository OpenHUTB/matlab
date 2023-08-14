function report=socModelAnalyzer(modelName,varargin)













































































    try

        report=struct;


        if~builtin('license','checkout','SoC_Blockset')
            error(message('soc:utils:NoLicense'));
        end

        currentDir=pwd;
        dirCleanup=onCleanup(@()cd(currentDir));
        currentPath=path();
        pathCleanup=onCleanup(@()path(currentPath));
        addpath(pwd);


        origWarn(1)=warning('query','MATLAB:xlswrite:AddSheet');
        origWarn(2)=warning('query','Simulink:slbuild:unsavedMdlRefsAllowed');
        origWarn(3)=warning('query','Simulink:slbuild:unsavedMdlRefsCause');
        warningCleanup=onCleanup(@()warning(origWarn));
        warning('off','MATLAB:xlswrite:AddSheet');
        warning('off','Simulink:slbuild:unsavedMdlRefsAllowed');
        warning('off','Simulink:slbuild:unsavedMdlRefsCause');

        origLoadedMdl=get_param(Simulink.allBlockDiagrams(),'Name');
        loadedMdlCleanup=onCleanup(@()cleanupLoadedMdl(origLoadedMdl));


        p=inputParser;

        addParameter(p,'AnalysisMethod','dynamic',@(x)validatestringopt(x,{'static','dynamic'}));
        addParameter(p,'IncludeBlockPath',{},@(x)validatecellstr(x));
        addParameter(p,'ExcludeBlockPath',{},@(x)validatecellstr(x));
        addParameter(p,'IncludeOperator',{},@(x)validatecellstr(x));
        addParameter(p,'ExcludeOperator',{},@(x)validatecellstr(x));
        addParameter(p,'Folder','',@(x)validateattributes(x,{'char','string'},{'nonempty'}));
        addParameter(p,'Verbose','off',@(x)validatestringopt(x,{'on','off','quiet'}));

        addParameter(p,'ExcludeInternalLibraries',false,@(x)validateattributes(x,{'logical'},{'nonempty'}));
        addParameter(p,'CGIRInstrumentationLevel',1,@(x)validateattributes(x,{'numeric'},{'scalar','integer','nonnegative'}));

        parse(p,varargin{:});

        method=p.Results.AnalysisMethod;
        incl_block=p.Results.IncludeBlockPath;
        excl_block=p.Results.ExcludeBlockPath;
        incl_op=p.Results.IncludeOperator;
        excl_op=p.Results.ExcludeOperator;
        output_dir=p.Results.Folder;
        verbose=p.Results.Verbose;

        excl_internal=p.Results.ExcludeInternalLibraries;
        inst_level=p.Results.CGIRInstrumentationLevel;

        if~iscell(incl_op)
            incl_op={incl_op};
        end

        if~iscell(excl_op)
            excl_op={excl_op};
        end

        if~iscell(incl_block)
            incl_block={incl_block};
        end

        if~iscell(excl_block)
            excl_block={excl_block};
        end

        incl_path=incl_block;
        excl_path=excl_block;

        if excl_internal
            excl_path=[excl_path,fullfile(matlabroot,'toolbox','eml')];
        end

        fullname=which(modelName);
        if isempty(fullname)
            error(message('soc:complexity:NotFound',modelName));
        end

        [input_path,input_name,input_ext]=fileparts(fullname);
        if isempty(input_ext)
            error(message('soc:complexity:NotAFile',fullname));
        end

        if~strcmp(input_ext,'.slx')&&~strcmp(input_ext,'.mdl')
            error(message('soc:complexity:NotSL',fullname));
        end

        if isempty(output_dir)
            output_dir=pwd;
        end

        if~strcmp(verbose,'quiet')
            msg=message('soc:complexity:Start',fullname);
            disp(msg.getString);
        end

        input_arg={};

        obj=matlabshared.opcount.internal.opcountbase(method,input_path,input_name,input_ext,input_arg,output_dir,incl_op,excl_op,incl_path,excl_path,inst_level,verbose);
        objCleanup=onCleanup(@()delete(obj));

        obj.exec_generation();
        obj.db_generation();
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


function cleanupLoadedMdl(origLoadedMdl)
    currLoadedMdl=get_param(Simulink.allBlockDiagrams(),'Name');
    newLoadedMdl=setdiff(currLoadedMdl,origLoadedMdl);
    if~isempty(newLoadedMdl)
        close_system(newLoadedMdl);
    end
end


