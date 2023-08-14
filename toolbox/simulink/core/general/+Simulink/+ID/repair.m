function out=repair(model,varargin)




    load_system(model);
    sidSpace=get_param(model,'SIDSpace');
    out=sidSpace.repair;
