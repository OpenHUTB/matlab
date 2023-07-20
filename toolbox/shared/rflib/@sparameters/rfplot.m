function varargout=rfplot(obj,varargin)




    if nargin>1
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    nargoutchk(0,1)

    numsparamargs=nargin;
    if any(strcmp(varargin,'Parent'))
        hax=varargin{end};
        if~strcmp(hax.Type,'axes')
            error(message('rflib:shared:RFPlotTargetHandle',class(hax)))
        end
        appdata=get(hax,'ApplicationData');
        isfirstplot=~ishold(hax)||~isfield(appdata,'RFNetParamInfo');
        varargin=varargin(1:end-2);
        numsparamargs=numsparamargs-2;
    else
        narginchk(1,5)
        hfig=get(0,'CurrentFigure');
        if(isempty(hfig))
            isfirstplot=true;
        else
            hax=get(hfig,'CurrentAxes');
            if isempty(hax)
                isfirstplot=true;
            else
                appdata=get(hax,'ApplicationData');
                isfirstplot=~ishold(hax)||~isfield(appdata,'RFNetParamInfo');
            end
        end
        hax=gca;
    end

    if isfirstplot
        rfstruct.FcnType={};
        rfstruct.Lines=gobjects(0);
        oldlgndtxt={};
    else
        rfstruct=appdata.RFNetParamInfo;
        hlegend=get(hax,'Legend');
        oldlgndtxt=get(hlegend,'String');
    end

    numports=obj.NumPorts;

    lspec='-';
    mkr='';
    func=@(x)20*log10(abs(x));
    v=[1:obj.NumPorts,1:obj.NumPorts];
    rrng=zeros(size(unique(nchoosek(v,2),'rows','stable'),1),1);
    crng=rrng;
    index=1;
    for z=1:obj.NumPorts
        for w=1:obj.NumPorts
            rrng(index,1)=w;
            crng(index,1)=z;
            index=index+1;
        end
    end

    ystr='Magnitude (dB)';
    fcnstr='dB';

    s=settings;
    if isprop(s,'rf')
        axisHasBeenSpecified=s.rf.PlotAxis.UseEngUnits.ActiveValue;
    else
        axisHasBeenSpecified=true;
    end

    if numsparamargs>1

        if isvector(varargin{1})&&isnumeric(varargin{1})

            rrng=varargin{1};
            validateattributes(rrng,{'numeric'},...
            {'integer','positive','<=',numports},'rfplot','I',2)
            if isscalar(rrng)&&(nargin==2||ischar(varargin{2}))
                crng=1:obj.NumPorts;
                rrng=rrng*ones(size(crng'));
                ports=unique([[rrng;crng'],[crng';rrng]],"rows","stable");
                rrng=ports(:,1);
                crng=ports(:,2);
                idx=2;
            else
                crng=varargin{2};
                validateattributes(crng,{'numeric'},...
                {'integer','positive','<=',numports},'rfplot','J',3)
                idx=3;
                c_rows=zeros(numel(rrng)*numel(crng),1);
                c_cols=c_rows;
                index=1;
                for m=1:numel(rrng)
                    for n=1:numel(crng)
                        c_rows(index)=rrng(m);
                        c_cols(index)=crng(n);
                        index=index+1;
                    end
                end
                rrng=c_rows;
                crng=c_cols;
            end
        elseif any(strcmpi(varargin{1},'diag'))||...
            any(strcmpi(varargin{1},'reflection'))||any(strcmpi(varargin{1},'self'))
            rrng=1:obj.NumPorts;
            crng=rrng;
            idx=2;
        elseif ischar(varargin{1})&&~isempty(regexp(varargin{1},'tri[ul]','once'))
            fn=str2func(varargin{1});
            ports=reshape(1:obj.NumPorts^2,size(obj.Parameters,[1,2]));
            if numsparamargs>2&&isscalar(varargin{2})
                kth=varargin{2};
                idx=3;
            else
                kth=0;
                idx=2;
            end
            [rrng,crng]=ind2sub(size(obj.Parameters,[1,2]),find(fn(ports,kth)));
            [~,I]=sort([rrng,crng],1);
            rrng=rrng(I(:,1));
            crng=crng(I(:,1));
        elseif iscell(varargin{1})
            ports=cell2mat(reshape(varargin{1},numel(varargin{1}),1));
            rrng=ports(:,1);
            crng=ports(:,2);
            idx=2;
        else
            idx=1;
        end

        funcHasBeenSpecified=false;
        lspecHasBeenSpecified=false;
        while idx<=numel(varargin)
            str=lower(varargin{idx});
            validateattributes(str,{'char'},{'row'},'rfplot','',idx+1)

            if any(strcmp(str,{'db','angle','real','imag','abs'}))
                if funcHasBeenSpecified
                    error(message('rflib:shared:RFPlotTooManyPlotFlags'))
                else
                    funcHasBeenSpecified=true;

                    fcnstr=str;
                    switch str
                    case 'angle'
                        func=@(x)180*unwrap(angle(x))/pi;
                        ystr='Angle (degrees)';
                    case 'real'
                        func=str2func(str);
                        ystr=sprintf('Re(%s-parameters)',obj.TypeFlag);
                    case 'imag'
                        func=str2func(str);
                        ystr=sprintf('Im(%s-parameters)',obj.TypeFlag);
                    case 'abs'
                        func=str2func(str);
                        ystr='Magnitude';
                    end
                end
            else

                if lspecHasBeenSpecified

                    error(message('rflib:shared:RFPlotTooManyLineSpecs'))
                else
                    [~,~,mkr,err]=colstyle(str);
                    if~isempty(err)
                        error(message(err.identifier))
                    end
                    lspecHasBeenSpecified=true;
                    lspec=str;
                end
            end
            idx=idx+1;
        end
    end


    freq=obj.Frequencies;
    if isscalar(freq)&&isempty(mkr)
        lspec=['o',lspec];
    end


    if strcmpi(fcnstr,'db')
        fcnstr='dB';
    end

    plotvar=zeros(numel(obj.Frequencies),numel(rrng));
    newlgndtxt=cell(1,numel(rrng));
    idx=1;
    for k=1:numel(crng)
        rr=rrng(k);
        cc=crng(k);
        plotvar(:,idx)=rfparam(obj,rr,cc);
        tempstr=calculateLegendText(obj,rr,cc);
        newlgndtxt{idx}=sprintf('%s(%s)',fcnstr,tempstr);
        rfstruct.FcnType{end+1}=fcnstr;
        idx=idx+1;
    end


    if axisHasBeenSpecified
        [freq,~,freqUnit]=engunits(freq);
    end
    newlines=plot(hax,freq,func(plotvar),lspec);
    rfstruct.Lines=[rfstruct.Lines;newlines(:)];


    if~all(strcmpi(rfstruct.FcnType{1},rfstruct.FcnType))
        ystr='';
    end

    ylabel(hax,ystr)

    if axisHasBeenSpecified
        xlabel(hax,sprintf('Frequency (%sHz)',freqUnit))
    else
        xlabel(hax,horzcat('Frequency (Hz)'))
    end

    lgd=legend(rfstruct.Lines,horzcat(oldlgndtxt,newlgndtxt),'AutoUpdate','off');
    ilegend=numel(get(lgd,'PlotChildren'))>1;
    if ilegend
        matlabshared.internal.InteractiveLegend(lgd);
    end
    grid(hax,'on')

    appdata=get(hax,'ApplicationData');
    appdata.RFNetParamInfo=rfstruct;
    set(hax,'ApplicationData',appdata)

    if nargout==1
        varargout{1}=newlines;
    end

    if strcmp(class(hax),'matlab.graphics.axis.Axes')&&ilegend %#ok<STISA> 
        fig=ancestor(hax,'Figure');
        addlistener(fig,'WindowMouseMotion',@(fig,ev)mb_Dispatch(fig,ev));
        if~isappdata(fig,'ShownInteractiveBehaviorBanner')
            setappdata(fig,'ShownInteractiveBehaviorBanner',false);
        end
    end
end

function mb_Dispatch(fig,~)








    if~getappdata(fig,'ShownInteractiveBehaviorBanner')
        setappdata(fig,'ShownInteractiveBehaviorBanner',true);
        c=internal.BannerMessage(fig);
        c.BackgroundColor=[255,255,225]./255;
        c.ForegroundColor='k';
        c.HighlightColor='k';
        c.RemainFor=8;
        c.Location='top';
        start(c,string(message('rflib:shared:RFPlotBanner')))
    end
end