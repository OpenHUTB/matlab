function viewHelp(this)






    if~isempty(this.HelpHtmlFile)
        helpview(this.HelpHtmlFile);

    else
        helpKey=this.HelpMapKey;
        if isempty(helpKey)
            helpKey=['category.',strrep(this.CategoryName,' ','_')];
        end

        mapFile=RptgenML.getHelpMapfile(this.HelpMapFile);

        helpview(mapFile,helpKey);

    end
