






function out=getReleaseName(this,versionString)






    out='';


    majorRelease=regexp(versionString,'\((?<release>\w*)\)','match');
    if length(majorRelease)==1
        out=majorRelease{1};
    end
end
