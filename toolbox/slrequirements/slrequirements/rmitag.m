function rmitag( model, method, tag, varargin )
%RMITAG - manage user keywords on requirements links. 
%
%   Modify links:
%
%   RMITAG(MODEL, 'add', KEYWORD) adds a string KEYWORD as a keyword for
%   all requirement links in model MODEL.
%
%   RMITAG(MODEL, 'add', KEYWORD, DOC_PATTERN) adds KEYWORD as a keyword for
%   all links in MODEL where document name matches regular expression
%   DOC_PATTERN.
%
%   RMITAG(MODEL, 'delete', KEYWORD) removes keyword KEYWORD from all
%   requirement links in MODEL.
%   
%   RMITAG(MODEL, 'delete', KEYWORD, DOC_PATTERN) removes keyword KEYWORD
%   from all requirement links in MODEL where document name matches DOC_PATTERN.
%
%   RMITAG(MODEL, 'replace', KEYWORD, NEW_KEYWORD) replaces KEYWORD with NEW_KEYWORD for
%   all links in MODEL.
% 
%   RMITAG(MODEL, 'replace', KEYWORD, NEW_KEYWORD, DOC_PATTERN) replaces KEYWORD with
%   NEW_KEYWORD for links in MODEL where document name matches DOC_PATTERN.
%
%   RMITAG(MODEL, 'list') lists all link keywords in a given Simulink MODEL
%
%   Examples:
%       rmitag(gcs, 'add', 'local drive', '^[CD]:')
%       rmitag(gcs, 'replace', 'web', 'internal web', 'www-internal')
%
%
%   Keyword-based link removal:
%
%   RMITAG(MODEL, 'clear', KEYWORD) - deletes all requirement links with
%   matching keywords.
%
%   RMITAG(MODEL, 'clear', KEYWORD, DOC_PATTERN) - deletes all requirement
%   links with matching keyword and document.
%
%   Examples:
%       rmitag(gcs, 'clear', 'outdated')
%       rmitag(gcs, 'clear', 'rejected', 'ProposedChanges.doc') 
%
%
%   Regular expression matching of DOC_PATTERN in case-insensitive.
%
%
%   See also RMI RMIDOCRENAME

%   Copyright 2011-2018 The MathWorks, Inc.

    if nargin < 2 
        error(message('Slvnv:reqmgt:rmitag:IncorrectUsage'));
    end
    
    model = convertStringsToChars(model);
    method = convertStringsToChars(method);
    if nargin > 2
        tag = convertStringsToChars(tag);
    end
    if nargin > 3
        [varargin{:}] = convertStringsToChars(varargin{:});
    end
    
    if ~ischar(method)
        error(message('Slvnv:reqmgt:rmitag:IncorrectUsage'));
    elseif nargin == 2 && ~strcmp(method, 'list')
        error(message('Slvnv:reqmgt:rmitag:IncorrectUsage'));
    elseif nargin > 2 && ~ischar(tag) || (nargin > 3 && ~ischar(varargin{1}))
        error(message('Slvnv:reqmgt:rmitag:IncorrectUsage'));
    end

    if (strcmp(method, 'add') && nargin <= 4) || ...
            (strcmp(method, 'delete') && nargin <= 4) || ...
            (strcmp(method, 'replace') && (nargin == 4 || (nargin == 5 && ischar(varargin{2}) && ~isempty(varargin{2})))) || ...
            (strcmp(method, 'clear') && nargin <= 4)  % if this set of arguments looks right

        % All these use cases require license:
        if ~license('test','Simulink_Requirements')
            disp(getString(message('Slvnv:vnv_panel_mgr:ReqLicenseRequired')));
            return;
        end

        modelH = rmisl.getmodelh(model);
        if ishandle(modelH)
            [ total_objects, total_links, modified_objects, modified_links ] = rmisl.usertag(modelH, method, strtrim(tag), varargin{1:end});
            disp(getString(message('Slvnv:reqmgt:rmitag:TotalObjects', num2str(total_objects), num2str(modified_objects))));
            if strcmp(method, 'clear')
                disp(getString(message('Slvnv:reqmgt:rmitag:TotalLinksCleared', num2str(total_links), num2str(modified_links))));
            else
                disp(getString(message('Slvnv:reqmgt:rmitag:TotalLinksModified', num2str(total_links), num2str(modified_links))));
            end
        else
            error(message('Slvnv:reqmgt:rmitag:ResolveModelHandleFailed', model));
        end
    elseif nargin == 2 && strcmp(method, 'list')
        modelH = rmisl.getmodelh(model);
        if ishandle(modelH)
            [ total_objects, total_links, all_tags, all_counters ] = rmisl.usertag(modelH, 'list');
            disp(getString(message('Slvnv:reqmgt:rmitag:TotalTags', ...
                num2str(total_objects), num2str(total_links), num2str(length(all_tags)))));
            for i = 1:length(all_tags)
                fprintf(1, '%20s: %d\n', all_tags{i}, all_counters(i));
            end
            fprintf(1, '\n');
        else
            error(message('Slvnv:reqmgt:rmitag:ResolveModelHandleFailed', model));
        end
    else
        error(message('Slvnv:reqmgt:rmitag:IncorrectUsage'));
    end
end

