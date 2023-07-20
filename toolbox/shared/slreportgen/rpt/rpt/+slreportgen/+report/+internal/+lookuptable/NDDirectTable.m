classdef NDDirectTable<slreportgen.report.internal.lookuptable.LookupTableSource

    properties(Access=private)
        m_tableDataClassName=[];
    end
    methods
        function h=NDDirectTable(blkH)
            h@slreportgen.report.internal.lookuptable.LookupTableSource(blkH);
            h.dim=slreportgen.utils.getResolvedParamValue(h.Handle,"NumberOfTableDimensions");
        end

        function breakPoints=getBreakPoints(h)





            eNumDims=slreportgen.utils.getResolvedParamValue(h.Handle,"NumberOfTableDimensions");
            breakPoints=cell(eNumDims,1);

        end

        function tableData=getTableData(h)

            tBlock=h.Handle;
            eNumDims=slreportgen.utils.getResolvedParamValue(tBlock,"NumberOfTableDimensions");
            tableData=slreportgen.utils.getResolvedParamValue(tBlock,'Table');
            h.m_tableDataClassName=class(tableData);
            dims=getTableDataDimensions(h,tableData);
            if(dims~=eNumDims)
                str=(getString(message("slreportgen:report:error:dimensionsMismatch")));
                error('slreportgen:LUTDimensionMismatch',...
                str);
            end
        end

        function title=getTableTitle(h)
            title=sprintf('(%s output)',...
            get_param(h.Handle,"outDims"));
        end

        function tableDataExpr=getTableDataExpression(h)
            tableDataExpr=getExpressionInfo(h,"Table");
        end


        function isTableUsedAsInput=isInputSimulated(h)
            isTableUsedAsInput=strcmp(get_param(h.Handle,"TableIsInput"),"on");
        end

        function tableInputStr=getBlockInputStr(h)%#ok<MANU>
            tableInputStr=getString(message("slreportgen:report:LookupTable:TableDataInput"));
        end

        function dtProps=getLookupTableDataTypeProperties(h)

            rowInd=1;
            dataTypePropertyName={"TableDataTypeStr"};
            dataTypePropNameLen=length(dataTypePropertyName);
            dtProps=cell(dataTypePropNameLen,2);
            dParam=get_param(h.Handle,"dialogparameters");
            propName=dParam.(dataTypePropertyName{1}).("Prompt");
            propName=strrep(propName,":","");
            dataTypeValue=get_param(h.Handle,dataTypePropertyName{1});
            modelH=slreportgen.utils.getModelHandle(h.Handle);
            isCompiled=slreportgen.utils.isModelCompiled(modelH);
            if(isCompiled)&&contains(dataTypeValue,"Inherit: Inherit from 'Table data'")
                dataTypeValue=h.m_tableDataClassName;
            end
            dtProps{rowInd,1}=propName;
            dtProps{rowInd,2}=dataTypeValue;

        end

    end

end

