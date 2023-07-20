



classdef MatlabFunctionDatatypeConstraint<slci.compatibility.StateflowDatatypeConstraint

    methods


        function out=getDescription(aObj)%#ok
            out=['Matlab function data must be of type ''boolean'',''int8'','...
            ,'''int16'',''int32'',''uint8'',''uint16'',''uint32'',''single'', ''double'','...
            ,'enum with default value 0 or a bus'];
        end


        function obj=MatlabFunctionDatatypeConstraint
            obj.setEnum('MatlabFunctionDatatype');
            obj.setFatal(false);
            obj.fSupportedTypes=...
            {'boolean','int8','int16','int32','uint8','uint16',...
            'uint32','single','double'};
        end


        function out=check(aObj)

            out=[];
            owner=aObj.getOwner();

            dataType=owner.getDataType();
            if isa(owner,'slci.matlab.EMData')
                dataWidth=owner.getSize();
            else
                assert(isa(owner,'slci.ast.SFAst'));
                dataWidth=owner.getDataWidth();
            end

            isMissingType=isempty(dataType)||isempty(dataWidth);
            if~isMissingType
                isSupported=aObj.supportedType(dataType,dataWidth);
                if~isSupported
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    'MatlabFunctionDatatype',...
                    aObj.resolveBlockClassName,...
                    aObj.ParentBlock().getName());
                end
            end

        end


        function[SubTitle,Information,StatusText,RecAction]=...
            getSpecificMAStrings(aObj,varargin)
            status=varargin{1};
            id=strrep(class(aObj),'slci.compatibility.','');
            if status
                status='Pass';
            else
                status='Warn';
            end
            if isa(aObj.getOwner(),'slci.matlab.EMData')
                ownerType='EMData';
            else
                assert(isa(aObj.getOwner(),'slci.ast.SFAst'));
                ownerType='Ast';
            end
            blk_class_name=aObj.resolveBlockClassName;
            StatusText=DAStudio.message(['Slci:compatibility:',id,ownerType,status],blk_class_name);
            RecAction=DAStudio.message(['Slci:compatibility:',id,ownerType,'RecAction'],blk_class_name);
            SubTitle=DAStudio.message(['Slci:compatibility:',id,ownerType,'SubTitle'],blk_class_name);
            Information=DAStudio.message(['Slci:compatibility:',id,ownerType,'Info'],blk_class_name);
        end

    end

    methods(Access=protected)


        function result=isSupportedBus(aObj,dt)
            if isa(aObj.ParentBlock,'slci.simulink.StateflowBlock')
                result=isSupportedBus@slci.compatibility.StateflowDatatypeConstraint(aObj,dt);
                return;
            end
            result=false;

            resolvedType=aObj.resolveType(dt);
            if isa(resolvedType,'Simulink.Bus')&&...
                aObj.ParentBlock().getSupportsBuses()
                for idx=1:numel(resolvedType.Elements)
                    dim=resolvedType.Elements(idx).Dimensions;
                    [flag,dim]=slci.internal.resolveDim(aObj.ParentModel.getHandle,dim);
                    if~flag
                        return;
                    end
                    if~aObj.supportedType(resolvedType.Elements(idx).DataType,...
                        prod(dim))
                        return
                    end
                end

                result=true;
            elseif isa(resolvedType,'slci.mlutil.NamedType')
                result=aObj.isSupportedBus(resolvedType.getName());
            else

                result=false;
            end
        end


        function resolvedType=resolveType(aObj,dt)
            parentChart=aObj.getOwner().ParentChart();
            assert(isa(parentChart,'slci.matlab.EMChart'));
            assert(ischar(dt));
            resolvedType=dt;
            if parentChart.getSymbolTable().hasSymbol(dt)
                resolvedType=parentChart.getSymbolTable().getType(...
                resolvedType);
            else

                try
                    resolvedType=slResolve(dt,...
                    aObj.ParentBlock().getSID());
                    return;
                catch
                    resolvedType=[];
                end
            end
        end

    end

end

