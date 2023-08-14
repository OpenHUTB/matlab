function fixblkinhdllib(this,blkh)%#ok<INUSL>








    if~isempty(strfind(hdlgetblocklibpath(blkh),'dspobslib'))
        delete(blkh);
    else
        set_param(blkh,'RateOptions','Allow multirate processing');
    end


