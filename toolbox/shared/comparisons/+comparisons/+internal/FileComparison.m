classdef(Abstract,Hidden)FileComparison<...
    comparisons.Comparison&...
    matlab.mixin.CustomDisplay






    properties(Dependent,GetAccess=public)

        Left;

        Right;
    end

    properties(Hidden,Access=protected)
        JavaDriver;
    end

    methods(Hidden,Access=public)

        function obj=FileComparison(driver)
            obj.JavaDriver=driver;
        end

    end

    methods(Access=public)

        function delete(this)
            if~isempty(this.JavaDriver)
                this.JavaDriver.dispose();
            end
        end

        function report=publish(comparison,varargin)%#ok<INUSD,STOUT>
            comparisons.internal.message(...
            'error',...
'comparisons:comparisons:PublishNotSupported'...
            );
        end

        function filter(comparison,filter)%#ok<INUSD>
            comparisons.internal.message(...
            'error',...
'comparisons:comparisons:FilterNotSupported'...
            );
        end

    end

    methods

        function name=get.Left(this)
            import comparisons.internal.util.APIUtils;

            leftSource=this.JavaDriver.getLeftSource();
            name=APIUtils.getSourceName(leftSource);
        end

        function name=get.Right(this)
            import comparisons.internal.util.APIUtils;

            rightSource=this.JavaDriver.getRightSource();
            name=APIUtils.getSourceName(rightSource);
        end

    end

    methods(Sealed,Hidden,Access=protected)

        function s=getFooter(this)
            s=getFooter@matlab.mixin.CustomDisplay(this);
        end

        function displayEmptyObject(this)
            displayEmptyObject@matlab.mixin.CustomDisplay(this);
        end

        function displayNonScalarObject(this)
            displayNonScalarObject@matlab.mixin.CustomDisplay(this);
        end

        function displayScalarHandleToDeletedObject(this)
            displayScalarHandleToDeletedObject@matlab.mixin.CustomDisplay(this);
        end

        function displayScalarObject(this)
            displayScalarObject@matlab.mixin.CustomDisplay(this);
        end

        function header=getHeader(this)
            header=getHeader@matlab.mixin.CustomDisplay(this);
        end

        function propertyGroups=getPropertyGroups(this)
            propertyGroups=getPropertyGroups@matlab.mixin.CustomDisplay(this);
        end
    end

end
