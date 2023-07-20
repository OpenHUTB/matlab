function varargout=codeinfo(function_name,varargin)




    [varargout{1:nargout}]=feval(function_name,varargin{1:end});





    function out=getHTMLReport(codeInfo,expInports,hyperlink,buildDir,reportPage)

        model=codeInfo.GraphicalPath;

        [functions,functionHeadings]=getHTMLFunctions(codeInfo,expInports,hyperlink,reportPage);

        col1Heading=getString(message('RTW:codeInfo:reportBlockName'));
        inports=getHTMLDataInterface(codeInfo.Inports,col1Heading,hyperlink,reportPage);
        outports=getHTMLDataInterface(codeInfo.Outports,col1Heading,hyperlink,reportPage);
        col1Heading=getString(message('RTW:codeInfo:reportParameterSource'));
        params=getHTMLDataInterface(codeInfo.Parameters,col1Heading,hyperlink,reportPage);
        col1Heading=getString(message('RTW:codeInfo:reportDataStoreSource'));
        dStores=getHTMLDataInterface(codeInfo.DataStores,col1Heading,hyperlink,reportPage);


        doc=Advisor.Document;
        doc.addHeadItem('<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />');

        if isa(reportPage,'Simulink.ModelReference.ProtectedModel.CodeInterface')
            title=getString(message('RTW:codeInfo:protectedMdlReportTitle',model));
        else
            title=getString(message('RTW:codeInfo:reportTitle',model));
        end
        doc.setTitle(title);
        doc.addHeadItem('<link rel="stylesheet" type="text/css" href="rtwreport.css" />');
        doc.addHeadItem(getJavascript(reportPage,model,buildDir,hyperlink));


        titleText=Advisor.Element;
        titleText.setContent(title);
        titleText.setTag('h1');
        doc.addItem(titleText);


        tocTitle=Advisor.Element;
        tocTitle.setContent(getString(message('RTW:codeInfo:reportTableOfContents')));
        tocTitle.setTag('h3');
        doc.addItem(tocTitle);
        toc=Advisor.List;
        doc.addItem(toc);


        if reportPage.hasEntryPointFcns()
            fcnTitle=reportPage.getEntryFcnTitle;

            addSection(doc,toc,fcnTitle,[]);
            for k=1:length(functions)
                doc.addItem(functionHeadings{k});
                doc.addItem(functions{k});
            end
        end


        if isempty(inports)
            inports=Advisor.Paragraph(getString(message('RTW:codeInfo:reportNoInports')));
        end
        addSection(doc,toc,getString(message('RTW:codeInfo:reportInports')),inports);


        if isempty(outports)
            outports=Advisor.Paragraph(getString(message('RTW:codeInfo:reportNoOutports')));
        end
        addSection(doc,toc,getString(message('RTW:codeInfo:reportOutports')),outports);


        if isempty(params)
            params=Advisor.Paragraph(getString(message('RTW:codeInfo:reportNoInterfaceParameters')));
        end
        addSection(doc,toc,getString(message('RTW:codeInfo:reportInterfaceParameters')),params);


        if isempty(dStores)
            dStores=Advisor.Paragraph(getString(message('RTW:codeInfo:reportNoDataStores')));
        end
        addSection(doc,toc,getString(message('RTW:codeInfo:reportDataStores')),dStores);

        out=doc;




        function out=getJavascript(reportPage,model,buildDir,hyperlink)
            rtwHiliteJS='';
            if hyperlink==true

                includeTag=false;
                rtwHiliteJS=coder.internal.slcoderReport('getRtwHiliteJS',...
                '','',includeTag,'',reportPage.getLinkManager().hasWebview);
            else
                rtwHiliteJS='';
            end

            out=['<script language="JavaScript" type="text/javascript">'...
            ,getRTWTableShrinkDef...
            ,'</script>'...
            ,rtwHiliteJS];



            if Simulink.report.ReportInfo.featureReportV2
                out=[out,'<script>',coder.report.internal.getPostParentWindowMessageDef,'</script>'];
            end







            function[tables,tableHeadings]=getHTMLFunctions(codeInfo,expInports,hyperlink,reportPage)

                [functions,descriptions,semantics]=getFunctions(codeInfo,expInports,reportPage);

                tables=cell(length(functions),1);
                tableHeadings=cell(length(functions),1);
                for k=1:length(functions)
                    f=functions(k);
                    fcnName=getFcnName(f.Prototype);
                    srcFile=f.Prototype.SourceFile;
                    fcnlink=getCodeHyperlink(srcFile,['#fcn_',fcnName],fcnName);
                    heading=Advisor.Paragraph(getString(message('RTW:codeInfo:reportFunctionHeading',fcnlink)));
                    tableHeadings{k}=heading;
                    table=Advisor.Table(6,2);
                    table.setBorder(1);
                    table.setStyle('AltRow');
                    table.setAttribute('width','100%');
                    table.setColWidth(1,1);
                    table.setColWidth(2,3);

                    table.setEntry(1,1,Advisor.Text(getString(message('RTW:codeInfo:reportEntryPrototype'))));
                    fcnDecl=Advisor.Text(getFunctionDeclaration(f));
                    fcnDecl.setBold(true);
                    table.setEntry(1,2,fcnDecl);

                    table.setEntry(2,1,Advisor.Text(getString(message('RTW:codeInfo:reportEntryDescription'))));
                    table.setEntry(2,2,Advisor.Text(descriptions{k}));

                    table.setEntry(3,1,Advisor.Text(getString(message('RTW:codeInfo:reportEntryTiming'))));
                    table.setEntry(3,2,Advisor.Text(semantics{k}));

                    table.setEntry(4,1,Advisor.Text(getString(message('RTW:codeInfo:reportEntryArguments'))));
                    table.setEntry(4,2,getHTMLFunctionArguments(f,hyperlink,reportPage));

                    table.setEntry(5,1,Advisor.Text(getString(message('RTW:codeInfo:reportEntryReturnValue'))));
                    table.setEntry(5,2,getHTMLFunctionReturnValue(f,hyperlink,reportPage));

                    table.setEntry(6,1,Advisor.Text(getString(message('RTW:codeInfo:reportEntryHeaderFile'))));
                    headerFile=f.Prototype.HeaderFile;
                    headerLink=getCodeHyperlink(headerFile,[],headerFile);
                    table.setEntry(6,2,Advisor.Text(headerLink));
                    tables{k}=table;
                end







                function out=existCodeInfo(buildDir)
                    out=exist(fullfile(buildDir,'codeInfo.mat'),'file')==2;







                    function out=existCodeInfoMR(buildDir,modelName)
                        out=exist(fullfile(buildDir,[modelName,'_mr_codeInfo.mat']),'file')==2;

                        function out=getCodeInfo(buildDir,modelName)
                            codeDescriptor=coder.getCodeDescriptor(buildDir,modelName);
                            out=codeDescriptor.getFullCodeInfo();







                            function out=getCodeHyperlink(file,tag,contents)
                                if~Simulink.report.ReportInfo.featureReportV2
                                    out=['<a href="',strrep(file,'.','_'),'.html',tag,'">',contents,'</a>'];
                                else
                                    out=['<a href="javascript: void(0)" onclick="'...
                                    ,coder.report.internal.getPostParentWindowMessageCall('jumpToCode',contents),'">',contents,'</a>'...
                                    ];
                                end






                                function addSection(doc,toc,title,contents)


                                    section=Advisor.Element;

                                    aName=Advisor.Element;
                                    aName.setTag('a');
                                    aName.setContent(title);
                                    name=['sec_',strrep(title,' ','_')];
                                    aName.setAttribute('name',name);
                                    section.setContent(aName.emitHTML);
                                    section.setTag('h3');
                                    doc.addItem(section);
                                    if~isempty(contents)

                                        if isa(contents,'Advisor.Table')&&contents.NumRow>2
                                            doc.addItem([getRTWTableShrinkButton,contents.emitHTML]);
                                        else
                                            doc.addItem(contents.emitHTML);
                                        end
                                    end

                                    aHref=Advisor.Element;
                                    aHref.setTag('a');
                                    aHref.setContent(title);
                                    aHref.setAttribute('href',['#',name]);
                                    toc.addItem(aHref);

                                    function out=getFunctionInterfacesForReport(in)
                                        out=RTW.FunctionInterface.empty(0,numel(in));
                                        if isempty(in)
                                            return
                                        end


                                        for idx=1:numel(in)
                                            fIntf=in(idx);

                                            skip=isa(fIntf,'RTW.SimulinkFunctionInterface')&&isempty(fIntf.Prototype.HeaderFile);
                                            if(skip)
                                                continue;
                                            end
                                            out(end+1)=fIntf;%#ok 

                                        end







                                        function[functions,descriptions,semantics]=getFunctions(codeInfo,...
                                            expInports,reportPage)

                                            model=codeInfo.GraphicalPath;
                                            allocationFunction=getFunctionInterfacesForReport(codeInfo.AllocationFunction);
                                            initializeFunctions=getFunctionInterfacesForReport(codeInfo.InitializeFunctions);
                                            outputFunctions=getFunctionInterfacesForReport(codeInfo.OutputFunctions);
                                            updateFunctions=getFunctionInterfacesForReport(codeInfo.UpdateFunctions);
                                            terminateFunctions=getFunctionInterfacesForReport(codeInfo.TerminateFunctions);



                                            functions=[...
                                            allocationFunction(:);...
                                            initializeFunctions(:);...
                                            outputFunctions(:);...
                                            updateFunctions(:);...
                                            terminateFunctions(:);...
                                            ];



                                            descriptions=cell(length(functions),1);
                                            semantics=arrayfun(@(x)getFunctionCallSemantics(x),functions,'UniformOutput',false);
                                            idx=1;
                                            for k=1:length(allocationFunction)
                                                descriptions{idx}=getString(message('RTW:codeInfo:reportAllocationDescription'));
                                                idx=idx+1;
                                            end
                                            for k=1:length(initializeFunctions)
                                                descriptions{idx}=getString(message('RTW:codeInfo:reportInitializationDescription'));
                                                idx=idx+1;
                                            end
                                            for k=1:length(outputFunctions)
                                                if isResetFunction(outputFunctions(k))
                                                    descriptions{idx}=getString(message('RTW:codeInfo:reportResetDescription'));
                                                elseif isempty(expInports)
                                                    descriptions{idx}=getString(message('RTW:codeInfo:reportOutputDescription'));
                                                else
                                                    descriptions{idx}=getExportedFunctionDescription(reportPage,expInports,model,k);
                                                end
                                                idx=idx+1;
                                            end
                                            for k=1:length(updateFunctions)
                                                descriptions{idx}=getString(message('RTW:codeInfo:reportUpdateDescription'));
                                                idx=idx+1;
                                            end
                                            for k=1:length(terminateFunctions)
                                                descriptions{idx}=getString(message('RTW:codeInfo:reportTerminationDescription'));
                                                idx=idx+1;
                                            end





                                            function out=isResetFunction(func)

                                                out=(func.Timing.TimingMode=="RESET");





                                                function out=getExportedFunctionDescription(reportPage,expInports,model,k)

                                                    ssH=reportPage.getLinkManager().SourceSubsystem;
                                                    if isempty(ssH)
                                                        ssH=[];
                                                    else
                                                        ssH=get_param(ssH,'Handle');
                                                    end
                                                    portH=get_param(ssH,'PortHandles');

                                                    portNum=arrayfun(@(x)(strcmp(x.('PortType'),'fcn_call')...
                                                    &&x.('Index')==k),expInports,'UniformOutput',true);

                                                    if~isempty(portH)
                                                        if length(expInports)==length(portH.Inport)
                                                            blockH=coder.internal.slBus('LocalGetBlockForPortPrm',...
                                                            portH.Inport(portNum),'Handle');
                                                        else


                                                            blockH=coder.internal.slBus('LocalGetBlockForPortPrm',...
                                                            portH.Trigger,'Handle');
                                                        end
                                                    else
                                                        portNumStr=num2str(find(portNum));
                                                        if isempty(portNumStr)
                                                            blockH=[];
                                                        else
                                                            inportBlk=find_system(model,'SearchDepth',1,...
                                                            'BlockType','Inport','Port',portNumStr);
                                                            blockH=get_param(inportBlk{1},'Handle');
                                                        end
                                                    end
                                                    if isempty(blockH)

                                                        out=getString(message('RTW:codeInfo:reportSimulinkFuncDescription'));
                                                    else
                                                        out=getString(message('RTW:codeInfo:reportExportedFuncDescription',...
                                                        reportPage.getHyperlink(Simulink.ID.getSID(blockH))));
                                                    end





                                                    function out=getFunctionCallSemantics(fcnInfo)

                                                        timing=fcnInfo.Timing;
                                                        switch timing.TimingMode
                                                        case 'ONESHOT'
                                                            out=getString(message('RTW:codeInfo:reportCallSemanticsOnce'));
                                                        case{'PERIODIC','APERIODIC','ASYNCHRONOUS'}
                                                            period=timing.SamplePeriod;
                                                            if(period==-1)
                                                                out=getString(message('RTW:codeInfo:reportCallSemanticsInherited'));
                                                            elseif(period==1)
                                                                out=getString(message('RTW:codeInfo:reportCallSemanticsPerSecond'));
                                                            else
                                                                out=DAStudio.message('RTW:codeInfo:reportCallSemanticsNSeconds',...
                                                                num2str(timing.SamplePeriod));
                                                            end
                                                        case 'INHERITED'
                                                            out=getString(message('RTW:codeInfo:reportCallSemanticsInherited'));
                                                        case 'RESET'
                                                            out=getString(message('RTW:codeInfo:reportCallSemanticsReset'));
                                                        otherwise
                                                            out=getString(message('RTW:codeInfo:reportCallSemanticsUnknown'));
                                                        end





                                                        function out=getHTMLFunctionArguments(fcnInfo,hyperlink,reportPage)
                                                            n=length(fcnInfo.Prototype.Arguments);
                                                            if n==0
                                                                out=Advisor.Text('None');
                                                                return
                                                            end


                                                            fxpType=arrayfun(@(x)getFxpType(x.Type),...
                                                            fcnInfo.Prototype.Arguments,'UniformOutput',false);
                                                            reportFxpType=hasFxpTypeToReport(fxpType);

                                                            t=Advisor.Table(n,4+reportFxpType);
                                                            t.setBorder(1);
                                                            t.setStyle('AltRow');
                                                            t.setColHeading(1,'#');
                                                            t.setColHeading(2,getString(message('RTW:codeInfo:reportNameHeading')));
                                                            t.setColHeading(3,getString(message('RTW:codeInfo:reportDataTypeHeading')));


                                                            column=4;
                                                            if reportFxpType
                                                                t.setColHeading(column,getString(message('RTW:codeInfo:reportScalingHeading')));
                                                                column=column+1;
                                                            end

                                                            t.setColHeading(column,getString(message('RTW:codeInfo:reportDescriptionHeading')));

                                                            for k=1:n
                                                                arg=fcnInfo.Prototype.Arguments(k);
                                                                t.setEntry(k,1,num2str(k));
                                                                t.setEntryAlign(k,1,'right');
                                                                t.setEntry(k,2,arg.Name);
                                                                t.setEntry(k,3,getTypeIdentifier(arg.Type));
                                                                column=4;
                                                                if reportFxpType
                                                                    t.setEntry(k,column,fxpType{k});
                                                                    column=column+1;
                                                                end
                                                                if isempty(fcnInfo.ActualArgs)

                                                                    switch(arg.IOType)
                                                                    case 'INPUT'
                                                                        descStr=getString(message('RTW:codeInfo:inputArgument'));
                                                                    case 'OUTPUT'
                                                                        descStr=getString(message('RTW:codeInfo:outputArgument'));
                                                                    otherwise
                                                                        descStr=getString(message('RTW:codeInfo:inOutArgument'));
                                                                    end
                                                                    t.setEntry(k,column,descStr);
                                                                else
                                                                    t.setEntry(k,column,getGraphicalPath(fcnInfo.ActualArgs(k),hyperlink,reportPage));
                                                                end
                                                            end

                                                            if n>2
                                                                out=[getRTWTableShrinkButton,t.emitHTML];
                                                            else
                                                                out=t.emitHTML;
                                                            end





                                                            function out=getHTMLFunctionReturnValue(fcnInfo,hyperlink,reportPage)
                                                                if isempty(fcnInfo.Prototype.Return)
                                                                    out=Advisor.Text('None');
                                                                else
                                                                    fxpType=getFxpType(fcnInfo.Prototype.Return.Type);
                                                                    reportFxpType=hasFxpTypeToReport({fxpType});
                                                                    t=Advisor.Table(1,2+reportFxpType);
                                                                    t.setStyle('AltRow');
                                                                    t.setBorder(1);
                                                                    t.setColHeading(1,getString(message('RTW:codeInfo:reportDataTypeHeading')));
                                                                    column=2;
                                                                    if reportFxpType
                                                                        t.setColHeading(column,getString(message('RTW:codeInfo:reportScalingHeading')));
                                                                        column=column+1;
                                                                    end
                                                                    t.setColHeading(column,getString(message('RTW:codeInfo:reportDescriptionHeading')));

                                                                    t.setEntry(1,1,getTypeIdentifier(fcnInfo.Prototype.Return.Type));
                                                                    column=2;
                                                                    if reportFxpType
                                                                        t.setEntry(1,column,fxpType);
                                                                        column=column+1;
                                                                    end
                                                                    if isempty(fcnInfo.ActualReturn)
                                                                        descStr=getString(message('RTW:codeInfo:outputArgument'));
                                                                        t.setEntry(1,column,descStr);
                                                                    else
                                                                        t.setEntry(1,column,getGraphicalPath(fcnInfo.ActualReturn,hyperlink,reportPage));
                                                                    end
                                                                    out=t;
                                                                end





                                                                function out=getHTMLDataInterface(data,srcHeading,hyperlink,reportPage)

                                                                    if isempty(data)
                                                                        out=[];
                                                                        return
                                                                    end
                                                                    reportCodeIdentifier=reportPage.ReportCodeIdentifier;

                                                                    fxpType=arrayfun(@(x)getFxpType(getImplementationType(x)),...
                                                                    data,'UniformOutput',false);
                                                                    reportFxpType=hasFxpTypeToReport(fxpType);




                                                                    numColumns=3+reportCodeIdentifier+reportFxpType;
                                                                    t=Advisor.Table(length(data),numColumns);
                                                                    t.setBorder(1);
                                                                    t.setStyle('AltRow');
                                                                    t.setAttribute('width','100%');


                                                                    column=1;
                                                                    t.setColHeading(column,srcHeading);
                                                                    t.setColWidth(column,4);

                                                                    if reportCodeIdentifier

                                                                        column=column+1;
                                                                        t.setColHeading(column,getString(message('RTW:codeInfo:reportCodeIdentifierHeading')));
                                                                        t.setColWidth(column,2.5);
                                                                    end


                                                                    column=column+1;
                                                                    t.setColHeading(column,getString(message('RTW:codeInfo:reportDataTypeHeading')));
                                                                    t.setColWidth(column,2);

                                                                    if reportFxpType

                                                                        column=column+1;
                                                                        t.setColHeading(column,getString(message('RTW:codeInfo:reportScalingHeading')));
                                                                        t.setColWidth(column,1);
                                                                    end


                                                                    column=column+1;
                                                                    t.setColHeading(column,getString(message('RTW:codeInfo:reportDimensionHeading')));
                                                                    t.setColHeadingAlign(column,'right');
                                                                    t.setColWidth(column,1);


                                                                    contents=cell(length(data),numColumns);


                                                                    dash=Advisor.Text('-');
                                                                    customStorage=Advisor.Text(getString(message('RTW:codeInfo:reportCustomStorage')));
                                                                    customStorage.setItalic(true);

                                                                    for k=1:length(data)

                                                                        column=1;
                                                                        contents{k,column}=Advisor.Text(getGraphicalPath(data(k),hyperlink,reportPage));


                                                                        varImp=data(k).Implementation;
                                                                        if~isempty(varImp)
                                                                            if varImp.isDefined
                                                                                identifier=Advisor.Text(varImp.getExpression);
                                                                            else
                                                                                if isa(varImp,'RTW.AutosarExpression')
                                                                                    switch(varImp.DataAccessMode)
                                                                                    case{'ExplicitSend','ImplicitSend'}
                                                                                        identifier=Advisor.Text(getString(message('RTW:codeInfo:reportProvidePort')));
                                                                                    case{'ExplicitReceive','ImplicitReceive','QueuedExplicitReceive'}
                                                                                        identifier=Advisor.Text(getString(message('RTW:codeInfo:reportRequirePort')));
                                                                                    case{'ModeReceive'}
                                                                                        identifier=Advisor.Text(getString(message('RTW:codeInfo:reportModeRequirePort')));
                                                                                    case{'ErrorStatus'}
                                                                                        identifier=Advisor.Text(getString(message('RTW:codeInfo:reportErrorStatus')));
                                                                                    case{'Calibration'}
                                                                                        identifier=Advisor.Text(getString(message('RTW:codeInfo:reportCalibration')));
                                                                                    otherwise
                                                                                        identifier=Advisor.Text(getString(message('RTW:codeInfo:reportDefinedExternally')));
                                                                                    end
                                                                                    identifier.setItalic(true);
                                                                                elseif isa(varImp,'RTW.Variable')&&...
                                                                                    isequal(varImp.StorageSpecifier,'extern')
                                                                                    myText=Advisor.Text(getString(message('RTW:codeInfo:reportImportedData')));
                                                                                    myText.setItalic(true);
                                                                                    identifier=[myText,Advisor.Text(varImp.Identifier)];
                                                                                elseif isa(varImp,'RTW.CustomExpression')
                                                                                    identifier=Advisor.Text(getString(message('RTW:codeInfo:reportImported')));
                                                                                    identifier.setItalic(true);
                                                                                elseif isa(varImp,'RTW.BasicAccessFunctionExpression')
                                                                                    identifier=Advisor.Text(varImp.Prototype.Name);
                                                                                else
                                                                                    identifier=Advisor.Text(getString(message('RTW:codeInfo:reportDefinedExternally')));
                                                                                    identifier.setItalic(true);
                                                                                end
                                                                            end
                                                                            if reportCodeIdentifier
                                                                                column=column+1;
                                                                                contents{k,column}=identifier;
                                                                            end


                                                                            column=column+1;
                                                                            contents{k,column}=Advisor.Text(getTypeIdentifier(data(k).Implementation.Type));


                                                                            if reportFxpType
                                                                                column=column+1;
                                                                                contents{k,column}=fxpType{k};
                                                                            end


                                                                            column=column+1;
                                                                            relevantType=reportPage.getRelevantType(data(k));
                                                                            if(isa(relevantType,'embedded.matrixtype')||isa(relevantType,'coder.types.Matrix'))&&...
                                                                                relevantType.getWidth>1

                                                                                contents{k,column}=Advisor.Text(['[',num2str(relevantType.Dimensions),']']);
                                                                            else

                                                                                contents{k,column}=Advisor.Text(num2str(relevantType.getWidth));
                                                                            end
                                                                            t.setEntryAlign(k,column,'right');
                                                                        else

                                                                            if reportCodeIdentifier

                                                                                column=column+1;
                                                                                contents{k,column}=customStorage;
                                                                            end

                                                                            column=column+1;
                                                                            contents{k,column}=dash;
                                                                            if reportFxpType

                                                                                column=column+1;
                                                                                contents{k,column}=dash;
                                                                                column=column+1;
                                                                            end

                                                                            column=column+1;
                                                                            contents{k,column}=dash;
                                                                        end
                                                                    end
                                                                    t.setEntries(contents);
                                                                    out=t;

                                                                    function out=hasFxpTypeToReport(fxpType)
                                                                        out=~all(strcmp(fxpType,''));





                                                                        function out=getRTWTableShrinkButton

                                                                            tooltip=getString(message('RTW:codeInfo:reportTableShrinkToolTip'));
                                                                            out=['<span title="',tooltip,'" onclick="',getRTWTableShrinkCall('this'),'">[-]</span>'];





                                                                            function out=getRTWTableShrinkCall(arg)

                                                                                out=['rtwTableShrink(',arg,')'];





                                                                                function out=getRTWTableShrinkDef


                                                                                    out=[...
                                                                                    'function ',getRTWTableShrinkCall('o'),' {'...
                                                                                    ,'var t = o.nextSibling;',...
                                                                                    'if (t.nodeType != 1) {',...
                                                                                    't = t.nextSibling;',...
                                                                                    '}',...
'if (t.style.display == "none") {'...
                                                                                    ,'t.style.display = "";'...
                                                                                    ,'o.innerHTML = "[-]"'...
                                                                                    ,'} else {'...
                                                                                    ,'t.style.display = "none";'...
                                                                                    ,'o.innerHTML = "[+] ... "'...
                                                                                    ,'}'...
                                                                                    ,'}'];








                                                                                    function out=getGraphicalPath(data,hyperlink,reportPage)
                                                                                        sid=data.SID;
                                                                                        if isempty(sid)


                                                                                            out=data.GraphicalName;
                                                                                        else
                                                                                            if isValidSlObject(slroot,sid)
                                                                                                if strcmp(get_param(Simulink.ID.getHandle(sid),'Type'),'block_diagram')
                                                                                                    arg=data.GraphicalName;
                                                                                                    out=getString(message('RTW:codeInfo:reportModelArgument',arg));
                                                                                                else
                                                                                                    if~isempty(reportPage)
                                                                                                        if hyperlink
                                                                                                            out=reportPage.getHyperlink(sid);
                                                                                                        else
                                                                                                            grPath=getfullname(sid);
                                                                                                            out=rtwprivate('rtwhtmlescape',coder.internal.getNameForBlock(grPath));
                                                                                                        end
                                                                                                    else
                                                                                                        grPath=getfullname(sid);
                                                                                                        if hyperlink
                                                                                                            out=rtwprivate('gethyperlink',grPath,'JavaScript','off');
                                                                                                        else
                                                                                                            out=rtwprivate('rtwhtmlescape',coder.internal.getNameForBlock(grPath));
                                                                                                        end
                                                                                                    end
                                                                                                end
                                                                                            else
                                                                                                url=Simulink.URL.parseURL(data.SID);

                                                                                                if isParamInModelWS(url)
                                                                                                    blkId=url.getID();
                                                                                                    out=getString(message('RTW:codeInfo:reportSourceInModelWorkspace',blkId));
                                                                                                    return
                                                                                                end

                                                                                                out=getString(message('RTW:codeInfo:reportSynthesizedBlock'));
                                                                                            end
                                                                                        end





                                                                                        function result=isParamInModelWS(url)
                                                                                            result=false;
                                                                                            if~isempty(url.getKind)&&url.getKind==Simulink.URL.URLKind.var
                                                                                                if isValidSlObject(slroot,url.getParent)&&...
                                                                                                    strcmp(get_param(Simulink.ID.getHandle(url.getParent),'Type'),'block_diagram')
                                                                                                    result=true;
                                                                                                end
                                                                                            end





                                                                                            function fcnCall=getFunctionDeclaration(fcnInfo)

                                                                                                argsCall=getArgsDeclaration(fcnInfo.Prototype);

                                                                                                returnType=getReturnType(fcnInfo.Prototype);

                                                                                                fcnName=getFcnName(fcnInfo.Prototype);

                                                                                                fcnCall=[returnType,' ',fcnName,'(',argsCall,')'];


                                                                                                function returnType=getReturnType(fcnPrototype)


                                                                                                    if isa(fcnPrototype.Return,'coder.types.Argument')&&...
                                                                                                        ~isempty(fcnPrototype.Return)

                                                                                                        returnType=getTypeIdentifier(fcnPrototype.Return.Type);
                                                                                                    else
                                                                                                        returnType='void';
                                                                                                    end


                                                                                                    function fcnName=getFcnName(fcnPrototype)


                                                                                                        fcnName=fcnPrototype.Name;


                                                                                                        function argDecl=getArgsDeclaration(fcnPrototype)


                                                                                                            argDecl='';

                                                                                                            argsLen=length(fcnPrototype.Arguments);

                                                                                                            if argsLen==0
                                                                                                                argDecl='void';
                                                                                                                return;
                                                                                                            else
                                                                                                                for argIter=1:argsLen
                                                                                                                    currargDecl=...
                                                                                                                    getVariableDeclaration(fcnPrototype.Arguments(argIter));

                                                                                                                    if isempty(argDecl)
                                                                                                                        argDecl=currargDecl;
                                                                                                                    else
                                                                                                                        argDecl=[argDecl,', ',currargDecl];%#ok<AGROW>
                                                                                                                    end
                                                                                                                end

                                                                                                            end

                                                                                                            function Iden=getTypeIdentifier(Type)


                                                                                                                if isa(Type,'embedded.type')||isa(Type,'coder.types.Type')

                                                                                                                    if isempty(Type.Identifier)

                                                                                                                        if(~Type.isPointer)&&(~Type.isMatrix)
                                                                                                                            Iden='';
                                                                                                                            return;
                                                                                                                        end

                                                                                                                        Iden=getTypeIdentifier(Type.BaseType);

                                                                                                                        if Type.isPointer

                                                                                                                            if Iden(end)=='*'
                                                                                                                                Iden=[Iden,'*'];
                                                                                                                            else
                                                                                                                                Iden=[Iden,'&nbsp;*'];
                                                                                                                            end
                                                                                                                        end

                                                                                                                        if Type.ReadOnly
                                                                                                                            if Iden(end)=='*'
                                                                                                                                Iden=[Iden,'const'];
                                                                                                                            else
                                                                                                                                Iden=[Iden,'&nbsp;const'];
                                                                                                                            end
                                                                                                                        end

                                                                                                                    else
                                                                                                                        Iden=Type.Identifier;

                                                                                                                        if Type.Volatile
                                                                                                                            Iden=['volatile ',Iden];
                                                                                                                        end

                                                                                                                        if Type.ReadOnly
                                                                                                                            Iden=['const ',Iden];
                                                                                                                        end

                                                                                                                    end

                                                                                                                else


                                                                                                                    Iden='';
                                                                                                                end

                                                                                                                function out=getFxpType(Type)

                                                                                                                    out='';
                                                                                                                    if isa(Type,'coder.types.Type')
                                                                                                                        Type=Type.getEmbeddedType;
                                                                                                                    end
                                                                                                                    if isa(Type,'embedded.type')
                                                                                                                        if isa(Type,'embedded.numerictype')
                                                                                                                            if Type.isfixed
                                                                                                                                if Type.isscalingbinarypoint&&Type.FractionLength==0
                                                                                                                                    out='';
                                                                                                                                    tooltip='';
                                                                                                                                else
                                                                                                                                    out=Type.tostringInternalSlName;
                                                                                                                                    if Type.isscalingbinarypoint



                                                                                                                                        tooltip=[...
                                                                                                                                        sprintf('  DataTypeMode: %s\n','Fixed-point: binary point scaling'),...
                                                                                                                                        sprintf('    Signedness: %s\n',Type.Signedness),...
                                                                                                                                        sprintf('    WordLength: %d\n',Type.WordLength),...
                                                                                                                                        sprintf('FractionLength: %d\n',Type.FractionLength)];
                                                                                                                                    else
                                                                                                                                        tooltip=evalc('disp(Type)');
                                                                                                                                    end
                                                                                                                                end

                                                                                                                                if~isempty(tooltip)
                                                                                                                                    out=['<span title="',tooltip,'">',out,'</span>'];
                                                                                                                                end
                                                                                                                            end
                                                                                                                        elseif isprop(Type,'BaseType')

                                                                                                                            out=getFxpType(Type.BaseType);
                                                                                                                        end
                                                                                                                    end

                                                                                                                    function out=getImplementationType(data)
                                                                                                                        if~isempty(data.Implementation)
                                                                                                                            out=data.Implementation.Type;
                                                                                                                        else
                                                                                                                            out=[];
                                                                                                                        end

                                                                                                                        function currDecl=getVariableDeclaration(varImp)

                                                                                                                            try
                                                                                                                                if isa(varImp,'RTW.Variable')

                                                                                                                                    if varImp.isDefined
                                                                                                                                        currExpr=varImp.getExpression;
                                                                                                                                    else
                                                                                                                                        currExpr=varImp.Identifier;
                                                                                                                                    end

                                                                                                                                    currTypeIdentifier=getTypeIdentifier(varImp.Type);

                                                                                                                                    if varImp.Type.isMatrix
                                                                                                                                        matrixWidth=varImp.Type.getWidth;
                                                                                                                                        if matrixWidth>1
                                                                                                                                            currDecl=[currTypeIdentifier,' ',currExpr,'[',num2str(matrixWidth),']'];
                                                                                                                                        else
                                                                                                                                            currDecl=[currTypeIdentifier,' ',currExpr];
                                                                                                                                        end
                                                                                                                                    elseif varImp.Type.isPointer
                                                                                                                                        currDecl=[currTypeIdentifier,currExpr];
                                                                                                                                    else
                                                                                                                                        currDecl=[currTypeIdentifier,' ',currExpr,''];
                                                                                                                                    end

                                                                                                                                elseif(isa(varImp,'RTW.Argument')||isa(varImp,'coder.types.Argument'))
                                                                                                                                    currTypeIdentifier=getTypeIdentifier(varImp.Type);

                                                                                                                                    if varImp.Type.isPointer
                                                                                                                                        space='&nbsp;';
                                                                                                                                        if currTypeIdentifier(end)=='*'
                                                                                                                                            space='';
                                                                                                                                        end
                                                                                                                                        currDecl=[currTypeIdentifier,space,varImp.Name];

                                                                                                                                    elseif varImp.Type.isMatrix
                                                                                                                                        matrixWidth=varImp.Type.getWidth;
                                                                                                                                        if matrixWidth>1
                                                                                                                                            currDecl=[currTypeIdentifier,' ',varImp.Name,'[',num2str(matrixWidth),']'];
                                                                                                                                        else
                                                                                                                                            currDecl=[currTypeIdentifier,' ',varImp.Name];
                                                                                                                                        end
                                                                                                                                    else
                                                                                                                                        currDecl=[currTypeIdentifier,' ',varImp.Name];
                                                                                                                                    end

                                                                                                                                end

                                                                                                                            catch %#ok<CTCH>
                                                                                                                                currDecl='';
                                                                                                                            end




