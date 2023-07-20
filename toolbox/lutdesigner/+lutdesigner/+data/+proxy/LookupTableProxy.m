classdef LookupTableProxy<lutdesigner.data.proxy.DataProxy




    properties(Dependent)
NumDims
    end

    methods
        function restrictions=getNumDimsReadRestrictions(this)
            restrictions=getNumDimsReadRestrictionsImpl(this);
            restrictions=restrictions(:);
        end

        function restrictions=getNumDimsWriteRestrictions(this)
            restrictions=getNumDimsWriteRestrictionsImpl(this);
            restrictions=restrictions(:);
        end

        function numDims=get.NumDims(this)
            restrictions=this.getNumDimsReadRestrictions();
            if~isempty(restrictions)
                error(restrictions(end).Reason);
            end
            numDims=getNumDimsImpl(this);
        end

        function set.NumDims(this,numDims)
            restrictions=this.getNumDimsWriteRestrictions();
            if~isempty(restrictions)
                error(restrictions(end).Reason);
            end
            setNumDimsImpl(this,numDims);
        end

        function axisProxy=getAxisProxy(this,dimensionIndex)
            axisProxy=getAxisProxyImpl(this,dimensionIndex);
        end

        function tableProxy=getTableProxy(this)
            tableProxy=getTableProxyImpl(this);
        end
    end

    methods(Abstract,Access=protected)
        restrictions=getNumDimsReadRestrictionsImpl(this);

        restrictions=getNumDimsWriteRestrictionsImpl(this);

        numDims=getNumDimsImpl(this);

        setNumDimsImpl(this,numDims);

        bpProxy=getAxisProxyImpl(this,dimensionIndex);

        tableProxy=getTableProxyImpl(this);
    end
end
