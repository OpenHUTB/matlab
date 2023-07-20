function dLabel=getDisplayLabel(this)




    [~,sFile,~]=fileparts(this.SrcFileName);

    dLabel=getString(message('rptgen:FileConverter:Convert'));

    if~isempty(sFile)
        dLabel=[dLabel,' - ',sFile];
    end
