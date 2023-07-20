classdef LookupTableDynamic<slreportgen.report.internal.lookuptable.LookupTableSource

    methods
        function h=LookupTableDynamic(blkH)
            h@slreportgen.report.internal.lookuptable.LookupTableSource(blkH);
        end

        function breakPoints=getBreakPoints(h)%#ok<MANU>
            breakPoints=[];
        end

        function tableData=getTableData(h)%#ok<MANU>
            tableData=[];
        end

        function title=getTableTitle(h)%#ok<MANU>
            title="";
        end

        function isTableUsedAsInput=isInputSimulated(h)%#ok<MANU>
            isTableUsedAsInput=true;
        end

        function tableInputStr=getBlockInputStr(h)%#ok<MANU>


            tableInputStr=getString(message("slreportgen:report:LookupTable:LookupTableDynamic"));
        end

        function dtProps=getLookupTableDataTypeProperties(h)

            rowInd=1;
            dataTypePropertyName={"OutDataTypeStr"};
            dParam=get_param(h.Handle,"dialogparameters");
            dataTypePropNameLen=length(dataTypePropertyName);
            dtProps=cell(dataTypePropNameLen,2);
            propName=dParam.(dataTypePropertyName{1}).("Prompt");
            propName=strrep(propName,":","");
            dataTypeValue=get_param(h.Handle,dataTypePropertyName{1});

            modelH=slreportgen.utils.getModelHandle(h.Handle);
            isCompiled=slreportgen.utils.isModelCompiled(modelH);

            if(isCompiled&&contains(dataTypeValue,"Inherit:"))
                dataTypeValue=resolveDataTypeInheritedValue(h,dataTypeValue);
            end
            dtProps{rowInd,1}=propName;
            dtProps{rowInd,2}=dataTypeValue;

        end

    end

end

