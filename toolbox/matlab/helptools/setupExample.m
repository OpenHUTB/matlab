function varargout = setupExample(arg,workDir)
% 

%   Copyright 2017-2022 The MathWorks, Inc.

% 从matlab\examples\sl3d\example.xml中解析出该示例的元数据
metadata = findExample(arg);

% Determine workDir
if nargin < 2 || ...
        isempty(workDir) || ...
        (isstring(workDir) && length(workDir) == 1 && strlength(workDir)==0)
    workDir = matlab.internal.examples.getWorkDir(metadata);
else
    workDir = matlab.internal.examples.validateWorkDir(workDir);
end

% Setup workdir.
matlab.internal.examples.setupWorkDir(workDir);

% 主文件：新加入的例子没找到就会去网上下载
matlab.internal.examples.setupMainFile(metadata, workDir);

% Supporting files.
metadata = matlab.internal.examples.setupSupportingFiles(metadata, workDir);

if nargout
    varargout{1} = workDir;
    varargout{2} = metadata;
end
end

