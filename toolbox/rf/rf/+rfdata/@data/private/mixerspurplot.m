function varargout=mixerspurplot(varargin)




    nargoutchk(0,1);


    hlines=[];

    h=varargin{1};

    kindex=varargin{2};

    spurdata=get(h,'SpurPower');
    if isempty(spurdata)
        error(message('rf:rfdata:data:mixerspurplot:NoMixerSpur'))
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
    [~,~,xunit,xfactor]=scalingfrequency(h,sort(allxdata));
    xname='Freq';
    yname='Stage of cascade';
    zname='Power';
    zformat='dBm';

    fig=findfigure(h);
    hold_state=false;
    if~(fig==-1)
        hold_state=ishold;
    end
    if strncmpi(kindex,'all',3)
        all_xdata={};
        all_yydata={};
        all_zzdata={};
        indexes={};
        all_xdata{1}=[];
        all_xdata{2}=[];
        all_yydata{1}=[];
        all_yydata{2}=[];
        all_zzdata{1}=[];
        all_zzdata{2}=[];
        indexes{1}={};
        indexes{2}={};
        for k=1:nydata
            xdata=xfactor*spurdata.Freq{k};
            nxdata=numel(xdata);
            zdata=spurdata.Pout{k};
            zzdata=[];
            yydata=[];
            index={};
            zzdata(1:nxdata,1)=zdata;
            index(1:nxdata,1)=spurdata.Indexes{k};
            yydata(1:nxdata,1)=ydata(k)-1;
            all_xdata{1}=[all_xdata{1};NaN;xdata(1)];
            all_xdata{2}=[all_xdata{2};NaN;xdata(2:end)];
            all_yydata{1}=[all_yydata{1};NaN;yydata(1)];
            all_yydata{2}=[all_yydata{2};NaN;yydata(2:end)];
            numLines=size(zzdata,2);
            all_zzdata{1}=[all_zzdata{1};NaN(1,numLines);zzdata(1)];
            all_zzdata{2}=[all_zzdata{2};NaN(1,numLines);zzdata(2:end)];
            indexes{1}={indexes{1}{1:end},'',index{1}};
            indexes{2}={indexes{2}{1:end},'',index{2:end}};
        end
        if~all(isnan(all_xdata{2}))
            hlines(1,1)=stem3(all_xdata{1},all_yydata{1},...
            all_zzdata{1},'-b','fill',...
            'BaseValue',min(all_zzdata{2})-2);
            hold all;
            hlines(2,1)=stem3(all_xdata{2},all_yydata{2},...
            all_zzdata{2},'-r','fill',...
            'BaseValue',min(all_zzdata{2})-2);
            addlegend(h,hlines,{'Signal','Spurs'});
        else
            hlines(1,1)=stem3(all_xdata{1},all_yydata{1},...
            all_zzdata{1},'-b','fill',...
            'BaseValue',min(all_zzdata{1})-2);
            addlegend(h,hlines,{'Signal'});
        end
        zlabel(sprintf('%s [%s]',zname,zformat));

        xlabel(sprintf('%s %s',xname,xunit));
        ylabel(yname);
        set(gca,'ytick',1:nydata);
        view([58.5,26]);

        nhlines=numel(hlines);
        for k=1:nhlines
            linesinfo=currentlineinfo(h,'MixerSpur3',zname,xname,...
            all_xdata{k},xunit,modifyformat(h,zformat,2),'',h.ZS,...
            h.Z0,h.ZL,indexes{k});
            set(hlines(k),'UserData',linesinfo);
        end
        datatip(h,fig,hlines);
    else
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
        hlines(1,1)=stem(all_xdata{1},all_yydata{1},'-b','fill',...
        'BaseValue',min(all_yydata{1})-2);
        if~all(isnan(all_xdata{2}))
            hlines(1,1)=stem(all_xdata{1},all_yydata{1},'-b','fill',...
            'BaseValue',min(all_yydata{2})-2);
            hold all;
            hlines(2,1)=stem(all_xdata{2},all_yydata{2},'-r','fill',...
            'BaseValue',min(all_yydata{2})-2);
            addlegend(h,hlines,{'Signal','Spurs'});
        else
            hlines(1,1)=stem(all_xdata{1},all_yydata{1},'-b','fill',...
            'BaseValue',min(all_yydata{1})-2);
            addlegend(h,hlines,{'Signal'});
        end
        ylabel(sprintf('%s [%s]',zname,zformat));

        set(get(gca,'YLabel'),'Rotation',90.0);

        xlabel(sprintf('%s %s',xname,xunit));

        nhlines=numel(hlines);
        for k=1:nhlines
            linesinfo=currentlineinfo(h,'MixerSpur2',zname,xname,...
            all_xdata{k},regexprep(xunit,'[\[\]]',''),...
            modifyformat(h,zformat,2),'',h.ZS,h.Z0,h.ZL,indexes{k});
            set(hlines(k),'UserData',linesinfo);
        end
        datatip(h,fig,hlines);
    end
    grid on;
    if~hold_state
        hold off;
    end

    if nargout==1
        varargout{1}=hlines;
    end