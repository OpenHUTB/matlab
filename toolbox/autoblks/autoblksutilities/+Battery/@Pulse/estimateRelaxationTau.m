function estimateRelaxationTau(pObj,varargin)












































    p=inputParser;
    p.addParameter('ShowPlots',false,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParameter('PlotDelay',0,@(x)validateattributes(x,{'numeric'},{'scalar','nonnegative'}));
    p.addParameter('ReusePlotFigure',true,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParameter('UpdateEndingEm',false,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParameter('UseLoadData',false,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.parse(varargin{:});


    ShowPlots=p.Results.ShowPlots;
    PlotDelay=p.Results.PlotDelay;
    ReusePlotFigure=p.Results.ReusePlotFigure;
    UpdateEndingEm=p.Results.UpdateEndingEm;





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
            Tx=squeeze(Param.Tx(:,sIdx,1));
            TxMin=squeeze(Param.TxMin(:,sIdx,1));
            TxMax=squeeze(Param.TxMax(:,sIdx,1));
        else
            Tx=squeeze(Param.Tx(:,sIdx));
            TxMin=squeeze(Param.TxMin(:,sIdx));
            TxMax=squeeze(Param.TxMax(:,sIdx));
        end
        [~,TxSortOrder]=sort(Tx);


        Data=pObj(pIdx).getRelaxationData();



        if length(Data)<6
            warning(getString(message('autoblks:autoblkErrorMsg:errNrelP',pIdx)));
            continue
        end


        t=Data(:,1);
        v=Data(:,2);


        t=t-t(1);


        vInit=v(1);



        switch NumRC
        case 1
            FitTypeObj=fittype(@(a1,a2,x)a1*exp(-x/a2)+vInit-a1);
        case 2
            FitTypeObj=fittype(@(a1,b1,a2,b2,x)a1*exp(-x/a2)+b1*exp(-x/b2)+vInit-a1-b1);
        case 3
            FitTypeObj=fittype(@(a1,b1,c1,a2,b2,c2,x)a1*exp(-x/a2)+b1*exp(-x/b2)+c1*exp(-x/c2)+vInit-a1-b1-c1);
        case 4
            FitTypeObj=fittype(@(a1,b1,c1,d1,a2,b2,c2,d2,x)a1*exp(-x/a2)+b1*exp(-x/b2)+c1*exp(-x/c2)+d1*exp(-x/d2)+vInit-a1-b1-c1-d1);
        case 5
            FitTypeObj=fittype(@(a1,b1,c1,d1,e1,a2,b2,c2,d2,e2,x)a1*exp(-x/a2)+b1*exp(-x/b2)+c1*exp(-x/c2)+d1*exp(-x/d2)+e1*exp(-x/e2)+vInit-a1-b1-c1-d1-e1);
        end



        vDiff=vInit-v(end);
        vRCx=vDiff./(NumRC*ones(1,NumRC));


        x0=[vRCx,Tx'];


        if pObj(pIdx).IsDischarge
            lb=[repmat(vDiff,1,NumRC),TxMin(:)'];
            ub=[zeros(1,NumRC),TxMax(:)'];
        else
            lb=[zeros(1,NumRC),TxMin(:)'];
            ub=[repmat(vDiff,1,NumRC),TxMax(:)'];
        end


        if any(lb>=ub)
            warning(getString(message('autoblks:autoblkErrorMsg:errInfTx',pIdx)));
            continue
        end


        FitObj=fit(t(1:end)-t(1),...
        v(1:end),FitTypeObj,'Lower',lb,'Upper',ub,...
        'StartPoint',x0);
        result=coeffvalues(FitObj);


        if ShowPlots


            if~exist('h','var')||~isfield(h,'Fig')||~ishghandle(h.Fig)||~ReusePlotFigure
                h=i_CreateFigure();
            end

            set(h.Title,'String',getString(message('autoblks:autoblkUtilMisc:hTitleExp',pIdx,numel(pObj))));
            set(h.DataLine,'XData',t,'YData',v)
            set(h.FitLine,'XData',t,'YData',FitObj(t))
            axis(h.Axes,'tight');
drawnow
            pause(PlotDelay);

        end


        Tx(1:NumRC)=result(NumRC+1:end);



        Tx=sort(Tx,1);
        Tx=Tx(TxSortOrder);






        Param.Tx(:,:,1)=repmat(Tx,[1,2,1]);


        if UpdateEndingEm

            Em2=FitObj(inf);





            OldEm=Param.Em(sIdx);
            OldMin=Param.EmMin(sIdx);
            OldMax=Param.EmMax(sIdx);
            if pObj(pIdx).IsDischarge
                Em2=max(Em2,OldEm);
                Param.EmMax(sIdx)=max(OldMax,Em2);
            else
                Em2=min(Em2,OldEm);
                Param.EmMin(sIdx)=min(OldMin,Em2);
            end


            Param.Em(sIdx)=Em2;


            if pIdx<numel(pObj)
                if pObj(pIdx+1).IsDischarge
                    pObj(pIdx+1).Parameters.Em(2)=Em2;
                else
                    pObj(pIdx+1).Parameters.Em(1)=Em2;
                end
            end

        end


        pObj(pIdx).Parameters=Param;

    end




    function h=i_CreateFigure()

        h.Fig=figure(...
        'Name','Relaxation Tau fit',...
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
