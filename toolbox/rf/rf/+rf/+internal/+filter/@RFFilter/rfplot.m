function[hlines,haxes]=rfplot(obj,varargin)















    m=2;
    n=1;
    validateattributes(varargin{1},{'numeric'},...
    {'vector','real'},'rfplot','m',2);

    numsparamargs=nargin-1;
    if any(strcmp(varargin,'Parent'))
        numsparamargs=numsparamargs-2;
        h=varargin{end};
        if isscalar(h)&&ishghandle(h)
            if~isnumeric(h)&&isprop(h,'Type')
                switch h.Type
                case{'figure','uicontainer','uipanel','axes','uigridlayout'}
                    Fig=ancestor(h,'figure');
                otherwise
                    error(message('siglib:polarpattern:HandleInput'));
                end
            else
                Fig=ancestor(h,'figure');
            end
        end
    else
        Fig=figure('Name','S-Parameters 21');
        h=Fig;
    end

    sparam=sparameters(obj,varargin{1:numsparamargs});

    h_toolbar=findobj(Fig,'Tag','SparametersToolbar');
    if~isempty(h_toolbar)
        delete(h_toolbar);
    end


    createSparametersToolbar(Fig,sparam,m,n);
    data=rfparam(sparam,m,n);
    func=@(x)20*log10(abs(x));

    s=settings;
    if isprop(s,'rf')
        axisHasBeenSpecified=s.rf.PlotAxis.UseEngUnits.ActiveValue;
    else
        axisHasBeenSpecified=true;
    end

    if axisHasBeenSpecified
        [freq,~,freqUnit]=engunits(varargin{1});
    else
        freq=varargin{1};
        freqUnit='';
    end

    switch h.Type
    case 'figure'
        h=axes(Fig);
    case{'uipanel','uicontainer','uigridlayout'}
        h=axes(h);
    end

    hlines=plot(h,freq,func(data),'-','LineWidth',2);
    titleStr=['s',num2str(m),num2str(n),' vs. Frequency'];
    unit='dB';
    str='Magnitude';


    updateAxisLabels(Fig.CurrentAxes,str,unit,titleStr,freqUnit)



    haxes=Fig.CurrentAxes;
end

function createSparametersToolbar(fig,sparam,m,n)

    h=uitoolbar(fig,'Tag','SparametersToolbar','UserData',{sparam,m,n});
    load(fullfile(matlabroot,...
    'toolbox','rf','rf','+rf','+internal','+rfbudget','@RFBudget','filtdes_icons.mat'),...
    'bmp');

    uitoggletool(h,'CData',bmp.mag,'TooltipString','Magnitude Response',...
    'HandleVisibility','on','Tag','magnitude','ClickedCallback',...
    {@modifyplot,fig},'State','on');

    uitoggletool(h,'CData',bmp.phase,'TooltipString','Phase Response',...
    'HandleVisibility','on','Tag','phase','ClickedCallback',...
    {@modifyplot,fig});

    uitoggletool(h,'CData',bmp.phasedelay,'TooltipString',...
    'Phase Delay','HandleVisibility','on','Tag',...
    'phasedelay','ClickedCallback',...
    {@modifyplot,fig});

    uitoggletool(h,'CData',bmp.grpdelay,'TooltipString',...
    'Group Delay','HandleVisibility','on','Tag',...
    'groupdelay','ClickedCallback',...
    {@modifyplot,fig});
end

function modifyplot(h,~,f)


    pa=findobj(f,'Tag','SparametersToolbar');
    set(pa.Children,'State','off')


    set(h,'State','on')


    ax=f.CurrentAxes;
    titleStr=ax.Title.String;



    sparam=pa.UserData{1};
    m=pa.UserData{2};
    n=pa.UserData{3};
    data=rfparam(sparam,m,n);


    switch h.Tag
    case 'magnitude'
        func=@(x)20*log10(abs(x));
        str='Magnitude';unit='dB';
    case 'phase'
        func=@(x)(180/pi)*unwrap(angle(x));
        str='Phase';unit='degrees';
    case 'phasedelay'
        func=@(x)-unwrap(angle(x))./(2*pi*sparam.Frequencies);
        str='Phase delay';unit='s';
    case 'groupdelay'
        func=@(x)groupdelay(sparam);
        str='Group delay';
        unit='s';
    end

    s=settings;
    if isprop(s,'rf')
        axisHasBeenSpecified=s.rf.PlotAxis.UseEngUnits.ActiveValue;
    else
        axisHasBeenSpecified=true;
    end


    freq=sparam.Frequencies;
    if axisHasBeenSpecified
        [freq,~,freqUnit]=engunits(freq);
    else
        freqUnit='';
    end

    if ishold(ax)
        cla(ax)
    end
    plot(ax,freq,func(data),'-','LineWidth',2);
    updateAxisLabels(ax,str,unit,titleStr,freqUnit)
end

function updateAxisLabels(ax,str,unit,titleStr,freqUnit)


    ylabel(ax,sprintf('%s (%s)',str,unit))
    xlabel(ax,sprintf('Frequency (%sHz)',freqUnit))
    title(ax,titleStr)
    grid(ax,'on')
end
