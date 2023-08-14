function logException(exception)





    mExceptionAdapter=createAdapter(exception);
    addCauses(mExceptionAdapter,exception);

    mExceptionAdapter.logMException();
end

function addCauses(mExceptionAdapter,exception)
    causes=exception.cause();

    if isempty(causes)
        return
    end

    for i=1:length(causes)
        cause=causes{i};
        causeAdapter=createAdapter(cause);
        addCauses(causeAdapter,cause);
        mExceptionAdapter.addCause(causeAdapter);
    end
end

function mExceptionAdapter=createAdapter(exception)
    import com.mathworks.toolbox.slproject.project.matlab.api.exception.MExceptionAdapter;
    mExceptionAdapter=MExceptionAdapter(exception.identifier,exception.message,exception.stack);
end