function[varargout]=vehdynman(varargin)


    block=varargin{1};
    maskMode=varargin{2};
    simStopped=autoblkschecksimstopped(block);








    if maskMode==0

        if simStopped











        end
















    end

    if maskMode==1







        varargout{1}=[];
    end
    if maskMode==2
        figh=findobj(allchild(groot),'flat','type','figure','Name','Vehicle Position');
        if~isempty(figh)
            axObjs=figh.Children;
            dataObjs=axObjs.Children;
            h=findobj(dataObjs,'Type','line');
            paramstruct=autoblkscheckparams(block,'Vehicle XY Plotter',{'figBorder',[1,1],{'gt',0}});
            xlim([min(min(h.XData))-paramstruct.figBorder,max(max(h.XData))+paramstruct.figBorder]);
            ylim([min(min(h.YData))-paramstruct.figBorder,max(max(h.YData))+paramstruct.figBorder]);
            axis equal;
        end
        varargout{1}=[];
    end
    if maskMode<4
        varargout{1}=[];
    end

    if maskMode==8
        varargout{1}=DrawCommands(block);
    end

end


function IconInfo=DrawCommands(~)














    IconInfo=[];
end
