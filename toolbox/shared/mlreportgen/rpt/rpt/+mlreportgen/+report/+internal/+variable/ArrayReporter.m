classdef(Abstract)ArrayReporter<mlreportgen.report.internal.variable.VariableReporter



















    methods(Access=protected,Abstract)


        content=getTableContent(this);
    end

    methods

        function this=ArrayReporter(reportOptions,varName,varValue)
            this@mlreportgen.report.internal.variable.VariableReporter(reportOptions,...
            varName,varValue);
        end

        function content=makeAutoReport(this)


            content=this.makeTabularReport();
        end

        function content=makeTabularReport(this)



            if length(size(this.VarValue))>2


                if(this.ReportOptions.IncludeTitle)
                    arrayTitle=getTitleText(this);
                else
                    arrayTitle="";
                end



                make2DArrayReporters(this,this.VarValue,arrayTitle,[]);
                content=[];
            else

                baseTable=copy(this.ReportOptions.TableReporterTemplate);
                addAnchor(this,baseTable);


                if(this.ReportOptions.IncludeTitle)
                    appendTitle(baseTable,getTitleText(this));
                end


                domTable=getTableContent(this);
                baseTable.Content=domTable;

                if(domTable.NCols>this.ReportOptions.MaxCols)




                    baseTable.MaxCols=this.ReportOptions.MaxCols;
                end
                content=baseTable;
            end
        end

    end

    methods(Access=protected)
        function make2DArrayReporters(this,array,arrayName,history)



            import mlreportgen.report.internal.variable.*;

            sz=size(array);
            nDims=length(sz);
            thisDim=nDims-length(history);

            if(thisDim<=2)
                titleSuffix=makeTitleSuffix(history);
                arrayName=[arrayName,{titleSuffix}];
                history=num2cell(history);
                arraySlice=array(:,:,history{:});
                reportOptions=this.ReportOptions;
                reportOptions.IncludeTitle=true;
                sliceReporter=ReporterFactory.makeReporter(reportOptions,...
                strcat(this.VarName,titleSuffix),arraySlice);
                sliceReporter.TitleWithSuffix=arrayName;
                ReporterQueue.instance().add(sliceReporter);
            else
                for i=1:sz(thisDim)
                    make2DArrayReporters(this,array,arrayName,[i,history]);
                end
            end
        end
    end

end

function ts=makeTitleSuffix(history)



    ts="(";
    for i=1:2
        ts=strcat(ts,":,");
    end

    idxNames=sprintf('%i,',history);
    ts=strcat(ts,idxNames(1:end-1),")");
end