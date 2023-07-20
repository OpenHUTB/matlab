classdef PreLookup<slreportgen.report.internal.lookuptable.LookupTableSource




    properties(Access=private)
        BreakpointsLength=[];
        BreakpointsClass=[];
    end

    methods
        function this=PreLookup(blkH)
            this@slreportgen.report.internal.lookuptable.LookupTableSource(blkH);
            this.BreakpointsHeader=getString(message("lutdesigner:PreLookupReporter:Row"));
        end

        function outputs=getBreakPoints(h)
            outputs={1:h.BreakpointsLength};
        end


        function outputs=getTableData(h)






            tBlock=h.Handle;
            outputs={};
            breakpointsSpecification=get_param(tBlock,"BreakpointsSpecification");
            if strcmp(breakpointsSpecification,"Explicit values")
                outputs=slreportgen.utils.getResolvedParamValue(tBlock,"BreakpointsData");

            elseif strcmp(breakpointsSpecification,"Even spacing")

                firstPoint=slResolve(get_param(tBlock,'BreakpointsFirstPoint'),tBlock);
                spacing=slResolve(get_param(tBlock,'BreakpointsSpacing'),tBlock);
                numOfPoints=slResolve(get_param(tBlock,'BreakpointsNumPoints'),tBlock);


























                robj=get_param(gcb,'RuntimeObject');

                rprm=robj.RuntimePrm(1);
                firstPoint=rprm.Data;

                rprm=robj.RuntimePrm(2);
                spacing=rprm.Data;

                for i=1:numOfPoints
                    bp(i)=firstPoint;%#ok<AGROW>
                    firstPoint=firstPoint+spacing;
                end

                if isFPFixedPoint
                    p=fi([],firstPointFixed.numerictype);
                    fixedPointData=zeros(1,length(bpValue),'like',p);
                    for i=1:length(bp)
                        fixedPointData(i)=fi((firstPointFixed.Slope*bp(i))+firstPointFixed.Bias,firstPointFixed.numerictype);
                    end
                    bp=fixedPointData;
                end

                outputs=bp;

            elseif strcmp(breakpointsSpecification,"Breakpoint object")
                bpObjName=get_param(tBlock,"BreakpointObject");
                if~isempty(bpObjName)
                    bpObj=slResolve(bpObjName,tBlock);
                    outputs=bpObj.Breakpoints.Value;
                end
            end

            h.BreakpointsLength=length(outputs);
            h.BreakpointsClass=class(outputs);
        end

        function title=getTableTitle(h)%#ok<MANU>
            title="";
        end

        function bpExpr=getBreakpointExpression(h)




            tBlock=h.Handle;
            bpExpr={};
            breakpointsSpecification=get_param(tBlock,"BreakpointsSpecification");

            if strcmp(breakpointsSpecification,"Explicit values")

                breakPointExpr=getExpressionInfo(h,"BreakpointsData");
                if~isempty(breakPointExpr)
                    WorkspaceExpr={"prelookup",breakPointExpr};
                    bpExpr{end+1}=WorkspaceExpr;
                end

            elseif strcmp(breakpointsSpecification,"Even spacing")

                firstPointExpr=getExpressionInfo(h,'BreakpointsFirstPoint');
                if~isempty(firstPointExpr)
                    WorkspaceExpr={"prelookup",firstPointExpr};
                    bpExpr{end+1}=WorkspaceExpr;
                end
            end
        end

        function bpObjExpr=getBreakpointObjExpression(h)
            tBlock=h.Handle;
            breakpointsSpecification=get_param(tBlock,"BreakpointsSpecification");
            bpObjExpr=[];
            if strcmp(breakpointsSpecification,"Breakpoint object")
                bpObjName=get_param(tBlock,"BreakpointObject");
                if~isempty(bpObjName)
                    bpVar=Simulink.findVars(getfullname(tBlock),'Name',bpObjName,'SearchMethod','cached');
                    if~isempty(bpVar)
                        bpObjExpr=bpObjName;
                    end
                end
            end
        end

        function isTableUsedAsInput=isInputSimulated(h)
            isTableUsedAsInput=strcmp(get_param(h.Handle,"BreakpointsDataSource"),"Input port");
        end

        function tableInputStr=getBlockInputStr(h)%#ok<MANU>
            tableInputStr=getString(message("lutdesigner:PreLookupReporter:BreakpointsInput"));
        end


        function dtProps=getLookupTableDataTypeProperties(h)
            rowInd=1;
            dataTypePropertyName=["BreakpointDataTypeStr","IndexDataTypeStr","FractionDataTypeStr","OutputBusDataTypeStr"];
            dParam=get_param(h.Handle,"dialogparameters");
            dataTypePropNameLen=length(dataTypePropertyName);
            dtProps=cell(dataTypePropNameLen,2);
            for i=1:dataTypePropNameLen
                propName=dParam.(dataTypePropertyName{i}).("Prompt");
                propName=strrep(propName,":","");
                dataTypeValue=get_param(h.Handle,dataTypePropertyName{i});
                if contains(dataTypeValue,"Inherit:")
                    dataTypeValue=resolveDataTypeInheritedValue(h,dataTypeValue);
                end
                dtProps{rowInd,1}=propName;
                dtProps{rowInd,2}=dataTypeValue;
                rowInd=rowInd+1;
            end

        end

        function resolvedLUTDataTypeValue=resolveDataTypeInheritedValue(h,breakPointDataTypeValue)
            switch breakPointDataTypeValue
            case getString(message("lutdesigner:PreLookupReporter:InheritSameAsInput"))
                compiledPortDataTypes=get_param(h.Handle,"CompiledPortDatatypes");
                resolvedLUTDataTypeValue=compiledPortDataTypes.Inport{1};
            case getString(message("lutdesigner:PreLookupReporter:InheritFromBreakPoint"))
                resolvedLUTDataTypeValue=h.BreakpointsClass;
            otherwise
                resolvedLUTDataTypeValue=breakPointDataTypeValue;
            end
        end

    end
end
