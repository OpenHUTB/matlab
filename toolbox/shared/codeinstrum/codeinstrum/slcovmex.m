function varargout = slcovmex(varargin)
%SLCOVMEX Compile level 2 C/C++ MEX S-Function to work with model coverage
%   SLCOVMEX compiles and links level 2 C/C++ MEX S-Function source files
%   to work with model coverage. 
%
%   The general syntax of the SLCOVMEX command is:
%       SLCOVMEX [options ...] file [files ...]
%
%   SLCOVMEX accepts the same options as MEX. In addition, it accepts 
%   options specific to instrumentation of the level 2 C/C++ S-Function 
%   for model coverage:
%      -idir <dirname>
%           Ignore the coverage of all the files inside the specified
%           folder <dirname> (the option can be specified multiple times).
%           The folder <dirname> can be absolute or a relative path. Use 
%           the syntax <dirname>/* for excluding all the sub-folders.
%       -ifile <filename>
%           Ignore the coverage of the file <filename> and all the functions
%           inside the specified file (the option can be specified multiple
%           times). The file <filename> can be absolute or a relative path.
%       -ifcn <funname>
%           Ignore the coverage of the function <funname> (the option can  
%           be specified multiple times). Use {<filename>}<funname> for only 
%           excluding the function <funname> defined in the file <filename>.
%       -sldv
%           Enable support for Design Verifier.
%
%   If the S-Function compilation requires multiple MEX commands invocation
%   then all MEX options must be passed as a cell array of strings:
%       % Original MEX commands
%       MEX -c file1.c
%       MEX -c file2.c
%       MEX file1.o file2.o -output sfcnOutput
%
%       % MEX commands passed to SLCOVMEX
%       SLCOVMEX({'-c', 'file1.c'}, {'-c', 'file2.c'}, ...
%          {'file1.o', 'file2.o', '-output', 'sfcnOutput'})
%
%   See also MEX

%   Copyright 2013-2014 The MathWorks, Inc.

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

try
    [varargout{1:nargout}] = feval('slcovmexImpl', varargin{1:nargin});
catch Me
    throw(Me);
end
