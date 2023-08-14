function hgState=getFigures(clientFigures,defaultFigureSize,varargin)

    p=inputParser;
    p.addParameter('changeAspectRatio',false);
    p.addParameter('maxFigures',6);
    p.addParameter('dpi',0);
    p.addParameter('clientDpi',0);
    p.addParameter('overflowStrategy','border',@(arg)any(strcmpi(arg,{'border','stretch'})));
    p.addParameter('skipImages',false);
    p.addParameter('method','print');
    p.addParameter('thumbnailSize',[]);
    p.addParameter('imageFormat','png',@(arg)any(validatestring(arg,mls.internal.ImageUtils.SupportedImageFormats)));
    p.addParameter('imageQuality',1.0,@(arg)validateattributes(arg,{'double'},{'scalar','real','>',0,'<=',1.0}));
    p.parse(varargin{:});
    config=p.Results;
    if~isempty(config.thumbnailSize)
        if(isnumeric(config.thumbnailSize)&&isreal(config.thumbnailSize)&&...
            isvector(config.thumbnailSize)&&numel(config.thumbnailSize)==2&&...
            config.thumbnailSize>0)
            config.thumbnailSize=double(config.thumbnailSize(:)');
        else
            config.thumbnailSize=[];
        end
    end

    hgState.currentFigureId='';
    hgState.figures={};

    openFigures=get(groot,'Children');
    numFigures=numel(openFigures);
    if numFigures>0

        if numel(openFigures)>config.maxFigures
            hgState.fault={};
            hgState.fault.faultCode='FigureService.MaxFiguresExceeded';
            hgState.fault.message='MaxFiguresExceeded';
        end

        numFigures=min(numFigures,config.maxFigures);

        hiddenHandles=get(groot,'ShowHiddenHandles');
        set(groot,'ShowHiddenHandles','on');
        hgState.currentFigureId=mls.internal.handleID('toID',gcf);
        set(groot,'ShowHiddenHandles',hiddenHandles);

        hgState.figures=cell(numFigures,1);

        openFigureIds=arrayfun(@(fig)mls.internal.handleID('toID',fig),openFigures,'UniformOutput',false);
        clientFigureIds=arrayfun(@(fig)fig.id,clientFigures,'UniformOutput',false);

        existingFigures=intersect(clientFigureIds,openFigureIds,'stable');

        if numel(existingFigures)<numFigures
            newFigures=setdiff(openFigureIds,clientFigureIds,'stable');
            newFigCount=numFigures-numel(existingFigures);
            finalFigures=cat(1,existingFigures,newFigures(1:newFigCount));
        else
            finalFigures=existingFigures;
        end

        for i=1:numFigures
            fig=mls.internal.handleID('toHandle',finalFigures{i});
            hgState.figures{i}=mls.internal.figure.getFigureData(fig,clientFigures,...
            defaultFigureSize,config.changeAspectRatio,config.dpi,config.skipImages,...
            config.clientDpi,config.overflowStrategy,config.method,config.thumbnailSize,...
            config.imageFormat,config.imageQuality);
        end
    end

end

