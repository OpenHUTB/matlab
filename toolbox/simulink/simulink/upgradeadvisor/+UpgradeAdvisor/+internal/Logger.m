classdef Logger<handle




    methods(Abstract)

        initialize(obj)

        showReport(obj)

        close(obj)

        addFailMessage(obj,message)

        addPassMessage(obj,message)

        addMessage(obj,message)

        addFixedMessage(obj,message)

        addUnfixedMessage(obj,message)

        addSkippedCheckMessage(obj,message)

        addFixAvailableMessage(obj,message)

        setCurrentModel(obj,model)

    end

end

