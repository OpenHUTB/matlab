classdef StructField<lutdesigner.data.source.DataSource

    properties(SetAccess=immutable)
StructSource
FieldPathParts
    end

    methods
        function this=StructField(structSource,fieldPathParts)
            this=this@lutdesigner.data.source.DataSource(...
            structSource.SourceType,...
            structSource.Source,...
            [structSource.Name,'.',strjoin(fieldPathParts,'.')]);
            this.StructSource=structSource;
            this.FieldPathParts=fieldPathParts;
        end

        function lock(this,userTag)
            assert(~this.StructSource.isPeerLocked(),message('lutdesigner:data:invalidLock'));
            lock@lutdesigner.data.source.DataSource(this,userTag);
        end

        function unlock(this)
            assert(~this.StructSource.isPeerLocked(),message('lutdesigner:data:invalidUnlock'));
            unlock@lutdesigner.data.source.DataSource(this);
        end
    end

    methods(Access=protected)
        function restrictions=getReadRestrictionsImpl(this)
            restrictions=this.StructSource.getReadRestrictionsImpl();
        end

        function restrictions=getWriteRestrictionsImpl(this)
            import lutdesigner.data.restriction.WriteRestriction
            restrictions=this.StructSource.getWriteRestrictionsImpl();
            if strcmp(this.StructSource.SourceType,'dialog')
                restrictions=[
                restrictions(:)
                WriteRestriction('lutdesigner:data:rootStructSpecifiedAsExpression');
                ];
            end
        end

        function data=readImpl(this)
            s=this.StructSource.readImpl();
            data=getfield(s,this.FieldPathParts{:});
        end

        function writeImpl(this,data)
            s=this.StructSource.readImpl();
            s=setfield(s,this.FieldPathParts{:},data);
            this.StructSource.writeImpl(s);
        end
    end
end
