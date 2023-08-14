function addBlockDiagramCallback(h,type,callback)







    if ishandle(h.fcnclass.ModelHandle)&&...
        isempty(rtwprivate('getSourceSubsystemHandle',h.fcnclass.ModelHandle))
        modelObject=get_param(h.fcnclass.ModelHandle,'Object');
        callbackId=[strrep(class(h),'.','_'),'_',type];
        if~modelObject.hasCallback(type,callbackId)

            modelObject.addCallback(type,callbackId,callback);
        end
    end
