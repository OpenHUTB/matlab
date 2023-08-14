function data=ValidateOptions(obj,from_engine)



    data=obj.data;

    data.origpath=path;
    if~obj.Debugging
        data.workdirectory=tempname;
    else
        data.workdirectory=fullfile(pwd,'workspace');
    end
    data.currentdirectory=pwd;

    coder.internal.errorIf(isempty(obj.FunctionName)||~ischar(obj.FunctionName),'dsp:dspunfold:InvalidFunctionName');
    [data.fpath,data.fname,data.fext]=fileparts(which(obj.FunctionName));
    if isempty(data.fpath)
        fname=fullfile(data.currentdirectory,obj.FunctionName);
        coder.internal.errorIf(~exist(fname,'file'),'dsp:dspunfold:MissingFunctionName',obj.FunctionName);
        [data.fpath,data.fname,data.fext]=fileparts(fname);
        coder.internal.errorIf(isempty(data.fpath),'dsp:dspunfold:MissingFunctionName',obj.FunctionName);
    end
    coder.internal.errorIf(strcmpi(data.fext,'.p'),'dsp:dspunfold:PCodedFunctionName');
    C=textscan(data.fname,'%s','Delimiter',['A':'Z','a':'z','0':'9','_']);
    words=cellstr(C{1});
    words=words(~cellfun('isempty',words));
    coder.internal.errorIf(...
    (~isempty(words)||~contains(['A':'Z','a':'z'],data.fname(1))),...
    'dsp:dspunfold:WrongFunctionName',obj.FunctionName);

    if isempty(obj.MexName)
        data.mpath=data.currentdirectory;
        data.mname=data.fname;
        data.real_mname=[data.mname,'_mt'];
    else
        coder.internal.errorIf(~ischar(obj.MexName),'dsp:dspunfold:InvalidMexName');
        [data.mpath,data.mname,~]=fileparts(obj.MexName);
        data.real_mname=data.mname;
    end
    coder.internal.errorIf(isempty(data.mname)||~ischar(data.mname),'dsp:dspunfold:InvalidMexName');
    C=textscan(data.real_mname,'%s','Delimiter',['A':'Z','a':'z','0':'9','_']);
    words=cellstr(C{1});
    words=words(~cellfun('isempty',words));
    coder.internal.errorIf(...
    (~isempty(words)||~contains(['A':'Z','a':'z'],data.real_mname(1))),...
    'dsp:dspunfold:WrongMexName',data.real_mname);

    if isempty(data.mpath)
        data.mpath=data.currentdirectory;
    end
    data.mext=['.',mexext];
    coder.internal.errorIf(strcmpi(data.fname,data.real_mname),'dsp:dspunfold:FunctionNameMexNameSame',data.real_mname);

    coder.internal.errorIf(~isempty(obj.InputArgs)&&~iscell(obj.InputArgs),'dsp:dspunfold:InvalidInputArgs');

    coder.internal.errorIf(isempty(obj.Threads)||~isnumeric(obj.Threads)||~isscalar(obj.Threads)||isfi(obj.Threads)||(obj.Threads<1)||isinf(obj.Threads)||(obj.Threads~=floor(obj.Threads)),...
    'dsp:dspunfold:InvalidThreads');

    coder.internal.errorIf(isempty(obj.Repetition)||~isnumeric(obj.Repetition)||~isscalar(obj.Repetition)||isfi(obj.Repetition)||(obj.Repetition<1)||isinf(obj.Repetition)||(obj.Repetition~=floor(obj.Repetition)),...
    'dsp:dspunfold:InvalidRepetition');

    coder.internal.errorIf(obj.Threads==1&&obj.Repetition<2,'dsp:dspunfold:SingleThreadMultipleRepetitions');

    coder.internal.errorIf(isempty(obj.StateLength)||~isnumeric(obj.StateLength)||~isscalar(obj.StateLength)||isfi(obj.StateLength)||(obj.StateLength<-1)||(obj.StateLength~=floor(obj.StateLength)),...
    'dsp:dspunfold:InvalidStateLength');

    coder.internal.errorIf(isempty(obj.FrameInputs)||~islogical(obj.FrameInputs),'dsp:dspunfold:InvalidFrameInputs');

    coder.internal.errorIf((numel(obj.FrameInputs)~=1)&&(numel(obj.FrameInputs)~=numel(obj.InputArgs)),'dsp:dspunfold:InvalidFrameInputs');

    coder.internal.errorIf(numel(obj.InputArgs)==0&&any(obj.FrameInputs),'dsp:dspunfold:FrameInputsNoArguments');

    if(numel(obj.FrameInputs)==1)
        data.FrameInputs=true(numel(obj.InputArgs),1)&obj.FrameInputs;
    else
        data.FrameInputs=obj.FrameInputs;
    end

    coder.internal.errorIf(isempty(obj.Verbose)||~islogical(obj.Verbose),'dsp:dspunfold:InvalidVerbose');


    coder.internal.errorIf(isempty(obj.SubFrameCapable)||~islogical(obj.SubFrameCapable),'dsp:dspunfold:InvalidSubFrameCapability');


    coder.internal.errorIf(~isempty(obj.BuildConfig)&&~isa(obj.BuildConfig,'coder.EmbeddedCodeConfig')&&~isa(obj.BuildConfig,'coder.CodeConfig')&&~isa(obj.BuildConfig,'coder.MexCodeConfig'),...
    'dsp:dspunfold:InvalidBuildConfig');


    coder.internal.errorIf(isempty(obj.NonBlockingOutput)||~islogical(obj.NonBlockingOutput),'dsp:dspunfold:InvalidNonBlockingOutput');


    coder.internal.errorIf(isempty(obj.GenerateAnalyzer)||~islogical(obj.GenerateAnalyzer),'dsp:dspunfold:InvalidGenerateAnalyzer');


    coder.internal.errorIf(isempty(obj.RunFirstFrame)||~islogical(obj.RunFirstFrame),'dsp:dspunfold:InvalidRunFirstFrame');


    coder.internal.errorIf(isempty(obj.AnalyzerInputDifferent)||~islogical(obj.AnalyzerInputDifferent),'dsp:dspunfold:InvalidAnalyzerInputDifferent');


    coder.internal.errorIf(isempty(obj.Debugging)||~islogical(obj.Debugging),'dsp:dspunfold:InvalidDebugging');


    coder.internal.errorIf(isempty(obj.GenerateEmpty)||~islogical(obj.GenerateEmpty),'dsp:dspunfold:InvalidGenerateEmptyMex');


    if(from_engine)

        if obj.NonBlockingOutput
            latency=2*obj.Threads*obj.Repetition;
        else
            latency=obj.Threads*obj.Repetition;
        end
        if(obj.StateLength>-1)

            if any(data.FrameInputs)
                UnfoldingVerbose(obj,false,getString(message('dsp:dspunfold:ShowConfigurationManualSamples',num2str(obj.StateLength),num2str(obj.Repetition),num2str(latency),num2str(obj.Threads))));
            else
                UnfoldingVerbose(obj,false,getString(message('dsp:dspunfold:ShowConfigurationManualFrames',num2str(obj.StateLength),num2str(obj.Repetition),num2str(latency),num2str(obj.Threads))));
            end
        else

            if any(data.FrameInputs)
                UnfoldingVerbose(obj,false,getString(message('dsp:dspunfold:ShowConfigurationAutoSamples',num2str(obj.Repetition),num2str(latency),num2str(obj.Threads))));
            else
                UnfoldingVerbose(obj,false,getString(message('dsp:dspunfold:ShowConfigurationAutoFrames',num2str(obj.Repetition),num2str(latency),num2str(obj.Threads))));
            end
        end
    end
end

