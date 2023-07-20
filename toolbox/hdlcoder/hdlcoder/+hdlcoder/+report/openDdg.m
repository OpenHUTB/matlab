function openDdg(fileName)




    if isfile(fileName)
        w=rtw.report.Web;
        w.Url=fileName;
        w.Title=fileName;
        w.show;
    end
end
