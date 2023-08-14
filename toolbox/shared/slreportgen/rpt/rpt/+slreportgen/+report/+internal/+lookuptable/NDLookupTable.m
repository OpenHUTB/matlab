classdef NDLookupTable<slreportgen.report.internal.lookuptable.LookupTableSource

    methods
        function h=NDLookupTable(blkH)
            h@slreportgen.report.internal.lookuptable.LookupTableSource(blkH);
            h.dim=slreportgen.utils.getResolvedParamValue(h.Handle,"NumberOfTableDimensions");
        end
        function breakPoints=getBreakPoints(h)






            dataSpecification=get_param(h.Handle,"DataSpecification");
            if strcmp(dataSpecification,"Table and breakpoints")

                breakPoints=getnDTableBreakPoints(h);

            elseif strcmp(dataSpecification,"Lookup table object")
                breakPoints=getLookupTableObjectBpData(h);
            end

        end

        function tableData=getTableData(h)






            dataSpecification=get_param(h.Handle,"DataSpecification");
            if strcmp(dataSpecification,"Table and breakpoints")

                tableData=getnDTableData(h);

            elseif strcmp(dataSpecification,"Lookup table object")
                tableData=getLookupTableObjectTableData(h);
            end
        end


        function title=getTableTitle(h)%#ok<MANU>
            title="";
        end

        function bpExpr=getBreakpointExpression(h)
            bpExpr=[];
            tBlock=h.Handle;
            expr=[];
            dataSpecification=get_param(tBlock,"DataSpecification");
            if strcmp(dataSpecification,"Table and breakpoints")

                eNumDims=slreportgen.utils.getResolvedParamValue(tBlock,"NumberOfTableDimensions");
                breakpointsSpecification=get_param(tBlock,"BreakpointsSpecification");

                if strcmp(breakpointsSpecification,"Explicit values")
                    expr.breakPointExpr={};

                    for j=1:1:eNumDims

                        breakPointExpression=getExpressionInfo(h,sprintf("bp%i",j));
                        if~isempty(breakPointExpression)
                            WorkspaceExpr={sprintf("BreakPoint%i",j),breakPointExpression};
                            bpExpr{end+1}=WorkspaceExpr;%#ok<AGROW>
                        end

                    end
                elseif strcmp(breakpointsSpecification,"Even spacing")
                    for j=1:1:eNumDims
                        breakPointExpression=getExpressionInfo(h,strcat("BreakpointsForDimension",mat2str(j),"FirstPoint"));
                        if~isempty(breakPointExpression)
                            WorkspaceExpr={sprintf("BreakPoint%i",j),breakPointExpression};
                            bpExpr{end+1}=WorkspaceExpr;%#ok<AGROW>
                        end
                    end
                end
            end
        end

        function tableDataExpr=getTableDataExpression(h)

            tableDataExpr=[];
            dataSpecification=get_param(h.Handle,"DataSpecification");
            if strcmp(dataSpecification,"Table and breakpoints")
                tableDataExpr=getExpressionInfo(h,"tableData");
            end
        end

        function lutObjExpr=getLookupTableObjExpression(h)
            lutObjExpr=[];
            dataSpecification=get_param(h.Handle,"DataSpecification");
            if strcmp(dataSpecification,"Lookup table object")
                lutObjExpr=getLookupTableObjectName(h);
            end
        end

        function bpEvenSpacingInfo=getEvenSpacingInfo(h)
            bpEvenSpacingInfo=[];
            tBlock=h.Handle;
            dataSpecification=get_param(tBlock,"DataSpecification");
            if strcmp(dataSpecification,"Table and breakpoints")

                eNumDims=slreportgen.utils.getResolvedParamValue(tBlock,"NumberOfTableDimensions");
                breakpointsSpecification=get_param(tBlock,"BreakpointsSpecification");

                if strcmp(breakpointsSpecification,"Even spacing")
                    bpEvenSpacingInfo=cell(1,eNumDims);
                    for j=1:1:eNumDims
                        firstPoint=get_param(tBlock,strcat("BreakpointsForDimension",mat2str(j),"FirstPoint"));
                        spacing=get_param(tBlock,strcat("BreakpointsForDimension",mat2str(j),"Spacing"));
                        if~isempty(firstPoint)&&~isempty(spacing)
                            WorkspaceExpr={sprintf("BreakPoint%i",j),firstPoint,spacing};
                            bpEvenSpacingInfo{j}=WorkspaceExpr;
                        end
                    end
                end
            end
        end

        function breakPoints=getnDTableBreakPoints(h)
            tBlock=h.Handle;


            breakpointsSpecification=get_param(tBlock,"BreakpointsSpecification");
            if strcmp(breakpointsSpecification,"Explicit values")

                eNumDims=slreportgen.utils.getResolvedParamValue(tBlock,"NumberOfTableDimensions");
                breakPoints=cell(eNumDims,1);
                for j=1:1:eNumDims
                    breakPoints{j}=slreportgen.utils.getResolvedParamValue(tBlock,sprintf("BreakpointsForDimension%i",j));
                end
            elseif strcmp(breakpointsSpecification,"Even spacing")
                breakPoints=getnDEvenSpacingBreakPointData(h);
            end

        end

        function tableData=getnDTableData(h)

            tBlock=h.Handle;

            eNumDims=slreportgen.utils.getResolvedParamValue(tBlock,"NumberOfTableDimensions");
            tableData=slreportgen.utils.getResolvedParamValue(tBlock,"tableData");

            dims=getTableDataDimensions(h,tableData);
            if(dims~=eNumDims)
                str=(getString(message("slreportgen:report:error:dimensionsMismatch")));
                error('slreportgen:LUTDimensionMismatch',...
                str);
            end
        end


        function tableData=getLookupTableObjectTableData(h)

            LookupTableObject=slreportgen.utils.getResolvedParamValue(h.Handle,"LookupTableObject");
            tableData=LookupTableObject.Table.Value;

        end

        function isTableUsedAsInput=isInputSimulated(h)%#ok<MANU>
            isTableUsedAsInput=false;
        end

        function tableInputStr=getBlockInputStr(h)%#ok<MANU>
            tableInputStr="";
        end

        function breakPoints=getnDEvenSpacingBreakPointData(h)
            tBlock=h.Handle;
            tableData=getnDTableData(h);
            sz=size(tableData);
            if(sz(1)==1)
                numOfBreakPoints=1;
            else
                numOfBreakPoints=numel(sz);
            end
            breakPoints=cell(1,numOfBreakPoints);
            for i=1:numOfBreakPoints
                bpValue=[];
                firstPoint=slreportgen.utils.getResolvedParamValue(tBlock,strcat("BreakpointsForDimension",mat2str(i),"FirstPoint"));
                spacing=slreportgen.utils.getResolvedParamValue(tBlock,strcat("BreakpointsForDimension",mat2str(i),"Spacing"));

                firstPoint=double(firstPoint);
                spacing=double(spacing);
                if(sz(1)==1)
                    breakPointValues=sz(2);
                else
                    breakPointValues=sz(i);
                end
                for j=1:breakPointValues
                    bpValue(j)=firstPoint;%#ok<AGROW>
                    firstPoint=firstPoint+spacing;
                end
                breakPoints{i}=bpValue;
            end
        end

        function dtProps=getLookupTableDataTypeProperties(h)
            rowInd=1;
            dataTypePropertyName={"TableDataTypeStr","IntermediateResultsDataTypeStr","OutDataTypeStr","FractionDataTypeStr"};
            for i=1:h.dim
                dataTypePropertyName{end+1}=strcat("BreakpointsForDimension",string(i),"DataTypeStr");%#ok<AGROW>
            end

            dParam=get_param(h.Handle,"dialogparameters");
            dataTypePropNameLen=length(dataTypePropertyName);
            dtProps=cell(dataTypePropNameLen,2);

            modelH=slreportgen.utils.getModelHandle(h.Handle);
            isCompiled=slreportgen.utils.isModelCompiled(modelH);

            for i=1:dataTypePropNameLen
                propName=dParam.(dataTypePropertyName{i}).("Prompt");
                propName=strrep(propName,':','');

                if~isCompiled
                    dataTypeValue=get_param(h.Handle,dataTypePropertyName{i});
                else
                    switch dataTypePropertyName{i}
                    case "TableDataTypeStr"
                        dataTypeValue=get_param(h.Handle,"TableDataTypeName");
                    case "IntermediateResultsDataTypeStr"
                        dataTypeValue=get_param(h.Handle,"IntermediateResultsDataTypeName");
                    case "FractionDataTypeStr"
                        dataTypeValue=get_param(h.Handle,"FractionDataTypeName");
                    otherwise
                        if contains(dataTypePropertyName{i},"BreakpointsForDimension")
                            tokens=regexp(dataTypePropertyName{i},"BreakpointsForDimension(\d*)DataTypeStr","tokens","once");
                            str=strcat("BreakpointsForDimension",tokens,"DataTypeName");
                            dataTypeValue=get_param(h.Handle,str);
                        else
                            dataTypeValue=get_param(h.Handle,dataTypePropertyName{i});
                            if contains(dataTypeValue,"Inherit:")
                                dataTypeValue=resolveDataTypeInheritedValue(h,dataTypeValue);
                            end
                        end
                    end
                end
                dtProps{rowInd,1}=propName;
                dtProps{rowInd,2}=dataTypeValue;
                rowInd=rowInd+1;
            end
        end

        function assertValidBreakPoints(h,breakPoints,tableData)
            dimensionMatch=true;
            sz=size(tableData);
            nDims=getTableDataDimensions(h,tableData);
            if(nDims==1)
                if(numel(breakPoints{1})~=numel(tableData))
                    dimensionMatch=false;
                end
            else
                for i=1:nDims
                    if numel(breakPoints{i})~=sz(i)
                        dimensionMatch=false;
                    end
                end
            end
            if~dimensionMatch
                str=(getString(message("slreportgen:report:error:dimensionsMismatch")));
                error('slreportgen:LUTDimensionMismatch',...
                str);
            end
        end
    end
end

