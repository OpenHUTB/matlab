function op=create_impl(varargin)






    if nargin<1
        msg=message('MATLAB:minrhs');
        MException(msg).throw();
    end

    varargin=cellfun(@(x)pm_charvector(x,@(cv)cv,x),varargin,'UniformOutput',false);
    argClass=class(varargin{1});

    switch argClass
    case 'simscape.logging.Node'
        fcn=@simscape.op.internal.log2op;
    case{'double','char'}
        lValidateModel(bdroot(varargin{1}));
        fcn=@simscape.op.internal.sl2op;
    otherwise
        msg=message('physmod:simscape:op:create:UnsupportedArgumentForCreate');
        MException(msg).throw();
    end

    try
        op=fcn(varargin{:});
    catch ME
        ME.throwAsCaller();
    end


end

function lValidateModel(model)



    simMode=get_param(model,'SimulationMode');
    supportedModes={'normal','accelerator'};
    unsupportedSimMode=~any(strcmpi(simMode,supportedModes));
    if unsupportedSimMode
        str=sprintf('{''%s''}',strjoin(supportedModes,''', '''));
        pm_error('physmod:simscape:op:create:UnsupportedSimulationMode',...
        simMode,str);
    end
end
