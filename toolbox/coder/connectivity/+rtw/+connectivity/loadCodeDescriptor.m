



function handle=loadCodeDescriptor(varargin)

    args=varargin;
    if coder.internal.connectivity.featureOn('PSTestCodeInstrumentation')
        args{end+1}=247362;
    end

    handle=coder.getCodeDescriptor(args{:});
