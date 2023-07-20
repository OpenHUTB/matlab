function abspath=makeAbsolutePath(inpath)

















    if(~isempty(regexp(inpath,'^\.|^\w[^:]','once')))
        abspath=fullfile(pwd,inpath);
    else
        abspath=inpath;
    end

end
