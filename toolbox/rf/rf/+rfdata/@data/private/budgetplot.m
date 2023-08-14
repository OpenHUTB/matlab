function varargout=budgetplot(h,zdata,znames,zformat,xdata,xparam,xformat)




    nargoutchk(0,1);


    numtrace=numel(zdata);

    xdata=xdata{1};
    [xname,xunit]=xaxis(h,xparam,xformat);
    yname='Stage of cascade';
    ydata=(1:h.BudgetData.nCkts)';
    zzzdata=zeros(numel(zdata{1}),numtrace);
    for ii=1:numtrace
        zzzdata(:,ii)=zdata{ii};
    end


    fig=findfigure(h);
    hold_state=false;
    if~(fig==-1);
        hold_state=ishold;
    end
    nxdata=numel(xdata)/h.BudgetData.nCkts;
    nydata=numel(ydata);
    legendcell={};
    nznames=numel(znames);
    for ii=1:nznames
        legendcell={legendcell{:},znames{ii}};
    end

    if nxdata==1

        hlines=builtin('plot',ydata,zzzdata);

        if numtrace==1
            if strcmp(zformat,'None')
                ylabel(sprintf('%s',znames{1}));
            else
                ylabel(sprintf('%s [%s]',znames{1},zformat));
            end
        else
            if~strcmp(zformat,'None')
                ylabel(zformat);
            end
        end

        addlegend(h,hlines,legendcell);
        set(get(gca,'YLabel'),'Rotation',90.0);

        xlabel(sprintf('%s',yname));
        set(gca,'xtick',ydata);

        tipcell=simplifytip(h,legendcell);
        nhlines=numel(hlines);
        for k=1:nhlines
            linesinfo=currentlineinfo(h,'X-Y Plot',tipcell{k},yname,...
            ydata,'',modifyformat(h,zformat,2),'');
            set(hlines(k),'UserData',linesinfo);
        end
        datatip(h,fig,hlines);
    else
        k=0;
        all_xdata=[];
        all_yydata=[];
        all_zzdata=[];
        for ii=1:nydata

            xxdata(1:nxdata,1)=xdata(1:nxdata);
            zzdata(1:nxdata,1:numtrace)=zzzdata(k+1:k+nxdata,1:numtrace);
            yydata(1:nxdata,1)=ydata(ii);
            k=k+nxdata;
            all_xdata=[all_xdata;NaN;xxdata];
            all_yydata=[all_yydata;NaN;yydata];
            numLines=size(zzdata,2);
            all_zzdata=[all_zzdata;NaN(1,numLines);zzdata];
        end
        hlines=builtin('plot3',all_xdata,all_yydata,all_zzdata);

        if numtrace==1
            if strcmp(zformat,'None')
                zlabel(sprintf('%s',znames{1}));
            else
                zlabel(sprintf('%s [%s]',znames{1},zformat));
            end
        else
            if~strcmp(zformat,'None')
                zlabel(zformat);
            end
        end

        addlegend(h,hlines,legendcell);
        xlabel(sprintf('%s %s',xname,xunit));
        ylabel(yname);
        set(gca,'ytick',ydata);
        view([58.5,26]);

        tipcell=simplifytip(h,legendcell);
        nhlines=numel(hlines);
        for k=1:nhlines
            linesinfo=currentlineinfo(h,'Budget',tipcell{k},xname,...
            all_xdata,xunit,modifyformat(h,zformat,2),'');
            set(hlines(k),'UserData',linesinfo);
        end
        datatip(h,fig,hlines);
    end
    grid on;
    if~hold_state;hold off;end;

    if nargout==1
        varargout{1}=hlines;
    end