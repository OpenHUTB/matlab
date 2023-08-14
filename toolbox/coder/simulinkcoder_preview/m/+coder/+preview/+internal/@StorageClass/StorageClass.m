classdef StorageClass<coder.preview.internal.CodePreviewBase




    properties
EntryType
        SupportMultipleInstance=true
    end
    methods
        function obj=StorageClass(sourceDD,type,name)

            obj@coder.preview.internal.CodePreviewBase(sourceDD,type,name);
        end

        function out=getPreview(obj)

            storageClass=obj.getEntry.StorageClass;
            if isempty(storageClass)||isempty(storageClass.UUID)
                out=obj.getPreviewNotAvailable;
            else
                p=coder.preview.internal.CodePreview(obj.DD,'StorageClass',...
                storageClass.Name);
                if obj.SupportMultipleInstance
                    out=p.getPreview;
                else
                    s=p.getPreview;

                    out.previewStr=s.singleInstance;
                    out.type=obj.EntryType;
                end
            end
        end
    end
end
