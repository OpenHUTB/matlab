function obj=loadobj(var)




    obj=Simulink.sdi.DatasetRef(var.RunID,var.Domain,var.FileLocation);
end
