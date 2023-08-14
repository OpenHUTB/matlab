function execute(obj)
    execute@rtw.report.Summary(obj);

    t=Advisor.Text;
    t.setContent(['<iframe id="rtwIdContentsIframe" ','style="width:100%" frameborder="0" src="',obj.ModelName,'_contents.html" scrolling="auto" />']);
    obj.addItem(t);
end
