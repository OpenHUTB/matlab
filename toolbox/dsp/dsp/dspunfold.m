function dspunfold(varargin)









































































































    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    FunctionName=false;
    InputArgs=false;
    MexName=false;
    Repetition=false;
    Threads=false;
    StateLength=false;
    FrameInputs=false;
    Verbose=false;

    try


        featureVal1=dsp.internal.feature("dspunfoldOptimizedCG","enable");
        clean1=onCleanup(@()(dsp.internal.feature("dspunfoldOptimizedCG","enable",featureVal1)));
        dsp.internal.feature("dspunfoldOptimizedCG","enable",true);




        featureVal2=dsp.internal.feature("EnableTBBForCGSim");
        clean2=onCleanup(@()(dsp.internal.feature("EnableTBBForCGSim",featureVal2)));
        dsp.internal.feature("EnableTBBForCGSim",false);

        hUnfolding=unfoldingEngine;

        i=1;
        while(i<=nargin)
            coder.internal.errorIf(~ischar(varargin{i}),'dsp:dspunfold:UnknownOption',varargin{i});
            coder.internal.errorIf(isempty(strtrim(varargin{i})),'dsp:dspunfold:UnknownOption',['''',varargin{i},'''']);
            switch lower(strtrim(varargin{i}))
            case '-args'
                coder.internal.errorIf(InputArgs,'dsp:dspunfold:MultipleInputArgs');
                i=i+1;
                coder.internal.errorIf(i>nargin,'dsp:dspunfold:IncompleteInputArgs');
                if ischar(varargin{i})&&~isempty(strtrim(varargin{i}))
                    try
                        hUnfolding.InputArgs=evalin('caller',strtrim(varargin{i}));
                    catch
                        hUnfolding.InputArgs=evalin('base',strtrim(varargin{i}));
                    end
                else
                    hUnfolding.InputArgs=varargin{i};
                end
                InputArgs=true;
            case{'-o','-output'}
                coder.internal.errorIf(MexName,'dsp:dspunfold:MultipleMexName');
                i=i+1;
                coder.internal.errorIf(i>nargin,'dsp:dspunfold:IncompleteMexName');
                hUnfolding.MexName=strtrim(varargin{i});
                MexName=true;
            case{'-r','-repetition'}
                coder.internal.errorIf(Repetition,'dsp:dspunfold:MultipleRepetition');
                i=i+1;
                coder.internal.errorIf(i>nargin,'dsp:dspunfold:IncompleteRepetition');
                if ischar(varargin{i})&&~isempty(strtrim(varargin{i}))
                    try
                        hUnfolding.Repetition=evalin('caller',strtrim(varargin{i}));
                    catch
                        hUnfolding.Repetition=evalin('base',strtrim(varargin{i}));
                    end
                else
                    hUnfolding.Repetition=varargin{i};
                end
                Repetition=true;
            case{'-t','-threads'}
                coder.internal.errorIf(Threads,'dsp:dspunfold:MultipleThreads');
                i=i+1;
                coder.internal.errorIf(i>nargin,'dsp:dspunfold:IncompleteThreads');
                if ischar(varargin{i})&&~isempty(strtrim(varargin{i}))
                    try
                        hUnfolding.Threads=evalin('caller',strtrim(varargin{i}));
                    catch
                        hUnfolding.Threads=evalin('base',strtrim(varargin{i}));
                    end
                else
                    hUnfolding.Threads=varargin{i};
                end
                Threads=true;
            case{'-s','-statelength'}
                coder.internal.errorIf(StateLength,'dsp:dspunfold:MultipleStateLength');
                i=i+1;
                coder.internal.errorIf(i>nargin,'dsp:dspunfold:IncompleteStateLength');
                if ischar(varargin{i})&&~isempty(strtrim(varargin{i}))
                    if strcmpi(strtrim(varargin{i}),'auto')
                        hUnfolding.StateLength=-1;
                    else
                        try
                            hUnfolding.StateLength=evalin('caller',strtrim(varargin{i}));
                        catch
                            hUnfolding.StateLength=evalin('base',strtrim(varargin{i}));
                        end
                    end
                else
                    hUnfolding.StateLength=varargin{i};
                end
                StateLength=true;
            case{'-f','-frameinputs'}
                coder.internal.errorIf(FrameInputs,'dsp:dspunfold:MultipleFrameInputs');
                i=i+1;
                coder.internal.errorIf(i>nargin,'dsp:dspunfold:IncompleteFrameInputs');
                if ischar(varargin{i})&&~isempty(strtrim(varargin{i}))
                    try
                        hUnfolding.FrameInputs=evalin('caller',strtrim(varargin{i}));
                    catch
                        hUnfolding.FrameInputs=evalin('base',strtrim(varargin{i}));
                    end
                else
                    hUnfolding.FrameInputs=varargin{i};
                end
                FrameInputs=true;
            case{'-v','-verbose'}
                coder.internal.errorIf(Verbose,'dsp:dspunfold:MultipleVerbose');
                i=i+1;
                coder.internal.errorIf(i>nargin,'dsp:dspunfold:IncompleteVerbose');
                if ischar(varargin{i})&&~isempty(strtrim(varargin{i}))
                    try
                        hUnfolding.Verbose=evalin('caller',strtrim(varargin{i}));
                    catch
                        hUnfolding.Verbose=evalin('base',strtrim(varargin{i}));
                    end
                else
                    hUnfolding.Verbose=varargin{i};
                end
                Verbose=true;
            otherwise
                fname=strtrim(varargin{i});
                coder.internal.errorIf(fname(1)=='-','dsp:dspunfold:UnknownOption',fname);
                coder.internal.errorIf(FunctionName,'dsp:dspunfold:MultipleInputFunctionName');
                hUnfolding.FunctionName=fname;
                FunctionName=true;
            end
            i=i+1;
        end

        ValidateOptions(hUnfolding,false);

        ValidateCompiler(hUnfolding);
        if~StateLength
            coder.internal.warning('dsp:dspunfold:NoStateLength');
        end
        generate(hUnfolding);
        clear hUnfolding;
    catch err
        clear hUnfolding;
        error(err.identifier,strrep(err.message,'\','\\'));
    end
end


