function swVersion=extractSwVerFromMdlVer(mdlVerStr)





    output=regexp(mdlVerStr,'\D*(?<major>\d*)\D*(?<minor>\d*)\D*(?<rev>\d*).*','names');

    major=str2num(output.major);%#ok<ST2NM>
    minor=str2num(output.minor);%#ok<ST2NM>
    rev=str2num(output.rev);%#ok<ST2NM>

    if~isempty(major)
        swVersion(1)=major;
    else
        swVersion(1)=1;
    end

    if~isempty(minor)
        swVersion(2)=minor;
    else
        swVersion(2)=1;
    end

    if~isempty(rev)
        swVersion(3)=rev;
    else
        swVersion(3)=1;
    end



