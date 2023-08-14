function pcode(varargin)
%PCODE  创建对代码内容进行了模糊处理的可执行文件。
%   PCODE F1 F2... makes content-obscured versions of F1, F2...
%
%   The arguments F1, F2... must describe MATLAB functions or files
%   containing MATLAB code.
%
%   If the flag -INPLACE is used, the result is placed in the same
%   directory in which the corresponding file was found.
%   Otherwise, the result is placed in the current directory.  Any
%   existing results will be overwritten.  Needed private and class
%   directories will be created in the current directory if they do
%   not already exist.
%
%   Once created, a pcoded file takes precedence over the corresponding
%   .m file for execution, even if the .m file is subsequently changed.
%   Each created pcoded file has the suffix .p.
%
%   An argument that has no file extension and is not a directory must
%   be a function found on the MATLAB path or in the current directory.
%   The found file is used for input.
%
%   If ISDIR(F) is true for an argument F and neither '..' nor '*'
%   appears in F, pcoded files are created for all MATLAB code files in F
%   (but not in its subdirectories).
%
%   The file part F of an argument of the form DIR/F (where DIR/ might
%   be absent) can contain wildcards '*'.  The wildcards are expanded.
%   Files with extensions other than  '.m', '.M' or '.p' are ignored.
%   The '.p' extension is a special case, indicating either '.m' or '.M'.
%

%   Copyright 1984-2022 The MathWorks, Inc.


% FEATURES
%
%   It is no longer possible to make old-style P-files (R2008a and later).
%
%   Flags other than -inplace will get a generally worded error message.
%
%   In general an argument that cannot be processed will be warned and
%   skipped in contrast to causing an error.
%

% HOW PCODE.M works
%
%   The general approach is to reduce each complex general argument to a
%   standard form, check the validity of the input and then pass the
%   now-standardized args to the undocumented builtin _pwrite that does
%   the heavy lifting.
%
% PROGRAM PCODE.M STRUCTURE
%
% The entry is pcode(...).
%   1. arguments are processed and flags are checked
%   2. arguments are standardized, ending with .m or .M
%   3. each argument is an entry to the local function pcodefile(...)
%   4. insure code file(s) exist
%   5. if there is no flag -inplace, insure private, + and @ directories
%      are created to hold the new pcoded files.
%   6. call undocumented builtin _mcheck(fullpath2m) to insure input
%      can compile.
%   7. call undocumented builtin _pwrite(fullpath2m, fullpath2p)
%
%   The debugging PTRACE facilty exists but is turned off.
% -------------------------------------------------------------------
    if nargin > 0
        [varargin{:}] = convertStringsToChars(varargin{:});
    end

    PTRACE('PTRACE 0: enter pcode, nargin=%d  pwd=%s\n', nargin, pwd);

    % ---Make a pass over the input arguments, record and remove flags.---

    r2022a = false;     % Was R2022a file format flag supplied?
    r2007b = false;     % Was R2007b file format flag supplied?
    inplace = false;    % Put F.p alongside source file (default: put in pwd)
    nocheck = false;    % Skip _mcheck (default: _mcheck before P-coding)
    nodebug = false;    % Disable source matching (R2022a file format only)

    for i = nargin:-1:1                             % backwards so delete works

        if ~ischar(varargin{i})       ...
                ||  numel(varargin{i})  == 0  ...
                ||  size(varargin{i},1) ~= 1  ...
                ||  ndims(varargin{i})  ~= 2
            error(message('MATLAB:pcode:ArgMustBeString'));
        end
        % the argument is now known to be a string

        % check, record, and remove flags from arg list
        if strncmp(varargin{i},'-',1)                 % it's a flag
            if strcmpi(varargin{i},'-R2022a')
                r2022a = true;
            elseif strcmpi(varargin{i},'-R2007b')
                r2007b = true;
            elseif strcmpi(varargin{i},'-inplace')
                inplace = true;                           % put F.P where F.M is
            elseif strcmpi(varargin{i},'-nocheck')
                nocheck = true;    % don't load the file first, just P-code it.
            elseif strcmpi(varargin{i},'-nodebug')
                nodebug = true;
            else
                error(message('MATLAB:pcode:UnknownFlag', varargin{ i }));
            end
            varargin(i) = [];                           % Remove flag from input list
        end
    end
    % check if user provided a valid combination of flags
    if r2022a && r2007b
        error(message('MATLAB:pcode:IncompatibleFlags'));
    end
    if nodebug && ~r2022a
        error(message('MATLAB:pcode:R2022aRequired'));
    end
    % remaining arguments must be function, file or dir descriptions

    PTRACE('PTRACE 1: numel(varargin)=%d  inplace=%d  nocheck=%d\n', ...
           numel(varargin), inplace, nocheck);

    % --------------- 一次处理一个参数 --------------------
    for i=1:numel(varargin)

        arg = varargin{i};                            % a raw non-flag input

        % ------------ check and transform argument ---------------
        baddots = strfind(arg, '..');                 % leads to trouble
        badqmark = strfind(arg, '?');                 % needed for marker
        if ~isempty(baddots) || ~isempty(badqmark)
            warning(message('MATLAB:pcode:BadPath', arg));
            continue;
        end
        PTRACE('PTRACE 2: i=%d  arg=%s\n', i, arg);

        % using ? as a marker; whole directory DIR becomes DIR/*.?
        if isfolder(arg)                          % convert dir to files
            if isfile([arg, '.m']) ...
                    || isfile([arg, '.M'])
                warning(message('MATLAB:pcode:Ambiguous', arg));
            end
            arg = fullfile(arg, '*.?');                 % ready to expand
        end
        PTRACE('PTRACE 3: i=%d  arg=%s\n', i, arg);

        % a function name: which looks for it on path
        [pn, fn, en] = fileparts(arg);                % arg = pn/fn.en
        if ~isempty(fn)                               % there is a file name
            if isempty(en) || strcmpi(en, '.p')         % no .M extension
                origName = which(fullfile(pn, [fn '.m']));
                if ~isempty(origName)
                    arg = origName;
                else
                    arg = fullfile(pn, [fn '.?']);          % use dir later
                end
            else                                        % try input extension
                fullarg = which(arg);                     % look on path
                if ~isempty(fullarg)
                    arg = fullarg;                          % abs path to file
                end
            end
        end
        PTRACE('PTRACE 4: i=%d  arg=%s\n', i, arg);

        %  no path, make one
        pn = fileparts(arg);                          % get path
        if isempty(pn)
            arg = fullfile(pwd, arg);                   % pn becomes full path
        end
        PTRACE('PTRACE 5: i=%d  arg=%s\n', i, arg);

        % warn and skip if path is invalid
        [pn, fn, en] = fileparts(arg);                % arg = pn/fn.en
        if ~isfolder(pn)
            warning(message('MATLAB:pcode:NotPath', varargin{ i }));
            continue
        end
        PTRACE('PTRACE 6: i=%d pn=%s  fn=%s  en=%s\n', i, pn, fn, en);

        % make absolute path from relative path if necessary
        if isempty(which(arg))
            [pn, fn, en] = fileparts(arg);                % arg = pn/fn.en
            ap = fullfile(pwd, pn, '');                   % see if pwd is valid prefix
            if isfolder(ap)                           % pn was relative
                arg = fullfile(ap, [fn en]);                % arg now absolute
            end
            PTRACE('PTRACE 7: i=%d arg=%s\n', i, arg);

            % ensure there is a file name (it may have wildcards)
            [pn, fn, en] = fileparts(arg);                % arg = pn/fn.en
            if isempty(fn)
                warning(message('MATLAB:pcode:NotFileName', varargin{ i }));
                continue;                                   % skip this entry
            end
        end

        % discard .p extension -- let wildcards find .m and .M
        if strcmpi(en, '.p') || strcmp(en, '.*')      % often from DEPENDS.pcode
            en = '.?';                                  % pick up .m and .M
        elseif ~strcmpi(en, '.m') && ~strcmp(en, '.?')
            warning(message('MATLAB:pcode:FileUnsupported', varargin{ i }));
            continue;
        end
        arg = fullfile(pn, [fn en]);                  % reconstitute arg
        PTRACE('PTRACE 8: i=%d arg=%s\n', i, arg);

        %----------------- prepare individual files-----------------

        % wild card expansion
        [pn, fn, en] = fileparts(arg);                % arg = pn/fn.en
        if strcmp(en, '.?')
            fm = dir(fullfile(pn, [fn '.m']));
            fM = dir(fullfile(pn, [fn '.M']));
            files = [fm; fM];
        else
            files = dir(arg);
        end
        PTRACE('PTRACE 9: i=%d numel(files)=%d\n', i, numel(files));

        if isempty(files)
            warning(message('MATLAB:pcode:FileNotFound', varargin{ i }));
            continue;
        end

        for j = 1:numel(files)
            fname = files(j).name;                      % local file name
            [~, ~, en] = fileparts(fname);              % en is found extension
            if strcmpi(en, '.m')                        % check for .m or .M
                pcodefile(pn, fname, inplace, r2022a, nocheck, nodebug);
            end                                         % discard other files
        end

    end  % end loop on varargin{}

    rehash % Force MATLAB to see any newly generated or regenerated pcoded files.
end    % end pcode


% ---- the workhorse ----
function pcodefile(pth, fn, inplace, r2022a, nocheck, nodebug)
    PTRACE('PTRACE 10: pth=%s  fn=%s  inplace=%d  r2022a=%d  nocheck=%d  nodebug=%d\n', ...
           pth, fn, inplace, r2022a, nocheck, nodebug);

    origName = fullfile(pth, fn);
    if inplace
        pname = [origName(1:end-2) '.p'];               % .p ext
    else
        npth = pcodedirs(pth);                        % set up dirs in pwd
        pname = fullfile(npth, [fn(1:end-2) '.p']);      % dot-p target
        PTRACE('PTRACE 11: codefile=%s  pf=%s\n', origName, pname);
    end


    if ~nocheck
        [~,~,ext] = fileparts(origName);
        assert(strcmpi(ext,'.m'), 'Calling _mcheck on %s is not supported.' ...
               ,fn);


        builtin('_mcheck', origName);               % detect compile errors
    end

    if r2022a
        if nodebug
            builtin('_pwrite2', '-nodebug', origName, pname);
        else
            builtin('_pwrite2', origName, pname);
        end
    else
        builtin('_pwrite', origName, pname);
    end

end   % end pcodefile

%-------- mirror +,@ and private dirs in pwd -----------------
%{

  private, + and @ directories are implicitly on the path.  Ensure that the
  implicit directories from the source path are appended to the parent of
  the implicit directories in the destination path.

%}

function destinationDir = pcodedirs(sourceDir)
    destinationDir = pwd;
    PTRACE('PTRACE 12: dirs sourceDir=%s destinationDir=%s\n', sourceDir, destinationDir);

    % strip off all implicit dirs from the target dir
    destinationDir = matlab.internal.language.introspective.separateImplicitDirs(destinationDir);

    % get the implicit dirs from the source dir
    [~, sourceImplicitDirs] = matlab.internal.language.introspective.separateImplicitDirs(sourceDir);

    if ~isempty(sourceImplicitDirs)
        % append the implicit directories from the source dir to the
        % parent dir of the implicit directories from the destination
        destinationDir = fullfile(destinationDir, sourceImplicitDirs);
        cmkdir(destinationDir);
    end
end

% make directory if it does not already exist
function cmkdir(pth)
    if ~isfolder(pth)
        mkdir(pth);
    end
end   % end cmkdir

function PTRACE(f, varargin)
%   fprintf(f, varargin{:});              % comment this line for normal use
end
