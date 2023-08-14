function fileName=getDisplayIcon(this)






    if~isempty(this.ErrorMessage)

        fileName='toolbox/rptgen/resources/warning.png';
    else
        fileName='toolbox/rptgen/resources/Report.png';
    end


