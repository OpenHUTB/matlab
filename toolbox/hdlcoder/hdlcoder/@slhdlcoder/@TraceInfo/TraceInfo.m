function h=TraceInfo(model,varargin)





    if ishandle(model)
        model=getfullname(model);
    else
        load_system(model);
    end

    h=slhdlcoder.TraceInfo;
    h.Model=model;
    h.Target='hdl';
    h.HelpMethod='helpview([docroot ''/toolbox/hdlcoder/ug/hdlcoder_ug.map''], ''hdl_codegen_report'')';



    if nargin>1
        h.setBuildDir(varargin{1});
    end



    h.CheckTimeStampOneFileOnly=true;


    set_param(h.Model,'HDLTraceInfo',h);
