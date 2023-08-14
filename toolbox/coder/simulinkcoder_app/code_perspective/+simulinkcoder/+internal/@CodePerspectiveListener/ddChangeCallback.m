function ddChangeCallback(obj,varargin)



    ed=varargin{2};
    [~,edFile,~]=fileparts(ed.ddFile);


    bd=obj.bd;
    mdlH=bd.Handle;
    [~,ddFile,~]=fileparts(get_param(mdlH,'DataDictionary'));


    if strcmp(ddFile,edFile)
        cps=obj.cps;
        cps.reset();
    end


