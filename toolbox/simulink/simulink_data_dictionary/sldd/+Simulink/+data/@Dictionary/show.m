%SHOW Show data dictionary in Model Explorer
%
%   SHOW(dictionaryObj) opens the Model Explorer window and displays the
%   data dictionary represented by dictionaryObj as the selected tree node
%   in the Model Hierarchy pane. 
% 
%   SHOW(dictionaryObj, openModelExplorer) adds the data dictionary
%   represented by dictionaryObj as a tree node in the Model Hierarchy pane
%   of the Model Explorer and opens the Model Explorer window if
%   openModelExplorer is specified as true. If openModelExplorer is
%   specified as false, this function adds the target dictionary to the
%   model hierarchy but does not automatically open the Model Explorer
%   window.
%
%   The target dictionary remains a tree node in the Model Hierarchy pane
%   of the Model Explorer until the hide function is invoked.
%
%   See also HIDE, SIMULINK.DATA.DICTIONARY

% Copyright 2014 The MathWorks, Inc.
