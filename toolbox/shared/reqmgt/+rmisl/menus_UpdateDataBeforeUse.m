function varargout=menus_UpdateDataBeforeUse(varargin)

    if nargin<1...
        ||isa(varargin{1},'SLM3I.CallbackInfo')...
        ||isa(varargin{1},'DAStudio.CallbackInfo')...
        ||isstruct(varargin{1})

        schema=DAStudio.ActionSchema;
        schema.label=getString(message('Slvnv:rmisl:menus_rmi_tools:UpdateDataBeforeUseMenu'));
        schema.tag='Simulink:UpdateDataBeforeUseMenu';
        schema.callback=@UpdateDataBeforeUse_callback;
        schema.autoDisableWhen='Busy';
        varargout{1}=schema;
    else

        modelH=varargin{1};
        varargout{1}=~rmiut.isBuiltinNoRmi(modelH)...
        &&~rmidata.storageModeCache('get',modelH)&&rmisl.modelHasEmbeddedReqInfo(modelH);
    end
end

function UpdateDataBeforeUse_callback(callbackInfo)
    modelH=callbackInfo.model.Handle;
    rmidata.updateEmbeddedData(modelH);
end

