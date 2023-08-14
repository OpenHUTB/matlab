function out=isInBat()



    if(ispc)
        user=getenv('USERNAME');
    else
        user=getenv('USER');
    end
    inbat=strcmp(user,'batserve');
    out=inbat||is_inside_sbruntests;


    function inside_sbruntests=is_inside_sbruntests()

        inside_sbruntests=~isempty(getenv('SBRUNTESTS_ACTIVE'));
