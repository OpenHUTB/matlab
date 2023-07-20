function out=reportEMLBlocks(this,d,out)






    context=getContextObject(rptgen_sl.appdata_sl);

    if isempty(context)
        this.status(getString(message('RptgenSL:csl_emlfcn:RunCmpnContextErrorNotInLoop',this.getName())),1);
        return;
    end

    context=get_param(context,'Object');
    if isa(context,'Simulink.SubSystem')




        searchTerms={'-depth',2};
    else
        searchTerms={};
    end

    emlFcns={};

    fcns=find(context,searchTerms{:},'-isa','Stateflow.EMChart');

    for i=1:length(fcns)
        emlFcns=[emlFcns,{fcns(i)}];%#ok<AGROW>
    end


    linkCharts=find(context,searchTerms{:},'-isa','Stateflow.LinkChart');

    for i=1:length(linkCharts)
        linkChart=linkCharts(i);
        chartId=sfprivate('block2chart',sf('get',linkChart.Id,'.handle'));
        chartObj=idToHandle(sfroot,chartId);
        if isa(chartObj,'Stateflow.EMChart')
            emlFcns=[emlFcns,{chartObj}];%#ok<AGROW>
        end
    end

    for i=1:length(emlFcns)
        emlFcn=emlFcns{i};

        if this.includeFcnProps
            this.makeFcnPropsTable(d,out,emlFcn);
        end

        if this.includeArgSummTable
            this.makeArgSummaryTable(d,out,emlFcn);
        end

        if this.includeArgDetails
            this.makeDetailedArgReport(d,out,emlFcn);
        end


        if this.includeFcnSymbData
            this.makeFcnSymbolDataTables(d,out,emlFcn);
        end

        if this.includeScript

            elem=d.createElement('emphasis',[emlFcn.Name,' '...
            ,getString(message('RptgenSL:csl_emlfcn:functionScriptTag'))]);
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

        if this.includeSupportingFunctions||this.includeSupportingFunctionsCode
            fcnData=getSupportingFcnByEMLNameResolution(this,emlFcn);
        end

        if this.includeSupportingFunctions
            this.makeSupportingFunctionsTable(d,out,emlFcn,fcnData);
        end

        if this.includeSupportingFunctionsCode
            this.makeSupportingFunctionsCodeElems(d,out,fcnData);
        end
    end

end