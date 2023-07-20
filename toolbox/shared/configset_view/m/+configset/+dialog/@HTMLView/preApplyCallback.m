function[out,msg]=preApplyCallback(obj,~)








    out=true;
    msg='';

    c=loc_refresh(obj);%#ok<*NASGU>

    if obj.isSecondSourceNameChanged
        adp=obj.Source;
        csc=adp.Source;

        try
            ref=csc.getRefObject;
        catch me
            out=false;
            msg=me.message;
            return
        end

        [out,msg]=configset.internal.util.applyChangeToDD(ref);
        if csc.UpToDate=="off"

            csc.refresh(true);
        end

        obj.isSecondSourceNameChanged=false;
    end

    function c=loc_refresh(obj)
        obj.inRefresh=true;
        obj.Source.inReset=true;
        c=onCleanup(@()loc_cleanup(obj));

        function loc_cleanup(obj)
            obj.inRefresh=false;
            obj.Source.inReset=false;
