classdef LookupTableSource<handle

    properties
        Handle=[];
        PropTableHeader=getString(message("slreportgen:report:LookupTable:Datatype"));
        BreakpointsHeader=getString(message("slreportgen:report:LookupTable:Breakpoints"));
        dim=0;
    end

    methods
        function h=LookupTableSource(blkH)
            h.Handle=slreportgen.utils.getSlSfHandle(blkH);
        end
    end

    methods(Abstract)
        isTableUsedAsInput=isInputSimulated(h);
        tableInputStr=getBlockInputStr(h);
        title=getTableTitle(h);
        bp=getBreakPoints(h);
        tableData=getTableData(h);
        dtProps=getLookupTableDataTypeProperties(h);
    end

    methods(Access=public)


        function bpExpr=getBreakpointExpression(h)%#ok<MANU>
            bpExpr=[];
        end

        function tableDataExpr=getTableDataExpression(h)%#ok<MANU>
            tableDataExpr=[];
        end

        function lutExpr=getLookupTableObjExpression(h)%#ok<MANU>
            lutExpr=[];
        end

        function bpObjExpr=getBreakpointObjExpression(h)%#ok<MANU>
            bpObjExpr=[];
        end

        function bpEvenSpacingInfo=getEvenSpacingInfo(h)%#ok<MANU>
            bpEvenSpacingInfo=[];
        end

        function assertValidBreakPoints(~,~,~)
        end

        function displayLabel=getDisplayLabel(h)
            blkH=slreportgen.utils.getSlSfHandle(h.Handle);
            objName=get_param(blkH,"Name");
            displayLabel=mlreportgen.utils.normalizeString(objName);
        end

        function titleStr=getPropertiesTableTitle(h)
            titleStr=strcat(getDisplayLabel(h)," ",...
            getString(message("slreportgen:report:LookupTable:Datatypes")));
        end

        function resolvedLUTDataTypeValue=resolveDataTypeInheritedValue(h,breakPointDataTypeValue)
            switch breakPointDataTypeValue
            case "Inherit: Inherit via back propagation"
                compiledPortDataTypes=get_param(h.Handle,"CompiledPortDatatypes");
                resolvedLUTDataTypeValue=compiledPortDataTypes.Outport{1};
            case "Inherit: Same as first input"
                compiledPortDataTypes=get_param(h.Handle,"CompiledPortDatatypes");
                resolvedLUTDataTypeValue=compiledPortDataTypes.Inport{1};
            case "Inherit: Inherit from 'Table data'"
                resolvedLUTDataTypeValue=get_param(h.Handle,"TableDataTypeName");
            case "Inherit: Same as output"
                compiledPortDataTypes=get_param(h.Handle,"CompiledPortDatatypes");
                resolvedLUTDataTypeValue=compiledPortDataTypes.Outport{1};
            otherwise
                resolvedLUTDataTypeValue=breakPointDataTypeValue;
            end
        end
    end

    methods(Access=protected)
        function expr=getExpressionInfo(h,pName)



            expr=[];
            pString=get_param(h.Handle,pName);
            symbolicVar=symvar(pString);

            if(~isempty(symbolicVar)||strcmp(pString,"i")||strcmp(pString,"j"))
                expr=pString;
            end
        end

        function breakPoints=getLookupTableObjectBpData(h)







            breakPoints=[];
            LookupTableObject=slreportgen.utils.getResolvedParamValue(h.Handle,"LookupTableObject");
            lutObjBreakpointSpec=LookupTableObject.BreakpointsSpecification;
            switch lutObjBreakpointSpec
            case "Explicit values"
                breakPoints=getExplicitValuesBreakPoints(h,LookupTableObject);
            case "Reference"
                breakPoints=getReferenceBreakPoints(h,LookupTableObject);
            case "Even spacing"
                breakPoints=getEvenSpacingBreakPoints(h,LookupTableObject);

            end
        end

        function lutObjExpr=getLookupTableObjectName(h)


            tBlock=h.Handle;
            lutObjName=get_param(tBlock,"LookupTableObject");
            if~isempty(lutObjName)
                lutVar=Simulink.findVars(getfullname(tBlock),'Name',lutObjName,'SearchMethod','cached');
                if~isempty(lutVar)
                    lutObjExpr=lutObjName;
                end
            end
        end

        function nDims=getTableDataDimensions(h,tableData)%#ok<INUSL>
            sz=size(tableData);
            nDims=numel(sz);
            if nDims==2&&min(sz)==1
                nDims=1;
            end
        end
    end

    methods(Access=private)

        function breakPoints=getExplicitValuesBreakPoints(h,LookupTableObject)%#ok<INUSL>
            lutObjBrkPointsLen=numel(LookupTableObject.Breakpoints);
            for i=1:lutObjBrkPointsLen
                breakPoints{i}=LookupTableObject.Breakpoints(i).Value;%#ok<AGROW>
            end
        end

        function breakPoints=getReferenceBreakPoints(h,LookupTableObject)
            breakPoints={};
            lutObjBrkPointsLen=numel(LookupTableObject.Breakpoints);
            for i=1:lutObjBrkPointsLen

                bpObjValue=slResolve(LookupTableObject.Breakpoints{i},h.Handle);
                if isa(bpObjValue,"Simulink.Breakpoint")
                    breakPoints{i}=bpObjValue.Breakpoints.Value;%#ok<AGROW>
                else
                    breakPoints{i}=bpObjValue;%#ok<AGROW>
                end
            end

        end

        function breakPoints=getEvenSpacingBreakPoints(h,LookupTableObject)%#ok<INUSL>

            sz=size(LookupTableObject.Table.Value);
            if(sz(1)==1)
                numOfBreakPoints=1;
            else
                numOfBreakPoints=numel(sz);
            end
            breakPoints=cell(1,numOfBreakPoints);
            for i=1:numOfBreakPoints
                bpValue=[];
                firstPoint=LookupTableObject.Breakpoints(i).FirstPoint;
                spacing=LookupTableObject.Breakpoints(i).Spacing;

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
    end
end