function response=getFiguresSimple(varargin)


    p=inputParser;
    p.addParameter('width',0);
    p.addParameter('height',0);
    p.addParameter('clientDpi',0);
    p.parse(varargin{:});
    config=p.Results;

    if config.width>0&&config.height>0&&config.clientDpi>0
        hgState=mls.internal.figure.getFigures('',[config.width,config.height],...
        'changeAspectRatio',true,...
        'clientDpi',config.clientDpi);
    else
        hgState=mls.internal.figure.getFigures('','');
    end

    if numel(hgState.figures)>0
        figures=cell2mat(hgState.figures);
        response.figures=struct('title',{figures.title},...
        'width',{figures.imageWidth},...
        'height',{figures.imageHeight},...
        'base64Data',{figures.imageUrl});
    else
        response=struct('figures',...
        struct('title',{},'width',[],'height',[],'base64Data',{}));
    end

    if isfield(hgState,'fault')
        response.fault=hgState.fault;
    else
        response.fault=struct('faultCode','','message','');
    end


end

