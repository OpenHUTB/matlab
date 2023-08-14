function varargout=plot(pObj)






















    for pIdx=1:numel(pObj)


        h.Figure(pIdx)=figure('WindowStyle','docked');


        h.Axes(1,pIdx)=subplot(5,1,1:3);
        h.Axes(2,pIdx)=subplot(5,1,4);
        h.Axes(3,pIdx)=subplot(5,1,5);

        for idx=1:size(h.Axes,1)
            hold(h.Axes(idx,pIdx),'on')
        end


        h.Line(1,pIdx)=plot(h.Axes(1,pIdx),...
        pObj(pIdx).Time/60,...
        pObj(pIdx).Voltage,'.-');
        h.Load(1,pIdx)=plot(h.Axes(1,pIdx),...
        pObj(pIdx).Time(pObj(pIdx).idxLoad(:))/60,...
        pObj(pIdx).Voltage(pObj(pIdx).idxLoad(:)),...
        'ro','MarkerSize',4,'LineWidth',2);
        h.Relax(1,pIdx)=plot(h.Axes(1,pIdx),...
        pObj(pIdx).Time(pObj(pIdx).idxRelax(:))/60,...
        pObj(pIdx).Voltage(pObj(pIdx).idxRelax(:)),...
        'gd','MarkerSize',4,'LineWidth',2);


        h.Line(2,pIdx)=plot(h.Axes(2,pIdx),...
        pObj(pIdx).Time/60,...
        pObj(pIdx).Current,'.-');
        h.Load(2,pIdx)=plot(h.Axes(2,pIdx),...
        pObj(pIdx).Time(pObj(pIdx).idxLoad(:))/60,...
        pObj(pIdx).Current(pObj(pIdx).idxLoad(:)),'ro','MarkerSize',4,'LineWidth',2);
        h.Relax(2,pIdx)=plot(h.Axes(2,pIdx),...
        pObj(pIdx).Time(pObj(pIdx).idxRelax(:))/60,...
        pObj(pIdx).Current(pObj(pIdx).idxRelax(:)),'gd','MarkerSize',4,'LineWidth',2);


        h.Line(3,pIdx)=plot(h.Axes(3,pIdx),...
        pObj(pIdx).Time/60,...
        pObj(pIdx).SOC,'.-');
        h.Load(3,pIdx)=plot(h.Axes(3,pIdx),...
        pObj(pIdx).Time(pObj(pIdx).idxLoad(:))/60,...
        pObj(pIdx).SOC(pObj(pIdx).idxLoad(:)),'ro','MarkerSize',4,'LineWidth',2);
        h.Relax(3,pIdx)=plot(h.Axes(3,pIdx),...
        pObj(pIdx).Time(pObj(pIdx).idxRelax(:))/60,...
        pObj(pIdx).SOC(pObj(pIdx).idxRelax(:)),'gd','MarkerSize',4,'LineWidth',2);



        ylabel(h.Axes(1,pIdx),'Voltage')
        ylabel(h.Axes(2,pIdx),'Current (A)')
        ylabel(h.Axes(3,pIdx),'SOC')

        xlabel(h.Axes(end,pIdx),'Time (minutes)')


        linkaxes(h.Axes(:,pIdx),'x');


        for idx=1:size(h.Axes,1)


            axis(h.Axes(idx,pIdx),'tight')


            grid(h.Axes(idx,pIdx),'on')

        end


        TitleStr=getString(message('autoblks:autoblkUtilMisc:titleStr',...
        num2str(round(pObj(pIdx).PulseSOCRange(1),3)),...
        num2str(round(pObj(pIdx).PulseSOCRange(2),3)),...
        num2str(round(pObj(pIdx).MeanCurrent,2))));
        Names={getString(message('autoblks:autoblkUtilMisc:voltage')),...
        getString(message('autoblks:autoblkUtilMisc:pairsLoad')),...
        getString(message('autoblks:autoblkUtilMisc:pairsRel'))};
        title(h.Axes(1,pIdx),TitleStr);
        legend(h.Axes(1,pIdx),Names,getString(message('autoblks:autoblkUtilMisc:location')),...
        getString(message('autoblks:autoblkUtilMisc:best')));

    end


    if nargout
        varargout{1}=h;
    end