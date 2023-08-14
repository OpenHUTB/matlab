classdef JMIExceptionHandler<...
    comparisons.internal.exception.AbstractJavaExceptionHandler




    properties(Constant,Access=private)
        InnerExceptionType='java.lang.Exception';
        JMIExceptionType='com.mathworks.jmi.MatlabException';
    end

    methods(Access=public)

        function obj=JMIExceptionHandler()
            import comparisons.internal.exception.JMIExceptionHandler;

            obj@comparisons.internal.exception.AbstractJavaExceptionHandler(...
            JMIExceptionHandler.InnerExceptionType...
            );
        end

        function bool=canHandle(this,exception)
            bool=this.canHandle@comparisons.internal.exception...
            .AbstractJavaExceptionHandler(exception);
            bool=bool&&this.containsJMIException(exception);
        end

        function result=handleException(~,exception)%#ok<STOUT>
            jmiException=exception.ExceptionObject.getCause();
            mException=MException(...
            'comparisons:comparisons:MATLABException',...
            '%s',char(jmiException.getLocalizedMessage())...
            );
            mException=mException.addCause(exception);
            throw(mException);
        end

    end

    methods(Access=private)

        function bool=containsJMIException(this,exception)
            jException=exception.ExceptionObject.getCause();
            bool=isa(jException,this.JMIExceptionType);
        end

    end

end