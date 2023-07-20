function h = sharedauto_private(fcnName)
% SHAREDAUTO_PRIVATE return a function handle to the named private function
% 
% @H=SHAREDAUTO_PRIVATE('NAME') returns a handle to the named function
% in the private directory.  Note, SHAREDAUTO_PRIVATE does not insist that
% the function reside in the private directory.

%   Copyright 2018 The MathWorks, Inc.
    narginchk(1,1);
    h = str2func(fcnName);
end

    
