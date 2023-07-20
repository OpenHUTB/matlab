classdef TestSequence<slreportgen.report.Reporter
























































































    properties





        Object{mustBeTestSequenceObject(Object)}=[];







        IncludeSymbols{mlreportgen.report.validators.mustBeLogical}=true;







        IncludeStepHierarchy{mlreportgen.report.validators.mustBeLogical}=true;






        IncludeStepContent{mlreportgen.report.validators.mustBeLogical}=true;




        IncludeStepDescription{mlreportgen.report.validators.mustBeLogical}=true;




        IncludeStepWhenCondition{mlreportgen.report.validators.mustBeLogical}=true;




        IncludeStepAction{mlreportgen.report.validators.mustBeLogical}=true;





        IncludeStepTransitions{mlreportgen.report.validators.mustBeLogical}=true;




        IncludeStepRequirements{mlreportgen.report.validators.mustBeLogical}=false;













TableReporter








ListFormatter
    end

    properties(Access=private)




        SFChart=[];



        Steps=[];



        ReactiveViewManager=[];


        InputDataSymbols={};
        OutputDataSymbols={};
        LocalDataSymbols={};
        ConstDataSymbols={};
        ParamDataSymbols={};
        DSMDataSymbols={};


        ShouldNumberTableHierarchically=[];
    end

    methods

        function this=TestSequence(varargin)
            if(nargin==1)
                varargin=[{"Object"},varargin];
            end

            this=this@slreportgen.report.Reporter(varargin{:});





            p=inputParser;




            p.KeepUnmatched=true;




            addParameter(p,"TemplateName","TestSequence");
            addParameter(p,"Object",[]);

            tableReporter=mlreportgen.report.BaseTable();
            tableReporter.TableStyleName="TestSequenceTable";
            addParameter(p,"TableReporter",tableReporter);

            list=mlreportgen.dom.UnorderedList;
            list.StyleName="TestSequenceList";
            addParameter(p,"ListFormatter",list);


            parse(p,varargin{:});



            results=p.Results;
            this.TemplateName=results.TemplateName;
            this.TableReporter=results.TableReporter;
            this.ListFormatter=results.ListFormatter;
        end

        function set.TableReporter(this,value)

            mustBeNonempty(value);


            mlreportgen.report.validators.mustBeInstanceOf("mlreportgen.report.BaseTable",value);

            this.TableReporter=value;
        end

        function set.ListFormatter(this,value)

            mustBeNonempty(value);


            mlreportgen.report.validators.mustBeInstanceOfMultiClass(...
            {'mlreportgen.dom.UnorderedList','mlreportgen.dom.OrderedList'},value);


            if~isempty(value.Children)
                error(message("slreportgen:report:error:nonemptyListFormatter"));
            end

            this.ListFormatter=value;
        end

        function impl=getImpl(this,rpt)

            if isempty(this.Object)
                error(message("slreportgen:report:error:noSourceObjectSpecified",class(this)));
            else

                if~isempty(this.ListFormatter.Children)
                    error(message("slreportgen:report:error:nonemptyListFormatter"));
                end


                this.SFChart=getSFChart(this);

                if~isempty(this.SFChart)

                    manager=Stateflow.STT.StateEventTableMan(this.SFChart.Id);
                    this.ReactiveViewManager=manager.viewManager;


                    this.Steps=this.ReactiveViewManager.chartDataDetails();

                    this.ShouldNumberTableHierarchically=isChapterNumberHierarchical(this,rpt);





                    if isempty(this.LinkTarget)
                        obj=this.Object;
                        if isa(obj,"slreportgen.finder.DiagramElementResult")
                            obj=obj.Object;
                        end

                        objH=slreportgen.utils.getSlSfHandle(obj);
                        parent=get_param(objH,"Parent");
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

    methods(Access={?mlreportgen.report.ReportForm,?slreporten.report.TestSequence})

        function content=getSymbolData(this,rpt)


            content=[];

            if this.IncludeSymbols

                allDataSymbols=this.SFChart.find(...
                '-isa','Stateflow.Data',...
                '-or','-isa','Stateflow.Message',...
                '-or','-isa','Stateflow.FunctionCall',...
                '-or','-isa','Stateflow.Trigger');

                if(numel(allDataSymbols)>0)

                    processSymbols(this,rpt,allDataSymbols);




                    if isa(this.TemplateSrc,"slreportgen.report.internal.DocumentPart")
                        docPart=slreportgen.report.internal.DocumentPart(this.TemplateSrc,"TestSequenceSymbolData");
                    else
                        docPart=slreportgen.report.internal.DocumentPart(rpt.Type,this.TemplateSrc,"TestSequenceSymbolData");
                    end
                    openImpl(this,docPart);

                    while~strcmp(docPart.CurrentHoleId,"#end#")
                        switch docPart.CurrentHoleId
                        case "SymbolTitle"

                            append(docPart,mlreportgen.dom.Paragraph(...
                            getString(message("slreportgen:report:TestSequence:symbols"))));
                        case "InputSymbols"
                            if~isempty(this.InputDataSymbols)

                                inputSymbolReporter=getInputSymbolsReporter(this);
                                append(docPart,inputSymbolReporter.getImpl(rpt));
                            end
                        case "OutputSymbols"
                            if~isempty(this.OutputDataSymbols)

                                outputSymbolReporter=getOutputSymbolsReporter(this);
                                append(docPart,outputSymbolReporter.getImpl(rpt));
                            end
                        case "LocalSymbols"
                            if~isempty(this.LocalDataSymbols)

                                localSymbolReporter=getLocalSymbolsReporter(this);
                                append(docPart,localSymbolReporter.getImpl(rpt));
                            end
                        case "ConstantSymbols"
                            if~isempty(this.ConstDataSymbols)

                                constantSymbolReporter=getConstantSymbolsReporter(this);
                                append(docPart,constantSymbolReporter.getImpl(rpt));
                            end
                        case "ParameterSymbols"
                            if~isempty(this.ParamDataSymbols)

                                paramSymbolReporter=getParamSymbolsReporter(this);
                                append(docPart,paramSymbolReporter.getImpl(rpt));
                            end
                        case "DSMSymbols"
                            if~isempty(this.DSMDataSymbols)

                                dsmSymbolReporter=getDSMSymbolsReporter(this);
                                append(docPart,dsmSymbolReporter.getImpl(rpt));
                            end
                        case "Note"
                            if~isModelCompiled(this)

                                para=mlreportgen.dom.Paragraph();
                                para.WhiteSpace="preserve";

                                noteText=getString(message("slreportgen:report:TestSequence:symbolNote"));
                                note=mlreportgen.dom.Text(noteText);
                                note.Bold=true;
                                append(para,note);
                                append(para," ");

                                warningText=getString(message("slreportgen:report:TestSequence:notCompiledWarning"));
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

        function content=getStepHierarchy(this,rpt)


            content=[];

            if this.IncludeStepHierarchy


                if isa(this.TemplateSrc,"slreportgen.report.internal.DocumentPart")
                    docPart=slreportgen.report.internal.DocumentPart(this.TemplateSrc,"TestSequenceStepHierarchy");
                else
                    docPart=slreportgen.report.internal.DocumentPart(rpt.Type,this.TemplateSrc,"TestSequenceStepHierarchy");
                end
                openImpl(this,docPart);

                while~strcmp(docPart.CurrentHoleId,"#end#")
                    switch docPart.CurrentHoleId
                    case "StepHierarchyTitle"
                        wrapperPara=mlreportgen.dom.Paragraph;




                        targetID=getStepHierarchyLinkTargetID(this);
                        append(wrapperPara,...
                        mlreportgen.dom.LinkTarget(targetID));


                        append(wrapperPara,...
                        getString(message("slreportgen:report:TestSequence:stepHierarchy")));

                        append(docPart,wrapperPara);
                    case "StepHierarchyContent"



                        stepHierarchyLists=getStepHierarchyDOMLists(this);
                        nLists=length(stepHierarchyLists);
                        for iList=1:nLists
                            append(docPart,stepHierarchyLists{iList});
                        end






                        if isUsingScenarios(this)&&...
                            this.ReactiveViewManager.getIsReadActiveFromWorkspace
                            para=mlreportgen.dom.Paragraph();
                            para.StyleName="TestSequenceNote";
                            para.WhiteSpace="preserve";

                            noteHeading=append(para,mlreportgen.dom.Text(...
                            getString(message("slreportgen:report:TestSequence:note"))));
                            noteHeading.Bold=true;
                            append(para," ");

                            append(para,mlreportgen.dom.Text(...
                            getString(message("slreportgen:report:TestSequence:activeScenarioFromWorkspace"))));
                            append(docPart,para);
                        end
                    end
                    moveToNextHole(docPart);
                end
                close(docPart);



                content=docPart;
            end
        end

        function content=getStepData(this,rpt)


            content={};

            if this.IncludeStepContent
                nSteps=numel(this.Steps);
                activeScenarioIdx=getActiveScenarioIdx(this);


                for iStep=1:nSteps


                    if isUsingScenarios(this)

                        isActiveScenario=(iStep==activeScenarioIdx);
                        content=processStep(this,this.Steps{iStep},true,isActiveScenario,content,rpt);
                    else
                        content=processStep(this,this.Steps{iStep},false,false,content,rpt);
                    end
                end
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
                if isa(obj,"Stateflow.ReactiveTestingTableChart")
                    sfChart=obj;
                end
            else
                try
                    chart=slreportgen.utils.block2chart(obj);
                    if isa(chart,"Stateflow.ReactiveTestingTableChart")
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

        function processSymbols(this,rpt,allDataSymbols)








            modelH=slreportgen.utils.getModelHandle(this.SFChart);
            compileModel(rpt,modelH);

            for i=1:numel(allDataSymbols)
                currDataSymbol=allDataSymbols(i);

                s=struct("Name",currDataSymbol.Name,...
                "DataType","",...
                "Size","");


                if~isa(currDataSymbol,"Stateflow.FunctionCall")...
                    &&~isa(currDataSymbol,"Stateflow.Trigger")
                    if isModelCompiled(this)

                        s.DataType=currDataSymbol.CompiledType;
                        s.Size=currDataSymbol.CompiledSize;
                    else

                        s.DataType=currDataSymbol.DataType;
                        s.Size=currDataSymbol.Props.Array.Size;
                    end
                end


                switch currDataSymbol.Scope
                case "Input"

                    s.Class=strrep(class(currDataSymbol),"Stateflow.","");
                    s.Port=currDataSymbol.Port;
                    this.InputDataSymbols{end+1}=s;
                case "Output"

                    s.Class=strrep(class(currDataSymbol),"Stateflow.","");
                    s.Port=currDataSymbol.Port;
                    this.OutputDataSymbols{end+1}=s;
                case "Local"

                    this.LocalDataSymbols{end+1}=s;
                case "Constant"

                    s.Value=currDataSymbol.Props.InitialValue;
                    this.ConstDataSymbols{end+1}=s;
                case "Parameter"

                    this.ParamDataSymbols{end+1}=s;
                case "Data Store Memory"

                    this.DSMDataSymbols{end+1}=s;
                end
            end


            this.InputDataSymbols=sortOnPort(this.InputDataSymbols);
            this.OutputDataSymbols=sortOnPort(this.OutputDataSymbols);



            this.LocalDataSymbols=sortOnName(this.LocalDataSymbols);
            this.ConstDataSymbols=sortOnName(this.ConstDataSymbols);
            this.ParamDataSymbols=sortOnName(this.ParamDataSymbols);
            this.DSMDataSymbols=sortOnName(this.DSMDataSymbols);
        end

        function headerProps=getSymbolTableHeaderProperties(this,nProp)





            headerProps=cell(1,nProp);
            iProp=1;


            if(nProp==5)
                headerProps{iProp}=getString(message("slreportgen:report:TestSequence:port"));
                iProp=iProp+1;
            end


            headerProps{iProp}=getString(message("slreportgen:report:TestSequence:name"));
            iProp=iProp+1;

            if(nProp==5)

                headerProps{iProp}=getString(message("slreportgen:report:TestSequence:class"));
                iProp=iProp+1;
            elseif(nProp==4)

                headerProps{iProp}=getString(message("slreportgen:report:TestSequence:value"));
                iProp=iProp+1;
            end


            if isModelCompiled(this)
                headerProps{iProp}=getString(message("slreportgen:report:TestSequence:dataType"));
                headerProps{iProp+1}=getString(message("slreportgen:report:TestSequence:size"));
            else
                headerProps{iProp}=getString(message("slreportgen:report:TestSequence:dataTypeFootRef"));
                headerProps{iProp+1}=getString(message("slreportgen:report:TestSequence:sizeFootRef"));
            end
        end

        function tableReporter=createBaseTableReporter(this,title,header,content)


            tableReporter=copy(this.TableReporter);

            if~isempty(title)

                appendTitle(tableReporter,title);
            end

            if mlreportgen.report.Reporter.isInlineContent(tableReporter.Title)
                titleReporter=getTitleReporter(tableReporter);
                titleReporter.TemplateSrc=this;

                if this.ShouldNumberTableHierarchically
                    titleReporter.TemplateName="TestSequenceHierNumberedTitle";
                else
                    titleReporter.TemplateName="TestSequenceNumberedTitle";
                end
                tableReporter.Title=titleReporter;
            end

            if~isempty(header)&&~isempty(content)

                table=mlreportgen.dom.FormalTable(header,content);
                tableReporter.Content=table;
            end
        end

        function inputSymbolsReporter=getInputSymbolsReporter(this)

            nProp=5;
            title=getString(message("slreportgen:report:TestSequence:input"));


            nInputDataSym=numel(this.InputDataSymbols);
            tableContent=cell(nInputDataSym,nProp);
            for iSym=1:nInputDataSym
                tableContent{iSym,1}=this.InputDataSymbols{iSym}.Port;
                tableContent{iSym,2}=this.InputDataSymbols{iSym}.Name;
                tableContent{iSym,3}=getString(message(...
                strcat("slreportgen:report:TestSequence:class",...
                this.InputDataSymbols{iSym}.Class)));
                tableContent{iSym,4}=this.InputDataSymbols{iSym}.DataType;
                tableContent{iSym,5}=this.InputDataSymbols{iSym}.Size;
            end


            headerPropList=getSymbolTableHeaderProperties(this,nProp);


            inputSymbolsReporter=createBaseTableReporter(this,title,headerPropList,tableContent);
        end

        function outputSymbolsReporter=getOutputSymbolsReporter(this)

            nProp=5;
            title=getString(message("slreportgen:report:TestSequence:output"));


            nOutputDataSym=numel(this.OutputDataSymbols);
            tableContent=cell(nOutputDataSym,nProp);
            for iSym=1:nOutputDataSym
                tableContent{iSym,1}=this.OutputDataSymbols{iSym}.Port;
                tableContent{iSym,2}=this.OutputDataSymbols{iSym}.Name;
                tableContent{iSym,3}=getString(message(...
                strcat("slreportgen:report:TestSequence:class",...
                this.OutputDataSymbols{iSym}.Class)));
                tableContent{iSym,4}=this.OutputDataSymbols{iSym}.DataType;
                tableContent{iSym,5}=this.OutputDataSymbols{iSym}.Size;
            end


            headerPropList=getSymbolTableHeaderProperties(this,nProp);


            outputSymbolsReporter=createBaseTableReporter(this,title,headerPropList,tableContent);
        end

        function localSymbolsReporter=getLocalSymbolsReporter(this)

            nProp=3;
            title=getString(message("slreportgen:report:TestSequence:local"));


            nLocalDataSym=numel(this.LocalDataSymbols);
            tableContent=cell(nLocalDataSym,nProp);
            for iSym=1:nLocalDataSym
                tableContent{iSym,1}=this.LocalDataSymbols{iSym}.Name;
                tableContent{iSym,2}=this.LocalDataSymbols{iSym}.DataType;
                tableContent{iSym,3}=this.LocalDataSymbols{iSym}.Size;
            end


            headerPropList=getSymbolTableHeaderProperties(this,nProp);


            localSymbolsReporter=createBaseTableReporter(this,title,headerPropList,tableContent);
        end

        function constSymbolsReporter=getConstantSymbolsReporter(this)

            nProp=4;
            title=getString(message("slreportgen:report:TestSequence:constant"));


            nConstDataSym=numel(this.ConstDataSymbols);
            tableContent=cell(nConstDataSym,nProp);
            for iSym=1:nConstDataSym
                tableContent{iSym,1}=this.ConstDataSymbols{iSym}.Name;
                tableContent{iSym,2}=this.ConstDataSymbols{iSym}.Value;
                tableContent{iSym,3}=this.ConstDataSymbols{iSym}.DataType;
                tableContent{iSym,4}=this.ConstDataSymbols{iSym}.Size;
            end


            headerPropList=getSymbolTableHeaderProperties(this,nProp);


            constSymbolsReporter=createBaseTableReporter(this,title,headerPropList,tableContent);
        end

        function paramSymbolsReporter=getParamSymbolsReporter(this)

            nProp=3;
            title=getString(message("slreportgen:report:TestSequence:parameter"));


            nParamDataSym=numel(this.ParamDataSymbols);
            tableContent=cell(nParamDataSym,nProp);
            for iSym=1:nParamDataSym

                if isUsingScenarios(this)&&...
                    strcmp(this.ParamDataSymbols{iSym}.Name,this.ReactiveViewManager.getScenarioParameterName)
                    wrapperPara=mlreportgen.dom.Paragraph;
                    append(wrapperPara,this.ParamDataSymbols{iSym}.Name);

                    scenarioParamText=getString(message("slreportgen:report:TestSequence:scenarioParameter"));
                    scenarioParamText=compose(" (%s)",scenarioParamText);
                    scenarioParamDOMText=append(wrapperPara,mlreportgen.dom.Text(scenarioParamText));
                    scenarioParamDOMText.Italic=true;
                    tableContent{iSym,1}=wrapperPara;
                else
                    tableContent{iSym,1}=this.ParamDataSymbols{iSym}.Name;
                end

                tableContent{iSym,2}=this.ParamDataSymbols{iSym}.DataType;
                tableContent{iSym,3}=this.ParamDataSymbols{iSym}.Size;
            end


            headerPropList=getSymbolTableHeaderProperties(this,nProp);


            paramSymbolsReporter=createBaseTableReporter(this,title,headerPropList,tableContent);
        end

        function dsmSymbolsReporter=getDSMSymbolsReporter(this)

            nProp=3;
            title=getString(message("slreportgen:report:TestSequence:dataStoreMemory"));


            nDSMDataSym=numel(this.DSMDataSymbols);
            tableContent=cell(nDSMDataSym,nProp);
            for iSym=1:nDSMDataSym
                tableContent{iSym,1}=this.DSMDataSymbols{iSym}.Name;
                tableContent{iSym,2}=this.DSMDataSymbols{iSym}.DataType;
                tableContent{iSym,3}=this.DSMDataSymbols{iSym}.Size;
            end


            headerPropList=getSymbolTableHeaderProperties(this,nProp);


            dsmSymbolsReporter=createBaseTableReporter(this,title,headerPropList,tableContent);
        end

        function transitionTableReporter=getTransitionTableReporter(this,step)

            title=getString(message("slreportgen:report:TestSequence:transitionTable"));


            headerPropList={...
            getString(message("slreportgen:report:TestSequence:condition")),...
            getString(message("slreportgen:report:TestSequence:nextStep")),...
            };


            nTransitions=numel(step.transitions);
            tableContent=cell(nTransitions,2);
            for iTrans=1:nTransitions
                condition=step.transitions{iTrans}.cond;
                if isempty(condition)

                    condition=mlreportgen.dom.Text("true");
                    condition.Italic=true;
                end

                tableContent{iTrans,1}=condition;
                tableContent{iTrans,2}=step.transitions{iTrans}.dest;
            end


            transitionTableReporter=createBaseTableReporter(this,title,headerPropList,tableContent);
        end

        function requirementsReporter=getRequirementsReporter(this,step)

            title=getString(message("slreportgen:report:TestSequence:stepRequirements"));


            requirementsReporter=createBaseTableReporter(this,title,[],[]);


            reqs=cell2mat(step.requirements);
            requirementsReporter.Content=...
            slreportgen.utils.internal.reqsToTable(reqs);
        end

        function id=getStepHierarchyLinkTargetID(this)

            id=mlreportgen.utils.normalizeLinkID(...
            "TestSequence-"+this.SFChart.Id+"-StepHierarchy");
        end

        function id=getStepContentLinkTargetID(this,step)


            id=mlreportgen.utils.normalizeLinkID(...
            "TestSequence-"+this.SFChart.Id+"-"+step.Id+"-"+step.stateName);
        end

        function lists=getStepHierarchyDOMLists(this)


            nSteps=numel(this.Steps);

            if isUsingScenarios(this)


                lists=cell(1,nSteps);


                activeScenarioIdx=getActiveScenarioIdx(this);
            else


                lists={clone(this.ListFormatter)};
            end

            for iStep=1:nSteps


                if isUsingScenarios(this)

                    isActiveScenario=(iStep==activeScenarioIdx);


                    lists{iStep}=mlreportgen.dom.UnorderedList;
                    addStepToList(this,this.Steps{iStep},true,isActiveScenario,lists{iStep});
                else
                    addStepToList(this,this.Steps{iStep},false,false,lists{1});
                end
            end
        end

        function addStepToList(this,step,isScenario,isActiveScenario,list)






            if(this.IncludeStepContent)
                stepName=mlreportgen.dom.InternalLink(...
                getStepContentLinkTargetID(this,step),...
                step.stateName);
            else
                stepName=mlreportgen.dom.Text(step.stateName);
            end




            updatedStepName=updateStepName(this,stepName,isScenario,isActiveScenario);

            append(list,mlreportgen.dom.ListItem(updatedStepName));


            nChildren=numel(step.children);
            if(nChildren>0)

                nestedList=append(list,clone(this.ListFormatter));


                for iChild=1:nChildren
                    addStepToList(this,step.children{iChild},false,false,nestedList);
                end
            end
        end

        function content=processStep(this,step,isScenario,isActiveScenario,content,rpt)

            content=addStepContent(this,step,isScenario,isActiveScenario,content,rpt);


            nChildren=numel(step.children);
            for iChild=1:nChildren
                content=processStep(this,step.children{iChild},false,false,content,rpt);
            end
        end

        function content=addStepContent(this,step,isScenario,isActiveScenario,content,rpt)


            if isa(this.TemplateSrc,"slreportgen.report.internal.DocumentPart")
                docPart=slreportgen.report.internal.DocumentPart(this.TemplateSrc,"TestSequenceStepData");
            else
                docPart=slreportgen.report.internal.DocumentPart(rpt.Type,this.TemplateSrc,"TestSequenceStepData");
            end
            openImpl(this,docPart);

            while~strcmp(docPart.CurrentHoleId,"#end#")
                switch docPart.CurrentHoleId
                case "StepName"
                    wrapperPara=mlreportgen.dom.Paragraph;




                    targetID=getStepContentLinkTargetID(this,step);
                    append(wrapperPara,...
                    mlreportgen.dom.LinkTarget(targetID));



                    if(this.IncludeStepHierarchy)
                        stepName=mlreportgen.dom.InternalLink(...
                        getStepHierarchyLinkTargetID(this),...
                        step.stateName);
                    else
                        stepName=mlreportgen.dom.Text(step.stateName);
                    end




                    updatedStepName=updateStepName(this,stepName,isScenario,isActiveScenario,wrapperPara);

                    append(docPart,updatedStepName);
                case "StepDescriptionTitle"
                    if this.IncludeStepDescription&&~isempty(step.description)
                        append(docPart,mlreportgen.dom.Paragraph(...
                        getString(message("slreportgen:report:TestSequence:description"))));
                    end
                case "StepDescriptionContent"
                    if this.IncludeStepDescription&&~isempty(step.description)
                        append(docPart,...
                        mlreportgen.dom.Paragraph(step.description));
                    end
                case "StepWhenConditionTitle"
                    if this.IncludeStepWhenCondition&&~isempty(step.whenCondition)
                        append(docPart,mlreportgen.dom.Paragraph(...
                        getString(message("slreportgen:report:TestSequence:whenCondition"))));
                    end
                case "StepWhenConditionContent"
                    if this.IncludeStepWhenCondition&&~isempty(step.whenCondition)
                        append(docPart,...
                        mlreportgen.utils.internal.MATLABCode(step.whenCondition));
                    end
                case "StepActionTitle"
                    if this.IncludeStepAction&&~isempty(step.stateAction)
                        append(docPart,mlreportgen.dom.Paragraph(...
                        getString(message("slreportgen:report:TestSequence:action"))));
                    end
                case "StepActionContent"
                    if this.IncludeStepAction&&~isempty(step.stateAction)
                        append(docPart,...
                        mlreportgen.utils.internal.MATLABCode(step.stateAction));
                    end
                case "StepTransitionContent"
                    if this.IncludeStepTransitions&&~isempty(step.transitions)
                        transitionTableReporter=getTransitionTableReporter(this,step);
                        append(docPart,transitionTableReporter.getImpl(rpt));
                    end
                case "StepRequirements"
                    if this.IncludeStepRequirements&&~isempty(step.requirements)
                        if rmi.isInstalled()


                            requirementsReporter=getRequirementsReporter(this,step);
                            append(docPart,requirementsReporter.getImpl(rpt));
                        else

                            para=mlreportgen.dom.Paragraph();
                            para.StyleName="TestSequenceNote";
                            para.WhiteSpace="preserve";

                            noteHeading=append(para,mlreportgen.dom.Text(...
                            getString(message("slreportgen:report:TestSequence:note"))));
                            noteHeading.Bold=true;
                            append(para," ");
                            append(para,mlreportgen.dom.Text(...
                            getString(message("slreportgen:report:TestSequence:SLReqNotInstalled"))));
                            append(docPart,para);
                        end
                    end
                end
                moveToNextHole(docPart);
            end
            close(docPart);



            content{end+1}=docPart;
        end

        function tf=isUsingScenarios(this)


            tf=this.ReactiveViewManager.getIsUseScenarios();
        end

        function activeScenarioIdx=getActiveScenarioIdx(this)




            activeScenarioIdx=-1;

            if isUsingScenarios(this)&&...
                ~this.ReactiveViewManager.getIsReadActiveFromWorkspace

                activeScenarioIdx=...
                this.ReactiveViewManager.jsActiveScenario()+1;
            end
        end

        function path=getScenarioIcon(this)

            path=this.ReactiveViewManager.getPathForScenarioIcon();
        end

        function path=getActiveScenarioIcon(this)

            path=this.ReactiveViewManager.getPathForActivateIcon();
        end

        function wrapperPara=updateStepName(this,stepName,isScenario,isActiveScenario,varargin)




            if nargin>4
                wrapperPara=varargin{1};
            else
                wrapperPara=mlreportgen.dom.Paragraph();
            end


            if isScenario
                append(wrapperPara,mlreportgen.dom.Image(getScenarioIcon(this)));
            end


            append(wrapperPara,stepName);



            if isActiveScenario
                append(wrapperPara,mlreportgen.dom.Text(" ("));
                append(wrapperPara,mlreportgen.dom.Text(...
                getString(message("slreportgen:report:TestSequence:active"))));
                append(wrapperPara,mlreportgen.dom.Image(getActiveScenarioIcon(this)));
                append(wrapperPara,mlreportgen.dom.Text(")"));
                wrapperPara.Bold=true;
            end
        end

    end

    methods(Static)
        function path=getClassFolder()


            [path]=fileparts(mfilename('fullpath'));
        end

        function template=createTemplate(templatePath,type)








            path=slreportgen.report.TestSequence.getClassFolder();
            template=mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function classfile=customizeReporter(toClasspath)










            classfile=mlreportgen.report.ReportForm.customizeClass(...
            toClasspath,"slreportgen.report.TestSequence");
        end

    end
end

function list=sortOnPort(list)

    if length(list)>1
        nList=cellfun(@(x)x.Port,list);
        [~,sortIdx]=sort(nList);
        list=list(sortIdx);
    end
end

function list=sortOnName(list)

    if length(list)>1
        nList=cellfun(@(x)x.Name,list,"UniformOutput",false);
        [~,sortIdx]=sort(nList);
        list=list(sortIdx);
    end
end

function mustBeTestSequenceObject(object)

    if~isempty(object)
        if isa(object,"slreportgen.finder.DiagramElementResult")
            object=object.Object;
        end

        if~slreportgen.utils.isTestSequence(object)
            error(message("slreportgen:report:error:invalidSourceObject"));
        end
    end
end
