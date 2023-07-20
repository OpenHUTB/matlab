



























function opts=getTraceabilityMatrixOptions(varargin)

    if nargin==0
        opts=slreq.report.rtmx.utils.getDefaultOptions('file');
        return;
    end

    if nargin==1&&strcmpi(varargin{1},'current')
        configs=slreq.report.rtmx.utils.MatrixWindow.getCurrentConfig();
        if isempty(configs)
            opts=slreq.report.rtmx.utils.getDefaultOptions('file');
        else
            opts.leftArtifacts=configs.leftArtifacts;
            opts.topArtifacts=configs.topArtifacts;
            opts.options=slreq.matrix.Configuration('current');
        end
        return;
    end

    error(message('Slvnv:slreq_rtmx:APIErrorArgumentsForOptions'));
end

