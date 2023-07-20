function varargout=plot(parObj,Names)



























    if nargin>1
        validateattributes(Names,{'cell'},{'numel',numel(parObj)});
    else
        Names=cellfun(@num2str,num2cell(1:numel(parObj)),'UniformOutput',false);
    end


    NumRC=max([parObj.NumRC]);


    h.Figure=figure('WindowStyle','docked','Name','Parameter Tables','NumberTitle','off');


    NumCol=NumRC+1;
    for aIdx=1:2*NumCol
        h.Axes(aIdx)=subplot(2,NumCol,aIdx);
        hold(h.Axes(aIdx),'all')
    end
    h.Axes=reshape(h.Axes,[],2)';



    for pIdx=1:numel(parObj)


        h.Line(1,1,pIdx)=plot(h.Axes(1,1),...
        parObj(pIdx).SOC,...
        parObj(pIdx).Em,...
        'Marker','.');


        h.Line(2,1,pIdx)=plot(h.Axes(2,1),...
        parObj(pIdx).SOC,...
        parObj(pIdx).R0,...
        'Marker','.');

        NumTC=parObj(pIdx).NumTimeConst;


        for tIdx=1:parObj(pIdx).NumRC


            h.Line(1,tIdx+1,pIdx)=plot(h.Axes(1,tIdx+1),...
            parObj(pIdx).SOC,...
            parObj(pIdx).Tx(tIdx,:,1),...
            'Marker','.');
            if NumTC==2
                h.Line(1,NumTC+tIdx+1,pIdx)=plot(h.Axes(1,tIdx+1),...
                parObj(pIdx).SOC,...
                parObj(pIdx).Tx(tIdx,:,2),...
                'Marker','.');
            end


            h.Line(2,tIdx+1,pIdx)=plot(h.Axes(2,tIdx+1),...
            parObj(pIdx).SOC,...
            parObj(pIdx).Rx(tIdx,:),...
            'Marker','.');
        end

    end





    title(h.Axes(1,1),'E_m')
    ylabel(h.Axes(1,1),'Volts')
    title(h.Axes(2,1),'R_0')
    ylabel(h.Axes(2,1),'Ohms')
    xlabel(h.Axes(2,1),'SOC')
    for tIdx=1:parObj(pIdx).NumRC
        title(h.Axes(1,tIdx+1),['\tau_',num2str(tIdx)])
        ylabel(h.Axes(1,tIdx+1),'seconds')
        title(h.Axes(2,tIdx+1),['R_',num2str(tIdx)])
        ylabel(h.Axes(2,tIdx+1),'Ohms')
        xlabel(h.Axes(2,tIdx+1),'SOC')
    end


    if numel(parObj)>1
        legend(h.Axes(1,end),Names,'Location','best','Interpreter','none')
        uistack(h.Axes(1,end),'top')
    end




    if nargout
        varargout{1}=h;
    end