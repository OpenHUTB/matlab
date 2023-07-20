function cb_DataTypeChanged(varargin)




    Simulink.DataTypePrmWidget.callbackDataTypeWidget(varargin{:});
    Simulink.signaleditorblock.cb_signalPropertiesChanged(varargin{2});

end