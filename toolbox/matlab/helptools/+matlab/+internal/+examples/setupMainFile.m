function setupMainFile(metadata, workDir)
% 打开示例时在{userpath}/Examples中设置主文件，如果本地不存在，就到网上下载

%   Copyright 2020 The MathWorks, Inc.

mainFile = [metadata.main '.' metadata.extension];
src = fullfile(metadata.componentDir, 'main', mainFile);
target = fullfile(workDir, mainFile);
matlab.internal.examples.copyIfMissing(src,target);
end
