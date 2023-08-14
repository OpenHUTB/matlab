function estimateLinearEmRx(pObj,varargin)































































    p=inputParser;
    p.addParameter('EstimateEm',true,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParameter('EstimateR0',true,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParameter('RetainEm',true,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParameter('RetainR0',true,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParameter('NumRepeats',10,@(x)validateattributes(x,{'numeric'},{'scalar','integer','nonnegative'}));
    p.addParameter('ShowPlots',false,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParameter('ShowBeforePlots',false,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParameter('PlotDelay',0,@(x)validateattributes(x,{'numeric'},{'scalar','nonnegative'}));
    p.addParameter('IgnoreRelaxation',false,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.parse(varargin{:});


    EstimateEm=p.Results.EstimateEm;
    EstimateR0=p.Results.EstimateR0;
    RetainEm=p.Results.RetainEm;
    RetainR0=p.Results.RetainR0;
    NumRepeats=p.Results.NumRepeats;
    ShowPlots=p.Results.ShowPlots;
    ShowBeforePlots=p.Results.ShowBeforePlots;
    PlotDelay=p.Results.PlotDelay;
    IgnoreRelaxation=p.Results.IgnoreRelaxation;



    if ShowPlots
        h=i_CreateFigure(ShowBeforePlots);
    end





    for pIdx=1:numel(pObj)


        Param=pObj(pIdx).Parameters;
        NumRC=Param.NumRC;


        if Param.NumSocPoints~=2
            warning(getString(message('autoblks:autoblkErrorMsg:errNsoc')));
            continue
        end



        if Param.NumTimeConst==2
            Tx=squeeze(Param.Tx(:,:,1));
        else
            Tx=Param.Tx;
        end


        if pObj(pIdx).IsDischarge


            Em=fliplr(Param.Em);
            EmMin=fliplr(Param.EmMin);
            EmMax=fliplr(Param.EmMax);
            R0=fliplr(Param.R0);
            R0Min=fliplr(Param.R0Min);
            R0Max=fliplr(Param.R0Max);
            Rx=fliplr(Param.Rx);
            RxMin=fliplr(Param.RxMin);
            RxMax=fliplr(Param.RxMax);
            Tx=fliplr(Tx);
        else


            Em=Param.Em;
            EmMin=Param.EmMin;
            EmMax=Param.EmMax;
            R0=Param.R0;
            R0Min=Param.R0Min;
            R0Max=Param.R0Max;
            Rx=Param.Rx;
            RxMin=Param.RxMin;
            RxMax=Param.RxMax;

        end






        ThisLoadData=pObj(pIdx).getLoadData([1,0]);
        ThisRelaxData=pObj(pIdx).getRelaxationData();
        if IgnoreRelaxation
            ThisData=[ThisLoadData;ThisRelaxData(1,:)];
        else
            ThisData=[ThisLoadData;ThisRelaxData];
        end


        t=ThisData(:,1);
        v=ThisData(:,2);
        c=ThisData(:,3);
        SOC=ThisData(:,5);



        dSOC=diff(pObj(pIdx).PulseSOCRange);
        ChangeFrac=(SOC-SOC(1))/dSOC;
        ChangeMatrix=[1-ChangeFrac,ChangeFrac];


        relaxStartRow=size(ThisLoadData,1)+1;
        tp=t(1:relaxStartRow,1)-t(2,1);
        tp(1)=0;


        tr=t(relaxStartRow+1:end,1)-t(relaxStartRow,1);


        EmBlock=ChangeMatrix;


        R0Block=-ChangeMatrix.*[c,c];



        cp=ThisLoadData(:,3);
        cp_delay=circshift([cp;0],1);

        RxBlock=cell(NumRC,1);
        for rIdx=1:NumRC


            dt=tp(end)-tp(1);


            T1=Tx(rIdx,1);
            T2=Tx(rIdx,2);
            Td=(T2-T1)/dt;
            Tch=tp/dt*(T2-T1)/T1;



            if abs(Td)<1e-10
                TCol1=1-exp(-tp/T1)-(T1*exp(-tp/T1)+tp-T1)/dt;
                TCol2=(T1*exp(-tp/T1)+tp-T1)/dt;
            else
                TCol1=1-(1+Tch).^(-1/Td)-(T1/(1+Td)*(1+Tch).^(-1/Td)+(tp-T1)/(1+Td))/dt;
                TCol2=(T1/(1+Td)*(1+Tch).^(-1/Td)+(tp-T1)/(1+Td))/dt;
            end
            RxPulseBlock=-real([TCol1,TCol2].*[cp_delay,cp_delay]);



            RxBlock{rIdx}=[
RxPulseBlock
            exp(-tr/T2)*RxPulseBlock(end,:)
            ];

        end


        C=horzcat(EmBlock,R0Block,RxBlock{:});



        C=vertcat(repmat(C(1,:),NumRepeats,1),C);%#ok<AGROW>
        v=vertcat(repmat(v(1,:),NumRepeats,1),v);%#ok<AGROW>
        dt=pObj(pIdx).RelaxationFrequency;
        t=vertcat((-NumRepeats:-1)'*dt,t);%#ok<AGROW>





        if~EstimateEm
            EmMin=Em-1e-6;
            EmMax=Em+1e-6;
        end
        if~EstimateR0
            R0Min=R0-1e-6;
            R0Max=R0+1e-6;
        end


        lb=[EmMin;R0Min;RxMin];
        lb=reshape(lb',1,[])';
        ub=[EmMax;R0Max;RxMax];
        ub=reshape(ub',1,[])';


        if any(lb>=ub)
            error(getString(message('autoblks:autoblkErrorMsg:errLbound',pIdx)));
        end


        x0=[Em;R0;Rx];
        x0=reshape(x0',1,[])';


        opts=optimoptions('lsqlin');
        opts.Algorithm='trust-region-reflective';
        opts.Display='none';
        opts.TypicalX=x0;
        coeffs=lsqlin(C,v,[],[],[],[],lb,ub,x0,opts);


        if ShowPlots
            vBefore=C*x0;
            vFit=C*coeffs;
            set(h.Title,'String',getString(message('autoblks:autoblkUtilMisc:hTitleLin',pIdx,numel(pObj))));
            set(h.DataLine,'XData',t,'YData',v)
            set(h.BeforeLine,'XData',t,'YData',vBefore)
            set(h.FitLine,'XData',t,'YData',vFit)
            axis(h.Axes,'tight');
drawnow
            pause(PlotDelay);
        end


        coeffsR=reshape(coeffs,Param.NumSocPoints,[])';





        if pObj(pIdx).IsDischarge

            if EstimateEm&&RetainEm
                Param.Em=fliplr(coeffsR(1,:));
            end
            if EstimateR0&&RetainR0
                Param.R0=fliplr(coeffsR(2,:));
            end
            Param.Rx=fliplr(coeffsR(3:end,:));
        else

            if EstimateEm&&RetainEm
                Param.Em=coeffsR(1,:);
            end
            if EstimateR0&&RetainR0
                Param.R0=coeffsR(2,:);
            end
            Param.Rx=coeffsR(3:end,:);
        end


        pObj(pIdx).Parameters=Param;

    end




    function h=i_CreateFigure(ShowBeforePlots)

        h.Fig=figure(...
        'Name','Linear fit',...
        'NumberTitle','off',...
        'WindowStyle','docked');
        h.Axes=axes('Parent',h.Fig,...
        'FontSize',12);
        axis(h.Axes,'tight');
        h.DataLine=line('Parent',h.Axes,'XData',NaN,'YData',NaN,...
        'LineStyle','none',...
        'MarkerEdgeColor',[0,0,1],...
        'Marker','o',...
        'MarkerSize',6);
        h.BeforeLine=line('Parent',h.Axes,'XData',NaN,'YData',NaN,...
        'Color',[1,.8,0],...
        'LineWidth',2);
        h.FitLine=line('Parent',h.Axes,'XData',NaN,'YData',NaN,...
        'Color',[1,0,0],...
        'LineWidth',2,...
        'MarkerEdgeColor',[1,0,0],...
        'Marker','x',...
        'MarkerSize',3);
        h.Title=title('Linear fit 0 of N');
        xlabel(h.Axes,'time (s)');
        ylabel(h.Axes,'voltage');
        grid(h.Axes,'on')
        if ShowBeforePlots
            legend(h.Axes,[h.DataLine;h.BeforeLine;h.FitLine],'Data','Before Fit','After Fit')
        else
            legend(h.Axes,[h.DataLine;h.FitLine],'Data','Fit')
            set(h.BeforeLine,'Visible','off');
        end
