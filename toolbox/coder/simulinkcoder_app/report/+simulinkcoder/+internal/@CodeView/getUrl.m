function url=getUrl(obj)


    cr=simulinkcoder.internal.Report.getInstance;
    url=cr.getUrl(obj.top,obj.model,obj.cid);
    url=[url,'&component=EC'];


    readonly=false;
    lics={'Matlab_Coder','Real-Time_Workshop','RTW_Embedded_Coder'};
    for i=1:length(lics)
        lic=lics{i};
        if~builtin('license','test',lic)
            readonly=true;
            break;
        end
    end

    url=[url,'&readonly=',jsonencode(readonly)];