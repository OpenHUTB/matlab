function convertToCustomFilter(this)


    if(strcmp(...
        questdlg(getString(message('RptgenSL:csl_ws_variable:confirmConvertText')),...
        getString(message('RptgenSL:csl_ws_variable:confirmConvertTitle')),...
        getString(message('RptgenSL:csl_ws_variable:dlgYes')),...
        getString(message('RptgenSL:csl_ws_variable:dlgNo')),...
        getString(message('RptgenSL:csl_ws_variable:dlgNo'))),...
        getString(message('RptgenSL:csl_ws_variable:dlgYes'))))

        this.customFilteringCode=this.buildPropertyFilterCode();
        this.customFilteringEnabled=true;

    end





