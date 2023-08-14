function widget=getSampleTimeWidget(stTag,stPrmIndex,stValue,typeTag,typeValue,source,varargin)























    if length(varargin)>2
        methods=varargin{3};
    else
        methods=[];
    end

    if length(varargin)>1
        allowedTypes=varargin{2};
    else
        allowedTypes=28;
    end

    if~isempty(varargin)
        showDialogWidget=varargin{1};
    else
        showDialogWidget=false;
    end



    if slfeature('EnableAdvancedSampleTimeWidget')&&showDialogWidget
        widget=localGetAdvancedSampleTimeWidget(...
        stTag,stPrmIndex,stValue,...
        typeTag,typeValue,...
        source,allowedTypes,methods);
        return
    elseif slfeature('HideSampleTimeWidgetWithDefaultValue')>0&&~showDialogWidget

        widget=localGetSampleTimeWidgetWithHiding(stTag,stPrmIndex,stValue,source,methods);
        return
    else


        widget=localCreateBasicSampleTimeWidget(stTag,stPrmIndex,stValue,source,methods);
        return
    end


