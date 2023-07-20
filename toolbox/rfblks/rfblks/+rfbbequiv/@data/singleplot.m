function fig=singleplot(h,plottype,parameters,freq,pin,...
    conditions,plotfun)




    if nargin<4
        freq={};
    end
    if nargin<5
        pin={};
    end
    if nargin<6
        conditions={};
    end
    if nargin<7
        plotfun='plot';
    end
    if numel(freq)==1
        freq={'freq',freq{:}};
    end
    if numel(pin)==1
        pin={'pin',pin{:}};
    end
    set(h,'CompositePlot',false,'NeedReset',false);


    switch plottype
    case 'X-Y plane'
        plot(h,parameters{:},freq{:},pin{:},conditions{:},plotfun);
    case 'Plotyy'
        plotyy(h,parameters{:},freq{:},pin{:},conditions{:},plotfun);
    case 'Link budget'
        plot(h,'budget',parameters{:},freq{:},pin{:},conditions{:});
    case 'Polar plane'
        polar(h,parameters{[1:2:end-2,end-1,end]},freq{:},pin{:},...
        conditions{:});
    case 'Z Smith chart'
        smith(h,parameters{[1:2:end-2,end-1,end]},freq{:},pin{:},...
        conditions{:},'z');
    case 'Y Smith chart'
        smith(h,parameters{[1:2:end-2,end-1,end]},freq{:},pin{:},...
        conditions{:},'y');
    case 'ZY Smith chart'
        smith(h,parameters{[1:2:end-2,end-1,end]},freq{:},pin{:},...
        conditions{:},'zy');
    end
    fig=gcf;
    if any(strcmpi(parameters,'S11'))||any(strcmpi(parameters,'S12'))||...
        any(strcmpi(parameters,'S21'))||...
        any(strcmpi(parameters,'S22'))||...
        any(strcmpi(parameters,'LS11'))||...
        any(strcmpi(parameters,'LS12'))||...
        any(strcmpi(parameters,'LS21'))||...
        any(strcmpi(parameters,'LS22'))||...
        any(strcmpi(parameters,'VSWRIN'))||...
        any(strcmpi(parameters,'VSWROUT'))
        ht=title(['Z0 = ',num2str(h.Z0)]);
        if strfind(plottype,'Smith chart')
            posvec=get(ht,'Position');
            posvec(1)=-1.0;
            set(ht,'Position',posvec);
        end
    end

    name=get(fig,'Name');
    if isempty(name)||~ishold
        name=h.Block;
    end
    if~isempty(name)
        set(fig,'Name',name);
    else
        set(fig,'Name',gcb);
    end
    set(fig,'NumberTitle','off')
    set(h,'NeedReset',true);
