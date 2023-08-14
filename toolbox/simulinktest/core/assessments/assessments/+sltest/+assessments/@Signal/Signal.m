


classdef(Sealed)Signal<sltest.assessments.Expression
    properties(SetAccess=immutable)
timeseries
    end

    properties(GetAccess=private,SetAccess=immutable,Hidden)
        id=''
    end

    methods
        function self=Signal(ts)
            if~isa(ts,'timeseries')
                error(message('sltest:assessments:NotTimeseries',mfilename()));
            end

            interp=ts.DataInfo.Interpolation;
            if~isequal(interp,tsdata.interpolation.createLinear())&&~isequal(interp,tsdata.interpolation.createZOH())
                error(message('sltest:assessments:NotLinearOrZohTimeseries',mfilename()));
            end

            self.timeseries=ts;
            self=self.loadobj(self);


            self.internal.setMetadata('originalData',ts);
            if isenum(ts.Data)
                enumDef=sltest.assessments.Expression.getEnumDefinition(ts.Data);
                self.internal.setMetadata('originalEnumType',enumDef);
            end
            self.id=self.internal.uuid;
        end

        function res=children(~)
            res={};
        end

        function ts=getTimeseries(self)
            ts=self.timeseries;
        end
    end

    methods(Access=protected,Hidden)
        function internal=constructInternal(self)
            ts=self.timeseries;
            uuid=self.id;
            interp=ts.DataInfo.Interpolation;
            data=squeeze(ts.Data);
            enumTypeName='';
            if(isenum(data))
                [data,enumTypeName]=sltest.assessments.Expression.castEnumData(data);
            else
                if isstruct(data)
                    data=ts.Data.Values(ts.Data.ValueIndices);
                    if isfield('originalEnumType',self.internal.metadata)
                        enumTypeName=self.internal.metadata.originalEnumType.EnumName;
                    end
                end
            end
            if isequal(interp,tsdata.interpolation.createLinear())
                internal=sltest.assessments.internal.expression.linearVariable(ts.Name,ts.Time,data,uuid);
            elseif isequal(interp,tsdata.interpolation.createZOH())
                internal=sltest.assessments.internal.expression.variable(ts.Name,ts.Time,data,uuid,enumTypeName);
            else
                assert(false);
            end
        end
    end
end
