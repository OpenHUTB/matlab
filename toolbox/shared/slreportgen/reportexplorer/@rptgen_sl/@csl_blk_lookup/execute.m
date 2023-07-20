function out=execute(c,d,varargin)




    out=d.createDocumentFragment;

    adSL=rptgen_sl.appdata_sl;
    singleList=findContextBlocks(adSL,'BlockType','\<Lookup\>');
    doubleList=findContextBlocks(adSL,'BlockType','\<Lookup2D\>');
    multiList=findContextBlocks(adSL,'BlockType','S-Function',...
    'MaskType','\<LookupNDInterp\>');
    multiPreList=findContextBlocks(adSL,'BlockType','S-Function',...
    'MaskType','\<LookupNDInterpIdx\>');
    multiDirectList=union(findContextBlocks(adSL,'BlockType','S-Function','MaskType','\<LookupNDDirect\>'),...
    findContextBlocks(adSL,'BlockType','\<LookupNDDirect\>'));
    multiLookup=findContextBlocks(adSL,'BlockType','\<Lookup_n-D\>');
    multiInterp=findContextBlocks(adSL,'BlockType','\<Interpolation_n-D\>');
    multiPrelook=findContextBlocks(adSL,'BlockType','\<PreLookup\>');


    c.InvertHardcopy='off';

    if c.isSinglePlot||c.isSingleTable
        for i=1:length(singleList)
            [xVal,xName]=LocParamValue(singleList{i},'InputValues');
            [yVal,yName]=LocParamValue(singleList{i},'OutputValues');

            if isempty(xVal)
                c.status(sprintf(getString(message('RptgenSL:rsl_csl_blk_lookup:oneDEmptyValueLabel')),singleList{i}),2);
            elseif length(xVal)~=length(yVal)
                c.status(sprintf(getString(message('RptgenSL:rsl_csl_blk_lookup:oneDXNotEqualToYLabel')),singleList{i}),2);
            else
                blkTitle=LocBlockTitle(c,singleList{i});
                if c.isSinglePlot
                    allPorts=get_param(singleList{i},'PortHandles');

                    h=makeFigureOneD(c,...
                    xVal,...
                    LocAxLabel(xName,allPorts.Inport,'Input Values'),...
                    yVal,...
                    LocAxLabel(yName,allPorts.Outport,'Output Values'));

                    if~isempty(h)
                        out.appendChild(c.gr_makeGraphic(d,h,...
                        blkTitle,...
                        singleList{i},...
                        d));
                    end
                end

                if c.isSingleTable
                    out.appendChild(locGenerateTable(d,yVal,blkTitle,0,xVal));
                end
            end
        end
    end

    if c.isDoublePlot||c.isDoubleTable
        for i=1:length(doubleList)
            [xVal,xName]=LocParamValue(doubleList{i},'x');
            [yVal,yName]=LocParamValue(doubleList{i},'y');
            [tVal,tName]=LocParamValue(doubleList{i},'t');

            xLength=length(xVal);
            yLength=length(yVal);
            tSize=tVal;

            if isempty(tVal)
                c.status(sprintf(getString(message('RptgenSL:rsl_csl_blk_lookup:twoDEmptyValueLabel')),doubleList{i}),2);
            elseif xLength*yLength~=numel(tSize)
                c.status(sprintf(getString(message('RptgenSL:rsl_csl_blk_lookup:twoDXNotEqualToYLabel')),doubleList{i}),2);
            else
                blkTitle=LocBlockTitle(c,doubleList{i});

                if c.isDoublePlot
                    allPorts=get_param(doubleList{i},'PortHandles');

                    h=makeFigureTwoD(c,...
                    xVal,...
                    LocAxLabel(xName,allPorts.Inport(2),getString(message('RptgenSL:rsl_csl_blk_lookup:columnValuesLabel'))),...
                    yVal,...
                    LocAxLabel(yName,allPorts.Inport(1),getString(message('RptgenSL:rsl_csl_blk_lookup:rowValuesLabel'))),...
                    tVal,...
                    LocAxLabel(tName,allPorts.Outport,getString(message('RptgenSL:rsl_csl_blk_lookup:tableValuesLabel'))));

                    if~isempty(h)
                        out.appendChild(c.gr_makeGraphic(d,h,...
                        blkTitle,...
                        doubleList{i}));
                    end
                end

                if c.isDoubleTable
                    out.appendChild(locGenerateTable(d,tVal,blkTitle,0,xVal,yVal));
                end
            end
        end
    end

    for i=1:length(multiList)
        locMultiTable(c,d,...
        multiList{i},...
        LocBlockTitle(c,multiList{i}),...
        out);
    end
    for i=1:length(multiPreList)
        locMultiPreTable(c,d,...
        multiPreList{i},...
        LocBlockTitle(c,multiPreList{i}),...
        out);
    end
    for i=1:length(multiDirectList)
        locMultiDirectTable(c,d,...
        multiDirectList{i},...
        LocBlockTitle(c,multiDirectList{i}),...
        out);
    end
    for i=1:length(multiLookup)
        locMultiTable(c,d,...
        multiLookup{i},...
        LocBlockTitle(c,multiLookup{i}),...
        out);
    end
    for i=1:length(multiInterp)
        locMultiInterpTable(c,d,...
        multiInterp{i},...
        LocBlockTitle(c,multiInterp{i}),...
        out);
    end
    for i=1:length(multiPrelook)
        locMultiPrelookTable(c,d,...
        multiPrelook{i},...
        LocBlockTitle(c,multiPrelook{i}),...
        out);
    end


    function[pVal,pString,resolved]=LocParamValue(blkName,pName)

        try
            pString=get_param(blkName,pName);
            pVal=slResolve(pString,blkName,'expression');
            resolved=true;
        catch %#ok<CTCH>
            resolved=false;
            pVal=[];
        end
        if isa(pVal,'Simulink.Data')
            pVal=pVal.Value;
        end


        function labelString=LocAxLabel(varName,portH,labelName)

            labelString='';

            avN=abs(varName);
            if any(find((avN>='a'&avN<='z')|...
                (avN>='A'&avN<='Z')))


                labelString=varName;
            else
                try
                    portType=get_param(portH,'porttype');
                catch %#ok<CTCH>
                    portType='not found';
                end

                switch portType
                case 'outport'
                    try %#ok<TRYNC>
                        labelString=get_param(portH,'Name');
                    end
                case 'inport'
                    try %#ok<TRYNC>
                        lineH=get_param(portH,'Line');
                        if lineH>0
                            srcH=get_param(lineH,'SrcPortHandle');
                            if srcH>0
                                labelString=get_param(srcH,'Name');
                            end
                        end
                    end
                end
            end

            labelString=rptgen.truncateString(labelString,...
            labelName,...
            32);



            function imTitle=LocBlockTitle(c,blkName)

                switch c.TitleType
                case 'none'
                    imTitle='';
                case 'auto'
                    try
                        imTitle=get_param(blkName,'Name');
                    catch %#ok<CTCH>
                        imTitle=blkName;
                    end
                otherwise
                    imTitle=rptgen.parseExpressionText(c.Title);
                end


                function locMultiTable(c,d,tBlock,tableTitle,out)

                    if locSpecifiesLUTObject(tBlock)
                        [tableData,inVals,exp,resolved]=locGetLUTObjectData(tBlock);
                    else
                        try
                            eNumDims=get_param(tBlock,'numDimsPopupSelect');
                            if strncmp(eNumDims,'More',4)
                                [eNumDims,exp,resolved]=LocParamValue(tBlock,'explicitNumDims');
                                if~resolved
                                    c.status(...
                                    getString(...
                                    message('RptgenSL:rsl_csl_blk_lookup:unresolvedDimensionExpression',...
                                    exp,tBlock)),1);
                                    return;
                                end
                            else
                                eNumDims=str2double(eNumDims);
                            end
                        catch ME
                            c.status(...
                            getString(...
                            message('RptgenSL:rsl_csl_blk_lookup:dimensionsError',...
                            ME.message,tBlock)),1);
                            return;
                        end

                        inVals=cell(eNumDims,1);
                        for i=min(4,eNumDims):-1:1
                            [inVals{i},exp,resolved]=LocParamValue(tBlock,sprintf('bp%i',i));
                            if~resolved
                                c.status(...
                                getString(...
                                message('RptgenSL:rsl_csl_blk_lookup:unresolvedBreakpointsExpression',...
                                exp,tBlock)),1);
                                return;
                            end
                        end

                        if eNumDims>4

                            [bpCell,exp,resolved]=LocParamValue(tBlock,'bpcell');

                            if~resolved
                                c.status(...
                                getString(...
                                message('RptgenSL:rsl_csl_blk_lookup:unresolvedBreakpointsExpression',...
                                exp,tBlock)),1);
                                return;
                            end

                            for i=eNumDims:-1:5
                                inVals{i}=bpCell{i-4};
                            end
                        end

                        [tableData,exp,resolved]=LocParamValue(tBlock,'tableData');

                    end

                    if resolved
                        if~isempty(tableData)
                            locMakeMultiTable(c,d,tBlock,tableData,inVals,tableTitle,[],0,out);
                        else
                            c.status(...
                            getString(message('RptgenSL:rsl_csl_blk_lookup:emptyTableData',...
                            tBlock)),1);
                        end
                    else
                        c.status(...
                        getString(...
                        message('RptgenSL:rsl_csl_blk_lookup:unresolvedTableDataExpression',...
                        exp,tBlock)),1);
                    end



                    function locMultiPreTable(c,d,tBlock,tableTitle,out)

                        if locSpecifiesLUTObject(tBlock)
                            [tableData,inVals,exp,resolved]=locGetLUTObjectData(tBlock);
                        else
                            try
                                eNumDims=get_param(tBlock,'numDimsPopupSelect');
                                if strncmp(eNumDims,'More',4)
                                    [eNumDims,exp,resolved]=LocParamValue(tBlock,'explicitNumDims');
                                    if~resolved
                                        c.status(...
                                        getString(...
                                        message('RptgenSL:rsl_csl_blk_lookup:unresolvedDimensionExpression',...
                                        exp,tBlock)),1);
                                        return;
                                    end
                                else
                                    eNumDims=str2double(eNumDims);
                                end
                            catch ME
                                c.status(...
                                getString(...
                                message('RptgenSL:rsl_csl_blk_lookup:dimensionsError',...
                                ME.message,tBlock)),1);
                                return;
                            end

                            inVals=cell(eNumDims,1);
                            for i=1:eNumDims

                                try %#ok<TRYNC>
                                    inputBlock=sl('tblpresrc',tBlock,i);
                                    if~isempty(inputBlock)
                                        [inVals{i},exp,resolved]=LocParamValue(inputBlock,'bpData');
                                        if~resolved
                                            c.status(...
                                            getString(...
                                            message('RptgenSL:rsl_csl_blk_lookup:unresolvedBreakpointsExpression',...
                                            exp,tBlock)),1);
                                            return;
                                        end
                                    end
                                end
                            end

                            [tableData,exp,resolved]=LocParamValue(tBlock,'table');
                        end

                        if resolved
                            if~isempty(tableData)
                                locMakeMultiTable(c,d,tBlock,tableData,inVals,tableTitle,[],0,out);
                            else
                                c.status(...
                                getString(message('RptgenSL:rsl_csl_blk_lookup:emptyTableData',...
                                tBlock)),1);
                            end
                        else
                            c.status(...
                            getString(...
                            message('RptgenSL:rsl_csl_blk_lookup:unresolvedTableDataExpression',...
                            exp,tBlock)),1);
                        end


                        function locMultiInterpTable(c,d,tBlock,tableTitle,out)

                            if strcmp(get_param(tBlock,'TableSource'),'Input port')
                                msg=getString(message('RptgenSL:rsl_csl_blk_lookup:dynamicTable',get_param(tBlock,'Name')));
                                paraEl=createElement(d,'para',msg);
                                out.appendChild(paraEl);
                                return
                            end

                            if locSpecifiesLUTObject(tBlock)
                                [tableData,inVals,exp,resolved]=locGetLUTObjectData(tBlock);
                            else
                                try
                                    eNumDims=str2double(get_param(tBlock,'NumberOfTableDimensions'));
                                catch ME
                                    c.status(...
                                    getString(...
                                    message('RptgenSL:rsl_csl_blk_lookup:dimensionsError',...
                                    ME.message,tBlock)),1);
                                    return;
                                end

                                inVals=cell(eNumDims,1);
                                for i=1:eNumDims

                                    try %#ok<TRYNC>
                                        inputBlock=sl('tblpresrc',tBlock,i);
                                        if~isempty(inputBlock)
                                            [inVals{i},exp,resolved]=LocParamValue(inputBlock,'BreakpointsData');
                                            if~resolved
                                                c.status(...
                                                getString(...
                                                message('RptgenSL:rsl_csl_blk_lookup:unresolvedBreakpointsExpression',...
                                                exp,tBlock)),1);
                                                return;
                                            end
                                        end
                                    end
                                end

                                [tableData,exp,resolved]=LocParamValue(tBlock,'table');
                            end

                            if resolved
                                if~isempty(tableData)
                                    locMakeMultiTable(c,d,tBlock,tableData,inVals,tableTitle,[],0,out);
                                else
                                    c.status(...
                                    getString(message('RptgenSL:rsl_csl_blk_lookup:emptyTableData',...
                                    tBlock)),1);
                                end
                            else
                                c.status(...
                                getString(...
                                message('RptgenSL:rsl_csl_blk_lookup:unresolvedTableDataExpression',...
                                exp,tBlock)),1);
                            end


                            function locMultiPrelookTable(c,d,tBlock,tableTitle,out)

                                if strcmp(get_param(tBlock,'BreakpointsDataSource'),'Input port')
                                    msg=getString(message('RptgenSL:rsl_csl_blk_lookup:dynamicPrelookupTable',get_param(tBlock,'Name')));
                                    paraEl=createElement(d,'para',msg);
                                    out.appendChild(paraEl);
                                    return
                                end

                                if locSpecifiesLUTObject(tBlock)
                                    [tableData,inVals,exp,resolved]=locGetLUTObjectData(tBlock);
                                else
                                    [tableData,exp,resolved]=LocParamValue(tBlock,'BreakpointsData');
                                end

                                if resolved
                                    if~isempty(tableData)
                                        inVals={tableData};
                                        outVals=0:(length(tableData)-1);

                                        locMakeMultiTable(c,d,tBlock,outVals,inVals,tableTitle,[],0,out);
                                    else
                                        c.status(...
                                        getString(message('RptgenSL:rsl_csl_blk_lookup:emptyTableData',...
                                        tBlock)),1);
                                    end
                                else
                                    c.status(...
                                    getString(...
                                    message('RptgenSL:rsl_csl_blk_lookup:unresolvedTableDataExpression',...
                                    exp,tBlock)),1);
                                end


                                function out=locMultiDirectTable(c,d,tBlock,tableTitle,out)

                                    if strcmp(get_param(tBlock,'TableIsInput'),'on')
                                        msg=getString(message('RptgenSL:rsl_csl_blk_lookup:dynamicTable',get_param(tBlock,'Name')));
                                        paraEl=createElement(d,'para',msg);
                                        out.appendChild(paraEl);
                                        return
                                    end

                                    if locSpecifiesLUTObject(tBlock)
                                        [tableData,inVals,exp,resolved]=locGetLUTObjectData(tBlock);
                                    else
                                        try
                                            eNumDims=get_param(tBlock,'maskTabDims');
                                            if strncmp(eNumDims,'More',4)
                                                [eNumDims,exp,resolved]=LocParamValue(tBlock,'explicitNumDims');
                                                if~resolved
                                                    c.status(...
                                                    getString(...
                                                    message('RptgenSL:rsl_csl_blk_lookup:unresolvedDimensionExpression',...
                                                    exp,tBlock)),1);
                                                    return;
                                                end
                                            else
                                                eNumDims=str2double(eNumDims);
                                            end
                                        catch ME
                                            c.status(...
                                            getString(...
                                            message('RptgenSL:rsl_csl_blk_lookup:dimensionsError',...
                                            ME.message,tBlock)),1);
                                            return;
                                        end

                                        inVals=cell(eNumDims,1);

                                        [tableData,exp,resolved]=LocParamValue(tBlock,'mxTable');

                                    end

                                    if resolved
                                        if~isempty(tableData)
                                            tableTitle=sprintf('%s (%s output)',...
                                            tableTitle,...
                                            get_param(tBlock,'outDims'));
                                            locMakeMultiTable(c,d,tBlock,tableData,inVals,tableTitle,[],1,out);
                                        else
                                            c.status(...
                                            getString(message('RptgenSL:rsl_csl_blk_lookup:emptyTableData',...
                                            tBlock)),1);
                                        end
                                    else
                                        c.status(...
                                        getString(...
                                        message('RptgenSL:rsl_csl_blk_lookup:unresolvedTableDataExpression',...
                                        exp,tBlock)),1);
                                    end


                                    function locMakeMultiTable(c,d,tBlock,tableData,inVals,tableTitle,history,zeroBasedIndices,out)







                                        sz=size(tableData);
                                        nDims=length(sz);
                                        if nDims==2&&min(sz)==1
                                            nDims=1;
                                        end
                                        thisDim=nDims-length(history);

                                        if isempty(history)


                                            if nDims==1
                                                if c.isSinglePlot
                                                    h=makeFigureOneD(c,...
                                                    inVals{1},...
                                                    'Input Values',...
                                                    tableData,...
                                                    'Output Values');


                                                    if~isempty(h)
                                                        out.appendChild(c.gr_makeGraphic(d,h,...
                                                        tableTitle,...
                                                        tBlock));
                                                    end
                                                end
                                                if~c.isSingleTable
                                                    return;
                                                end
                                            elseif nDims==2
                                                if c.isDoublePlot
                                                    h=makeFigureTwoD(c,...
                                                    inVals{1},...
                                                    getString(message('RptgenSL:rsl_csl_blk_lookup:columnValuesLabel')),...
                                                    inVals{2},...
                                                    getString(message('RptgenSL:rsl_csl_blk_lookup:rowValuesLabel')),...
                                                    tableData,...
                                                    getString(message('RptgenSL:rsl_csl_blk_lookup:tableValuesLabel')));

                                                    if~isempty(h)
                                                        out.appendChild(c.gr_makeGraphic(d,h,...
                                                        tableTitle,...
                                                        tBlock));
                                                    end
                                                end
                                                if~c.isDoubleTable
                                                    return;
                                                end
                                            elseif nDims>2
                                                if~c.isMultiTable
                                                    return;
                                                end
                                            end
                                        end

                                        if thisDim<=2
                                            tableTitle=[tableTitle,' ',locTitleSuffix(history,inVals,nDims,zeroBasedIndices)];
                                            history=num2cell(history);
                                            dataSlice=tableData(:,:,history{:});

                                            out.appendChild(locGenerateTable(d,dataSlice,tableTitle,zeroBasedIndices,inVals{1:min(nDims,2)}));
                                        else
                                            for i=1:sz(thisDim)
                                                locMakeMultiTable(c,d,tBlock,tableData,inVals,tableTitle,[i,history],zeroBasedIndices,out);
                                            end
                                        end


                                        function ts=locTitleSuffix(history,inVals,nDims,zeroBasedIndices)

                                            if nargin<4
                                                zeroBasedIndices=0;
                                            end

                                            ts='(:,:';
                                            for i=3:nDims
                                                thisIdx=history(i-2);
                                                try
                                                    ts=sprintf('%s,%f',ts,inVals{i}(thisIdx));
                                                catch %#ok<CTCH>
                                                    ts=sprintf('%s,[%i]',ts,thisIdx-zeroBasedIndices);
                                                end
                                            end
                                            ts=[ts,')'];


                                            function out=locGenerateTable(d,tableData,tableTitle,zeroBasedIndices,yData,xData)

                                                sz=size(tableData);
                                                yDim=sz(1);
                                                xDim=sz(2);
                                                if nargin<6


                                                    tableData=tableData(:);
                                                    xLabels=cell(0,2);
                                                    yDim=max(sz);
                                                else
                                                    xLabels=processBreakpoints(xData,xDim,zeroBasedIndices,d);
                                                    xLabels=[{''},xLabels(:)'];
                                                end

                                                yLabels=processBreakpoints(yData,yDim,zeroBasedIndices,d);
                                                tableData=[xLabels;[yLabels(:),num2cell(tableData)]];

                                                tm=makeNodeTable(d,...
                                                tableData,...
                                                0,...
                                                true);


                                                tm.setTitle(tableTitle);
                                                tm.setBorder(true);
                                                tm.setPageWide(false);
                                                tm.setNumHeadRows(0);
                                                tm.setNumFootRows(0);

                                                out=tm.createTable;


                                                function bpLabel=processBreakpoints(bpData,maxDim,zeroBasedIndices,d)

                                                    bpLabel=num2cell(bpData);
                                                    if length(bpLabel)<maxDim
                                                        for i=maxDim:-1:length(bpLabel)+1
                                                            bpLabel{i}=sprintf('[%i]',i-zeroBasedIndices);
                                                        end
                                                    elseif length(bpData)>maxDim
                                                        bpLabel=bpLabel(1:maxDim);
                                                    end

                                                    for i=1:length(bpLabel)
                                                        bpLabel{i}=d.createElement('emphasis',bpLabel{i});
                                                    end


                                                    function[tableData,breakpoints,tdExpression,resolved]=locGetLUTObjectData(tBlock)


                                                        lutSrc=slreportgen.report.internal.lookuptable.createSource(tBlock);

                                                        tableData=[];
                                                        breakpoints=[];
                                                        resolved=false;
                                                        tdExpression="";
                                                        try

                                                            breakpoints=getBreakPoints(lutSrc);

                                                            tableData=getTableData(lutSrc);
                                                            resolved=true;
                                                        catch
                                                            tdExpression=getLookupTableObjExpression(lutSrc);
                                                        end

                                                        function tf=locSpecifiesLUTObject(tBlock)


                                                            [dataSpecification,unresolved]=rptgen.safeGet(tBlock,"DataSpecification","get_param");
                                                            if~isempty(unresolved)
                                                                dataSpecification=rptgen.safeGet(tBlock,"TableSpecification","get_param");
                                                            end

                                                            tf=strcmp(dataSpecification{1},"Lookup table object");