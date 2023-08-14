function viewHelp(this,varargin)








    helpview(RptgenML.getHelpMapfile(varargin{:}),['obj.',class(this),'.',findSuffix(this)]);



    function editorType=findSuffix(this)

        if strcmpi(this.Value,'#t')
            editorType='boolean';
        else
            editorType='string';
        end
