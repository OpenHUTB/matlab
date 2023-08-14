function removeBlockDiagramCallback(h,type)




    if ishandle(h.fcnclass.ModelHandle)
        modelObject=get_param(h.fcnclass.ModelHandle,'Object');
        callbackId=[strrep(class(h),'.','_'),'_',type];
        if modelObject.hasCallback(type,callbackId)
            modelObject.removeCallback(type,callbackId);
        end
    end
