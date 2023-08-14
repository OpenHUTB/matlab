%Simulink.data.dictionary.closeAll   Close all open Simulink data
%dictionaries.
%   Simulink.data.dictionary.closeAll closes all open dictionaries that
%   have the specified name, or all open dictionaries if no name is
%   specified.
%
%   By default, Simulink.data.dictionary.closeAll issues an error if the
%   target dictionaries have unsaved changes. You can optionally save or
%   discard the unsaved changes for all of the target dictionaries.
%      '-discard'  Silently discard changes and then close dictionaries
%      '-save'     Silently save changes and then close dictionaries
%
%   Examples:
%
%     1. Close all open dictionaries. Issue an error if the dictionaries
%        have unsaved changes.
%
%          Simulink.data.dictionary.closeAll
%
%     2. Discard changes and close all open dictionaries.
%
%          Simulink.data.dictionary.closeAll('-discard')
%
%     3. Save changes and close all open dictionaries named 'mydd.sldd'.
%
%          Simulink.data.dictionary.closeAll('mydd.sldd', '-save')
%
%   See also SIMULINK.DATA.DICTIONARY,
%   SIMULINK.DATA.DICTIONARY.GETOPENDICTIONARYPATHS

% Copyright 2015 The MathWorks, Inc. Built-in function.
