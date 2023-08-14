function rfplot(obj,varargin)




    if~obj.Computable
        return
    end
    idxparent=(strcmpi(varargin,'Parent'));
    if any(idxparent)
        idxVal=find(idxparent);
        ax=varargin{idxVal+1};
        varargin=varargin([1:idxVal-1,idxVal+2:end]);
        narg=nargin-2;
    else
        ax=[];
        narg=nargin;
    end

    plotBandwidth=[];
    resolution=[];

    if isscalar(obj.InputFrequency)

        idxFRange=(strcmpi(varargin,'Bandwidth'));
        if any(idxFRange)
            idxVal=find(idxFRange);
            plotBandwidth=varargin{idxVal+1};
            varargin=varargin([1:idxVal-1,idxVal+2:end]);
            narg=narg-2;
            validateattributes(plotBandwidth,{'numeric'},...
            {'nonempty','scalar','real','nonnan','finite','positive'}...
            ,'Bandwidth');
        end
        idxRes=(strcmpi(varargin,'Resolution'));
        if any(idxRes)
            idxVal=find(idxRes);
            resolution=varargin{idxVal+1};
            varargin=varargin([1:idxVal-1,idxVal+2:end]);
            narg=narg-2;
            validateattributes(resolution,{'numeric'},...
            {'nonempty','scalar','nonnan','finite','integer','positive'}...
            ,'Resolution');
        end
    end

    m=2;
    n=1;

    if narg==1
        fld='Sparameters';
    elseif narg==2
        fld=varargin{1};
        validateattributes(fld,{'char','string'},{'nonempty','row'})
    else
        fld='Sparameters';
        validateattributes(varargin{1},{'numeric'},...
        {'integer','positive','scalar','real','nonzero','<=',2},...
        'rfplot','m',2);
        validateattributes(varargin{2},{'numeric'},...
        {'integer','positive','scalar','real','nonzero','<=',2},...
        'rfplot','n',3);
        m=varargin{1};
        n=varargin{2};
    end


    b=clone(obj);
    b.AutoUpdate=false;
    RF=b.InputFrequency;


    if isempty(plotBandwidth)&&isempty(resolution)

        if isscalar(RF)


            changeSolverToFriis(b);
            plotBandwidth=b.SignalBandwidth;
            resolution=51;
            b.InputFrequency=linspace(RF-plotBandwidth/2,RF+plotBandwidth/2,resolution);
            computeBudget(b);
        else


            [dataAvailable,~,b]=checkSolverDataAndUpdateSolver(b);
            if~dataAvailable
                computeBudget(b);
            end
        end
    else

        if isempty(plotBandwidth)
            plotBandwidth=b.SignalBandwidth;
        end

        if isempty(resolution)
            resolution=51;
        end

        if resolution==1


            dataAvailable=~isempty(b.(b.Solver).OutputPower);
            if~dataAvailable
                computeBudget(b);
            end
        else


            changeSolverToFriis(b);
            b.InputFrequency=linspace(RF-plotBandwidth/2,RF+plotBandwidth/2,resolution);
            computeBudget(b);
        end

    end
    nfreq=numel(b.InputFrequency);




    strval={'Pout','GainT','NF','OIP3','IIP3','SNR',...
    'Output Power',...
    'Transducer Gain',...
    'Noise Figure',...
    'Output Third-Order Intercept',...
    'Input Third-Order Intercept',...
    'Signal-to-Noise Ratio',...
    'Sparameters'};

    ip2Val={'OIP2','IIP2',...
    'Output Second-Order Intercept',...
    'Input Second-Order Intercept'};
    if strcmpi(b.Solver,'Friis')
        str=validatestring(fld,strval);
    else
        str=validatestring(fld,[strval,ip2Val]);
    end


    if isempty(b.Friis.OutputPower)
        computeBudget(b);
    end
    nelem=numel(b.Elements);
    [Rfreq,~,RfreqUnit]=engunits(b.InputFrequency);
    stage=ones(nfreq,nelem);
    stage=cumsum(stage,2);

    if isempty(ax)
        fig=figure;
        ax=axes(fig);
    else
        fig=ax.Parent;
    end

    if isa(fig,'matlab.ui.Figure')
        set(fig,'Name',str)
    end

    switch lower(fld)
    case{'pout','output power'}
        plotData=b.OutputPower;
        titleStr='Output Power ';
        unit='dBm';
        delete(findobj(fig,'Tag','SparametersToolbar'))

    case{'gaint','transducer gain'}
        plotData=b.TransducerGain;
        titleStr='Transducer Gain ';
        unit='dB';
        delete(findobj(fig,'Tag','SparametersToolbar'))

    case{'nf','noise figure'}
        plotData=b.NF;
        titleStr='Noise Figure ';
        unit='dB';
        delete(findobj(fig,'Tag','SparametersToolbar'))

    case{'oip3','output third-order intercept'}
        plotData=b.OIP3;
        titleStr='Output Third-Order Intercept ';
        unit='dBm';
        delete(findobj(fig,'Tag','SparametersToolbar'))

    case{'iip3','input third-order intercept'}
        plotData=b.IIP3;
        titleStr='Input Third-Order Intercept ';
        unit='dBm';
        delete(findobj(fig,'Tag','SparametersToolbar'))
    case{'oip2','output second-order intercept'}
        plotData=b.OIP2;
        titleStr='Output Second-Order Intercept ';
        unit='dBm';
        delete(findobj(fig,'Tag','SparametersToolbar'))

    case{'iip2','input second-order intercept'}
        plotData=b.IIP2;
        titleStr='Input Second-Order Intercept ';
        unit='dBm';
        delete(findobj(fig,'Tag','SparametersToolbar'))

    case{'snr','signal-to-noise ratio'}
        plotData=b.SNR;
        titleStr='Signal-to-Noise Ratio ';
        unit='dB';
        delete(findobj(fig,'Tag','SparametersToolbar'))

    case{'sparameters'}
        h=findobj(fig,'Tag','SparametersToolbar');
        if~isempty(h)
            delete(h);
        end


        if isa(fig,'matlab.ui.Figure')
            createSparametersToolbar(fig,b,m,n);
        end

        data=arrayfun(@rfparam,b.CascadeS,m*ones(nfreq,nelem),...
        n*ones(nfreq,nelem));
        func=@(x)20*log10(abs(x));
        plotData=func(data);
        titleStr=['s',num2str(m),num2str(n),' '];
        unit='dB';
        str='Magnitude';
    end
    solverVal=regexprep(b.Solver,{'armonic','alance'},'');
    if isscalar(b.InputFrequency)

        plot(ax,stage,plotData,'b-*','LineWidth',2)
        titleStr=[titleStr,newline,solverVal,' Analysis - ',num2str(Rfreq),RfreqUnit,'Hz'];
    else
        plot3(ax,stage,Rfreq,plotData,'-','LineWidth',2)
        titleStr=[titleStr,newline,solverVal,' Analysis'];
    end


    updateAxisLabels(ax,str,unit,titleStr,RfreqUnit,nelem,Rfreq)


    if isa(fig,'matlab.ui.Figure')
        dcm=datacursormode(fig);
        set(dcm,'UpdateFcn',@(h,e)plotUpdateFcn(e,b,str,unit))
    end

    axis(ax,'square')
end

function txt=plotUpdateFcn(e,b,str,unit)

    pos=get(e,'Position');
    ind=get(e,'DataIndex');
    finVal=b.InputFrequency;
    if~isscalar(finVal)
        finVal=b.InputFrequency(ind);
        [fIn,~,fInUnit]=engunits(finVal);
        [fOut,~,fOutUnit]=engunits(b.OutputFrequency(ind,pos(1)));
        txt={...
        sprintf('Fin: %.4g %sHz',fIn,fInUnit),...
        sprintf('Cascade: 1..%d',pos(1)),...
        sprintf('Fout: %.4g %sHz',fOut,fOutUnit),...
        sprintf('%s: %.4g %s',str,pos(3),unit)};
    else
        [fIn,~,fInUnit]=engunits(finVal);
        [fOut,~,fOutUnit]=engunits(b.OutputFrequency(ind));
        txt={...
        sprintf('Fin: %.4g %sHz',fIn,fInUnit),...
        sprintf('Cascade: 1..%d',pos(1)),...
        sprintf('Fout: %.4g %sHz',fOut,fOutUnit),...
        sprintf('%s: %.4g %s',str,pos(2),unit)};
    end



end

function createSparametersToolbar(fig,b,m,n)

    h=uitoolbar(fig,'Tag','SparametersToolbar','UserData',{b,m,n});
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
    if isscalar(b.InputFrequency)

        Enable='off';TooltipString='Cannot compute group delay for a single frequency';
    else
        Enable='on';TooltipString='Group Delay';
    end
    uitoggletool(h,'CData',bmp.grpdelay,'TooltipString',...
    TooltipString,'HandleVisibility','on','Tag',...
    'groupdelay','Enable',Enable,'ClickedCallback',...
    {@modifyplot,fig});
end


function modifyplot(h,~,f)


    pa=findobj(f,'Tag','SparametersToolbar');
    set(pa.Children,'State','off')


    set(h,'State','on')


    ax=f.CurrentAxes;
    titleStr=ax.Title.String;



    b=pa.UserData{1};
    m=pa.UserData{2};
    n=pa.UserData{3};

    nelem=numel(b.Elements);
    nfreq=numel(b.InputFrequency);
    stage=ones(nfreq,nelem);
    stage=cumsum(stage,2);

    data=arrayfun(@rfparam,b.CascadeS,m*ones(nfreq,nelem),...
    n*ones(nfreq,nelem));


    layer=b.OutputFrequency<0;
    data(layer)=conj(data(layer));


    switch h.Tag
    case 'magnitude'
        func=@(x)20*log10(abs(x));
        str='Magnitude';unit='dB';
    case 'phase'
        func=@(x)(180/pi)*unwrap(angle(x));
        str='Phase';unit='degrees';
    case 'phasedelay'
        func=@(x)-unwrap(angle(x))./(2*pi*b.InputFrequency);
        str='Phase delay';unit='s';
    case 'groupdelay'
        func=@(x)groupdelay(x,b.InputFrequency);
        str='Group delay';
        unit='s';
    end


    freqVal=b.InputFrequency;
    [freq,~,freqUnit]=engunits(freqVal);
    if ishold(ax)
        cla(ax)
    end
    if isscalar(freq)
        plot(ax,stage,func(data),'b-*','LineWidth',2)
    else
        plot3(ax,stage,freq,func(data),'-','LineWidth',2);
    end
    updateAxisLabels(ax,str,unit,titleStr,freqUnit,nelem,freq)
    dcm=datacursormode(f);
    set(dcm,'UpdateFcn',@(h,e)plotUpdateFcn(e,b,str,unit))
    axis(ax,'square')
end

function updateAxisLabels(ax,str,unit,titleStr,freqUnit,nelem,freq)


    c="1.."+[1:nelem];
    if~isscalar(freq)
        zlabel(ax,sprintf('%s (%s)',str,unit))
        xlabel(ax,'Cascade')
        ylabel(ax,sprintf('Input Frequency (%sHz)',freqUnit))
        lgd=legend(ax,c,'Location','northeastoutside');
        title(lgd,'Cascade')
    else
        ylabel(ax,sprintf('%s (%s)',str,unit))
        xlabel(ax,'Cascade')
    end
    title(ax,titleStr);
    grid(ax,'on');
    set(ax,'XLim',[0.5,nelem+0.5])
    set(ax,'XTickMode','manual')
    set(ax,'XTick',(1:nelem))
    set(ax,'XTickLabel',c)
end

function gd=groupdelay(origSIJ,gdfreq)

    angIJ=unwrap(angle(origSIJ));
    numGD=size(gdfreq,1);
    gd=zeros(size(angIJ));

    if numGD>2
        gd(2:end-1,:)=(angIJ(3:end,:)-angIJ(1:end-2,:))./...
        (gdfreq(1:end-2,:)-gdfreq(3:end,:));
    end
    gd(1,:)=(angIJ(2,:)-angIJ(1,:))./(gdfreq(1,:)-gdfreq(2,:));
    gd(end,:)=(angIJ(end,:)-angIJ(end-1))./...
    (gdfreq(end-1)-gdfreq(end));
    gd=gd/(2*pi);
end

function changeSolverToFriis(obj)
    if~strcmpi(obj.Solver,'Friis')
        warning(message('rf:rfbudget:ChangingToFriis'))
        obj.Solver='Friis';
    end
end

function[dataAvailable,Solver,obj]=checkSolverDataAndUpdateSolver(obj)
    dataAvailable=1;
    if strcmpi(obj.Solver,'Friis')
        if isempty(obj.Friis.OutputPower)
            dataAvailable=0;
        end
    else
        if isempty(obj.HarmonicBalance.OutputPower)

            changeSolverToFriis(obj);
            if isempty(obj.Friis.OutputPower)
                dataAvailable=0;
            end
        end
    end
    Solver=obj.Solver;
end