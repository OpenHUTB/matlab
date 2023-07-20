function self=autosave(varargin)





    self=Simulink.autosave;
    self.files={};
    self.filestate=[];
    self.keeporiginals=true;
    self.filedates={};
    self.autodates={};
    self.windowopen=false;
end
