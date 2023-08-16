function varargout = checkcode( varargin )
%CHECKCODE 检查MATLAB代码文件中可能存在的问题
%   CHECKCODE(FILENAME) 显示文件名FILENAME对应的代码分析信息
%   FILENAME can be a character vector, string array, or cell array of character vectors.
%   If FILENAME is a nonscalar string array or a cell array of character vectors,
%   MATLAB displays information for each file.
%
%   CHECKCODE(FILENAME1, FILENAME2, FILENAME3,...) displays information about each
%   FILENAME.
%
%   You cannot combine cell arrays with string arrays or character arrays.
%
%   Additional input arguments can be string scalars or character vectors.
%
%   INFO = CHECKCODE(...,'-struct') returns Code Analyzer information in a
%   structure array whose length is the number of suspicious constructs
%   found. The structure has the following fields:
%       line    : vector of line numbers to which the message refers
%       column  : two-column array of column extents for each line
%       message : message describing the suspect that code analysis caught
%   If multiple file names are specified, INFO contains a cell array of structures.
%
%   MSG = CHECKCODE(...,'-string') returns Code Analyzer information as a string
%   to the variable MSG. If multiple file names are specified, MSG contains
%   a string where each file's information is separated by ten "="
%   characters, a space, the file name, a space, and ten "=" characters.
%
%   If the -struct or -string argument is omitted and an output argument is
%   specified, the default behavior is '-struct'. If the argument is
%   omitted and there are no output arguments, the default behavior is to
%   display the information to the command line.
%
%   [INFO,FILEPATHS] = CHECKCODE(...) additionally returns FILEPATHS, the
%   absolute paths to the file names in the same order as they were input.
%
%   [...] = CHECKCODE(...,'-id') requests the Code Analyzer message ID as well.
%   When returned to a structure, the output has the following
%   additional field:
%       id       : ID associated with the message
%
%   [...] = CHECKCODE(...,'-fullpath') assumes that the input file names are
%   absolute paths, rather than requiring CHECKCODE to locate them.
%
%   To force Code Analyzer to ignore a line of code, use %#ok at the end of the
%   line. This tag can be followed by comments.  For example:
%       unsuppressed1 = 10   % This line will get caught
%       suppressed2 = 20     %#ok  These next two lines will not get caught
%       suppressed3 = 30     %#ok
%   [...] = CHECKCODE(...,'-notok') disables the %#ok tag.
%
%   [...] = CHECKCODE(...,'-cyc') displays the McCabe cyclomatic complexity
%   of each function in the file.
%
%   [...] = CHECKCODE(...,'-modcyc') displays the modified cyclomatic complexity
%   of each function in the file. The modified cyclomatic complexity for a function
%   is equal to the McCabe complexity except for one difference. McCabe complexity
%   counts each individual case within a switch statement as 1, while modified
%   cyclomatic complexity counts the entire switch statement as 1. In general,
%   switch statements are simpler than nested if-elseif-else statements and therefore,
%   the modified cyclomatic complexity is often considered a better measure of code
%   complexity.
%
%   [...] = CHECKCODE(...,'-config=<file>') overrides the default configuration
%   file and instead uses the one specified by "<file>".  If the file is
%   invalid, Code Analyzer returns a message indicating that the file cannot be opened
%   or read.  In that case, Code Analyzer uses the factory configuration.
%
%   [...] = CHECKCODE(...,'-config=factory') ignores all configuration files
%   and uses the factory configuration.
%
%   Examples:
%       % "lengthofline.m" is an example file with suspicious Code Analyzer
%       % constructs. It is found in the MATLAB demos as a read-only file.
%       cd(fullfile(docroot, 'techdoc', 'matlab_env', 'examples'));
%       checkcode lengthofline                    % Display to command line
%       info = checkcode('lengthofline','-id')    % Store to struct with ID
%
%   See also MLINTRPT.

%   CHECKCODE also takes additional input arguments that are not documented.
%   These arguments are passed directly into the Code Analyzer executable such
%   that the behavior is consistent with the executable.

%   Copyright 1984-2018 The MathWorks, Inc.

    if any(cellfun(@(x) isstring(x) && any(ismissing(x)), varargin))
        error(message('MATLAB:mlint:MissingString'));
    end

    if nargin > 0
        [varargin{:}] = convertStringsToChars(varargin{:});
    end

    try
        %% === Parse input arguments ===
        narginchk(1, inf);
        nargoutchk(0,2);
        validateInputs(varargin{:});
        parser = matlab.internal.codeanalyzer.inputParser();
        parser.parse( nargout, varargin{:} );

        % Ensure that when asking for output type "display" there are no output
        % arguments.
        if( strcmp( parser.outputType, 'display' ) && nargout > 0 )
            error( message( 'MATLAB:mlint:TooManyOutputArguments' ) );
        end

        %% === Get code analyzer messages ===
        mlntMsg = matlab.internal.codeanalyzer.getMessages( parser );

        %% === Modify and return/display output ===

        % Get an object to process the messages
        msgOutput = matlab.internal.codeanalyzer.getMessageOutputObject( parser.outputType, parser.fileListWasCell, parser.files, parser.hasText, parser.msgIdsWereRequested );

        % Process the message and return output
        [varargout{1:nargout-1}] = msgOutput.output( mlntMsg );
        if( nargout > 1 )
            % Since the messages are returned as a column vector, return the
            % list of files also as a column vector
            files = parser.files;
            if( isrow( files ) )
                files = files';
            end
            varargout{ 2 } = files;
        end

    catch e
        throw( e );
    end
end


function validateInputs(varargin)

% check that there are atmost one cell input
% Only the input files to be checked can be in a cell format. However, this check will not resolve the filenames
    cellArgIdx = cellfun( @iscell, varargin);
    numCellsInInputs = sum(cellArgIdx);

    if (numCellsInInputs > 1)
        error( message( 'MATLAB:mlint:TooManyCellArgs' ) );
    else
        charArgIdx = cellfun(@ischar, varargin);
        if any(cellfun(@(x) ischar(x) && isempty(x), varargin))
            error(message('MATLAB:mlint:EmptyInput'));
        end

        notCharVector = cellfun(@(x) ischar(x) && ~isrow(x), varargin);
        if any(notCharVector)
            error(message('MATLAB:mlint:NotCharacterRowVector'));
        end

        if (numCellsInInputs == 0)
            % no cell input , all the inputs must be of char type
            if (~all(charArgIdx))
                error( message( 'MATLAB:mlint:CheckCodeInputMustBeOfCharType' ) );
            end
        elseif (numCellsInInputs == 1)
            % single cell input with character type only arguments
            numNonCharInputs = sum(~charArgIdx);

            if any(cellfun(@(x) ischar(x) && isempty(x), varargin{cellArgIdx}))
                error(message('MATLAB:mlint:EmptyInput'));
            end

            if (numNonCharInputs > 1)
                error(message( 'MATLAB:mlint:CheckCodeInputMustBeOfCharType' ) );
            end

            % single cell input, only valid for files
            % cannot be a nested input

            % there should be only one cell input at this point. Otherwise this should be caught by the previous elseif block
            singleCellInputContent = varargin(cellArgIdx);
            nestedCellIdx = cellfun(@iscell, singleCellInputContent{:});

            if ( any( nestedCellIdx))
                error( message( 'MATLAB:mlint:NestedCell' ) );
            end

            fileInputCharArgIdx = cellfun(@(x)ischar(x), singleCellInputContent{:});
            if( ~all( fileInputCharArgIdx))
                error( message( 'MATLAB:mlint:CheckCodeInputMustBeOfCharType' ) );
            end

            if any(cellfun(@(x) ischar(x) && ~isrow(x), singleCellInputContent{:}))
                error(message('MATLAB:mlint:NotCharacterRowVector'));
            end
        end
    end

end
