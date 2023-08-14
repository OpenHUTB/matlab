function p = javaclasspath(a,b)
%JAVACLASSPATH Get and set Java class path.
%  The Java class path consists of a static portion and a dynamic portion:     
%  static  - A combination of the following, established at startup:
%              - MATLAB's built-in Java path
%              - the contents of javaclasspath.txt in the startup directory
%              - the contents of javaclasspath.txt in the preferences 
%                directory (see 'prefdir') 
%            The static java path cannot be modified during a MATLAB 
%            session. The static java path offers better java class loading 
%            performance than the dynamic java path. 
%  dynamic - Specified through this function, java classes can 
%            be reloaded using CLEAR JAVA. 
%
%  MATLAB will always search the static path BEFORE the dynamic path.
%  Java classes on the static path should not have dependencies on 
%  classes on the dynamic path, otherwise runtime errors will result. 
%  Whenever the dynamic path is changed, CLEAR JAVA is run.
%
%  JAVACLASSPATH displays the static and dynamic java path.
%
%  JAVACLASSPATH('-dynamic') displays the dynamic java path.
%
%  JAVACLASSPATH('-static') displays the static java path.
%
%  P = JAVACLASSPATH returns the dynamic java path.
%
%  P = JAVACLASSPATH('-static') returns only the static java path.
%
%  P = JAVACLASSPATH('-all') returns both the static and
%  dynamic java path.
%
%  JAVACLASSPATH(P) changes the dynamic java path to P, P is a string or cell array of
%  strings representing path entries. Relative paths are converted to absolute paths.
%
%  JAVACLASSPATH(P1,P2) changes the dynamic java path to the concatenation of the two
%  paths P1 and P2. Input should be a string array, character vector or cell array of
%  character vectors representing path entries. Relative paths are converted to absolute
%  paths.
% 
%  JAVACLASSPATH('-v0') no class loading messages will be displayed (default).
%
%  JAVACLASSPATH('-v1') prints messages when loading files from the dynamic java path.
%
%  Examples:
%
%  javaclasspath('/home/javastuff/')
%
%  javaclasspath({'/home/javastuff/','/home/morestuff/jarfile.jar'})
%
%  javaclasspath('http://domain.com')
%
%  javaclasspath('http://some.domain.com/jarfile.jar')
%
%  See also JAVAADDPATH, JAVARMPATH, JAVA, CLEAR.

% Copyright 2002-2016 The MathWorks, Inc.

% pretty-print
if nargin == 0  

    if nargout == 0
      local_javapath('-print')
    else 
      p = local_javapath('-dynamic');
    end

% javaclasspath(p)
elseif nargin == 1
    
    if ~ischar(a) && ~iscellstr(a) && (~isstring(a) || any(ismissing(a)))
        error(message('MATLAB:javaclasspath:InvalidInput'));
    end
    
    % p = javaclasspath(...)
    if nargout>0
        if isstring(a) && isscalar(a)
            a = char(a);
        end
        if ischar(a) && a(1)=='-' % p = javaclasspath(['-all'|'-static'])
            p = local_javapath(a);
        else
            error(message('MATLAB:javaclasspath:InvalidInput'));
        end
    else
        % javaclasspath('-v0') | javaclasspath('...')
        if ischar(a) || (isstring(a) && isscalar(a))
            a = char(a);
            switch(a)
                case {'-v0', '-v1', '-v2' }
                    local_set_verbose_level(a);
                case '-dynamic'
                    local_javapath(a);
                case '-static'
                    local_javapath(a);
                case '-all'
                    local_javapath('-print');
                otherwise
                    if a(1)=='-'
                        error(message('MATLAB:javaclasspath:InvalidInput'));
                    end
                    a = {a};
                    local_javapath('-setdynamic',a);
            end
        else
            if isstring(a) 
                a = cellstr(a);
            end
            local_javapath('-setdynamic',a);
        end
    end
      
% javaclasspath(a,b)
elseif nargin == 2 
    
    if (~ischar(a) && ~iscellstr(a) && (~isstring(a) || any(ismissing(a)))) || ...
       (~iscell(b) && ~ischar(b) && (~isstring(b) || any(ismissing(b))))
       error(message('MATLAB:javaclasspath:InvalidInput'));
    end

    newpath = local_remove_pair_redundancies(a,b);
     
    % Update new path
    local_javapath('-setdynamic',newpath);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [pathout] = local_javapath(varargin)
% Input args:
% -print, pretty print
% -dynamic, return dynamic java path
% -static, return static java path
% -set, set dynamic java path
    
jloader = com.mathworks.jmi.ClassLoaderManager.getClassLoaderManager;
    
arg1 = varargin{1};

% pretty print static and dynamic java path
if strcmp(arg1,'-print')
    
    if nargout > 0
        error(message('MATLAB:javaclasspath:InvalidInput'));
    end
    
    sp = local_get_static_path;
    local_pretty_print_static(sp);
  
    dp = javaclasspath('-dynamic');
    local_pretty_print_dynamic(dp);
   
% return dynamic java path
elseif strcmp(arg1,'-dynamic')
    jArray = jloader.getClassPath;
    if ~isempty(jArray)
      dynpath = cell(jArray);   
    else
      dynpath = {};
    end
    if nargout == 0
        local_pretty_print_dynamic(dynpath);
    else
        pathout = dynpath;
    end
    
 
% return static java path    
elseif strcmp(arg1,'-static')
    if nargout == 0
        local_pretty_print_static(local_get_static_path);
    else
        pathout = local_get_static_path;
    end
        
% return both static and dynamic java path    
elseif strcmp(arg1,'-all')
    sp = javaclasspath('-static');
    dp = javaclasspath('-dynamic');
    % change to match the shape of javaclasspath('-static')
    pathout = {sp{:},dp{:}}';

% set the dynamic java path    
elseif strcmp(arg1,'-setdynamic')
    pathin = varargin{2};
    pathin = local_validate_dynamic_path(pathin);
   
    % Enable dynamic java using undocumented switches
    jloader.setEnabled(1); 
    com.mathworks.jmi.OpaqueJavaInterface.enableClassReloading(1);
    jloader.setClassPath(pathin);
    
    %Clear/reload Java so that any new classes are picked up.
    clear('javaonly');
else
    error(message('MATLAB:javaclasspath:InvalidInput'));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [newpath] = local_remove_pair_redundancies(pa, pb)        
% Compare two cell arrays and remove any redundancies from input arg cell 
% array string "pa"

casesen = isunix; 

% wrap char arrays into cell arrays
if ischar(pa), pa = {pa};end
if ischar(pb), pb = {pb};end

% remove any redundancies in pa from pb
for i=1:length(pa)
   aa = pa{i};
   j = 1;
   while(j<=length(pb)) %for j=1:length(pb)
      bb = pb{j};
      if ~casesen, aa = lower(aa); end
      if ~casesen, bb = lower(bb); end
      if strcmp(aa,bb)
         pb = {pb{1:j-1},pb{j+1:end}};
      end
      j = j+1;
   end
end

p = {pa{:},pb{:}};

newpath = p;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [dp] = local_validate_dynamic_path(dp)        
% Validate dynamic path for correctness:
%   -Valid file/directories
%   -No duplicate entries within dynamic path
%   -No duplicate entries with static path

% Get a cell array of static path entries 
sp = javaclasspath('-static');

% Extract a cell array of static jar file names without absolute path 
spJars = {};
for n = 1:length(sp)
   spEntry = sp{n};
   jar_file_name = local_extract_jar_file_name(spEntry);
   if ~isempty(jar_file_name)      
       spJars{end+1} = jar_file_name;  %#ok  
   end
end % for

% Check each dynamic path entry for correctness
n = length(dp);
while(n>0)
  flag = false;
  is_url = false;
  
  % Convert to an absolute file path
  dp{n} = javapathutils('-relativetoabsolute',dp{n});
  
    % Candidate dynamic path entry
  pp = dp{n};
  
  % Flag as a URL
  if javapathutils('-isurl',pp)
      is_url = true;
  end
  
  % Remove if invalid
  if ~is_url && ~exist(pp,'file')
    warning(message('MATLAB:javaclasspath:invalidFile', pp));
    flag = true;
  
  % Remove if duplicate
  elseif sum(strcmp(pp,dp))>1
     % Silently ignore.  Don't warn because this is harmless
     % and will do what user expected.
    flag = true;
  
  % Remove if identical path already exists on the static path
  elseif any(strcmp(sp,pp)) 
      warning(message('MATLAB:javaclasspath:jarAlreadySpecified',pp));
      flag = true;
      
  % Throw warning (but do not remove) if entry is to a jar file name that 
  % already exists on the static path even if under a different directory     
  else
      jar_file_name = local_extract_jar_file_name(pp);
      if ~isempty(jar_file_name) && any(strcmp(spJars,jar_file_name))
           warning(message('MATLAB:javaclasspath:jarAlreadySpecified',...
               jar_file_name));
      end
  end
  
  % Remove entry if flagged
  if(flag), dp = {dp{1:n-1},dp{n+1:end}}; end 
  
  % Go to next entry
  n = n-1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function jar_file_name  = local_extract_jar_file_name(fullp)
% Extract jar file name "foo.jar" from path "S:/blah/foo.jar"

jar_file_name = [];
if strncmp(fliplr(fullp),fliplr('.jar'),4)
    fullp = strrep(fullp,'\','/');
    ind = strfind(fullp,'/');
    if ~isempty(ind)
        jar_file_name = fullp(ind(end)+1:end); 
    end
end
      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [p] = local_get_static_path
% get static path as a cell array

jString = java.lang.System.getProperty('java.class.path');
sp = char(jString);
p = strread(sp,'%s','delimiter',pathsep);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function local_pretty_print_path(p)
% input is cell array of strings

ch= strvcat(p); %#ok<VCAT>
tabspace = ones(size(ch,1),1);
tabspace(:) = sprintf('\t');
s = [tabspace, ch];
disp(s)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function local_pretty_print_static(sp)

    % Emulate PATH command format
    fprintf(getString(message('MATLAB:javaclasspath:StaticJavaPath')))
    local_pretty_print_path(sp);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function local_pretty_print_dynamic(dp)
% input is cell array of strings

    fprintf(getString(message('MATLAB:javaclasspath:DynamicJavaPath')))            
    if isempty(dp)
       fprintf('\t\t<empty>\n');
    else
       local_pretty_print_path(dp);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function local_set_verbose_level(pa)
% input is string "-v0", "-v1", or "-v2"
jloader = com.mathworks.jmi.ClassLoaderManager.getClassLoaderManager;

if strcmp(pa,'-v0')
  jloader.setVerbose(0);
elseif strcmp(pa,'-v1')
  jloader.setVerbose(1);
else
  jloader.setVerbose(2);
end

% LocalWords:  javastuff morestuff jarfile setdynamic completenames pb
% LocalWords:  relativetoabsolute
