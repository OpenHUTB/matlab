classdef(Abstract)ReceiverSenderService<coder.preview.internal.ServiceInterface




    methods
        function obj=ReceiverSenderService(sourceDD,type,name)

            obj@coder.preview.internal.ServiceInterface(sourceDD,type,name);
        end

        function out=getPreview(obj)

            if obj.Entry.DataCommunicationMethod=="DirectAccess"

                if~isempty(obj.Entry.StorageClass)
                    p=coder.preview.internal.CodePreview(obj.DD,...
                    'StorageClass',obj.Entry.StorageClass.Name);
                    out=p.getPreview;
                else

                    out=obj.getPreviewNotAvailable;
                end
            else
                out=obj.getPreview@coder.preview.internal.ServiceInterface;
            end
        end
    end
end
