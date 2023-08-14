function r=isMLFB(h)


    try
        sfId=sfprivate('block2chart',h);
        r=sfId>0;
    catch
        r=false;
    end
end
