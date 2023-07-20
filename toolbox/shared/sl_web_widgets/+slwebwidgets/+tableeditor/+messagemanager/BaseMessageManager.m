classdef BaseMessageManager<handle&matlab.mixin.Heterogeneous




    methods(Abstract)

        isSupported(obj,signalID);
        constructMessage(obj);

    end


    methods


        function fiDataObj=makeFiDataTableStruct(~,idealSignalValue,fiSignalValue,errorMetaData)

            fiDataObj=slwebwidgets.tableeditor.messagemanager.MessageManager.makeFiDataTableStruct(idealSignalValue,fiSignalValue,errorMetaData);

        end
    end
end

