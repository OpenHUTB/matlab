function h=TraceInfo(model,varargin)




    if ishandle(model)
        model=getfullname(model);
    else
        load_system(model);
    end

    h=RTW.TraceInfo;
    h.Model=model;
    h.Target='rtw';


    binfo=RTW.getBuildDir(h.Model);


    h.RelativeBuildDir=binfo.RelativeBuildDir;
    h.ModelRefRelativeBuildDir=binfo.ModelRefRelativeBuildDir;

    if nargin>1
        h.setBuildDir(varargin{1});
    end


    set_param(h.Model,'RTWTraceInfo',h);

