% matlab.desktop.editor Summary of Editor Document functionality
% 以编程方式访问MATLAB编辑器 以打开、更改、保存或关闭文档。
%
% MATLAB Version 9.13 (R2022b) 13-May-2022 
%
% 在编辑器中打开所有文件:
%   isEditorAvailable     - 验证编辑器可用。
%   getAll                - 识别所有编辑器打开的文档。
%
% 在编辑器中打开单个文档:
%   getActive             - 查找激活的编辑器文档。
%   getActiveFilename     - 查找激活文档的文件名。
%   findOpenDocument      - 为打开的文档创建文档对象。
%   isOpen                - Determine if specified file is open in Editor.
%
% 打开一个现有文档或创建一个新文档:
%   newDocument           - Create Document in Editor. 
%   openDocument          - Open file in Editor.
%   openAndGoToFunction   - Open MATLAB file and highlight specified function.
%   openAndGoToLine       - Open file and highlight specified line.
%
% 处理编辑器中的文本:
%   indexToPositionInLine - Convert text array index to position within line.
%   positionInLineToIndex - Convert position within line to text array index.
%   linesToText           - Convert cell array of text lines to character array.
%   textToLines           - Convert character array into cell array of text lines.

%   Copyright 2010-2022 The MathWorks, Inc. 
