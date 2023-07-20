classdef APIUtils






    methods(Static,Access=public)

        function[viewFactory,driver]=getViewFactoryAndDriver(files)











            import comparisons.internal.util.APIUtils;
            import com.mathworks.comparisons.matlab.MATLABAPIUtils;

            selection=MATLABAPIUtils.createComparisonSelection(...
            files.Left,files.Right...
            );
            viewFactory=MATLABAPIUtils.getMATLABViewFactory(selection);
            driver=APIUtils.createComparisonDriver(viewFactory,selection);
        end

        function driver=createComparisonDriver(...
            viewFactory,...
comparisonSelection...
            )











            import com.mathworks.comparisons.matlab.MATLABAPIUtils;

            data=MATLABAPIUtils.createComparisonData(...
comparisonSelection...
            );
            driver=viewFactory.createComparison(data);
        end

        function comparison=createMATLABView(viewFactory,driver)










            matlabWrapperFunction=str2func(...
            char(viewFactory.getMATLABViewCreator())...
            );
            comparison=feval(matlabWrapperFunction,driver);
        end


        function handleExceptionCallStack(exception)
            import com.mathworks.comparisons.matlab.MATLABAPIUtils;
            if~MATLABAPIUtils.shortenCallStacks()
                exception.rethrow();
            end

            exception=MException(...
            exception.identifier,'%s',exception.message...
            );
            exception.throwAsCaller();
        end

        function name=getSourceName(source)





            import com.mathworks.comparisons.source.ComparisonSourceUtilities;

            name=char(ComparisonSourceUtilities.getName(source));
        end

        function parse(funcName,filename1,filename2)














            import comparisons.internal.util.APIUtilsDecaf.parse
            try
                comparisons.internal.util.APIUtilsDecaf.parse(...
                funcName,filename1,filename2);
            catch exception
                exception.throwAsCaller();
            end
        end

    end

end