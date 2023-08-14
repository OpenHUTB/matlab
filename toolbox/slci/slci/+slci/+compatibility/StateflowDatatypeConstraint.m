classdef StateflowDatatypeConstraint<slci.compatibility.Constraint



    properties(Access=protected)
        fSupportedTypes={};
    end


    methods


        function out=getDescription(aObj)%#ok
            out='Stateflow data must of a supported type and dimension.';
        end


        function obj=StateflowDatatypeConstraint
            obj.setEnum('StateflowDatatype');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
            obj.fSupportedTypes=...
            {'boolean','int8','int16','int32','uint8','uint16','uint32','single','double'};
        end


        function out=check(aObj)
            out=[];
            if~aObj.supportedType(aObj.ParentData.getDataType(),...
                aObj.ParentData.getWidth())
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowDatatype',...
                aObj.ParentBlock().getName());
            end
        end

    end

    methods(Access=protected)


        function result=supportedType(aObj,dt,width)


            result=false;

            assert(ischar(dt));

            if strcmp(dt,'auto')
                result=true;
                return
            end

            if any(strcmp(dt,aObj.fSupportedTypes))
                result=true;
                return;
            end

            if strncmp(dt,'Bus:',4)
                dt=strtrim(dt(5:end));
            end

            if strncmp(dt,'Enum:',5)
                dt=strtrim(dt(6:end));
            end

            if isvarname(dt)
                if slci.compatibility.isSupportedEnumClass(dt)
                    result=aObj.ParentBlock().getSupportsEnums();
                else
                    result=aObj.isSupportedBus(dt);
                end
            end

        end


        function result=isSupportedBus(aObj,dt)
            result=false;
            try
                busObject=slResolve(dt,aObj.ParentBlock.getSID());
                if isa(busObject,'Simulink.Bus')&&...
                    aObj.ParentBlock().getSupportsBuses()

                    for idx=1:numel(busObject.Elements)
                        dim=busObject.Elements(idx).Dimensions;
                        if ischar(dim)


                            try
                                dim=slResolve(dim,...
                                aObj.ParentModel.getHandle);
                            catch
                                return;
                            end
                        end
                        [flag,dim]=slci.internal.resolveDim(aObj.ParentModel.getHandle,dim);
                        if~flag
                            return;
                        end
                        if~aObj.supportedType(busObject.Elements(idx).DataType,...
                            prod(dim))
                            return
                        end
                    end

                    result=true;
                    return
                else
                    result=false;
                    return
                end
            catch
            end
        end

    end


end
