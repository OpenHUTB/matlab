

classdef SupportedDataTypesConstraint<slci.compatibility.Constraint

    properties(Access=protected)
        fSupportedTypes={};
    end

    methods(Access=protected)

        function out=getSupportedTypes(aObj)
            out=aObj.fSupportedTypes;
        end

        function setSupportedTypes(aObj,aSupportedTypes)
            aObj.fSupportedTypes=aSupportedTypes;
        end

    end

    methods(Access=protected)

        function out=getIncompatibilityTextOrObj(aObj,aTextOrObj)
            if aObj.ParentBlock().getSupportsBuses()
                if aObj.ParentBlock().getSupportsEnums()
                    errorCode=['Non',aObj.getEnum(),'BusEnumOption'];
                else
                    errorCode=['Non',aObj.getEnum(),'BusOption'];
                end
            else
                if aObj.ParentBlock().getSupportsEnums()
                    errorCode=['Non',aObj.getEnum(),'EnumOption'];
                else
                    errorCode=['Non',aObj.getEnum()];
                end
            end
            out=getIncompatibilityTextOrObj@slci.compatibility.Constraint(...
            aObj,aTextOrObj,errorCode,...
            aObj.ParentBlock().getName(),...
            aObj.getListOfStrings(aObj.getSupportedTypes,false));
        end
    end

    methods

        function obj=SupportedDataTypesConstraint()
            obj.setEnum('SupportedDataTypes');
            obj.setCompileNeeded(1);
            obj.setFatal(0);
        end

        function errCode=getErrorCode(aObj)
            errCode=[aObj.getEnum(),'ConstraintRecAction'];
        end

        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,varargin)
            status=varargin{1};
            [SubTitle,Information,StatusText,~]=getSpecificMAStrings@slci.compatibility.Constraint(aObj,status);
            supportedTypesStr='';
            if aObj.ParentBlock().getSupportsEnums()
                supportedTypesStr=[supportedTypesStr...
                ,DAStudio.message('Slci:compatibility:SupportedEnumerations'),', '];
            end
            if aObj.ParentBlock().getSupportsBuses()
                supportedTypesStr=[supportedTypesStr...
                ,DAStudio.message('Slci:compatibility:BusesWhoseElementsAreSupportedDatatypes'),', '];
            end
            supportedTypesStr=[supportedTypesStr,aObj.getListOfStrings(aObj.fSupportedTypes,false)];
            supportedTypesStr=strrep(supportedTypesStr,' or',',');
            RecAction=[DAStudio.message(['Slci:compatibility:',aObj.getErrorCode()]),' ',supportedTypesStr];
        end

        function result=supportedType(aObj,dt,width)
            result=false;

            if strcmp(dt,'action')
                result=true;
                return;
            end

            if any(strcmp(dt,aObj.fSupportedTypes))
                result=true;
                return
            end


            if strcmpi(dt,'string')
                result=aObj.ParentBlock().getSupportsString;
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
                    try
                        aObject=slResolve(dt,aObj.ParentBlock.getSID());
                        if isa(aObject,'Simulink.Bus')...
                            &&aObj.ParentBlock().getSupportsBuses()
                            busObject=aObject;
                            for idx=1:numel(busObject.Elements)





                                buselem=busObject.Elements(idx);
                                dim=buselem.Dimensions;
                                if isnumeric(dim)
                                    ws=aObj.ParentModel.getHandle;
                                else
                                    ws=aObj.ParentBlock.getHandle;
                                end
                                [flag,dim]=slci.internal.resolveDim(ws,dim);
                                if~flag
                                    return;
                                end
                                size=prod(dim);
                                if~aObj.supportedType(buselem.DataType,size)
                                    result=false;
                                    return
                                end
                            end
                        elseif isa(aObject,'Simulink.AliasType')
                            if any(strcmp(aObject.BaseType,aObj.fSupportedTypes))
                                result=true;
                                return;
                            end
                        else
                            result=false;
                            return
                        end
                        result=true;
                        return
                    catch
                    end
                end
            end

        end

    end
end


