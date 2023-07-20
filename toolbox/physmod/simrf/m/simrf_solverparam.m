function[tones,harmonics,sim_noise,sep_stream,...
    noise_seed,RelTol,AbsTol,MaxIter,...
    ErrorEstimationType,SmallSignalApprox,...
    AllSimFreqs,SimFreqsInternal,spf]=simrf_solverparam(solver)




    sbp=lMaskParams(solver);
    tones=sbp.Tones;
    harmonics=sbp.Harmonics;
    sim_noise=sbp.SimulateNoise;

    sep_stream=false;
    noise_seed=0;
    RelTol=1e-3;
    AbsTol=1e-6;
    MaxIter=10;
    ErrorEstimationType=1;
    SmallSignalApprox=false;
    AllSimFreqs=true;
    SimFreqsInternal=[];
    spf=1;
    sbparent=get_param(solver,'Parent');





    if((isprop(get_param(sbparent,'Object'),'Type')&&...
        (strcmp(get_param(sbparent,'Type'),'block')))&&...
        ((isprop(get_param(sbparent,'Object'),'ClassName'))&&...
        (strcmp(get_param(sbparent,'ClassName'),'solver_simrf'))))
        rfsbp=lMaskParams(sbparent);
        if(sim_noise)
            if isfield(rfsbp,'Seed')
                sep_stream=~rfsbp.defaultRNG;
                if sep_stream
                    noise_seed=rfsbp.Seed;
                end
            end
        end
        if isfield(rfsbp,'RelTol')
            RelTol=rfsbp.RelTol;
        end
        if isfield(rfsbp,'AbsTol')
            AbsTol=rfsbp.AbsTol;
        end
        if isfield(rfsbp,'MaxIter')
            MaxIter=rfsbp.MaxIter;
        end
        if isfield(rfsbp,'ErrorEstimationType')
            ErrorEstimationType=rfsbp.ErrorEstimationType;
        end
        if isfield(rfsbp,'SmallSignalApprox')
            SmallSignalApprox=rfsbp.SmallSignalApprox;
        end
        if isfield(rfsbp,'AllSimFreqs')
            AllSimFreqs=rfsbp.AllSimFreqs;
        end
        if isfield(rfsbp,'SimFreqsInternal')



            SimFreqsInternal=eval(get_param(sbparent,'SimFreqsInternal'));
            lIsNumeric(sbparent,struct('SimFreqsInternal',SimFreqsInternal),'SimFreqsInternal');
            lIsNonnegative(sbparent,struct('SimFreqsInternal',SimFreqsInternal),'SimFreqsInternal');
        end
        if isfield(rfsbp,'SamplesPerFrame')
            spf=rfsbp.SamplesPerFrame;
        end
    end





    tests={
    @lIsNumeric,{'Tones'}
    @lIsNonnegative,{'Tones'}
    @lIsNumeric,{'Harmonics'}
    @lIsNonnegative,{'Harmonics'}
    @lIsInteger,{'Harmonics'}
    @lIsEqualLength,{'Harmonics','Tones'}
    };
    lTestBlock(solver,tests);
    tones=double(tones);
    harmonics=int32(harmonics);
    sim_noise=logical(sim_noise);
    sep_stream=logical(sep_stream);
    noise_seed=double(noise_seed);
    RelTol=double(RelTol);
    AbsTol=double(AbsTol);
    MaxIter=int32(MaxIter);
    ErrorEstimationType=int32(ErrorEstimationType);
    SmallSignalApprox=logical(SmallSignalApprox);
    AllSimFreqs=logical(AllSimFreqs);
    SimFreqsInternal=double(SimFreqsInternal);

end

function out=lMaskParams(block)
    ws=get_param(block,'MaskWSVariables');
    ca=[{ws.Name};{ws.Value}];
    out=struct(ca{:});
end

function lIsNumeric(block,values,name)
    if~isnumeric(values.(name))
        pm_error('simrf:create_dae:NumericParameter',name,block);
    end
end

function lIsNonnegative(block,values,name)
    if any(values.(name)<0)
        pm_error('simrf:create_dae:NonnegativeParameter',name,block);
    end
end

function lIsInteger(block,values,name)
    if any(floor(values.(name))~=values.(name))
        pm_error('simrf:create_dae:IntegerParameter',name,block);
    end
end

function lIsEqualLength(block,values,name1,name2)
    if length(values.(name1))~=length(values.(name2))
        pm_error('simrf:create_dae:SameLengthParameters',...
        name1,name2,block);
    end
end

function lTestBlock(block,tests)
    values=lMaskParams(block);
    for test=tests'
        [pred,names]=test{:};
        feval(pred,block,values,names{:});
    end
end


