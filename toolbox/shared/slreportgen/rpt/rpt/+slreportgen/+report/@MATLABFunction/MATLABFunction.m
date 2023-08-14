classdef MATLABFunction<slreportgen.report.Reporter


































































































    properties



        Object{mustBeMATLABFunctionObject(Object)}=[];




        IncludeObjectProperties{mustBeLogical}=true;



































        ObjectPropertiesReporter{mustBeBaseTable(ObjectPropertiesReporter)}=[];













        IncludeArgumentSummary{mustBeLogical}=true;



















        ArgumentSummaryProperties{mustBeValidArgumentProperty}=...
        {'Name','Scope','Port','Compiled Type','Compiled Size'};

















        ArgumentSummaryReporter{mustBeBaseTable(ArgumentSummaryReporter)}=[];










        IncludeArgumentProperties{mustBeLogical}=false;

















        ArgumentPropertiesReporter{mustBeBaseTable(ArgumentPropertiesReporter)}=[];




        IncludeFunctionScript{mustBeLogical}=true;




















        FunctionScript{mustBeDOMParagraph(FunctionScript)}=[];




















        FunctionScriptTitle{mustBeDOMParagraph(FunctionScriptTitle)}=[];





        IncludeSupportingFunctionsCode{mustBeLogical}=false;

















        SupportingFunctionsCodeTitle{mustBeDOMParagraph(SupportingFunctionsCodeTitle)};




















        SupportingFunctionsCode{mustBeDOMParagraph(SupportingFunctionsCode)};




        HighlightScriptSyntax{mustBeLogical}=true;











        IncludeFunctionSymbolData{mustBeLogical}=false;































































        FunctionSymbolReporter{mustBeBaseTable(FunctionSymbolReporter)}=[];








        IncludeSupportingFunctions{mustBeLogical}=false;









        SupportingFunctionsType{mustBeMember(SupportingFunctionsType,{'MATLAB','user-defined'})}=...
        {'MATLAB','user-defined'};















        SupportingFunctionsReporter{mustBeBaseTable(SupportingFunctionsReporter)}=[];

    end

    properties(Access=public,Hidden)











        ArgumentPropertiesReporters{mustBeBaseTableCellArray(ArgumentPropertiesReporters)}={};











        FunctionSymbolReporters{mustBeBaseTableCellArray(FunctionSymbolReporters)}={};

    end

    properties(Access=private)




        m_sfChart=[];






        m_mlSymbolData=[];


        m_ShouldNumberTableHierarchically=[];


        SupportingFcnTableData=-1;


        ModelCompiled=false;
    end

    methods
        function h=MATLABFunction(varargin)
            if(nargin==1)
                varargin=[{"Object"},varargin];
            end
            h=h@slreportgen.report.Reporter(varargin{:});





            p=inputParser;




            p.KeepUnmatched=true;




            addParameter(p,'TemplateName',"MATLABFunction");
            addParameter(p,'Object',[]);

            objectProperties=mlreportgen.report.BaseTable();
            objectProperties.TableStyleName="MATLABFunctionObjectPropertiesTable";
            addParameter(p,'ObjectPropertiesReporter',objectProperties);

            argumentSummary=mlreportgen.report.BaseTable();
            argumentSummary.TableStyleName="MATLABFunctionArgumentSummaryTable";
            addParameter(p,'ArgumentSummaryReporter',argumentSummary);

            argumentProperties=mlreportgen.report.BaseTable();
            argumentProperties.TableStyleName="MATLABFunctionArgumentPropertiesTable";
            addParameter(p,'ArgumentPropertiesReporter',argumentProperties);

            addParameter(p,'FunctionScriptTitle',mlreportgen.dom.Paragraph);

            para=mlreportgen.dom.Paragraph;
            para.WhiteSpace="preserve";
            addParameter(p,'FunctionScript',para);

            addParameter(p,'SupportingFunctionsCodeTitle',mlreportgen.dom.Paragraph);

            para=mlreportgen.dom.Paragraph;
            para.WhiteSpace="preserve";
            addParameter(p,'SupportingFunctionsCode',para);

            functionSymbol=mlreportgen.report.BaseTable();
            functionSymbol.TableStyleName="MATLABFunctionFunctionSymbolTable";
            addParameter(p,'FunctionSymbolReporter',functionSymbol);

            supportingFunctions=mlreportgen.report.BaseTable();
            supportingFunctions.TableStyleName="MATLABFunctionSupportingFunctionsTable";
            addParameter(p,'SupportingFunctionsReporter',supportingFunctions);


            parse(p,varargin{:});



            results=p.Results;
            h.TemplateName=results.TemplateName;
            h.ObjectPropertiesReporter=results.ObjectPropertiesReporter;
            h.ArgumentSummaryReporter=results.ArgumentSummaryReporter;
            h.ArgumentPropertiesReporter=results.ArgumentPropertiesReporter;
            h.FunctionScriptTitle=results.FunctionScriptTitle;
            h.FunctionScript=results.FunctionScript;
            h.SupportingFunctionsCodeTitle=results.SupportingFunctionsCodeTitle;
            h.SupportingFunctionsCode=results.SupportingFunctionsCode;
            h.FunctionSymbolReporter=results.FunctionSymbolReporter;
            h.SupportingFunctionsReporter=results.SupportingFunctionsReporter;
        end

        function set.ObjectPropertiesReporter(h,value)


            mustBeNonempty(value);



            h.ObjectPropertiesReporter=value;
        end

        function set.ArgumentSummaryReporter(h,value)


            mustBeNonempty(value);



            h.ArgumentSummaryReporter=value;
        end

        function set.ArgumentPropertiesReporter(h,value)


            mustBeNonempty(value);



            h.ArgumentPropertiesReporter=value;
        end

        function set.FunctionScriptTitle(h,value)


            mustBeNonempty(value);



            h.FunctionScriptTitle=value;
        end

        function set.FunctionScript(h,value)


            mustBeNonempty(value);



            h.FunctionScript=value;
        end

        function set.FunctionSymbolReporter(h,value)


            mustBeNonempty(value);



            h.FunctionSymbolReporter=value;
        end

        function set.SupportingFunctionsReporter(h,value)


            mustBeNonempty(value);



            h.SupportingFunctionsReporter=value;
        end

        function impl=getImpl(h,rpt)
            impl=[];

            if isempty(h.Object)
                error(message("slreportgen:report:error:noSourceObjectSpecified",class(h)));
            else

                h.m_sfChart=getSfChart(h);

                if~isempty(h.m_sfChart)






                    if isa(h.m_sfChart,'Stateflow.EMChart')&&...
                        (h.IncludeFunctionSymbolData||...
                        h.IncludeSupportingFunctions||...
                        h.IncludeSupportingFunctionsCode)
                        h.m_mlSymbolData=slreportgen.utils.MATLABFunctionSymbolData(h.m_sfChart);
                    end

                    if isempty(h.LinkTarget)

                        objH=slreportgen.utils.getSlSfHandle(h.Object);
                        if isa(objH,'Stateflow.Object')
                            parentPath=objH.Subviewer.Path;
                        else
                            parent=get_param(objH,"Parent");
                            hs=slreportgen.utils.HierarchyService;
                            dhid=hs.getDiagramHID(parent);
                            parentPath=hs.getPath(dhid);
                        end

                        if~isempty(parentPath)
                            parentPath=strrep(parentPath,newline,' ');
                            parentDiagram=getContext(rpt,parentPath);
                            if~isempty(parentDiagram)&&(parentDiagram.HyperLinkDiagram)
                                h.LinkTarget=slreportgen.utils.getObjectID(h.Object);
                            end
                        end
                    end

                    h.m_ShouldNumberTableHierarchically=isChapterNumberHierarchical(h,rpt);


                    impl=getImpl@slreportgen.report.Reporter(h,rpt);
                end
            end
        end
    end

    methods(Access={?mlreportgen.report.ReportForm,?slreporten.report.MATLABFunction})
        function content=getObjectProperties(h,rpt)


            content=[];

            if h.IncludeObjectProperties


                objPropTableData=getObjectPropertyTableData(h,rpt,h.m_sfChart);



                updateObjectPropertiesReporter(h,objPropTableData);
                if mlreportgen.report.Reporter.isInlineContent(h.ObjectPropertiesReporter.Title)

                    titleReporter=getTitleReporter(h.ObjectPropertiesReporter);
                    titleReporter.TemplateSrc=h;

                    if h.m_ShouldNumberTableHierarchically
                        titleReporter.TemplateName='MATLABFunctionHierNumberedTitle';
                    else
                        titleReporter.TemplateName='MATLABFunctionNumberedTitle';
                    end
                    h.ObjectPropertiesReporter.Title=titleReporter;
                end



                content=h.ObjectPropertiesReporter;
            end
        end

        function content=getArgumentSummary(h,rpt)


            content=[];

            if h.IncludeArgumentSummary

                args=h.m_sfChart.find('-isa','Stateflow.Data');


                props=h.ArgumentSummaryProperties;

                if~isempty(args)&&~isempty(props)


                    if any(strcmp(props,'Compiled Type'))||...
                        any(strcmp(props,'Compiled Size'))||...
                        any(strcmp(props,'Variable Size'))
                        compileModel(h,rpt);
                    end



                    args=sortArguments(h,args);



                    argSummaryTableData=getArgumentSummaryTableData(h,args,props);



                    updateArgumentSummaryReporter(h,argSummaryTableData);

                    if mlreportgen.report.Reporter.isInlineContent(h.ArgumentSummaryReporter.Title)
                        titleReporter=getTitleReporter(h.ArgumentSummaryReporter);
                        titleReporter.TemplateSrc=h;

                        if h.m_ShouldNumberTableHierarchically
                            titleReporter.TemplateName='MATLABFunctionHierNumberedTitle';
                        else
                            titleReporter.TemplateName='MATLABFunctionNumberedTitle';
                        end
                        h.ArgumentSummaryReporter.Title=titleReporter;
                    end


                    content=h.ArgumentSummaryReporter;
                end
            end
        end

        function content=getArgumentProperties(h,rpt)


            content=[];

            if h.IncludeArgumentProperties

                args=h.m_sfChart.find('-isa','Stateflow.Data');

                if~isempty(args)


                    compileModel(h,rpt);


                    args=sortArguments(h,args);

                    for iArg=1:numel(args)

                        arg=args(iArg);



                        argTableData=getArgumentTableData(h,arg);





                        argTableReporter=getArgumentTableReporter(h,arg,argTableData);
                        if mlreportgen.report.Reporter.isInlineContent(argTableReporter.Title)
                            titleReporter=getTitleReporter(argTableReporter);
                            titleReporter.TemplateSrc=h;

                            if h.m_ShouldNumberTableHierarchically
                                titleReporter.TemplateName='MATLABFunctionHierNumberedTitle';
                            else
                                titleReporter.TemplateName='MATLABFunctionNumberedTitle';
                            end
                            argTableReporter.Title=titleReporter;
                        end

                        h.ArgumentPropertiesReporters=[h.ArgumentPropertiesReporters,{argTableReporter}];

                    end



                    content=h.ArgumentPropertiesReporters;
                end
            end
        end

        function content=getFunctionSymbolData(h,rpt)%#ok<INUSD>


            content=[];



            if h.IncludeFunctionSymbolData&&...
                isa(h.m_sfChart,'Stateflow.EMChart')&&...
                ~isempty(h.m_mlSymbolData)


                fcnIdsToReport=getFunctionIdsToReport(h);

                for iFId=1:numel(fcnIdsToReport)
                    fId=fcnIdsToReport(iFId);



                    if(fId==h.m_mlSymbolData.getRootFunctionID())
                        isRootFcn=true;
                    else
                        isRootFcn=false;
                    end


                    fcnDetails=h.m_mlSymbolData.getFcnDetails(fId);



                    fcnDetTableData=getFcnDetailTableData(h,fcnDetails,fId);




                    fcnDetTableReporter=getFcnDetailTableReporter(h,fcnDetTableData,isRootFcn);

                    if mlreportgen.report.Reporter.isInlineContent(fcnDetTableReporter.Title)
                        titleReporter=getTitleReporter(fcnDetTableReporter);
                        titleReporter.TemplateSrc=h;

                        if h.m_ShouldNumberTableHierarchically
                            titleReporter.TemplateName='MATLABFunctionHierNumberedTitle';
                        else
                            titleReporter.TemplateName='MATLABFunctionNumberedTitle';
                        end
                        fcnDetTableReporter.Title=titleReporter;
                    end

                    h.FunctionSymbolReporters=[h.FunctionSymbolReporters,{fcnDetTableReporter}];


                    symbolDetails=h.m_mlSymbolData.getSymbolTableDetails(fId);
                    if~isempty(symbolDetails)


                        symbolTableData=getSymbolTableData(h,symbolDetails);




                        symbolTableReporter=getSymbolTableReporter(h,symbolTableData);

                        if mlreportgen.report.Reporter.isInlineContent(symbolTableReporter.Title)
                            titleReporter=getTitleReporter(symbolTableReporter);
                            titleReporter.TemplateSrc=h;

                            if h.m_ShouldNumberTableHierarchically
                                titleReporter.TemplateName='MATLABFunctionHierNumberedTitle';
                            else
                                titleReporter.TemplateName='MATLABFunctionNumberedTitle';
                            end
                            symbolTableReporter.Title=titleReporter;
                        end

                        h.FunctionSymbolReporters=...
                        [h.FunctionSymbolReporters,{symbolTableReporter}];
                    end


                    operationDetails=h.m_mlSymbolData.getOperTableDetails(fId);
                    if~isempty(operationDetails)


                        operationTableData=getOperationTableData(h,operationDetails);




                        operationTableReporter=getOperationTableReporter(h,operationTableData);
                        if mlreportgen.report.Reporter.isInlineContent(operationTableReporter.Title)
                            titleReporter=getTitleReporter(operationTableReporter);
                            titleReporter.TemplateSrc=h;

                            if h.m_ShouldNumberTableHierarchically
                                titleReporter.TemplateName='MATLABFunctionHierNumberedTitle';
                            else
                                titleReporter.TemplateName='MATLABFunctionNumberedTitle';
                            end
                            operationTableReporter.Title=titleReporter;
                        end

                        h.FunctionSymbolReporters=[h.FunctionSymbolReporters,{operationTableReporter}];
                    end


                    fcnCallSiteDetails=h.m_mlSymbolData.getFcnCallSiteDetails(fId);
                    if~isempty(fcnCallSiteDetails)


                        fcnCallSiteTableData=getFcnCallSiteTableData(h,fcnCallSiteDetails);




                        fcnCallSiteTableReporter=getFcnCallSiteTableReporter(h,fcnCallSiteTableData);

                        if mlreportgen.report.Reporter.isInlineContent(fcnCallSiteTableReporter.Title)
                            titleReporter=getTitleReporter(fcnCallSiteTableReporter);
                            titleReporter.TemplateSrc=h;

                            if h.m_ShouldNumberTableHierarchically
                                titleReporter.TemplateName='MATLABFunctionHierNumberedTitle';
                            else
                                titleReporter.TemplateName='MATLABFunctionNumberedTitle';
                            end
                            fcnCallSiteTableReporter.Title=titleReporter;
                        end

                        h.FunctionSymbolReporters=[h.FunctionSymbolReporters,{fcnCallSiteTableReporter}];
                    end
                end

                content=h.FunctionSymbolReporters;
            end
        end

        function content=getSupportingFunctions(h,rpt)%#ok<INUSD>


            content=[];



            if h.IncludeSupportingFunctions&&...
                isa(h.m_sfChart,'Stateflow.EMChart')&&...
                ~isempty(h.m_mlSymbolData)




                suppFcnTableData=getSupportingFcnTableData(h);

                if~isempty(suppFcnTableData)


                    updateSupportingFunctionsReporter(h,suppFcnTableData);
                    if mlreportgen.report.Reporter.isInlineContent(h.SupportingFunctionsReporter.Title)
                        titleReporter=getTitleReporter(h.SupportingFunctionsReporter);
                        titleReporter.TemplateSrc=h;

                        if h.m_ShouldNumberTableHierarchically
                            titleReporter.TemplateName='MATLABFunctionHierNumberedTitle';
                        else
                            titleReporter.TemplateName='MATLABFunctionNumberedTitle';
                        end
                        h.SupportingFunctionsReporter.Title=titleReporter;
                    end


                    content=h.SupportingFunctionsReporter;
                end
            end
        end

        function content=getFunctionScriptTitle(h,rpt)%#ok<INUSD>


            content=[];

            if h.IncludeFunctionScript
                titleText=getSfChartName(h)+" "+...
                getString(message("slreportgen:report:MATLABFunction:defaultFunctionScriptTitle"));
                titleObj=mlreportgen.dom.Text(titleText);
                h.FunctionScriptTitle.append(titleObj);
                content=h.FunctionScriptTitle;
            end
        end

        function content=getFunctionScript(h,rpt)


            content=[];

            if h.IncludeFunctionScript

                script=deblank(h.m_sfChart.Script);

                content=getScriptDOM(h,script,h.FunctionScript,h.Object,rpt);
            end
        end

        function content=getSupportingFunctionsCode(h,rpt)
            content=[];
            if h.IncludeSupportingFunctionsCode&&...
                isa(h.m_sfChart,'Stateflow.EMChart')&&...
                ~isempty(h.m_mlSymbolData)



                suppFcnTableData=getSupportingFcnTableData(h);
                if~isempty(suppFcnTableData)


                    if isa(h.TemplateSrc,"slreportgen.report.internal.DocumentPart")
                        baseDp=h.TemplateSrc;
                    else
                        baseDp=slreportgen.report.internal.DocumentPart(rpt.Type,h.TemplateSrc,"SupportingFunction");
                    end


                    userIdx=strcmp(suppFcnTableData(:,2),...
                    getString(message("slreportgen:report:MATLABFunction:user")));
                    userFcns=suppFcnTableData(userIdx,:);


                    [~,uniqueIdx,~]=unique(userFcns(:,3),'stable');
                    userFcns=userFcns(uniqueIdx,:);


                    if isempty(h.SupportingFunctionsReporter.LinkTarget)
                        fcnsTableId=getFunctionTableLinkTargetID(h.Object);
                        h.SupportingFunctionsReporter.LinkTarget=fcnsTableId;
                    else
                        fcnsTableId=h.SupportingFunctionsReporter.LinkTarget;
                    end


                    nFcns=height(userFcns);
                    content=slreportgen.report.internal.DocumentPart.empty(0,nFcns);
                    toRemove=[];
                    for idx=1:nFcns
                        filePath=userFcns{idx,3};

                        if isfile(filePath)
                            dp=slreportgen.report.internal.DocumentPart(baseDp,"SupportingFunction");
                            openImpl(h,dp);


                            currHole=moveToNextHole(dp);
                            while~strcmp(currHole,"#end#")
                                switch currHole
                                case "SupportingFunctionCodeTitle"
                                    if h.IncludeSupportingFunctions
                                        titleElem=mlreportgen.dom.InternalLink(fcnsTableId,userFcns{idx,1});
                                    else
                                        titleElem=mlreportgen.dom.Text(userFcns{idx,1});
                                    end
                                    titlePara=clone(h.SupportingFunctionsCodeTitle);
                                    append(titlePara,titleElem);

                                    append(dp,titlePara);
                                case "SupportingFunctionCode"
                                    fcnDOM=clone(h.SupportingFunctionsCode);
                                    fcnDOM=getScriptDOM(h,[],fcnDOM,filePath,rpt);
                                    append(dp,fcnDOM);
                                end
                                currHole=moveToNextHole(dp);
                            end

                            content(idx)=dp;
                        else


                            toRemove=idx;
                        end

                    end


                    if~isempty(toRemove)&&toRemove<nFcns
                        content(toRemove)=[];
                    end
                end
            end
        end
    end

    methods(Access=protected,Hidden)

        result=openImpl(reporter,impl,varargin)
    end

    methods(Access=private)
        function scriptDOM=getScriptDOM(h,script,scriptDOM,filePath,rpt)





            optionalWS=optionalPattern(whitespacePattern)+optionalPattern("...")+optionalPattern(whitespacePattern);


            fcnDefStartPattern=lookBehindBoundary(lineBoundary('start')+whitespaceBoundary('end'))+lookAheadBoundary("function");


            fcnMultiOutputPattern=textBoundary('start')+optionalWS+optionalPattern("["+wildcardPattern+"]"+optionalWS+"="+optionalWS);


            fcnSingleOutputPattern=textBoundary('start')+optionalWS+optionalPattern(alphanumericsPattern+optionalWS+"="+optionalWS);


            fcnNamePattern=textBoundary('start')+asManyOfPattern(alphanumericsPattern|"_",1);


            mlCode=mlreportgen.report.MATLABCode();
            if isempty(script)
                mlCode.FileName=filePath;
                [~,fileName,ext]=fileparts(filePath);
            else
                mlCode.Content=script;
                fileName=filePath;
                ext="";
            end

            if~h.HighlightScriptSyntax



                fcnText=mlCode.Content;

                if h.IncludeSupportingFunctions

                    fcns=split(fcnText,fcnDefStartPattern);

                    fcnNames=extractAfter(fcns,optionalWS+"function"+optionalWS);
                    fcnNames=extractAfter(fcnNames,fcnMultiOutputPattern);
                    fcnNames=extractAfter(fcnNames,fcnSingleOutputPattern);
                    fcnNames=string(extract(fcnNames,fcnNamePattern));


                    nFcns=numel(fcnNames);
                    for idx=1:nFcns

                        linkTarget=mlreportgen.dom.LinkTarget(...
                        getFunctionLinkTargetID(filePath,fcnNames(idx)));
                        append(scriptDOM,linkTarget);




                        scriptTextObj=mlreportgen.dom.Text(fcns{idx});
                        scriptDOM.append(scriptTextObj);
                    end
                else
                    scriptTextObj=mlreportgen.dom.Text(fcnText);
                    append(scriptDOM,scriptTextObj);
                end
            else


                if strcmpi(ext,".mlx")





                    mlCode.LinkTarget=getFunctionLinkTargetID(filePath,fileName);
                    scriptDOM=getImpl(mlCode,rpt);
                else


                    impl=getImpl(mlCode,rpt);
                    textNodes=getTextNodes(h,impl);

                    for i=1:numel(textNodes)
                        node=textNodes{i};

                        if h.IncludeSupportingFunctions...
                            &&strcmp(node.Content,"function")...
                            &&strcmp(node.Color,"#0e00ff")

                            fcnNameContent=textNodes{i+1}.Content;
                            fcnName=extractAfter(fcnNameContent,fcnMultiOutputPattern);
                            fcnName=extractAfter(fcnName,fcnSingleOutputPattern);
                            fcnName=string(extract(fcnName,fcnNamePattern));

                            linkTarget=mlreportgen.dom.LinkTarget(...
                            getFunctionLinkTargetID(filePath,fcnName));
                            append(scriptDOM,linkTarget);
                        end
                        scriptDOM.append(clone(node));
                    end
                end

            end
        end

        function chart=getSfChart(h)


            obj=h.Object;
            chart=[];
            if isa(obj,'Stateflow.Object')
                if isa(obj,'Stateflow.EMFunction')
                    chart=obj;
                end
            else
                try
                    emlFcnChart=slreportgen.utils.block2chart(obj);
                    if isa(emlFcnChart,'Stateflow.EMChart')
                        chart=emlFcnChart;
                    end
                catch

                end
            end
        end

        function chartName=getSfChartName(h)



            chartName=h.m_sfChart.Name;

            if~isempty(chartName)
                chartName=mlreportgen.utils.normalizeString(chartName);
            end
        end

        function compileModel(h,rpt)
            modelH=slreportgen.utils.getModelHandle(h.Object);
            compileModel(rpt,modelH);
            h.ModelCompiled=slreportgen.utils.isModelCompiled(modelH);
        end

        function objTableData=getObjectPropertyTableData(h,rpt,chartObj)




            inputFiMath=mlreportgen.dom.Paragraph();
            inputFiMath.WhiteSpace='preserve';

            if h.HighlightScriptSyntax


                htmlFileObj=getHighlightedContent(h,rpt,chartObj.InputFimath);



                textNodes=getTextNodes(h,htmlFileObj);
                for i=1:numel(textNodes)
                    inputFiMath.append(clone(textNodes{i}));
                end
            else


                textObj=mlreportgen.dom.Text(chartObj.InputFimath);
                inputFiMath.append(textObj);
            end

            import mlreportgen.utils.toString;
            if isa(chartObj,'Stateflow.EMChart')
                objTableData=...
                {...
                getString(message("slreportgen:report:MATLABFunction:updateMethod")),...
                chartObj.ChartUpdate;...
                getString(message("slreportgen:report:MATLABFunction:sampleTime")),...
                chartObj.SampleTime;...
                getString(message("slreportgen:report:MATLABFunction:variableArraySupport")),...
                toString(chartObj.SupportVariableSizing);...
                getString(message("slreportgen:report:MATLABFunction:satOnIntOverflow")),...
                toString(chartObj.SaturateOnIntegerOverflow);...
                getString(message("slreportgen:report:MATLABFunction:treatSignalAsFI")),...
                chartObj.TreatAsFi;...
                getString(message("slreportgen:report:MATLABFunction:embedFIMath")),...
                chartObj.EmlDefaultFimath;...
                getString(message("slreportgen:report:MATLABFunction:inputFIMath")),...
                inputFiMath;...
                getString(message("slreportgen:report:MATLABFunction:description")),...
                chartObj.Description...
                };
            else
                objTableData=...
                {...
                getString(message("slreportgen:report:MATLABFunction:satOnIntOverflow")),...
                toString(chartObj.SaturateOnIntegerOverflow);...
                getString(message("slreportgen:report:MATLABFunction:embedFIMath")),...
                chartObj.EmlDefaultFimath;...
                getString(message("slreportgen:report:MATLABFunction:inputFIMath")),...
                inputFiMath;...
                getString(message("slreportgen:report:MATLABFunction:description")),...
                chartObj.Description...
                };
            end
        end

        function updateObjectPropertiesReporter(h,objPropTableData)





            reporter=h.ObjectPropertiesReporter;


            title=...
            getSfChartName(h)+" "+...
            getString(message("slreportgen:report:MATLABFunction:defaultObjectPropertiesTableTitle"));

            if isempty(reporter.Title)
                reporter.Title=title;
            else


                appendTitle(reporter,title);
            end



            table=mlreportgen.dom.FormalTable(objPropTableData);


            tr=mlreportgen.dom.TableRow();
            append(tr,mlreportgen.dom.TableHeaderEntry(getString(message("slreportgen:report:MATLABFunction:property"))));
            append(tr,mlreportgen.dom.TableHeaderEntry(getString(message("slreportgen:report:MATLABFunction:value"))));
            append(table.Header,tr);




            reporter.Content=table;
        end

        function args=sortArguments(~,args)





            scopeName=arrayfun(@(x)strcat(x.Scope,x.Name),args,"UniformOutput",false);
            [~,sortIdx]=sort(scopeName);
            args=args(sortIdx);
        end

        function argTableData=getArgumentTableData(h,arg)




            import mlreportgen.utils.toString;


            [type,size,isVarSize]=getCompiledArgProperties(h,arg);

            argTableData=...
            {...
            getString(message("slreportgen:report:MATLABFunction:name")),...
            toString(arg.Name);...
            getString(message("slreportgen:report:MATLABFunction:scope")),...
            toString(arg.Scope);...
            getString(message("slreportgen:report:MATLABFunction:port")),...
            toString(arg.Port);...
            getString(message("slreportgen:report:MATLABFunction:compiledType")),...
            toString(type);...
            getString(message("slreportgen:report:MATLABFunction:compiledSize")),...
            toString(size);...
            getString(message("slreportgen:report:MATLABFunction:complexity")),...
            toString(arg.Complexity);...
            getString(message("slreportgen:report:MATLABFunction:description")),...
            toString(arg.Description);...
            getString(message("slreportgen:report:MATLABFunction:maxValue")),...
            toString(arg.Props.Range.Maximum);...
            getString(message("slreportgen:report:MATLABFunction:minValue")),...
            toString(arg.Props.Range.Minimum);...
            getString(message("slreportgen:report:MATLABFunction:tunable")),...
            toString(arg.Tunable);...
            getString(message("slreportgen:report:MATLABFunction:variableSize")),...
            toString(isVarSize)...
            };
        end

        function argTableReporter=getArgumentTableReporter(h,arg,argTableData)






            argTableReporter=copy(h.ArgumentPropertiesReporter);


            title=...
            arg.Name+" "+...
            getString(message("slreportgen:report:MATLABFunction:defaultArgPropertiesTableTitle"));
            if isempty(argTableReporter.Title)
                argTableReporter.Title=title;
            else


                appendTitle(argTableReporter,title);
            end


            table=mlreportgen.dom.FormalTable(argTableData);


            tr=mlreportgen.dom.TableRow();
            append(tr,mlreportgen.dom.TableHeaderEntry(getString(message("slreportgen:report:MATLABFunction:property"))));
            append(tr,mlreportgen.dom.TableHeaderEntry(getString(message("slreportgen:report:MATLABFunction:value"))));
            append(table.Header,tr);


            argTableReporter.Content=table;
        end

        function value=getArgPropertyValue(h,arg,prop)



            value="";
            import mlreportgen.utils.toString;
            switch prop
            case{'Name','Scope','Port','Complexity','Description','Tunable'}
                value=toString(arg.(prop));
            case 'Compiled Type'
                [value,~,~]=getCompiledArgProperties(h,arg);
                value=toString(value);
            case 'Compiled Size'
                [~,value,~]=getCompiledArgProperties(h,arg);
                value=toString(value);
            case 'Max Value'
                value=toString(arg.Props.Range.Maximum);
            case 'Min Value'
                value=toString(arg.Props.Range.Minimum);
            case 'Variable Size'
                [~,~,value]=getCompiledArgProperties(h,arg);
                value=toString(value);
            end
        end

        function[typeVal,sizeVal,isVarSizeVal]=getCompiledArgProperties(h,arg)
            if h.ModelCompiled
                obj=slreportgen.utils.getSlSfHandle(h.Object);
                if~isnumeric(obj)
                    obj=get_param(obj.Path,"Handle");
                end
                parsedData=sf('DataParsedInfo',arg.id,obj);
                typeVal=parsedData.compiled.type;
                sizeVal=parsedData.compiled.size;
                isVarSizeVal=parsedData.isVarSize;
            else
                typeVal="";
                sizeVal="";
                isVarSizeVal="";
            end
        end

        function argSummaryTableData=getArgumentSummaryTableData(h,args,props)



            nArgs=numel(args);
            nProps=numel(props);
            argSummaryTableData=cell(nArgs,nProps);
            for iArg=1:nArgs
                for iProp=1:nProps
                    argSummaryTableData{iArg,iProp}=...
                    getArgPropertyValue(h,args(iArg),props{iProp});
                end
            end
        end

        function updateArgumentSummaryReporter(h,argSummaryTableData)






            reporter=h.ArgumentSummaryReporter;


            title=...
            getSfChartName(h)+" "+...
            getString(message("slreportgen:report:MATLABFunction:defaultArgSummaryTableTitle"));
            if isempty(reporter.Title)
                reporter.Title=title;
            else


                appendTitle(reporter,title);
            end



            table=mlreportgen.dom.FormalTable(argSummaryTableData);


            tr=mlreportgen.dom.TableRow();
            props=h.ArgumentSummaryProperties;
            for iProp=1:numel(props)
                propName=[];

                switch props{iProp}
                case 'Name'
                    propName=getString(message("slreportgen:report:MATLABFunction:name"));
                case 'Scope'
                    propName=getString(message("slreportgen:report:MATLABFunction:scope"));
                case 'Port'
                    propName=getString(message("slreportgen:report:MATLABFunction:port"));
                case 'Compiled Type'
                    propName=getString(message("slreportgen:report:MATLABFunction:dataType"));
                case 'Compiled Size'
                    propName=getString(message("slreportgen:report:MATLABFunction:size"));
                case 'Complexity'
                    propName=getString(message("slreportgen:report:MATLABFunction:complexity"));
                case 'Description'
                    propName=getString(message("slreportgen:report:MATLABFunction:description"));
                case 'Max Value'
                    propName=getString(message("slreportgen:report:MATLABFunction:maximum"));
                case 'Min Value'
                    propName=getString(message("slreportgen:report:MATLABFunction:minimum"));
                case 'Tunable'
                    propName=getString(message("slreportgen:report:MATLABFunction:tunable"));
                case 'Variable Size'
                    propName=getString(message("slreportgen:report:MATLABFunction:variableSize"));
                end

                append(tr,mlreportgen.dom.TableHeaderEntry(propName));
            end
            append(table.Header,tr);




            reporter.Content=table;
        end

        function yn=isUserVisible(h,fId)


            fcnDetails=h.m_mlSymbolData.getFcnDetails(fId);
            yn=fcnDetails.isUserVisible;
        end

        function fcnIdsToReport=getFunctionIdsToReport(h)




            fcnIdsToReport=h.m_mlSymbolData.getRootFunctionID();


            if(h.IncludeSupportingFunctions||h.IncludeSupportingFunctionsCode)...
                &&~isempty(h.SupportingFunctionsType)
                fIdList=h.m_mlSymbolData.getFIdList();

                udFId=[];
                if~isempty(find(strcmp(h.SupportingFunctionsType,'user-defined'),1))

                    udFId=fIdList(arrayfun(@(s)isUserVisible(h,s),fIdList));
                end

                mdFId=[];
                if~isempty(find(strcmp(h.SupportingFunctionsType,'MATLAB'),1))

                    mdFId=fIdList(arrayfun(@(s)~isUserVisible(h,s),fIdList));
                end

                fcnIdsToReport=[fcnIdsToReport,udFId,mdFId];
                fcnIdsToReport=unique(fcnIdsToReport);
            end
        end

        function fcnDetTableData=getFcnDetailTableData(~,fcnDetails,fId)



            fcnDetTableData=...
            {...
            getString(message("slreportgen:report:MATLABFunction:functionName"))+": ",...
            fcnDetails.fcnName;...
            getString(message("slreportgen:report:MATLABFunction:functionId"))+": ",...
            fId;...
            getString(message("slreportgen:report:MATLABFunction:path"))+": ",...
            fcnDetails.scrPath...
            };
        end

        function fcnDetTableReporter=getFcnDetailTableReporter(h,fcnDetTableData,isRootFcn)







            fcnDetTableReporter=copy(h.FunctionSymbolReporter);


            if isRootFcn
                title=getSfChartName(h)+" "+...
                getString(message("slreportgen:report:MATLABFunction:defaultFunctionSymboDataTitle"));
                if isempty(fcnDetTableReporter.Title)
                    fcnDetTableReporter.Title=title;
                else


                    appendTitle(fcnDetTableReporter,title);
                end
            else
                fcnDetTableReporter.Title=[];
            end


            table=mlreportgen.dom.Table(fcnDetTableData);


            fcnDetTableReporter.Content=table;



            fcnDetTableReporter.TableStyleName='MATLABFunctionFunctionDetailTable';
        end

        function dataType=getSymbolDataTypeToReport(~,symbol)


            if isa(symbol.dataType,'eml.MxInfo')


                dataType="other";
            elseif all(symbol.size==1)

                dataType=symbol.dataType;
            else


                dataType=symbol.dataType+" ["+int2str(symbol.size)+"]";
            end
        end

        function symbolTableData=getSymbolTableData(h,symbolDetails)



            nSymbols=numel(symbolDetails);
            nProps=3;
            symbolTableData=cell(nSymbols,nProps);

            for iSym=1:nSymbols
                symbolDetail=symbolDetails(iSym);


                symbolTableData{iSym,1}=symbolDetail.name;
                symbolTableData{iSym,2}=getSymbolDataTypeToReport(h,symbolDetail);
                symbolTableData{iSym,3}=symbolDetail.position;
            end
        end

        function symbolTableReporter=getSymbolTableReporter(h,symbolTableData)






            symbolTableReporter=copy(h.FunctionSymbolReporter);




            title=mlreportgen.dom.Paragraph(getString(message("slreportgen:report:MATLABFunction:defaultSymbolTableTitle")));
            title.StyleName="MATLABFunctionSymbolDetailsTableTitle";
            symbolTableReporter.Title=title;


            table=mlreportgen.dom.FormalTable(symbolTableData);


            tr=mlreportgen.dom.TableRow();
            append(tr,mlreportgen.dom.TableHeaderEntry(getString(message("slreportgen:report:MATLABFunction:name"))));
            append(tr,mlreportgen.dom.TableHeaderEntry(getString(message("slreportgen:report:MATLABFunction:dataType"))));
            append(tr,mlreportgen.dom.TableHeaderEntry(getString(message("slreportgen:report:MATLABFunction:startPosition"))));
            append(table.Header,tr);


            symbolTableReporter.Content=table;
        end

        function operationTableData=getOperationTableData(h,operationDetails)



            noperations=numel(operationDetails);
            nProps=3;
            operationTableData=cell(noperations,nProps);

            for iOp=1:noperations
                operationDetail=operationDetails(iOp);


                operationTableData{iOp,1}=operationDetail.name;
                operationTableData{iOp,2}=getSymbolDataTypeToReport(h,operationDetail);
                operationTableData{iOp,3}=operationDetail.position;
            end
        end

        function operationTableReporter=getOperationTableReporter(h,operationTableData)






            operationTableReporter=copy(h.FunctionSymbolReporter);




            title=mlreportgen.dom.Paragraph(getString(message("slreportgen:report:MATLABFunction:defaultOperationsTableTitle")));
            title.StyleName="MATLABFunctionOperationDetailsTableTitle";
            operationTableReporter.Title=title;


            table=mlreportgen.dom.FormalTable(operationTableData);


            tr=mlreportgen.dom.TableRow();
            append(tr,mlreportgen.dom.TableHeaderEntry(getString(message("slreportgen:report:MATLABFunction:name"))));
            append(tr,mlreportgen.dom.TableHeaderEntry(getString(message("slreportgen:report:MATLABFunction:dataType"))));
            append(tr,mlreportgen.dom.TableHeaderEntry(getString(message("slreportgen:report:MATLABFunction:startPosition"))));
            append(table.Header,tr);


            operationTableReporter.Content=table;
        end

        function fcnCallSiteTableData=getFcnCallSiteTableData(h,fcnCallSiteDetails)



            nFcnCallSites=numel(fcnCallSiteDetails);
            nProps=4;
            fcnCallSiteTableData=cell(nFcnCallSites,nProps);

            for iFcn=1:nFcnCallSites
                fcnCallSiteDetail=fcnCallSiteDetails(iFcn);


                fcnCallSiteTableData{iFcn,1}=fcnCallSiteDetail.name;
                fcnCallSiteTableData{iFcn,2}=getSymbolDataTypeToReport(h,fcnCallSiteDetail);
                fcnCallSiteTableData{iFcn,3}=fcnCallSiteDetail.functionId;
                fcnCallSiteTableData{iFcn,4}=fcnCallSiteDetail.position;
            end
        end

        function fcnCallSiteTableReporter=getFcnCallSiteTableReporter(h,fcnCallSiteTableData)






            fcnCallSiteTableReporter=copy(h.FunctionSymbolReporter);




            title=mlreportgen.dom.Paragraph(getString(message("slreportgen:report:MATLABFunction:defaultFunctionCallSiteTableTitle")));
            title.StyleName="MATLABFunctionFunctionCallSiteDetailsTableTitle";
            fcnCallSiteTableReporter.Title=title;



            table=mlreportgen.dom.FormalTable(fcnCallSiteTableData);


            tr=mlreportgen.dom.TableRow();
            append(tr,mlreportgen.dom.TableHeaderEntry(getString(message("slreportgen:report:MATLABFunction:name"))));
            append(tr,mlreportgen.dom.TableHeaderEntry(getString(message("slreportgen:report:MATLABFunction:dataType"))));
            append(tr,mlreportgen.dom.TableHeaderEntry(getString(message("slreportgen:report:MATLABFunction:functionId"))));
            append(tr,mlreportgen.dom.TableHeaderEntry(getString(message("slreportgen:report:MATLABFunction:startPosition"))));
            append(table.Header,tr);


            fcnCallSiteTableReporter.Content=table;
        end

        function suppFcnTableData=getSupportingFcnTableData(h)





            if iscell(h.SupportingFcnTableData)
                suppFcnTableData=h.SupportingFcnTableData;
            else


                fIdsToReport=getFunctionIdsToReport(h);



                fIdsToReport(fIdsToReport==h.m_mlSymbolData.getRootFunctionID)=[];

                nFcns=numel(fIdsToReport);
                suppFcnTableData={};
                if nFcns>0
                    names=cell(1,nFcns);
                    definedBys=cell(1,nFcns);
                    paths=cell(1,nFcns);


                    for iFId=1:nFcns
                        fId=fIdsToReport(iFId);


                        fcnDetails=h.m_mlSymbolData.getFcnDetails(fId);

                        names{iFId}=fcnDetails.fcnName;
                        if isUserVisible(h,fId)
                            definedBys{iFId}=getString(message("slreportgen:report:MATLABFunction:user"));
                        else
                            definedBys{iFId}=getString(message("slreportgen:report:MATLABFunction:matlab"));
                        end
                        paths{iFId}=fcnDetails.scrPath;
                    end


                    [names,ix]=unique(names);
                    definedBys=definedBys(ix);
                    paths=paths(ix);


                    suppFcnTableData=cell(numel(names),3);
                    suppFcnTableData(1:end,1)=names;
                    suppFcnTableData(1:end,2)=definedBys;
                    suppFcnTableData(1:end,3)=paths;
                end

                h.SupportingFcnTableData=suppFcnTableData;
            end
        end

        function updateSupportingFunctionsReporter(h,suppFcnTableData)






            reporter=h.SupportingFunctionsReporter;
            if isempty(reporter.LinkTarget)
                reporter.LinkTarget=getFunctionTableLinkTargetID(h.Object);
            end


            title=...
            getSfChartName(h)+" "+...
            getString(message("slreportgen:report:MATLABFunction:defaultSuppFunctionsTableTitle"));
            if isempty(reporter.Title)
                reporter.Title=title;
            else


                appendTitle(reporter,title);
            end

            if h.IncludeSupportingFunctionsCode


                nFcns=height(suppFcnTableData);
                for idx=1:nFcns
                    if strcmp(suppFcnTableData{idx,2},...
                        getString(message("slreportgen:report:MATLABFunction:user")))
                        fcnName=suppFcnTableData{idx,1};
                        linkTarget=getFunctionLinkTargetID(suppFcnTableData{idx,3},fcnName);
                        suppFcnTableData{idx,1}=mlreportgen.dom.InternalLink(linkTarget,fcnName);
                    end
                end
            end



            table=mlreportgen.dom.FormalTable(suppFcnTableData);


            tr=mlreportgen.dom.TableRow();
            append(tr,mlreportgen.dom.TableHeaderEntry(getString(message("slreportgen:report:MATLABFunction:function"))));
            append(tr,mlreportgen.dom.TableHeaderEntry(getString(message("slreportgen:report:MATLABFunction:definedBy"))));
            append(tr,mlreportgen.dom.TableHeaderEntry(getString(message("slreportgen:report:MATLABFunction:path"))));
            append(table.Header,tr);




            reporter.Content=table;
        end

        function content=getHighlightedContent(~,rpt,code)




            mlCode=mlreportgen.report.MATLABCode();
            mlCode.Content=code;
            content=getImpl(mlCode,rpt);
        end

        function textNodes=getTextNodes(h,parentNode)



            textNodes={};
            children=parentNode.Children;

            for i=1:numel(children)
                node=children(i);
                if isa(node,'mlreportgen.dom.Text')
                    textNodes=[textNodes,{node}];%#ok<AGROW>
                end
                textNodes=[textNodes,getTextNodes(h,node)];%#ok<AGROW>
            end
        end

    end

    methods(Static)
        function path=getClassFolder()


            [path]=fileparts(mfilename('fullpath'));
        end

        function template=createTemplate(templatePath,type)








            path=slreportgen.report.MATLABFunction.getClassFolder();
            template=mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function classfile=customizeReporter(toClasspath)









            classfile=mlreportgen.report.ReportForm.customizeClass(toClasspath,...
            "slreportgen.report.MATLABFunction");
        end
    end

end

function id=getFunctionLinkTargetID(container,localFcnName)
    if isnumeric(container)||~endsWith(container,".m")&&~endsWith(container,".mlx")
        container=slreportgen.utils.getObjectID(container,"Hash",false);
    end
    id=mlreportgen.utils.normalizeLinkID("MATLABFunction-"+container+"-"+localFcnName);
end

function id=getFunctionTableLinkTargetID(obj)
    objId=slreportgen.utils.getObjectID(obj,"Hash",false);
    id=mlreportgen.utils.normalizeLinkID("MATLABFunction-"+objId+"-SupportingFcns");
end



function mustBeMATLABFunctionObject(object)
    if~isempty(object)&&~slreportgen.utils.isMATLABFunction(object)
        error(message("slreportgen:report:error:invalidSourceObject"));
    end
end

function mustBeBaseTable(table)
    mlreportgen.report.validators.mustBeInstanceOf('mlreportgen.report.BaseTable',table);
end

function mustBeBaseTableCellArray(tables)
    if~isempty(tables)
        if iscell(tables)
            for i=1:numel(tables)
                mlreportgen.report.validators.mustBeInstanceOf('mlreportgen.report.BaseTable',tables{i});
            end
        else
            error(message("slreportgen:report:error:mustBeBaseTableCellArray"));
        end
    end
end

function mustBeLogical(varargin)
    mlreportgen.report.validators.mustBeLogical(varargin{:});
end

function mustBeDOMParagraph(value)
    mlreportgen.report.validators.mustBeInstanceOf(...
    'mlreportgen.dom.Paragraph',value);
end

function mustBeValidArgumentProperty(prop)
    validProps=...
    {'Name','Scope','Port','Compiled Type','Compiled Size',...
    'Complexity','Description','Max Value','Min Value','Tunable',...
    'Variable Size'};
    mustBeMember(prop,validProps);
end