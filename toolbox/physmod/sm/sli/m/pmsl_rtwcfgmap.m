function map=pmsl_rtwcfgmap





    map=containers.Map(...
    {pm_message('sm:sli:BlockType')},...
    {fullfile(matlabroot,'toolbox','physmod','sm','ssci','m')});
end