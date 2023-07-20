function sldiffCallback(bdHandle)




    notifiers=get_param(bdHandle,'SLDiffStylerXButtonNotifier');
    arrayfun(@(x)x.notifyClicked(),notifiers);
end

