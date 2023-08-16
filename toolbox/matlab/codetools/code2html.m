function htmlOut = code2html(codeIn)
%CODE2HTML  为Matlab代码在HTML中显示做准备
%   htmlOut = CODE2HTML(codeIn)
%   出于显示目的进行以下替换
%      <     &lt;   less than
%      >     &gt;   greater than
%      &     &amp;  ampersand 与符号

% Copyright 1984-2003 The MathWorks, Inc.

htmlPartial = codeIn;
% 重要的是，在该列表中，与符号&首先运行，否则（不成立）随后的代替物（包含&）将中断
htmlPartial = strrep(htmlPartial,'&','&amp;');
htmlPartial = strrep(htmlPartial,'<','&lt;');
htmlPartial = strrep(htmlPartial,'>','&gt;');
htmlOut = htmlPartial;