function activeEditor = getActive
%matlab.desktop.editor.getActive 找到激活（打开）的编辑器文档。
%   EDITOROBJ = matlab.desktop.editor.getActive 
%       返回 Matlab 编辑器中和激活文档相关的文档对象。
%       激活的文档不总是和已保存的文档相关联。
%
%   示例: 确定编辑器中哪个文档是激活的。
%
%      allDocs = matlab.desktop.editor.getAll;
%      if ~isempty(allDocs)
%          activeDoc = matlab.desktop.editor.getActive
%      end
%
%   See also matlab.desktop.editor.Document,
%   matlab.desktop.editor.findOpenDocument, matlab.desktop.editor.getAll,
%   matlab.desktop.editor.openDocument.

assertEditorAvailable;  % matlab\toolbox\matlab\codetools\+matlab\+desktop\+editor\private\assertEditorAvailable.m

activeEditor = matlab.desktop.editor.Document.getActiveEditor;

end

