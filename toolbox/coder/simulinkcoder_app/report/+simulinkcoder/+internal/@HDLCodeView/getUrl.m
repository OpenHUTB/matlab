function url=getUrl(obj)




    cr=simulinkcoder.internal.Report.getInstance;
    url=cr.getUrl(obj.top,obj.model,obj.cid);
    url=[url,'&component=HDL'];
