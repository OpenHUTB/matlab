function installModelCloseListener(hDlgSrc)





    oModel=get_param(StdRpt.getBDRoot(hDlgSrc.rootSystem),'Object');
    hDlgSrc.hModelCloseListener=Simulink.listener(oModel,'CloseEvent',...
    @(src,evt)modelCloseListener(src,evt,hDlgSrc));

end

function modelCloseListener(~,~,hDlgSrc)
    hDlgSrc.delete;
end






