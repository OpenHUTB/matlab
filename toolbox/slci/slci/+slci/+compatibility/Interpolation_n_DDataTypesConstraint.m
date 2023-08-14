



classdef Interpolation_n_DDataTypesConstraint<slci.compatibility.SupportedDataTypesConstraint

    properties(Access=private)


        expectedDataType=[];

    end

    methods


        function out=getDescription(aObj)%#ok
            out='For an Interpolation_n-D block, each index inport (k) '+...
            ' must use uint32 data type while each fraction inport (f), '+...
            ' table data or outport must uniformly use single or double data type';
        end


        function obj=Interpolation_n_DDataTypesConstraint(aSupportedTypes)
            obj.setEnum('Interpolation_n_DDataTypes');
            obj.setSupportedTypes(aSupportedTypes);
        end


        function result=supportedType(aObj,dt,~)
            result=any(strcmp(dt,aObj.fSupportedTypes));
        end


        function out=getNumberOfTableDimensions(aObj)
            out=aObj.ParentBlock().getParam('NumberOfTableDimensions');
            out=str2num(out);%#ok<ST2NM>
        end


        function out=getNumSelectionDims(aObj)
            out=aObj.ParentBlock().getParam('NumSelectionDims');
            out=str2num(out(1));%#ok<ST2NM>
        end


        function out=checkIndexDataType(aObj)
            out=[];
            compiledPortDataTypes=...
            aObj.ParentBlock().getParam('CompiledPortDataTypes');
            numberOfTableDimensions=getNumberOfTableDimensions(aObj);
            numSelectionDims=getNumSelectionDims(aObj);
            numInPair=numberOfTableDimensions-numSelectionDims;

            for i=1:numInPair
                indexDataType=compiledPortDataTypes.Inport(2*i-1);
                if~strcmpi(indexDataType,'uint32')
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    aObj.getEnum(),...
                    aObj.ParentBlock().getName());
                    return;
                end
            end
        end


        function out=checkSelDataType(aObj)
            out=[];
            compiledPortDataTypes=...
            aObj.ParentBlock().getParam('CompiledPortDataTypes');
            numSelectionDims=getNumSelectionDims(aObj);%#ok<NASGU>
            numberOfTableDimensions=getNumberOfTableDimensions(aObj);
            numSelectionDims=getNumSelectionDims(aObj);
            numInPair=numberOfTableDimensions-numSelectionDims;

            for i=1:numSelectionDims
                selDataType=compiledPortDataTypes.Inport(2*numInPair+i);
                if~strcmpi(selDataType,'uint32')
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    aObj.getEnum(),...
                    aObj.ParentBlock().getName());
                    return;
                end
            end
        end


        function out=checkTableDataType(aObj)
            out=[];
            tableDataType=[];
            if strcmp(aObj.ParentBlock().getParam('TableSource'),'Input port')
                compiledPortDataTypes=...
                aObj.ParentBlock().getParam('CompiledPortDataTypes');
                numIn=numel(compiledPortDataTypes.Inport);
                tableDataType=compiledPortDataTypes.Inport(numIn);
            else
                blkObj=aObj.ParentBlock().getParam('Object');
                rtObj=blkObj.RuntimeObject;



                if isempty(rtObj)
                    return;
                end
                rtpNum=rtObj.NumRuntimePrms;
                for i=1:rtpNum
                    rtp=rtObj.RuntimePrm(i);
                    if strcmp(rtp.Name,'Table')
                        tableDataType=cellstr(rtp.Datatype);
                        break;
                    end
                end
            end
            assert(~isempty(tableDataType));
            if~aObj.supportedType(tableDataType)
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum(),...
                aObj.ParentBlock().getName());
                return;
            elseif isempty(aObj.expectedDataType)
                aObj.expectedDataType=tableDataType;
                assert(iscell(aObj.expectedDataType));
            end
        end


        function out=checkFracDataType(aObj)
            out=[];
            compiledPortDataTypes=...
            aObj.ParentBlock().getParam('CompiledPortDataTypes');
            numberOfTableDimensions=getNumberOfTableDimensions(aObj);
            numSelectionDims=getNumSelectionDims(aObj);
            numInPair=numberOfTableDimensions-numSelectionDims;

            for i=1:numInPair
                fracDataType=compiledPortDataTypes.Inport(2*i);
                if~aObj.supportedType(fracDataType)
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    aObj.getEnum(),...
                    aObj.ParentBlock().getName());
                    return;
                elseif isempty(aObj.expectedDataType)
                    aObj.expectedDataType=fracDataType;
                    assert(iscell(aObj.expectedDataType));
                elseif~strcmp(fracDataType,aObj.expectedDataType)
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    aObj.getEnum(),...
                    aObj.ParentBlock().getName());
                    return;
                end
            end
        end


        function out=checkOutputDataType(aObj)
            out=[];
            compiledPortDataTypes=...
            aObj.ParentBlock().getParam('CompiledPortDataTypes');
            outputDataType=compiledPortDataTypes.Outport(1);
            if~aObj.supportedType(outputDataType)
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum(),...
                aObj.ParentBlock().getName());
                return;
            elseif isempty(aObj.expectedDataType)
                aObj.expectedDataType=outputDataType;
                assert(iscell(aObj.expectedDataType));
            elseif~strcmp(outputDataType,aObj.expectedDataType)
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum(),...
                aObj.ParentBlock().getName());
                return;
            end
        end


        function out=checkIntermDataType(aObj)
            out=[];
            intermDataTypeStr=...
            aObj.ParentBlock().getParam('IntermediateResultsDataTypeStr');



            if strcmp(intermDataTypeStr,'Inherit: Inherit via internal rule')||...
                strcmp(intermDataTypeStr,'Inherit: Same as output')
                return;
            elseif~aObj.supportedType(intermDataTypeStr)
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum(),...
                aObj.ParentBlock().getName());
                return;
            elseif isempty(aObj.expectedDataType)
                aObj.expectedDataType=cellstr(intermDataTypeStr);
            elseif~strcmp(intermDataTypeStr,aObj.expectedDataType{1})
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum(),...
                aObj.ParentBlock().getName());
                return;
            end
        end


        function out=check(aObj)

            out=checkIndexDataType(aObj);
            if~isempty(out)
                return;
            end


            out=checkSelDataType(aObj);
            if~isempty(out)
                return;
            end


            out=checkTableDataType(aObj);
            if~isempty(out)
                return;
            end


            out=checkFracDataType(aObj);
            if~isempty(out)
                return;
            end


            out=checkOutputDataType(aObj);
            if~isempty(out)
                return;
            end


            out=checkIntermDataType(aObj);
            if~isempty(out)
                return;
            end

        end

    end

end