function pref=getBlockSupportPref()
    pref=[];
    if ispref('sltbledit','blockconfiglist')==1
        pref=getpref('sltbledit','blockconfiglist');
    end
end
