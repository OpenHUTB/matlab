function out=reportChartFcns(this,d,emlFcns,out)














    for iFcn=length(emlFcns)
        emlFcn=emlFcns(iFcn);

        if this.includeFcnProps
            this.makeFcnPropsTable(d,out,emlFcn);
        end

        if this.includeArgSummTable
            this.makeArgSummaryTable(d,out,emlFcn);
        end

        if this.includeArgDetails
            this.makeDetailedArgReport(d,out,emlFcn);
        end

        if this.includeScript

            elem=d.createElement('emphasis',[emlFcn.Name,' ',getString(message('RptgenSL:csl_emlfcn:functionScriptTag'))]);
            elem.setAttribute('role','bold');
            elem=d.createElement('para',elem);
            out.appendChild(elem);


            if this.highlightScriptSyntax
                if rptgen.use_java
                    script=com.mathworks.widgets.CodeAsXML.xmlize(java(d),emlFcn.Script);
                else
                    script=rptgen.internal.docbook.CodeAsXML.xmlize(d.Document,emlFcn.Script);
                end
            else
                script=d.createElement('programlisting',emlFcn.Script);
            end
            out.appendChild(script);
        end
    end

end









