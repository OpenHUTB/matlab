function has=hasEmbeddedCoder







    has=~isempty(which(fullfile(matlabroot,'toolbox','coder','embeddedcoder','Contents.m')));

end
