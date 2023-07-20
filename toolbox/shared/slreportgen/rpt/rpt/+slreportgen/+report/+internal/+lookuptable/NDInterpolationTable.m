classdef NDInterpolationTable<slreportgen.report.internal.lookuptable.LookupTableSource

    methods
        function h=NDInterpolationTable(blkH)
            h@slreportgen.report.internal.lookuptable.LookupTableSource(blkH);
            h.dim=slreportgen.utils.getResolvedParamValue(h.Handle,"NumberOfTableDimensions");
        end


        function breakPoints=getBreakPoints(h)



            tBlock=h.Handle;
            tableSpecification=get_param(tBlock,"TableSpecification");

            if strcmp(tableSpecification,"Explicit values")
                eNumDims=slreportgen.utils.getResolvedParamValue(tBlock,"NumberOfTableDimensions");
                breakPoints=cell(eNumDims,1);
                for i=1:eNumDims
                    inputBlock=sl("tblpresrc",tBlock,i);
                    if~isempty(inputBlock)
                        breakPoints{i}=slreportgen.utils.getResolvedParamValue(inputBlock,"BreakpointsData");
                    end
                end
            elseif strcmp(tableSpecification,"Lookup table object")
                breakPoints=getLookupTableObjectBpData(h);
            end
        end


        function tableData=getTableData(h)



            tBlock=h.Handle;
            tableData=[];
            tableSpecification=get_param(tBlock,"TableSpecification");
            if strcmp(tableSpecification,"Explicit values")
                eNumDims=slreportgen.utils.getResolvedParamValue(tBlock,"NumberOfTableDimensions");
                tableData=slreportgen.utils.getResolvedParamValue(tBlock,"table");
                dims=getTableDataDimensions(h,tableData);
                if(dims~=eNumDims)
                    str=(getString(message("slreportgen:report:error:dimensionsMismatch")));
                    error('slreportgen:LUTDimensionMismatch',...
                    str);
                end
            elseif strcmp(tableSpecification,"Lookup table object")
                LookupTableObject=slreportgen.utils.getResolvedParamValue(tBlock,"LookupTableObject");
                tableData=LookupTableObject.Table.Value;
            end
        end

        function title=getTableTitle(h)%#ok<MANU>
            title="";
        end

        function tableDataExpr=getTableDataExpression(h)
            tableDataExpr=[];
            tableSpecification=get_param(h.Handle,"TableSpecification");
            if strcmp(tableSpecification,"Explicit values")
                tableDataExpr=getExpressionInfo(h,"table");
            end
        end

        function lutObjExpr=getLookupTableObjExpression(h)
            lutObjExpr=[];
            tableSpecification=get_param(h.Handle,"TableSpecification");
            if strcmp(tableSpecification,"Lookup table object")
                lutObjExpr=getLookupTableObjectName(h);
            end
        end

        function isTableUsedAsInput=isInputSimulated(h)
            isTableUsedAsInput=strcmp(get_param(h.Handle,"TableSource"),"Input port");
        end

        function tableInputStr=getBlockInputStr(h)%#ok<MANU>
            tableInputStr=getString(message("slreportgen:report:LookupTable:TableDataInput"));
        end

        function dtProps=getLookupTableDataTypeProperties(h)

            rowInd=1;
            dataTypePropertyName={"OutDataTypeStr","TableDataTypeStr","IntermediateResultsDataTypeStr"};
            dParam=get_param(h.Handle,"dialogparameters");
            dataTypePropNameLen=length(dataTypePropertyName);
            dtProps=cell(dataTypePropNameLen,2);

            modelH=slreportgen.utils.getModelHandle(h.Handle);
            isCompiled=slreportgen.utils.isModelCompiled(modelH);

            for i=1:dataTypePropNameLen
                propName=dParam.(dataTypePropertyName{i}).("Prompt");
                propName=strrep(propName,":","");
                if~isCompiled
                    dataTypeValue=get_param(h.Handle,dataTypePropertyName{i});
                else
                    switch dataTypePropertyName{i}
                    case "TableDataTypeStr"
                        dataTypeValue=get_param(h.Handle,"TableDataTypeName");
                    case "IntermediateResultsDataTypeStr"
                        dataTypeValue=get_param(h.Handle,"IntermediateResultsDataTypeName");
                    otherwise
                        dataTypeValue=get_param(h.Handle,dataTypePropertyName{i});
                        if contains(dataTypeValue,"Inherit:")
                            dataTypeValue=resolveDataTypeInheritedValue(h,dataTypeValue);
                        end
                    end
                end
                dtProps{rowInd,1}=propName;
                dtProps{rowInd,2}=dataTypeValue;
                rowInd=rowInd+1;
            end

        end

    end
end


