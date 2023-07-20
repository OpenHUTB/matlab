function hasDLT = hasDeepLearningToolbox()
% hasDeepLearningToolbox returns true if Deep Learning Toolbox is
% available, and false otherwise.

%   Copyright 2019 The MathWorks, Inc.

hasDLT = builtin('license','test','Neural_Network_Toolbox') && ~isempty(ver('nnet'));

end