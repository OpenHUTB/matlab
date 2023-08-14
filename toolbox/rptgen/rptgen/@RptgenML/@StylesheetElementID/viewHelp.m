function viewHelp(this,varargin)







    helpview(RptgenML.getHelpMapfile(varargin{:}),['obj.',class(this),'.',findSuffix(this)]);



    function editorType=findSuffix(this)

        if strcmp(this.ID,'generate.toc')
            editorType=this.ID;
        elseif strcmp(this.ID,'formal.title.placement')
            editorType=this.ID;
        elseif(rptgen.use_java&&com.mathworks.toolbox.rptgen.xml.StylesheetEditor.isParameterNode(this.JavaHandle))...
            ||mlreportgen.re.internal.ui.StylesheetEditor.isParameterNode(this.JavaHandle)
            editorType='xml';
        elseif strcmp(this.DataType,'boolean')
            editorType='enum';
        elseif strncmp(this.DataType,'|',1)
            editorType='enum';
        else
            editorType='string';
        end
