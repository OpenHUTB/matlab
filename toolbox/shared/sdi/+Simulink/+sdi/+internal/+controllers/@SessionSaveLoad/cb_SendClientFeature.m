function cb_SendClientFeature(this,varargin)
    message.publish(Simulink.sdi.internal.controllers.SessionSaveLoad.ClientFeatureCtrlChannel,this.ClientFeatureCtrl);
end