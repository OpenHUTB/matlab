function varargout=plotIdentifiedPulses(psObj)























    for psIdx=1:numel(psObj)


        h.Figure(psIdx)=figure(...
        'Name','Pulse Identification',...
        'NumberTitle','off',...
        'WindowStyle','docked');


        h.Axes(1,psIdx)=subplot(5,1,1:3);
        h.Axes(2,psIdx)=subplot(5,1,4);
        h.Axes(3,psIdx)=subplot(5,1,5);

        for idx=1:size(h.Axes,1)
            hold(h.Axes(idx,psIdx),'on')
        end


        h.Line(1,psIdx)=plot(h.Axes(1,psIdx),...
        psObj(psIdx).Time/3600,...
        psObj(psIdx).Voltage,'.-');
        h.Load(1,psIdx)=plot(h.Axes(1,psIdx),...
        psObj(psIdx).Time(psObj(psIdx).idxLoad(:))/3600,...
        psObj(psIdx).Voltage(psObj(psIdx).idxLoad(:)),...
        'ro','MarkerSize',4,'LineWidth',2);
        h.Relax(1,psIdx)=plot(h.Axes(1,psIdx),...
        psObj(psIdx).Time(psObj(psIdx).idxRelax(:))/3600,...
        psObj(psIdx).Voltage(psObj(psIdx).idxRelax(:)),...
        'gd','MarkerSize',4,'LineWidth',2);


        h.Line(2,psIdx)=plot(h.Axes(2,psIdx),...
        psObj(psIdx).Time/3600,...
        psObj(psIdx).Current,'.-');
        h.Load(2,psIdx)=plot(h.Axes(2,psIdx),...
        psObj(psIdx).Time(psObj(psIdx).idxLoad(:))/3600,...
        psObj(psIdx).Current(psObj(psIdx).idxLoad(:)),'ro','MarkerSize',4,'LineWidth',2);
        h.Relax(2,psIdx)=plot(h.Axes(2,psIdx),...
        psObj(psIdx).Time(psObj(psIdx).idxRelax(:))/3600,...
        psObj(psIdx).Current(psObj(psIdx).idxRelax(:)),'gd','MarkerSize',4,'LineWidth',2);


        h.Line(3,psIdx)=plot(h.Axes(3,psIdx),...
        psObj(psIdx).Time/3600,...
        psObj(psIdx).SOC,'.-');
        h.Load(3,psIdx)=plot(h.Axes(3,psIdx),...
        psObj(psIdx).Time(psObj(psIdx).idxLoad(:))/3600,...
        psObj(psIdx).SOC(psObj(psIdx).idxLoad(:)),'ro','MarkerSize',4,'LineWidth',2);
        h.Relax(3,psIdx)=plot(h.Axes(3,psIdx),...
        psObj(psIdx).Time(psObj(psIdx).idxRelax(:))/3600,...
        psObj(psIdx).SOC(psObj(psIdx).idxRelax(:)),'gd','MarkerSize',4,'LineWidth',2);



        ylabel(h.Axes(1,psIdx),'Voltage')
        ylabel(h.Axes(2,psIdx),'Current (A)')
        ylabel(h.Axes(3,psIdx),'SOC')

        xlabel(h.Axes(end,psIdx),'Time (hours)')


        linkaxes(h.Axes(:,psIdx),'x');


        for idx=1:size(h.Axes,1)


            axis(h.Axes(idx,psIdx),'tight')


            grid(h.Axes(idx,psIdx),'on')

        end


        title(h.Axes(1,psIdx),psObj(psIdx).MetaData.Name,'Interpreter','none');
        Names={'Voltage','Pairs surround load','Pairs surround relaxation'};
        legend(h.Axes(1,psIdx),Names,'Location','best','Interpreter','none');

    end


    if nargout
        varargout{1}=h;
    end