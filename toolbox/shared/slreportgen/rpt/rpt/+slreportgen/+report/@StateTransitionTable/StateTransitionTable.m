classdef StateTransitionTable<slreportgen.report.Reporter









































































    properties






        Object{mustBeSTTObject(Object)}=[];








        IncludeSymbols{mlreportgen.report.validators.mustBeLogical}=false;













TableReporter
    end

    properties(Access=private)



        SFChart=[];


        ShouldNumberTableHierarchically=[];
    end

    properties(Access=private,Constant)


        DefaultTransitionIcon=fullfile(matlabroot,"toolbox","shared","dastudio","resources","stt_default_trans.png");
        HistoryJunctionIcon=fullfile(matlabroot,"toolbox","shared","dastudio","resources","stateflow","history_junction.png");
        DefaultTransitionRowIcon=fullfile(matlabroot,"toolbox","shared","dastudio","resources","stateflow","defaultTransitionRow.png");
        InnerTransitionRowIcon=fullfile(matlabroot,"toolbox","shared","dastudio","resources","stateflow","innerTransitionRow.png");
    end

    methods

        function this=StateTransitionTable(varargin)
            if(nargin==1)
                varargin=[{"Object"},varargin];
            end

            this=this@slreportgen.report.Reporter(varargin{:});





            p=inputParser;




            p.KeepUnmatched=true;




            addParameter(p,"TemplateName","StateTransitionTable");
            addParameter(p,"Object",[]);

            tableReporter=mlreportgen.report.BaseTable();
            tableReporter.TableStyleName="STTTableReporter";
            addParameter(p,"TableReporter",tableReporter);


            parse(p,varargin{:});



            results=p.Results;
            this.TemplateName=results.TemplateName;
            this.TableReporter=results.TableReporter;
        end

        function set.TableReporter(this,value)

            mustBeNonempty(value);


            mlreportgen.report.validators.mustBeInstanceOf("mlreportgen.report.BaseTable",value);

            this.TableReporter=value;
        end

        function impl=getImpl(this,rpt)

            if isempty(this.Object)
                error(message("slreportgen:report:error:noSourceObjectSpecified",class(this)));
            else

                this.SFChart=getSFChart(this);

                if~isempty(this.SFChart)
                    this.ShouldNumberTableHierarchically=isChapterNumberHierarchical(this,rpt);




                    if isempty(this.LinkTarget)
                        obj=this.Object;
                        if isa(obj,"slreportgen.finder.DiagramElementResult")
                            obj=obj.Object;
                        end

                        parent=slreportgen.utils.getParent(obj);
                        hs=slreportgen.utils.HierarchyService;
                        dhid=hs.getDiagramHID(parent);
                        parentPath=hs.getPath(dhid);

                        if~isempty(parentPath)
                            parentDiagram=getContext(rpt,parentPath);
                            if~isempty(parentDiagram)&&(parentDiagram.HyperLinkDiagram)
                                this.LinkTarget=slreportgen.utils.getObjectID(obj);
                            end
                        end
                    end


                    impl=getImpl@slreportgen.report.Reporter(this,rpt);
                end
            end
        end

    end

    methods(Access={?mlreportgen.report.ReportForm,?slreporten.report.StateTransitionTable})

        function content=getSymbolData(this,rpt)


            content=[];

            if this.IncludeSymbols


                allSymbols=find(this.SFChart,...
                '-isa','Stateflow.Data',...
                '-or','-isa','Stateflow.Message',...
                '-or','-isa','Stateflow.Event');

                if(numel(allSymbols)>0)



                    templateName="StateTransitionTableSymbolData";
                    if isa(this.TemplateSrc,"slreportgen.report.internal.DocumentPart")
                        docPart=slreportgen.report.internal.DocumentPart(this.TemplateSrc,templateName);
                    else
                        docPart=slreportgen.report.internal.DocumentPart(rpt.Type,this.TemplateSrc,templateName);
                    end
                    openImpl(this,docPart);

                    while~strcmp(docPart.CurrentHoleId,"#end#")
                        switch docPart.CurrentHoleId
                        case "SymbolsTable"

                            symbolsReporter=getSymbolsReporter(this,rpt,allSymbols);
                            append(docPart,getImpl(symbolsReporter,rpt));
                        case "Note"
                            if~isModelCompiled(this)

                                para=mlreportgen.dom.Paragraph();
                                para.WhiteSpace="preserve";

                                noteText=getString(message("slreportgen:report:StateTransitionTable:symbolNote"));
                                note=mlreportgen.dom.Text(noteText);
                                note.Bold=true;
                                append(para,note);
                                append(para," ");

                                warningText=getString(message("slreportgen:report:StateTransitionTable:notCompiledWarning"));
                                warning=mlreportgen.dom.Text(warningText);
                                append(para,warning);

                                append(docPart,para);
                            end
                        end
                        moveToNextHole(docPart);
                    end
                    close(docPart);



                    content=docPart;
                end

            end
        end

        function content=getSTTData(this,rpt)


            content=[];


            manager=Stateflow.STT.StateEventTableMan(this.SFChart.Id);
            sttData=manager.getTableAsStruct(true);

            if~isempty(sttData)


                content=getSTTDataReporter(this,rpt,sttData);
            end
        end
    end

    methods(Access=protected,Hidden)

        result=openImpl(reporter,impl,varargin)
    end

    methods(Access=private)

        function sfChart=getSFChart(this)


            obj=this.Object;
            if isa(obj,"slreportgen.finder.DiagramElementResult")
                obj=obj.Object;
            end

            sfChart=[];
            if isa(obj,"Stateflow.Object")
                if isa(obj,"Stateflow.StateTransitionTableChart")
                    sfChart=obj;
                end
            else
                try
                    chart=slreportgen.utils.block2chart(obj);
                    if isa(chart,"Stateflow.StateTransitionTableChart")
                        sfChart=chart;
                    end
                catch

                end
            end
        end

        function tf=isModelCompiled(this)


            tf=false;
            if~isempty(this.SFChart)
                modelH=slreportgen.utils.getModelHandle(this.SFChart);
                tf=slreportgen.utils.isModelCompiled(modelH);
            end
        end

        function symbolsReporter=getSymbolsReporter(this,rpt,allSymbols)

            symbolsReporter=copy(this.TableReporter);


            appendTitle(symbolsReporter,...
            getString(message("slreportgen:report:StateTransitionTable:symbols")));

            if mlreportgen.report.Reporter.isInlineContent(symbolsReporter.Title)
                titleReporter=getTitleReporter(symbolsReporter);
                titleReporter.TemplateSrc=this;

                if this.ShouldNumberTableHierarchically
                    titleReporter.TemplateName="STTHierNumberedTitle";
                else
                    titleReporter.TemplateName="STTNumberedTitle";
                end
                symbolsReporter.Title=titleReporter;
            end


            symbolsReporter.Content=getSymbolsDOMTable(this,rpt,allSymbols);
        end

        function symbolsDOMTable=getSymbolsDOMTable(this,rpt,allSymbols)



            modelH=slreportgen.utils.getModelHandle(this.SFChart);
            compileModel(rpt,modelH);


            header=cell(1,6);
            header{1}=getString(message("slreportgen:report:StateTransitionTable:type"));
            header{2}=getString(message("slreportgen:report:StateTransitionTable:name"));
            header{3}=getString(message("slreportgen:report:StateTransitionTable:value"));
            header{4}=getString(message("slreportgen:report:StateTransitionTable:port"));

            if isModelCompiled(this)
                header{5}=getString(message("slreportgen:report:StateTransitionTable:dataType"));
                header{6}=getString(message("slreportgen:report:StateTransitionTable:size"));
            else
                header{5}=getString(message("slreportgen:report:StateTransitionTable:dataTypeFootRef"));
                header{6}=getString(message("slreportgen:report:StateTransitionTable:sizeFootRef"));
            end


            nSymbols=numel(allSymbols);
            tableContent=cell(nSymbols,6);
            for iSym=1:nSymbols
                currSymbol=allSymbols(iSym);
                tableContent{iSym,1}=...
                strcat(currSymbol.Scope," ",...
                strrep(class(currSymbol),"Stateflow.",""));
                tableContent{iSym,2}=currSymbol.Name;

                if~isnan(currSymbol.Port)
                    tableContent{iSym,4}=currSymbol.Port;
                end

                if~isa(currSymbol,"Stateflow.Event")
                    tableContent{iSym,3}=currSymbol.Props.InitialValue;

                    if isModelCompiled(this)

                        tableContent{iSym,5}=currSymbol.CompiledType;
                        tableContent{iSym,6}=currSymbol.CompiledSize;
                    else

                        tableContent{iSym,5}=currSymbol.DataType;
                        tableContent{iSym,6}=currSymbol.Props.Array.Size;
                    end
                end
            end


            symbolsDOMTable=mlreportgen.dom.FormalTable(header,tableContent);
        end

        function sttDataReporter=getSTTDataReporter(this,rpt,sttData)


            sttDataReporter=copy(this.TableReporter);


            appendTitle(sttDataReporter,...
            getString(message("slreportgen:report:StateTransitionTable:stt")));

            if mlreportgen.report.Reporter.isInlineContent(sttDataReporter.Title)
                titleReporter=getTitleReporter(sttDataReporter);
                titleReporter.TemplateSrc=this;

                if this.ShouldNumberTableHierarchically
                    titleReporter.TemplateName="STTHierNumberedTitle";
                else
                    titleReporter.TemplateName="STTNumberedTitle";
                end
                sttDataReporter.Title=titleReporter;
            end


            sttDataReporter.Content=getSTTDataDOMTable(this,rpt,sttData);
        end

        function sttDataDOMTable=getSTTDataDOMTable(this,rpt,sttData)




            import mlreportgen.dom.*

            sttData=sttData(2:end);
            nCols=length(sttData(2).rowText);
            nTransitions=nCols-1;





            sttDataDOMTable=FormalTable(nCols+2);


            headerRowStyles={HAlign("center"),VAlign("middle")};
            headerRow1=TableRow;
            headerRow1.Style=headerRowStyles;
            statesHeaderEntry=TableHeaderEntry(...
            getString(message("slreportgen:report:StateTransitionTable:states")));
            statesHeaderEntry.ColSpan=3;
            statesHeaderEntry.RowSpan=2;
            append(headerRow1,statesHeaderEntry);

            transitionsHeaderEntry=TableHeaderEntry(...
            getString(message("slreportgen:report:StateTransitionTable:transitions")));
            transitionsHeaderEntry.ColSpan=nTransitions;
            append(headerRow1,transitionsHeaderEntry);
            appendHeaderRow(sttDataDOMTable,headerRow1);

            headerRow2=TableRow;
            headerRow2.Style=headerRowStyles;
            headerRow2.Style=[headerRow2.Style,{RepeatAsHeaderRow}];
            for iCol=1:nTransitions
                ifElseHeaderEntry=TableHeaderEntry();
                if(iCol==1)
                    append(ifElseHeaderEntry,"IF");
                else
                    ifElseContent=strcat("ELSE-IF (",num2str(iCol),")");
                    append(ifElseHeaderEntry,ifElseContent);
                end
                append(headerRow2,ifElseHeaderEntry);
            end
            appendHeaderRow(sttDataDOMTable,headerRow2);


            stateHierNumLabels=[];
            lastDepth=0;

            nStates=length(sttData);
            for iState=1:nStates

                currStateData=sttData(iState);
                rowText=currStateData.rowText;


                contentRow1=append(sttDataDOMTable.Body,TableRow);
                contentRow2=append(sttDataDOMTable.Body,TableRow);
                contentRow3=append(sttDataDOMTable.Body,TableRow);




                if rpt.ispdf
                    keepTogetherCustomAttribute=...
                    CustomAttribute("keep-together.within-page","always");
                    contentRow1.CustomAttributes={keepTogetherCustomAttribute};
                    contentRow2.CustomAttributes={keepTogetherCustomAttribute};
                    contentRow3.CustomAttributes={keepTogetherCustomAttribute};
                end


                hierNumEntry=append(contentRow1,TableEntry());
                hierNumEntry.RowSpan=3;


                newDepth=currStateData.depth;
                if(newDepth>lastDepth)
                    stateHierNumLabels(end+1)=0;%#ok<AGROW>
                    lastDepth=newDepth;
                elseif(newDepth<lastDepth)
                    stateHierNumLabels=stateHierNumLabels(1:newDepth);
                    lastDepth=newDepth;
                end

                stateHierNumLabels(end)=stateHierNumLabels(end)+1;
                hierNum=strjoin(string(stateHierNumLabels),".");
                nLabels=length(stateHierNumLabels);
                if nLabels>1
                    for z=1:nLabels


                        hierNum=strcat("  ",hierNum);
                    end
                end

                hierNumPara=append(hierNumEntry,Paragraph(hierNum));
                hierNumPara.WhiteSpace="preserve";



                iconsEntry=append(contentRow1,TableEntry());
                iconsEntry.RowSpan=3;
                iconsPara=append(iconsEntry,Paragraph());
                iconsPara.Style=[iconsPara.Style,{KeepLinesTogether}];

                if currStateData.isDefaultTransitionOwner
                    append(iconsPara,Image(this.DefaultTransitionIcon));
                end

                if currStateData.hasHistory
                    append(iconsPara,Image(this.HistoryJunctionIcon));
                end



                stateLabelEntry=append(contentRow1,TableEntry);
                stateLabelEntry.RowSpan=3;
                stateLabelPara=append(stateLabelEntry,Preformatted());
                stateLabelPara.Style=[stateLabelPara.Style,{KeepLinesTogether}];

                stateLabel=rowText{1};
                splitStateData=splitlines(stateLabel);
                nLines=length(splitStateData);
                if nLines>0

                    stateNameText=append(stateLabelPara,Text(splitStateData{1}));
                    stateNameText.Bold=true;

                    if nLines>1

                        for entryData=2:nLines
                            append(stateLabelPara,LineBreak);
                            append(stateLabelPara,Text(splitStateData{entryData}));
                        end
                    end
                end



                if currStateData.rowType==1
                    append(stateLabelPara,LineBreak);
                    append(stateLabelPara,Image(this.DefaultTransitionRowIcon));
                elseif currStateData.rowType==2
                    append(stateLabelPara,LineBreak);
                    append(stateLabelPara,Image(this.InnerTransitionRowIcon));
                end


                for iCol=2:nCols
                    transitionData=rowText(iCol);


                    conditionEntry=append(contentRow1,TableEntry);
                    append(conditionEntry,Preformatted(transitionData{1}{1}));


                    actionEntry=append(contentRow2,TableEntry);
                    append(actionEntry,Preformatted(transitionData{1}{2}));


                    destinationEntry=append(contentRow3,TableEntry);
                    destState=append(destinationEntry,Preformatted(transitionData{1}{3}));
                    destState.Bold=true;
                end
            end
        end

    end

    methods(Static)
        function path=getClassFolder()


            [path]=fileparts(mfilename("fullpath"));
        end

        function template=createTemplate(templatePath,type)








            path=slreportgen.report.StateTransitionTable.getClassFolder();
            template=mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function classfile=customizeReporter(toClasspath)










            classfile=mlreportgen.report.ReportForm.customizeClass(...
            toClasspath,"slreportgen.report.StateTransitionTable");
        end

    end
end

function mustBeSTTObject(object)

    if~isempty(object)
        if isa(object,"slreportgen.finder.DiagramElementResult")
            object=object.Object;
        end

        if~slreportgen.utils.isStateTransitionTable(object)
            error(message("slreportgen:report:error:invalidSourceObject"));
        end
    end
end
