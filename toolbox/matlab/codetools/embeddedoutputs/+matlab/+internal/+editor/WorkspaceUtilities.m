classdef WorkspaceUtilities

    methods(Static)

        function serializedSource=serializeArray(source)
            originalState=warning;
            warning('off','MATLAB:Java:ConvertFromOpaque')
            serializedSource=getByteStreamFromArray(source);
            warning(originalState);
        end

        function deserializedSource=deserializeArray(serializedSource)
            originalState=warning;
            warning('off','MATLAB:class:LoadInvalidDefaultElement')
            warning('off','MATLAB:load:classErrorNoCtor')
            deserializedSource=getArrayFromByteStream(serializedSource);
            warning(originalState);
        end

    end
end

