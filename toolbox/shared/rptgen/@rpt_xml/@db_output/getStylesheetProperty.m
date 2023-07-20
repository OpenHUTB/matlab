function propName=getStylesheetProperty(this,varargin)








    theFormat=this.getFormat(varargin{:});

    if rptgen.use_java
        formatXSLT='com.mathworks.toolbox.rptgencore.output.OutputFormatXSLT';
        formatFOP='com.mathworks.toolbox.rptgencore.output.OutputFormatFOP';
        formatDSSL='com.mathworks.toolbox.rptgencore.output.OutputFormatDSSSL';
        formatDB2DOM='com.mathworks.toolbox.rptgencore.output.OutputFormatDB2DOM';
    else
        formatXSLT='rptgen.internal.output.OutputFormatXSLT';
        formatFOP='rptgen.internal.output.OutputFormatFOP';
        formatDSSL='rptgen.internal.output.OutputFormatDSSSL';
        formatDB2DOM='rptgen.internal.output.OutputFormatDB2DOM';
    end

    if rptgen.use_java
        if isa(theFormat,formatXSLT)
            if isa(theFormat,formatFOP)||...
                theFormat.getID.equalsIgnoreCase('fot')

                propName='StylesheetFO';
            elseif theFormat.getID.equalsIgnoreCase('latex')
                propName='StylesheetLaTeX';
            else

                propName='StylesheetHTML';
            end
        elseif isa(theFormat,formatDSSL)

            propName='StylesheetDSSSL';
        elseif isa(theFormat,formatDB2DOM)
            if theFormat.getID.equalsIgnoreCase('dom-docx')||theFormat.getID.equalsIgnoreCase('dom-pdf')
                propName='TemplateDOCX';
            elseif theFormat.getID.equalsIgnoreCase('dom-htmx')
                propName='TemplateHTMX';
            elseif theFormat.getID.equalsIgnoreCase('dom-html-file')
                propName='TemplateHTMLFile';
            else
                propName='TemplatePDF';
            end

        else

            propName='';
        end
    else
        if isa(theFormat,formatXSLT)
            if isa(theFormat,formatFOP)||...
                theFormat.getID=="fot"

                propName='StylesheetFO';
            elseif theFormat.getID=="latex"
                propName='StylesheetLaTeX';
            else

                propName='StylesheetHTML';
            end
        elseif isa(theFormat,formatDSSL)

            propName='StylesheetDSSSL';
        elseif isa(theFormat,formatDB2DOM)
            if theFormat.getID=="dom-docx"||theFormat.getID=="dom-pdf"
                propName='TemplateDOCX';
            elseif theFormat.getID=="dom-htmx"
                propName='TemplateHTMX';
            elseif theFormat.getID=="dom-html-file"
                propName='TemplateHTMLFile';
            else
                propName='TemplatePDF';
            end

        else

            propName='';
        end
    end






