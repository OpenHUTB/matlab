function createSignalSelector(this)





    opts=Simulink.sigselector.Options;
    opts.ViewType='DDG';
    opts.InteractiveSelection=true;
    opts.BusSupport='all';
    opts.Model=this.fModel;
    opts.RootName=DAStudio.message('Simulink:dialog:BusHierarchyViewerSubTitle');
    try
        tc=Simulink.sigselector.SigSelectorTC(opts);
    catch Ex
        if strcmp(Ex.identifier,'Simulink:Bus:EditTimeBusPropFailureOutputPort')
            message=sprintf('%s\n%s',Ex.message,Ex.cause{1}.message);
        else
            message=Ex.message;
        end
        title=DAStudio.message('Simulink:sigselector:UnableToGetHierarchyTitle');
        opts=struct('WindowStyle','modal','Interpreter','none');
        errordlg(message,title,opts);
        this.delete;
        rethrow(Ex);
    end


    tc.update;

    selsigview=tc.createView;
    selsigview.Parent=this;
    this.fSigSelWid=selsigview;
end

