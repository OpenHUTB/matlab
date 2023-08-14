classdef LookupTableObject<lutdesigner.data.proxy.LookupTableProxy

    properties(SetAccess=immutable,GetAccess=private)
ObjectSource
    end

    methods
        function this=LookupTableObject(objectSource)
            this.ObjectSource=objectSource;
        end
    end

    methods(Access=protected)
        function dataUsage=listDataUsageImpl(this)
            dataUsage=lutdesigner.data.proxy.DataUsage;
            dataUsage.DataSource=this.ObjectSource;
            dataUsage.UsedAs='/';
        end

        function restrictions=getNumDimsReadRestrictionsImpl(this)
            restrictions=this.ObjectSource.getReadRestrictions();
        end

        function restrictions=getNumDimsWriteRestrictionsImpl(this)
            restrictions=this.ObjectSource.getWriteRestrictions();
        end

        function numDims=getNumDimsImpl(this)
            numDims=numel(this.ObjectSource.read().Breakpoints);
        end

        function setNumDimsImpl(this,numDims)
            luto=this.ObjectSource.read();
            curNumDims=numel(luto.Breakpoints);
            if numDims>curNumDims
                if strcmp(luto.BreakpointsSpecification,'Even spacing')
                    luto.Breakpoints(curNumDims+1:numDims)=repmat(Simulink.lookuptable.Evenspacing,[1,numDims-curNumDims]);
                else
                    luto.Breakpoints(curNumDims+1:numDims)=repmat(Simulink.lookuptable.Breakpoint,[1,numDims-curNumDims]);
                end
            elseif numDims<curNumDims
                luto.Breakpoints(numDims+1:curNumDims)=[];
            end
        end

        function axisProxy=getAxisProxyImpl(this,dimensionIndex)
            luto=this.ObjectSource.read();
            if strcmp(luto.BreakpointsSpecification,'Even spacing')
                axisProxy=lutdesigner.data.proxy.LUTOEvenSpacingObject(this.ObjectSource,dimensionIndex);
            else
                axisProxy=lutdesigner.data.proxy.LUTOBreakpointObject(this.ObjectSource,dimensionIndex);
            end
        end

        function tableProxy=getTableProxyImpl(this)
            tableProxy=lutdesigner.data.proxy.LUTOTableObject(this.ObjectSource);
        end
    end
end
