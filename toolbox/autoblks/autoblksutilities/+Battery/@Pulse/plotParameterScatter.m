function varargout=plotParameterScatter(pObj)

























    AllParam=[pObj.Parameters];


    if~isequal(AllParam.NumRC)
        error(getString(message('autoblks:autoblkErrorMsg:errNrc')));
    end
    NumRC=AllParam(1).NumRC;
    NumTC=AllParam(1).NumTimeConst;











    BinNames={'Discharge','Charge'};
    IsDisch=[pObj.IsDischarge];

    SOC={[AllParam(IsDisch).SOC],[AllParam(~IsDisch).SOC]};
    Em={[AllParam(IsDisch).Em],[AllParam(~IsDisch).Em]};
    R0={[AllParam(IsDisch).R0],[AllParam(~IsDisch).R0]};
    Rx={[AllParam(IsDisch).Rx],[AllParam(~IsDisch).Rx]};

    Tx={[AllParam(IsDisch).Tx],[AllParam(~IsDisch).Tx]};





    h.Figure=figure('WindowStyle','docked','Name',...
    getString(message('autoblks:autoblkUtilMisc:scatterPlot')),'NumberTitle','off');


    NumCol=NumRC+1;
    for aIdx=1:2*NumCol
        h.Axes(aIdx)=subplot(2,NumCol,aIdx);
        grid(h.Axes(aIdx),'on')
        hold(h.Axes(aIdx),'all')
    end
    h.Axes=reshape(h.Axes,[],2)';

    for bIdx=1:numel(BinNames)


        h.Line(1,1,bIdx)=plot(h.Axes(1,1),...
        SOC{bIdx},...
        Em{bIdx},...
        'LineStyle','none',...
        'Marker','.');


        h.Line(2,1,bIdx)=plot(h.Axes(2,1),...
        SOC{bIdx},...
        R0{bIdx},...
        'LineStyle','none',...
        'Marker','.');


        for tIdx=1:NumRC


            h.Line(1,tIdx+1,bIdx)=plot(h.Axes(1,tIdx+1),...
            SOC{bIdx},...
            Tx{bIdx}(tIdx,:),...
            'LineStyle','none',...
            'Marker','.');


            h.Line(2,tIdx+1,bIdx)=plot(h.Axes(2,tIdx+1),...
            SOC{bIdx},...
            Rx{bIdx}(tIdx,:),...
            'LineStyle','none',...
            'Marker','.');
        end

    end




    title(h.Axes(1,1),getString(message('autoblks:autoblkUtilMisc:titleEm')))
    ylabel(h.Axes(1,1),'Volts')
    title(h.Axes(2,1),getString(message('autoblks:autoblkUtilMisc:r0')))
    ylabel(h.Axes(2,1),'Ohms')
    xlabel(h.Axes(2,1),getString(message('autoblks:autoblkUtilMisc:soc')))
    for tIdx=1:NumRC
        title(h.Axes(1,tIdx+1),getString(message('autoblks:autoblkUtilMisc:titleTau',num2str(tIdx))))
        ylabel(h.Axes(1,tIdx+1),getString(message('autoblks:autoblkUtilMisc:seconds')))
        title(h.Axes(2,tIdx+1),getString(message('autoblks:autoblkUtilMisc:titleR',num2str(tIdx))))
        ylabel(h.Axes(2,tIdx+1),'Ohms')
        xlabel(h.Axes(2,tIdx+1),getString(message('autoblks:autoblkUtilMisc:soc')))
    end



    legend(h.Axes(1,end),BinNames,...
    getString(message('autoblks:autoblkUtilMisc:location')),...
    getString(message('autoblks:autoblkUtilMisc:best')))
    uistack(h.Axes(1,end),'top')





    if nargout
        varargout{1}=h;
    end