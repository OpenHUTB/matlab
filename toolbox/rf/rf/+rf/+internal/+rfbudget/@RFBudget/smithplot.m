function p=smithplot(obj,m,n,varargin)




    if~obj.Computable
        return
    end
    index=find(strcmp(varargin,'Parent'),1);
    if index
        fig=varargin{index+1};
    else
        fig=figure;
    end

    if numel(varargin)==1
        validateattributes(varargin{1},{'string','char'},{},...
        'smithplot','varargin',3)
    end

    validateattributes(m,{'numeric'},...
    {'integer','positive','scalar','real','nonzero'},...
    'smithplot','m',1);
    validateattributes(n,{'numeric'},...
    {'integer','positive','scalar','real','nonzero'},...
    'smithplot','n',2);
    if m~=n
        error(message('rf:rfbudget:SmithRefCoefficent'));
    end

    b=clone(obj);

    if~strcmpi(b.Solver,'Friis')
        warning(message('rf:rfbudget:ChangingToFriis'))
        b.AutoUpdate=false;
        b.Solver='Friis';
    end
    RF=b.InputFrequency;


    if isscalar(RF)
        BW=b.SignalBandwidth;
        nfreq=51;
        b.InputFrequency=linspace(RF-BW/2,RF+BW/2,nfreq);
    end
    computeBudget(b);
    nelem=numel(b.Elements);

    str='s'+string(m)+string(n);
    if isprop(fig,'Name')
        set(fig,'Name',str)
    end
    PV_pairs=varargin;
    p=smithplot(fig,PV_pairs{:});

    post_pv='LineWidth';
    if~any(strcmpi(PV_pairs,post_pv))
        p.LineWidth=2;
    end

    nStages=size(b.CascadeS,2);
    nFreq=size(b.CascadeS,1);

    data=arrayfun(@rfparam,b.CascadeS,m*ones(nFreq,nStages),...
    n*ones(nFreq,nStages));

    freq=arrayfun(@rfparamfreq,b.CascadeS);

    c=cell(1,nelem);
    for i=1:nelem
        p.add(freq(:,i),data(:,i));
        c{i}=sprintf('1..%d',i);
    end

    post_pv='LegendLabels';
    if~any(strcmpi(PV_pairs,post_pv))
        p.LegendLabels=c;
        title(p.hLegend,'Cascade')
    end

    post_pv='TitleTop';
    if~any(strcmpi(PV_pairs,post_pv))
        p.TitleTop=str;
    end

    if isa(fig,'matlab.ui.Figure')
        dcm=datacursormode(fig);
        set(dcm,'UpdateFcn',@(h,e)plotUpdateFcn(p,e,b,str))
    end

    p.NextPlot='replace';
end

function txt=plotUpdateFcn(p,e,b,name)

    pos=get(e,'Position');
    ind=get(e,'DataIndex');


    pos=pos(1)+1i*pos(2);
    [fIn,~,fInUnit]=engunits(b.InputFrequency(ind));
    [fOut,~,fOutUnit]=engunits(b.OutputFrequency(ind,...
    str2double(e.Target.DisplayName(4:end))));


    txt={...
    sprintf('Fin: %.4g %sHz',fIn,fInUnit),...
    sprintf('Cascade: %s',e.Target.DisplayName),...
    sprintf('Fout: %.4g %sHz',fOut,fOutUnit),...
    getComplexStringMA(pos,name)};
    switch lower(p.GridType)
    case{'z','y'}
        txt{end+1}=getComplexStringRI(pos,p.GridType);
    otherwise
        txt_temp=getComplexStringRI(pos,p.GridType);
        txt{end+1}=txt_temp{1};
        txt{end+1}=txt_temp{2};
    end
end

function outstr=getComplexStringMA(input,name)

    mag=abs(input);ang=angle(input)*180/pi;
    outstr=sprintf('%s = |%6.4f|, %4.1f [deg]',name,mag,ang);
end

function str=getComplexStringRI(pos,charttype)

    z=gamma2z(pos,1);
    y=g2y(pos);
    switch lower(charttype)
    case 'z'
        str=getComplexStringRI2(z,'Z');
    case 'y'
        str=getComplexStringRI2(y,'Y');
    otherwise
        str={...
        getComplexStringRI2(z,'Z'),...
        getComplexStringRI2(y,'Y')};
    end
end

function outstr=getComplexStringRI2(input,name)
    r=real(input);x=imag(input);
    if x>0
        outstr=sprintf('%s = %5.3f + j%5.3f',name,r,x);
    elseif x<0
        outstr=sprintf('%s = %5.3f - j%5.3f',name,r,-x);
    else
        outstr=sprintf('%s = %5.3f',name,r);
    end
end


function y=g2y(g)

    y=(1-g)./(1+g);
end

function data=rfparamfreq(obj)

    data=obj.Frequencies;
end
