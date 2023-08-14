classdef CompoundMatrixParameter<lutdesigner.data.proxy.MatrixParameterProxy

    properties(SetAccess=immutable,GetAccess=private)
MetaInfoSources
    end

    methods
        function this=CompoundMatrixParameter(varargin)
            import lutdesigner.data.source.UnknownDataSource

            p=inputParser;
            addParameter(p,'Min',UnknownDataSource);
            addParameter(p,'Max',UnknownDataSource);
            addParameter(p,'Unit',UnknownDataSource);
            addParameter(p,'FieldName',UnknownDataSource);
            addParameter(p,'Description',UnknownDataSource);
            parse(p,varargin{:});

            this.MetaInfoSources=p.Results;
        end

        function tf=isMetaFieldSpecified(this,metaField)
            restrictions=this.MetaInfoSources.(metaField).getReadRestrictions();
            tf=~any(arrayfun(@(r)strcmp(r.Reason.Identifier,'lutdesigner:data:unspecifiedDataSource'),restrictions));
        end
    end

    methods(Access=protected)
        function dataUsage=listDataUsageImpl(this)
            fields=fieldnames(this.MetaInfoSources);
            dataUsage=repmat(lutdesigner.data.proxy.DataUsage,[numel(fields),1]);
            for i=1:numel(fields)
                dataUsage(i).DataSource=this.MetaInfoSources.(fields{i});
                dataUsage(i).UsedAs=['/',fields{i}];
            end
        end


        function restrictions=getMinReadRestrictionsImpl(this)
            restrictions=this.MetaInfoSources.Min.getReadRestrictions();
        end

        function restrictions=getMinWriteRestrictionsImpl(this)
            restrictions=this.MetaInfoSources.Min.getWriteRestrictions();
        end

        function min=getMinImpl(this)
            min=this.readNumericSource(this.MetaInfoSources.Min);
        end

        function setMinImpl(this,min)
            this.writeNumericSource(this.MetaInfoSources.Min,min);
        end


        function restrictions=getMaxReadRestrictionsImpl(this)
            restrictions=this.MetaInfoSources.Max.getReadRestrictions();
        end

        function restrictions=getMaxWriteRestrictionsImpl(this)
            restrictions=this.MetaInfoSources.Max.getWriteRestrictions();
        end

        function max=getMaxImpl(this)
            max=this.readNumericSource(this.MetaInfoSources.Max);
        end

        function setMaxImpl(this,max)
            this.writeNumericSource(this.MetaInfoSources.Max,max);
        end


        function restrictions=getUnitReadRestrictionsImpl(this)
            restrictions=this.MetaInfoSources.Unit.getReadRestrictions();
        end

        function restrictions=getUnitWriteRestrictionsImpl(this)
            restrictions=this.MetaInfoSources.Unit.getWriteRestrictions();
        end

        function unit=getUnitImpl(this)
            unit=this.MetaInfoSources.Unit.read();
        end

        function setUnitImpl(this,unit)
            this.MetaInfoSources.Unit.write(unit);
        end


        function restrictions=getFieldNameReadRestrictionsImpl(this)
            restrictions=this.MetaInfoSources.FieldName.getReadRestrictions();
        end

        function restrictions=getFieldNameWriteRestrictionsImpl(this)
            restrictions=this.MetaInfoSources.FieldName.getWriteRestrictions();
        end

        function fieldName=getFieldNameImpl(this)
            fieldName=this.MetaInfoSources.FieldName.read();
        end

        function setFieldNameImpl(this,fieldName)
            this.MetaInfoSources.FieldName.write(fieldName);
        end


        function restrictions=getDescriptionReadRestrictionsImpl(this)
            restrictions=this.MetaInfoSources.Description.getReadRestrictions();
        end

        function restrictions=getDescriptionWriteRestrictionsImpl(this)
            restrictions=this.MetaInfoSources.Description.getWriteRestrictions();
        end

        function description=getDescriptionImpl(this)
            description=this.MetaInfoSources.Description.read();
        end

        function setDescriptionImpl(this,description)
            this.MetaInfoSources.Description.write(description);
        end
    end

    methods(Static,Access=protected)
        function value=readNumericSource(dataSource)
            value=dataSource.read();
            if isa(value,'Simulink.Parameter')
                value=value.Value;
            end
        end

        function writeNumericSource(dataSource,value)
            curValue=dataSource.read();
            if isa(curValue,'Simulink.Parameter')
                curValue.Value=value;
                dataSource.write(curValue);
            else
                dataSource.write(value);
            end
        end
    end
end
