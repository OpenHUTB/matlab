
function hgState=mobileGetChangedFigures(varargin)

    p=inputParser;
    p.addParameter('changeAspectRatio',false);
    p.addParameter('maxFigures',6);
    p.addParameter('dpi',0);
    p.addParameter('clientDpi',0);
    p.addParameter('method','print');
    p.addParameter('thumbnailSize',[]);
    p.addParameter('figureSize',[]);
    p.addParameter('imageFormat','png',@(arg)any(validatestring(arg,mls.internal.ImageUtils.SupportedImageFormats)));
    p.addParameter('imageQuality',1.0,@(arg)validateattributes(arg,{'double'},{'scalar','real','>',0,'<=',1.0}));
    p.parse(varargin{:});
    config=p.Results;
    if~isempty(config.thumbnailSize)
        if(isnumeric(config.thumbnailSize)&&isreal(config.thumbnailSize)&&...
            isvector(config.thumbnailSize)&&numel(config.thumbnailSize)==2&&...
            all(config.thumbnailSize>0))
            config.thumbnailSize=double(config.thumbnailSize(:)');
        else
            config.thumbnailSize=[];
        end
    end

    hgState.currentFigureId='';
    hgState.figures={};

    openFigures=get(groot,'Children');
    numFigures=numel(openFigures);
    openFigureIds=arrayfun(@(fig)mls.internal.handleID('toID',fig),openFigures,'UniformOutput',false);

    hgState.openFigureIds=openFigureIds;

    hgState.overMaxChangedFigureIds={};

    if numFigures>0

        if numFigures>config.maxFigures
            hgState.fault={};
            hgState.fault.faultCode='FigureService.MaxFiguresExceeded';
            hgState.fault.message='MaxFiguresExceeded';
        end

        hiddenHandles=get(groot,'ShowHiddenHandles');
        set(groot,'ShowHiddenHandles','on');
        hgState.currentFigureId=mls.internal.handleID('toID',gcf);
        set(groot,'ShowHiddenHandles',hiddenHandles);


        events=mls.internal.figure.MobileEventsController.getEvents();

        events=events(arrayfun(@(event)strcmp(event.type,'figure'),events));

        if numel(events)>0

            changedFigures=intersect(openFigures,arrayfun(@(event)event.payload,events),'stable');

            if(numel(changedFigures)>config.maxFigures)
                hgState.overMaxChangedFigureIds=arrayfun(@(fig)mls.internal.handleID('toID',fig),changedFigures(config.maxFigures+1:end),'UniformOutput',false);
                changedFigures=changedFigures(1:config.maxFigures);
            end

            hgState.figures=arrayfun(@(figure)mls.internal.figure.getFigureData(figure,[],...
            config.figureSize,config.changeAspectRatio,config.dpi,false,...
            config.clientDpi,'border',config.method,config.thumbnailSize,...
            config.imageFormat,config.imageQuality),...
            changedFigures,'UniformOutput',false);
        end
    end


end

