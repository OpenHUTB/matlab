function compareRelaxationTau(pObj,varargin)







































    p=inputParser;
    p.addParameter('NumTimeConst',1:5,@(x)validateattributes(x,{'numeric'},{'row','integer','>=',1,'<=',5}));
    p.addParameter('PlotEndTime',60,@(x)validateattributes(x,{'numeric'},{'scalar','>',0}));
    p.addParameter('ShowBothPlots',true,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.parse(varargin{:});


    NumTimeConst=p.Results.NumTimeConst;
    PlotEndTime=p.Results.PlotEndTime;
    ShowBothPlots=p.Results.ShowBothPlots;





    for pIdx=1:numel(pObj)


        Data=pObj(pIdx).getRelaxationData();



        if length(Data)<6
            warning(getString(message('autoblks:autoblkErrorMsg:errTau')));
            continue
        end


        t=Data(:,1);
        v=Data(:,2);


        t=t-t(1);



        TxMin=pObj(pIdx).RelaxationFrequency;
        TxMax=t(end);


        vInit=mean(v(1:3));




        FitTypeObj{1}=fittype(@(a1,a2,x)a1*exp(-x/a2)+vInit-a1);
        FitTypeObj{2}=fittype(@(a1,b1,a2,b2,x)a1*exp(-x/a2)+b1*exp(-x/b2)+vInit-a1-b1);
        FitTypeObj{3}=fittype(@(a1,b1,c1,a2,b2,c2,x)a1*exp(-x/a2)+b1*exp(-x/b2)+c1*exp(-x/c2)+vInit-a1-b1-c1);
        FitTypeObj{4}=fittype(@(a1,b1,c1,d1,a2,b2,c2,d2,x)a1*exp(-x/a2)+b1*exp(-x/b2)+c1*exp(-x/c2)+d1*exp(-x/d2)+vInit-a1-b1-c1-d1);
        FitTypeObj{5}=fittype(@(a1,b1,c1,d1,e1,a2,b2,c2,d2,e2,x)a1*exp(-x/a2)+b1*exp(-x/b2)+c1*exp(-x/c2)+d1*exp(-x/d2)+e1*exp(-x/e2)+vInit-a1-b1-c1-d1-e1);


        h=struct();
        ThisName=getString(message('autoblks:autoblkUtilMisc:thisName',pIdx,numel(pObj)));
        h.Fig=figure(...
        'Name',ThisName,...
        'NumberTitle','off',...
        'WindowStyle','docked');

        if ShowBothPlots
            h.Axes(1)=subplot(4,2,[1,3,5],...
            'Parent',h.Fig,...
            'FontSize',12);
            h.Axes(2)=subplot(4,2,[2,4,6],...
            'Parent',h.Fig,...
            'FontSize',12);
            h.Axes(3)=subplot(4,2,7,...
            'Parent',h.Fig,...
            'FontSize',12);
            h.Axes(4)=subplot(4,2,8,...
            'Parent',h.Fig,...
            'FontSize',12);
            for aIdx=1:numel(h.Axes)
                grid(h.Axes(aIdx),'on')
                axis(h.Axes(aIdx),'tight');
                hold(h.Axes(aIdx),'all');
            end
            h.DataLine(1)=plot(t,v,...
            'Parent',h.Axes(1),...
            'LineStyle','none',...
            'MarkerEdgeColor','none',...
            'MarkerFaceColor',[0,0,1],...
            'Marker','o',...
            'MarkerSize',4);
            h.DataLine(2)=plot(t(t<=PlotEndTime),v(t<=PlotEndTime),...
            'Parent',h.Axes(2),...
            'LineStyle','none',...
            'MarkerEdgeColor','none',...
            'MarkerFaceColor',[0,0,1],...
            'Marker','o',...
            'MarkerSize',4);
            h.Title(1)=title(h.Axes(1),ThisName);
            h.Title(2)=title(h.Axes(2),getString(message('autoblks:autoblkUtilMisc:hTitle2',PlotEndTime)));
            xlabel(h.Axes(3),getString(message('autoblks:autoblkUtilMisc:labelX')));
            xlabel(h.Axes(4),getString(message('autoblks:autoblkUtilMisc:labelX')));
            ylabel(h.Axes(1),getString(message('autoblks:autoblkUtilMisc:labelV')));
            ylabel(h.Axes(3),getString(message('autoblks:autoblkUtilMisc:labelR')));
            linkaxes(h.Axes([1,3]),'x');
            linkaxes(h.Axes([2,4]),'x');
        else
            h.Axes(1)=subplot(4,1,[1,2,3],...
            'Parent',h.Fig,...
            'FontSize',12);
            h.Axes(2)=subplot(4,1,4,...
            'Parent',h.Fig,...
            'FontSize',12);
            for aIdx=1:numel(h.Axes)
                grid(h.Axes(aIdx),'on')
                axis(h.Axes(aIdx),'tight');
                hold(h.Axes(aIdx),'all');
            end
            h.DataLine(1)=plot(t(t<=PlotEndTime),v(t<=PlotEndTime),...
            'Parent',h.Axes(1),...
            'LineStyle','none',...
            'MarkerEdgeColor','none',...
            'MarkerFaceColor',[0,0,1],...
            'Marker','o',...
            'MarkerSize',4);
            h.Title(1)=title(h.Axes(1),getString(message('autoblks:autoblkUtilMisc:hTitle1',ThisName,PlotEndTime)));
            xlabel(h.Axes(2),getString(message('autoblks:autoblkUtilMisc:labelX')));
            ylabel(h.Axes(1),getString(message('autoblks:autoblkUtilMisc:labelV')));
            ylabel(h.Axes(2),getString(message('autoblks:autoblkUtilMisc:labelR')));
            linkaxes(h.Axes([1,2]),'x');
        end

drawnow

        LegendNames={'1 TC','2 TC','3 TC','4 TC','5 TC'};


        for tIdx=1:numel(NumTimeConst)

            NumTC=NumTimeConst(tIdx);


            Tx=logspace(log10(TxMin),log10(TxMax),NumTC);



            vDiff=vInit-v(end);
            vRCx=vDiff./(NumTC*ones(1,NumTC));


            x0=[vRCx,Tx];


            if pObj(pIdx).IsDischarge
                lb=[repmat(vDiff,1,NumTC),repmat(TxMin,1,NumTC)];
                ub=[zeros(1,NumTC),repmat(TxMax,1,NumTC)];
            else
                lb=[zeros(1,NumTC),repmat(TxMin,1,NumTC)];
                ub=[repmat(vDiff,1,NumTC),repmat(TxMax,1,NumTC)];
            end


            FitObj{NumTC}=fit(t(1:end)-t(1),...
            v(1:end),FitTypeObj{NumTC},'Lower',lb,'Upper',ub,...
            'StartPoint',x0);%#ok<AGROW>



            v_out=FitObj{NumTC}(t);
            residual_mV=abs(v_out-v)*1000;


            if ShowBothPlots
                h.FitLine(tIdx,1)=plot(t,v_out,...
                'Parent',h.Axes(1),...
                'LineWidth',2);
                h.FitLine(tIdx,2)=plot(t(t<=PlotEndTime),v_out(t<=PlotEndTime),...
                'Parent',h.Axes(2),...
                'LineWidth',2);
            else
                h.FitLine(tIdx,1)=plot(t(t<=PlotEndTime),v_out(t<=PlotEndTime),...
                'Parent',h.Axes(1),...
                'LineWidth',2);
            end


            ThisColor=get(h.FitLine(tIdx,1),'Color');


            if ShowBothPlots
                h.Residual(tIdx,1)=plot(t,residual_mV,...
                'Parent',h.Axes(3),...
                'Color',ThisColor,...
                'LineWidth',2);
                h.Residual(tIdx,2)=plot(t(t<=PlotEndTime),residual_mV(t<=PlotEndTime),...
                'Parent',h.Axes(4),...
                'Color',ThisColor,...
                'LineWidth',2);
            else
                h.Residual(tIdx,1)=plot(t(t<=PlotEndTime),residual_mV(t<=PlotEndTime),...
                'Parent',h.Axes(2),...
                'Color',ThisColor,...
                'LineWidth',2);
            end

            axis(h.Axes(1),'tight');
            axis(h.Axes(2),'tight');
            legend(h.Axes(1),h.FitLine(1:tIdx,1),LegendNames(NumTimeConst(1:tIdx)),'Location','best')

drawnow

        end




    end
