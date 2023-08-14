function fName=cbkConvert(this)






    this.RuntimeConverting=true;

    r=this.up;
    if~isempty(r)&&isa(r,'RptgenML.Root')



        if~warnDirtyStylesheet(RptgenML.StylesheetRoot,this.getStylesheetID)
            fName='';
            this.RuntimeConverting=false;
            return;
        end

        r.getDisplayClient;
    end

    rptgen.internal.gui.GenerationDisplayClient.staticClearMessages;

    rptgen.displayMessage(getString(message('rptgen:RptgenML_FileConverter:convertingFileMsg',this.SrcFileName)),3);

    this.DstFileName='';
    try
        this.convertReport();
        fName=this.DstFileName;
    catch ME
        fName='';
        rptgen.displayMessage(getString(message('rptgen:RptgenML_FileConverter:conversionError',ME.message)),2);
    end

    if~ischar(fName)
        fName='';
    end

    if~isempty(fName)&&this.View
        try
            if strcmpi(this.Format,'dom-htmx')
                if(strcmpi(this.PackageType,'unzipped'))
                    [sPath,sName,~]=fileparts(fName);
                    fName=fullfile(sPath,sName);
                end
                rptview(fName);
            else
                rptgen.viewFile(fName);
            end
            rptgen.displayMessage(getString(message('rptgen:RptgenML_FileConverter:viewerLaunched')),4);
        catch ME
            rptgen.displayMessage(getString(message('rptgen:RptgenML_FileConverter:viewerError',ME.message)),2);
        end
    end
    this.RuntimeConverting=false;

    rptgen.displayMessage(getString(message('rptgen:RptgenML_FileConverter:conversionComplete')),3);


    rptgen.internal.gui.GenerationDisplayClient.reset;

    this.setDirty(false);
