function simrfV2closesolver(this,dlg)


    if isa(this.getBlock,'Simulink.SubSystem')&&...
        isfield(this.getBlock.UserData,'FigHandlePop')
        FigHandlePop=this.getBlock.UserData.FigHandlePop;
        if~isempty(FigHandlePop)&&ishghandle(FigHandlePop)
            this.getBlock.UserData.FigHandlePop=[];
            close(FigHandlePop);
        end
    end

    this.closeCallback(dlg)

end