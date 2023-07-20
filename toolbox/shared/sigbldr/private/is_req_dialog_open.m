function out=is_req_dialog_open(common)



    out=false;
    if isfield(common,'reqUIOpen')
        out=common.reqUIOpen;
    end