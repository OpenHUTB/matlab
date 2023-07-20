







function status=refresh()
    mm=slmetric.internal.MetricManager();
    mm.refresh();
    status=true;
end
