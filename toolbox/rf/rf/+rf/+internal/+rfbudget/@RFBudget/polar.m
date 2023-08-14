function p=polar(obj,m,n,varargin)




    if~obj.Computable
        return
    end

    if numel(varargin)==1
        validateattributes(varargin{1},{'string','char'},{},...
        'polar','varargin',3)
    end

    if nargin==1
        m=1;n=1;
    else
        validateattributes(m,{'numeric'},...
        {'integer','positive','scalar','real','nonzero'},...
        'polar','m',1);
        validateattributes(n,{'numeric'},...
        {'integer','positive','scalar','real','nonzero'},...
        'polar','n',2);
    end

    PV_pairs=varargin;

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

    nStages=size(b.CascadeS,2);
    nFreq=size(b.CascadeS,1);

    data=arrayfun(@rfparam,b.CascadeS,m*ones(nFreq,nStages),...
    n*ones(nFreq,nStages));

    post_pv='AntennaMetrics';
    index=find(strcmpi(PV_pairs,post_pv));
    if any(index)
        error(message('siglib:polarpattern:RFMetrics'));
    end

    str='s'+string(m)+string(n);
    index=find(strcmpi(PV_pairs,'Parent'));
    if any(index)
        fig=varargin{index+1};
        clo(fig);
        if isprop(fig,'Name')&&isprop(fig,'Toolbar')
            fig.Name=str;fig.ToolBar='none';
        end
    else
        fig=figure('Name',str,'Toolbar','none');
    end


    p=polarpattern(fig,data(:,1),PV_pairs{:});
    if builtin('license','test','Antenna_Toolbox')
        hc=p.UIContextMenu_Master;
        h1=hc.findobj('Label','Antenna Metrics','-depth',1);
        h1.Visible='off';
        hm=hc.findobj('Label','Measurements','-depth',1);
        setappdata(hm,'RFMetrics',true);
        hd=p.UIContextMenu_Grid;
        setappdata(hd,'RFMetrics',true);
    end

    post_pv='LineWidth';
    if~any(strcmpi(PV_pairs,post_pv))
        p.LineWidth=2;
    end






    c=cell(1,nelem);
    c{1}=sprintf('1..%d',1);
    for i=2:nelem
        p.add(data(:,i));
        c{i}=sprintf('1..%d',i);
    end

    post_pv='LegendLabels';
    if~any(strcmpi(PV_pairs,post_pv))
        p.LegendLabels=c;
        title(p.hLegend,'Cascade');
    end

    post_pv='TitleTop';
    if~any(strcmpi(PV_pairs,post_pv))
        p.TitleTop=str;
    end

    if isa(fig,'matlab.ui.Figure')
        dcm=datacursormode(fig);
        set(dcm,'UpdateFcn',@(h,e)plotUpdateFcn(e,b,str,p));
    end
end

function txt=plotUpdateFcn(e,b,name,p)

    pos=get(e,'Position');
    ind=get(e,'DataIndex');


    fOutInd=strrep(e.Target.DisplayName,...
    internal.polariCommon.getUTFCircleChar('A'),'');
    [fIn,~,fInUnit]=engunits(b.InputFrequency(ind));
    [fOut,~,fOutUnit]=engunits(b.OutputFrequency(ind,...
    str2double(fOutInd(4:end))));


    txt={...
    sprintf('Fin: %.4g %sHz',fIn,fInUnit),...
    sprintf('Cascade: %s',fOutInd),...
    sprintf('Fout: %.4g %sHz',fOut,fOutUnit),...
    getComplexStringMA(pos,name,p)};
end

function outstr=getComplexStringMA(pos,name,p)

    normMag=norm(pos(1:2));
    userMag=transformNormMagToUserMag(p,normMag);
    normRad=atan2(pos(2),pos(1));
    userDeg=transformNormRadToUserDeg(p,normRad);
    s_ang=internal.polariCommon.sprintfMaxNumFracDigits(userDeg,1);
    s_mag=internal.polariCommon.sprintfMaxNumTotalDigits(userMag,4);
    outstr=name+" = |"+s_mag+"|, "+s_ang+"[deg]";
end
