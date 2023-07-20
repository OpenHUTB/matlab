function h = auto_private(fcnName)
% AUTO_PRIVATE return a function handle to the named private function
% 
% @H=AUTO_PRIVATE('NAME') returns a handle to the named function
% in the private directory.  Note, AUTO_PRIVATE does not insist that
% the function reside in the private directory.

% Copyright 2015-2018 The MathWorks, Inc.
    narginchk(1,1);
    h = str2func(fcnName);
end

    
