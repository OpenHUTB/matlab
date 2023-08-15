function result = isEditorAvailable
%matlab.desktop.editor.isEditorAvailable 如果仿真平台有Java支持则返回true。
%   STATUS = matlab.desktop.editor.isEditorAvailable returns logical TRUE
%   if MATLAB is running with sufficient Java support for the MATLAB
%   Editor. To use functions in the matlab.desktop.editor package,
%   matlab.desktop.editor.isEditorAvailable must return TRUE.
%
%   Example: Check matlab.desktop.editor.isEditorAvailable before opening
%   an Editor Document.
%
%      if (matlab.desktop.editor.isEditorAvailable)
%          fftPath = which('fft.m');
%          matlab.desktop.editor.openDocument(fftPath);
%      end

%   Copyright 2010-2021 The MathWorks, Inc.

result = usejava('swing') || matlab.desktop.editor.internal.useJavaScriptBackEnd;
end