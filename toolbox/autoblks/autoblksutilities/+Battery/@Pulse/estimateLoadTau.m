function estimateLoadTau(pObj,varargin)







































    p=inputParser;
    p.KeepUnmatched=true;
    p.addParameter('ShowPlots',false,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParameter('PlotDelay',0,@(x)validateattributes(x,{'numeric'},{'scalar','nonnegative'}));
    p.addParameter('ReusePlotFigure',true,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParameter('UseLoadData',false,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.parse(varargin{:});


    ShowPlots=p.Results.ShowPlots;
    PlotDelay=p.Results.PlotDelay;
    ReusePlotFigure=p.Results.ReusePlotFigure;





    for pIdx=1:numel(pObj)


        Param=pObj(pIdx).Parameters;
        NumRC=Param.NumRC;


        if Param.NumSocPoints~=2
            warning(getString(message('autoblks:autoblkErrorMsg:errNsocP',pIdx)));
            continue
        end


        if pObj(pIdx).IsDischarge
            sIdx=1;
        else
            sIdx=2;
        end



        if Param.NumTimeConst==2
            Tx=squeeze(Param.Tx(:,sIdx,2));
            TxMin=squeeze(Param.TxMin(:,sIdx,2));
            TxMax=squeeze(Param.TxMax(:,sIdx,2));
        else
            Tx=squeeze(Param.Tx(:,sIdx));
            TxMin=squeeze(Param.TxMin(:,sIdx));
            TxMax=squeeze(Param.TxMax(:,sIdx));
        end
        [~,TxSortOrder]=sort(Tx);


        Data=pObj(pIdx).getLoadData();



        if length(Data)<6
            warning(getString(message('autoblks:autoblkErrorMsg:errNrelP',pIdx)));
            continue
        end


        t=Data(:,1);
        v=Data(:,2);
        i=Data(:,3);
        soc=Data(:,5);


        t=t-t(1);



        ocv=interp1(Param.SOC,Param.Em,soc);
        v=v-ocv;


        dVR0=diff(mean(i)*Param.R0);
        vr0=interp1(Param.SOC,[0,dVR0],soc);
        v=v-vr0;


        vInit=v(1);



        switch NumRC
        case 1
            FitTypeObj=fittype(@(a1,a2,d,x)d*x+a1*exp(-x/a2)+vInit-a1);
        case 2
            FitTypeObj=fittype(@(a1,b1,a2,b2,d,x)d*x+a1*exp(-x/a2)+b1*exp(-x/b2)+vInit-a1-b1);
        case 3
            FitTypeObj=fittype(@(a1,b1,c1,a2,b2,c2,d,x)d*x+a1*exp(-x/a2)+b1*exp(-x/b2)+c1*exp(-x/c2)+vInit-a1-b1-c1);
        case 4
            FitTypeObj=fittype(@(a1,b1,c1,d1,a2,b2,c2,d2,d,x)d*x+a1*exp(-x/a2)+b1*exp(-x/b2)+c1*exp(-x/c2)+d1*exp(-x/d2)+vInit-a1-b1-c1-d1);
        case 5
            FitTypeObj=fittype(@(a1,b1,c1,d1,e1,a2,b2,c2,d2,e2,d,x)d*x+a1*exp(-x/a2)+b1*exp(-x/b2)+c1*exp(-x/c2)+d1*exp(-x/d2)+e1*exp(-x/e2)+vInit-a1-b1-c1-d1-e1);
        end



        vDiff=vInit-v(end);
        vRCx=vDiff./(NumRC*ones(1,NumRC));
        dV=diff(Param.Em)/t(end);


        if pObj(pIdx).IsDischarge
            x0=[vRCx,Tx',-dV];
        else
            x0=[vRCx,Tx',dV];
        end



        if pObj(pIdx).IsDischarge
            lb=[zeros(1,NumRC),TxMin(:)',-dV*2];
            ub=[repmat(vDiff,1,NumRC),TxMax(:)',0];
        else
            lb=[repmat(vDiff,1,NumRC),TxMin(:)',0];
            ub=[zeros(1,NumRC),TxMax(:)',dV*2];
        end


        if any(lb>=ub)
            warning(getString(message('autoblks:autoblkErrorMsg:errInfTx',pIdx)));
            continue
        end


        try
            FitObj=fit(t(1:end)-t(1),...
            v(1:end),FitTypeObj,'Lower',lb,'Upper',ub,...
            'StartPoint',x0);
            result=coeffvalues(FitObj);
            StatusOk=true;
        catch err
            warning(err.message);
            result=x0;
            StatusOk=false;
        end


        if ShowPlots


            if~exist('h','var')||~isfield(h,'Fig')||~ishghandle(h.Fig)||~ReusePlotFigure
                h=i_CreateFigure();
            end

            set(h.Title,'String',getString(message('autoblks:autoblkUtilMisc:hTitleExp',pIdx,numel(pObj))));
            set(h.DataLine,'XData',t,'YData',v)
            if StatusOk
                set(h.FitLine,'XData',t,'YData',FitObj(t))
            else
                set(h.FitLine,'XData',[],'YData',[])
            end
            axis(h.Axes,'tight');
drawnow
            pause(PlotDelay);

        end


        Tx(1:NumRC)=result(NumRC+1:end-1);



        Tx=sort(Tx,1);
        Tx=Tx(TxSortOrder);







        if Param.NumTimeConst==2
            Param.Tx(:,:,2)=repmat(Tx,[1,2,1]);
        else
            Param.Tx=repmat(Tx,[1,2]);
        end


        pObj(pIdx).Parameters=Param;

    end




    function h=i_CreateFigure()

        h.Fig=figure(...
        'Name','Load Tau fit',...
        'NumberTitle','off',...
        'WindowStyle','docked');
        h.Axes=axes('Parent',h.Fig,...
        'FontSize',12);
        axis(h.Axes,'tight');
        h.DataLine=line('Parent',h.Axes,'XData',[],'YData',[],...
        'LineStyle','none',...
        'MarkerEdgeColor','none',...
        'MarkerFaceColor',[0,0,1],...
        'Marker','o',...
        'MarkerSize',4);
        h.FitLine=line('Parent',h.Axes,'XData',[],'YData',[],...
        'Color',[1,0,0],...
        'LineWidth',2);
        h.Title=title('Exponential fit 0 of N');
        xlabel(h.Axes,'time (s)');
        ylabel(h.Axes,'voltage');
        legend(h.Axes,[h.DataLine;h.FitLine],'Data','Fit')
        grid(h.Axes,'on')
