function varargout=mixerimtspurplot(varargin)



    nargoutchk(0,1);


    hlines=[];

    h=varargin{2};

    kindex=varargin{4};

    spurdata=varargin{3};
    if isempty(spurdata)
        error(message('rf:shared:NoMixerSpur'));
    end

    allxdata=[];
    nallxdata=0;
    nydata=numel(spurdata.Freq);
    ydata=1:nydata;
    ydata=ydata(:);
    for k=1:nydata
        freq=spurdata.Freq{k};
        kk=numel(freq);
        allxdata(nallxdata+1:nallxdata+kk)=freq(1:kk);
        nallxdata=nallxdata+kk;
    end
    s=settings;
    if isprop(s,'rf')
        axisHasBeenSpecified=s.rf.PlotAxis.UseEngUnits.ActiveValue;
    else
        axisHasBeenSpecified=true;
    end
    if axisHasBeenSpecified
        [~,xfactor,funit]=engunits(allxdata);
    end

    xunit=(horzcat(funit,'Hz'));
    xname='Frequency';
    yname='Stage of cascade';
    zname='Power';
    zformat='dBm';

    fig=varargin{end};






































































    kindex=kindex+1;
    xdata=xfactor*spurdata.Freq{kindex};
    zdata=spurdata.Pout{kindex};
    index=spurdata.Indexes{kindex};
    all_xdata={};
    all_yydata={};
    all_xdata{1}=[];
    all_yydata{1}=[];
    all_xdata{1}=xdata(1);
    all_yydata{1}=zdata(1);
    indexes=cell(2,2);
    indexes{1,1}=index(1);


    all_xdata{2}=[];
    all_yydata{2}=[];
    all_xdata{2}=xdata(2:end);
    all_yydata{2}=zdata(2:end);
    indexes{2,1}=index(2:end)';

    ax=varargin{end};
    hlines(1,1)=stem(ax,all_xdata{1},all_yydata{1},'-b','fill',...
    'BaseValue',min(all_yydata{1})-2);
    if~all(isnan(all_xdata{2}))
        hlines(1,1)=stem(ax,all_xdata{1},all_yydata{1},'-b','fill',...
        'BaseValue',min(all_yydata{2})-2);
        hold(ax,'on');
        hlines(2,1)=stem(ax,all_xdata{2},all_yydata{2},'-r','fill',...
        'BaseValue',min(all_yydata{2})-2);
        legend(ax,{'Signal','Spurs'});
        ylabel(ax,sprintf('%s [%s]',zname,zformat))
        xlabel(ax,sprintf('%s [%s]',xname,xunit))
        grid(ax,'on')
        titleStr='Mixer Spurs';
        title(ax,titleStr);
    else
        hlines(1,1)=stem(ax,all_xdata{1},all_yydata{1},'-b','fill',...
        'BaseValue',min(all_yydata{1})-2);
        legend(ax,{'Signal'});
        ylabel(ax,sprintf('%s [%s]',zname,zformat))
        xlabel(ax,sprintf('%s [%s]',xname,xunit))
        grid(ax,'on')
        titleStr='Mixer Signal';
        title(ax,titleStr);
    end

    nhlines=numel(hlines);
    for k=1:nhlines
        linesinfo=currentlineinfo(h,'MixerSpur2',zname,xname,...
        all_xdata{k},regexprep(xunit,'[\[\]]',''),...
        'dBm','',h.Impedance,h.Impedance,h.Impedance,indexes{k});
        set(hlines(k),'UserData',linesinfo);
    end
    datatip(h,fig,hlines);

    hold(ax,'off')
    if nargout==1
        varargout{1}=hlines;
    end

    function result=currentlineinfo(h,type,name,xname,xdata,xunit,...
        yunit,other,Zs,Z0,Zl,indexes)


        result.Type=type;
        result.Name=name;
        result.Xname=xname;
        result.XData=xdata;
        result.XUnit=xunit;
        result.YUnit=yunit;
        if nargin==7
            other='';
            Zs=50;
            Z0=50;
            Zl=50;
            indexes={};
        elseif nargin==8
            Zs=50;
            Z0=50;
            Zl=50;
            indexes={};
        elseif nargin==9
            Z0=50;
            Zl=50;
            indexes={};
        elseif nargin==10
            Zl=50;
            indexes={};
        elseif nargin==11
            indexes={};
        end
        result.OtherInfo=other;
        result.Zs=Zs;
        result.Z0=Z0;
        result.Zl=Zl;
        result.Indexes=indexes;
    end

    function datatip(~,fig,hLines)


        if fig==-1
            fig=gcf;
        end

        nhLines=numel(hLines);
        for k=1:nhLines

            hBehavior=hggetbehavior(hLines(k),'DataCursor');
            lineinfo=get(hLines(k),'UserData');
            switch lineinfo.Type
            case 'MixerSpur2'
                set(hBehavior,'UpdateFcn',{@localStringFcn7,hLines(k)});
            case 'MixerSpur3'
                set(hBehavior,'UpdateFcn',{@localStringFcn8,hLines(k)});
            end
        end
    end

    function[str]=localStringFcn7(~,hDataCursor,hLine)

        pos=get(hDataCursor,'Position');
        dindex=get(hDataCursor,'DataIndex');

        lineinfo=get(hLine,'UserData');
        xdata=lineinfo.XData;
        xunit=lineinfo.XUnit;
        yunit=lineinfo.YUnit;
        indexes=lineinfo.Indexes;
        other=lineinfo.OtherInfo;
        xd=xdata(dindex);

        str{1}=sprintf('%s = %s %s',indexes{dindex},num2str(xd),xunit);
        str{2}=sprintf('%s %s',num2str(pos(2)),yunit);
        if~isempty(other)
            str{3}=other;
        end
    end

    function[str]=localStringFcn8(~,hDataCursor,hLine)

        pos=get(hDataCursor,'Position');
        dindex=get(hDataCursor,'DataIndex');

        lineinfo=get(hLine,'UserData');
        xdata=lineinfo.XData;
        xunit=lineinfo.XUnit;
        yunit=lineinfo.YUnit;
        indexes=lineinfo.Indexes;
        other=lineinfo.OtherInfo;
        xd=xdata(int16(dindex));

        str{1}=sprintf('%s = %s %s',indexes{dindex},num2str(xd),xunit);
        str{2}=sprintf('%s [%s]',num2str(pos(3)),yunit);
        if~isempty(other)
            str{3}=other;
        end

    end
end