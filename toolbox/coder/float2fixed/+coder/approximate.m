










































function varargout=approximate(varargin)

    narginchk(1,1+6)

    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    approx_stats=coder.mathfcngenerator.ApproximationResults();

    varargin(2:2:end)=(varargin(2:2:end));
    objUserIn=struct(varargin{2:end});


    AllowedFieldNames={'GenerateFixptCode','GenerateTestBench','GenerateMatlabFunctionBlock'};
    [all_field_names_valid,errMsg]=validateCoderApproximate(objUserIn,AllowedFieldNames);
    if(~all_field_names_valid)
        error(message('float2fixed:MFG:InvalidProperty',errMsg));
    end

    defaults=containers.Map();
    defaults('GenerateFixptCode')=false;
    defaults('GenerateTestBench')=true;
    defaults('GenerateMatlabFunctionBlock')=false;

    for fieldName=defaults.keys
        fieldName=(fieldName{1});%#ok<FXSET>
        if(~isfield(objUserIn,fieldName))
            objUserIn.(fieldName)=defaults(fieldName);
        end
    end

    configObj=varargin{1};
    className=strsplit(class(configObj),'.');
    className=className{end};
    if(~any(strcmpi({'LookupTable','CORDIC','Flat'},className)))
        error(message('float2fixed:MFG:Appx1ArgOnly'));
    end

    MFG_Obj=coder.internal.mathfcngenerator.MathFunctionGenerator('UserInterp','Linear (degree-1 Polynomial)','CandidateFunctionName',configObj.Function);


    switch(upper(className))
    case 'CORDIC'
        error(message('float2fixed:MFG:CORDICUnsupported'));
        if(~any(strcmpi(MFG_Obj.Supported4CORDIC,configObj.Function)))%#ok<UNRCH>
            error(message('float2fixed:MFG:CORDICUnsupportedFcn',configObj.Function))
        end
    otherwise

    end


    for itr=configObj.Parameters.keys
        key=itr{1};
        MFG_Obj.Param=configObj.Parameters(key);
    end

    try
        internalObj=MFG_Obj.getGeneratorObject(configObj);


        if(~MFG_Obj.isSupportedFunction(configObj.Function))


            if(isempty(configObj.InputRange))
                error(message('float2fixed:MFG:CustomFcnRangeNotSpecified',configObj.Function));
            end


            if(isempty(configObj.CandidateFunction))
                if(~isempty(configObj.Function))
                    disp(['### ',message('float2fixed:MFG:CustomFcnNotSpecifiedReusingName',configObj.Function).getString()]);
                    configObj.CandidateFunction=str2func(configObj.Function);


                    try
                        configObj.CandidateFunction(configObj.InputRange(1,:));
                    catch mEx
                        mEx2=MException(message('float2fixed:MFG:CustomFcnNotSpecified',configObj.Function)).addCause(mEx);
                        throw(mEx2);
                    end
                else
                    error(message('float2fixed:MFG:CustomFcnNotSpecified',configObj.Function));
                end
            end

        end


        if(strcmpi(className,'Flat'))
            if(~objUserIn.GenerateFixptCode)
                warning(message('Coder:FXPCONV:RequiredGenFixptCodeForFlatMode'));
                objUserIn.GenerateFixptCode=true;
            end
            objUserIn.GenerateFixptCode=true;
        end



        internalObj.forwardProperties(configObj,objUserIn);


    catch mEx
        mEx2=MException(message('float2fixed:MFG:CodegenFailed',configObj.Function)).addCause(mEx);
        throw(mEx2);
    end

    [ValidBool,ErrorStr]=internalObj.InputRangeValidate();
    if(~ValidBool)
        error(message('float2fixed:MFG:CodegenFailedInputRangeValidate',ErrorStr));
    end

    try
        function_name=regexp(class(internalObj),'\.\w*$','match');
        function_name=lower(function_name{1}(2:end));
        if(strncmpi(function_name,'HDL',3))
            function_name=function_name(4:end);
        end
        design_filename=[configObj.FunctionNamePrefix,function_name,'.m'];
        tb_filename=[configObj.FunctionNamePrefix,function_name,'_tb.m'];
        verbosityLevel=false;
        [code_fcn,code_tb]=internalObj.writeToFile(design_filename,verbosityLevel);%#ok<ASGLU>
    catch mEx
        mEx2=MException(message('float2fixed:MFG:CodegenFailed',configObj.Function)).addCause(mEx);
        throw(mEx2);
    end

    link=@(fileName,dispName)['<a href="matlab:edit(''',fileName,''')">',dispName,'</a>'];

    designLink=link(fullfile(pwd(),design_filename),design_filename);
    testbenchLink=link(fullfile(pwd(),tb_filename),tb_filename);


    disp(['### ',message('float2fixed:MFG:GeneratedDesignFile',configObj.Function,designLink).getString()])
    if(objUserIn.GenerateTestBench)
        disp(['### ',message('float2fixed:MFG:GeneratedTestbenchFile',configObj.Function,testbenchLink).getString()])
    end

    approx_stats.DesignFile=fullfile(pwd(),design_filename);
    approx_stats.TestBenchFile=fullfile(pwd(),tb_filename);


    switch(lower(className))
    case lower('LookupTable')
        disp(['### ',message('float2fixed:MFG:LookupTableNumberOfPoints',configObj.Function,num2str(internalObj.N)).getString()])
        approx_stats.LookupTable.NumberOfPoints=internalObj.N;
    otherwise

    end

















    approx_stats.Error.Absolute=[];
    approx_stats.Error.Relative=[];
    approx_stats.Error.MeanSquared=[];


    try
        if(objUserIn.GenerateMatlabFunctionBlock)
            disp(['### ',message('float2fixed:MFG:Export2SL',configObj.Function).getString()])
            coder.internal.mathfcngenerator.EMLBlockGenerator.generate(configObj.Function,code_fcn);
        end
    catch mEx
        mEx2=MException(message('float2fixed:MFG:Export2SLFailed',configObj.Function)).addCause(mEx);
        throw(mEx2)
    end

    if(nargout>0)
        varargout{1}=approx_stats;
    end
end

function[all_field_names_valid,errMsg]=validateCoderApproximate(objUserIn,AllowedFieldNames)
    inputFields=fields(objUserIn);
    errMsg='';
    valid_fields=cellfun(@(x)any(strcmpi(AllowedFieldNames,x)),inputFields);
    all_field_names_valid=all(valid_fields);
    if(~all_field_names_valid)
        for itr=1:length(valid_fields)
            if(~valid_fields(itr))
                errMsg=[errMsg,char(10),message('float2fixed:MFG:CoderApproximateInvalidProperty',inputFields{itr}).getString()];%#ok<AGROW>
            end
        end
    end
end
