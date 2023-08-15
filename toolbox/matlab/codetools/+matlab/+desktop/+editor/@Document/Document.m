classdef (Sealed) Document < matlab.desktop.editor.DocumentInterface
%matlab.desktop.editor.Document  Access documents in Editor.
%   The matlab.desktop.editor package provides programmatic access to the
%   MATLAB Editor. Create Document objects to open, close, change, or check
%   the status of files in the Editor.  Each Document object corresponds to
%   an open Editor document.
%
%   To create Document objects, use any of the following
%   matlab.desktop.editor package functions:
%
%      matlab.desktop.editor.findOpenDocument    - Find open document
%      matlab.desktop.editor.getActive           - Return active document
%      matlab.desktop.editor.getAll              - Return all open documents
%      matlab.desktop.editor.newDocument         - Create a document
%      matlab.desktop.editor.openDocument        - Open existing file
%      matlab.desktop.editor.openAndGoToLine     - Open file and highlight line
%      matlab.desktop.editor.openAndGoToFunction - Open file and highlight
%                                                  function (MATLAB code only)
%   Document methods:
%   Document methods do not require that the document you access have
%   focus (among all the documents open in the Editor). However, these
%   methods do require that the document be open in the Editor. Only the
%   makeActive method makes a document become the one with focus.
%
%      appendText                 - Add text to end of document
%      close                      - Close document, prompting if unsaved changes exist
%      closeNoPrompt              - Close, discarding unsaved changes
%      goToFunction               - Move cursor to first occurrence of
%                                   specified function (MATLAB code only)
%      goToLine                   - Move cursor to specified line
%      goToPositionInLine         - Move cursor to specified position within line
%      insertTextAtPositionInLine - Insert text at specified position
%                                   within line
%      makeActive                 - Make document active (give focus)
%      reload                     - Revert to saved version of document
%      save                       - Save document
%      saveAs                     - Save document to specified filename
%      setdiff                    - Compare lists of Editor documents
%      smartIndentContents        - Smart indent document text
%
%   Document properties:
%   When you work interactively in the Editor to update documents, you
%   change the properties of the associated Document objects. Always
%   get property values immediately before using them.  All properties
%   are read-only, except Editable, Selection, and Text.
%
%      Filename     - Full path
%      Opened       - Specifies whether document is open (TRUE or FALSE)
%      Language     - Programming language associated with document
%      Text         - String array of the Document buffer contents
%      Selection    - Start and end positions of current selection
%      SelectedText - Text currently selected in document
%      Modified     - Specifies whether there are unsaved changes (TRUE or FALSE)
%      Editable     - Specifies whether document can be edited by the user
%
%   Example:  Create a document in the Editor and add text.  View the
%   properties of the Document object.
%
%      newDoc = matlab.desktop.editor.newDocument;
%      newDoc.Text = 'Sample text in new document.';
%
%      % View properties of newDoc:
%      newDoc
%
%   See also matlab.desktop.editor.

%   Copyright 2008-2021 The MathWorks, Inc.

    properties (SetAccess = private, Dependent = true)
        %Filename - Full path of file associated with Document object.
        %
        %   For new, unsaved documents, Filename is 'Untitled' or 'UntitledN',
        %   where N is an integer.
        %
        %   When you work interactively in the Editor to update documents, you
        %   change the properties of the associated Document objects. Always get
        %   property values immediately before using them.
        Filename;
        %Opened - Indicate whether Document is open.
        %
        %   If Opened is FALSE, the Document object is invalid.  All Document
        %   methods assume that Opened is TRUE.
        %
        %   When you work interactively in the Editor to update documents, you
        %   change the properties of the associated Document objects. Always get
        %   property values immediately before using them.
        Opened;
        %Language - Programming language associated with Document object.
        %
        %   MATLAB determines Language from the file extension, if specified, and
        %   the language associated with that extension in the Language preference
        %   settings. If your preferences do not include the specified extension,
        %   then Language is 'Plain' (plain text).
        %
        %   When you work interactively in the Editor to update documents, you
        %   change the properties of the associated Document objects. Always get
        %   property values immediately before using them.
        Language;
    end

    properties (SetAccess = public, Dependent = true)
        %Text - String array of the Document buffer contents.
        %
        %   To add text that contains single quotation marks, enclose them in a set
        %   of additional quotation marks.  For example, to create a document that
        %   contains disp('Hello'):
        %      myDoc = matlab.desktop.editor.newDocument('disp(''Hello'')');
        %
        %   To add a new line, use the integer 10.  For example, to add a line
        %   terminator and a call to the BEEP command to myDoc:
        %      myDoc.appendText([10 'beep']);
        %
        %   Before saving a new document, the line terminator, 10, equates to the
        %   '\n' escape sequence. On Microsoft Windows systems only, when you save
        %   the new document, MATLAB converts line terminators to the '\r\n' escape
        %   sequence. This conversion enables all Windows text editors, including
        %   Microsoft Notepad, to read the file. Line terminators added after
        %   saving equate to '\r\n'.
        %
        %   If you open an existing file, and then add a line terminator, MATLAB
        %   matches the line terminators already in the file ('\n' or '\r\n'),
        %   regardless of the operating system.
        %
        %   When you work interactively in the Editor to update documents, you
        %   change the properties of the associated Document objects. Always get
        %   property values immediately before using them.
        Text;
        %Selection - Start and end positions of selection in document.
        %
        %   Each position is represented by its line number and position within
        %   that line (both 1-based). The end position is exclusive. For example,
        %   to select from the first character of the first line to the third
        %   character of the second line (inclusive):
        %      Selection = [1 1 2 4];
        %
        %   Setting the end position before the start puts the end position at the
        %   start position. If either a line or position within a line is set less
        %   than 1, it defaults to 1. If a line number is specified beyond the
        %   maximum number of lines in the document, it defaults to the last line
        %   in the document. If a position is specified beyond the length of the
        %   corresponding line, it defaults to the end of that line. If the
        %   document does not contain MATLAB code, specifying a selection has no
        %   effect.
        %
        %   Note: a tab character is treated as a single character position within
        %   a line. Therefore, the position within a line might differ from the
        %   column number displayed in the MATLAB Editor status bar.
        %
        %   Note: If there are multiple selections made by multiple cursors in the document
        %   (column selection), this property will only return the position of the selection
        %   made by primary cursor (the first cursor created in the document).
        %   Use ExtendedSelection property to get positions for all the selections.
        %
        %   To select the entire document, use [-Inf -Inf Inf Inf].
        %
        %   When getting the property value, if either start or end position is
        %   not in a valid code line, the closest position in a code line is
        %   returned. If both start and end positions are not in a valid code line,
        %   [-1 -1 -1 -1] is returned.
        %
        %   matlab.desktop.editor.positionInLineToIndex and
        %   matlab.desktop.editor.indexToPositionInLine are helper functions for
        %   converting between an index into the text array and its corresponding
        %   position within a line.
        %
        %   When you work interactively in the Editor to update documents, you
        %   change the properties of the associated Document objects. Always get
        %   property values immediately before using them.
        Selection;
    end

    properties (SetAccess = private, Dependent = true)
        %SelectedText - Text currently selected in Document instance.
        %
        %   Note: If there are multiple selections made by multiple cursors in the document
        %   (column selection), this property will only return the text currently selected by the
        %   primary cursor (the first cursor created in the document).
        %   Use ExtendedSelectedText property to get text currently selected by all the cursors.
        %
        %   When you work interactively in the Editor to update documents, you
        %   change the properties of the associated Document objects. Always get
        %   property values immediately before using them.
        SelectedText;
        %Modified - Whether the Document instance contains unsaved changes.
        %
        %   When you work interactively in the Editor to update documents, you
        %   change the properties of the associated Document objects. Always get
        %   property values immediately before using them.
        Modified;
        %ExtendedSelection - N-by-4 matrix of start and end positions of selections in the document made by N cursors (column selection).
        %
        %   Each row of the matrix represents the position for selection made by a cursor.
        %   Each position is represented by its line number and position within
        %   that line (both 1-based). The end position is exclusive.
        %
        %   Note: a tab character is treated as a single character position within
        %   a line. Therefore, the position within a line might differ from the
        %   column number displayed in the MATLAB Editor status bar.
        %
        %   Note: Unlike Selection, this property is read-only.
        %
        %   ExtendedSelection is same as Selection if there is only one cursor in the document.
        %
        %   When you work interactively in the Editor to update documents, you
        %   change the properties of the associated Document objects. Always get
        %   property values immediately before using them.
        ExtendedSelection;
        %ExtendedSelectedText - Cell array of text currently selected by multiple cursors in Document instance.
        %
        %   ExtendedSelectedText is same as cellstr(SelectedText) if there is only one cursor
        %   in the document.
        %
        %   When you work interactively in the Editor to update documents, you
        %   change the properties of the associated Document objects. Always get
        %   property values immediately before using them.
        ExtendedSelectedText;
    end

    properties (SetAccess = public, Dependent = true)
        %Editable -  Make buffer editable or uneditable.
        %
        %   The Editable state determines whether the user can type into the MATLAB
        %   Editor or modify the text programmatically. The Editable state of a
        %   buffer does not affect the writeable state of the file.
        %
        %   When you work interactively in the Editor to update documents, you
        %   change the properties of the associated Document objects. Always get
        %   property values immediately before using them.
        Editable;
    end

    properties (SetAccess = private, Hidden = true)
        %Editor - Corresponding Editor Document object which will of type
        % JavaEditorDocument, RtcEditorDocument, MotwEditorDocument 
        % or HeadlessEditorDocument.
        Editor;
    end

    properties (SetAccess = private, Hidden = true, Dependent = true)
        %JavaEditor - Corresponding Java Editor object.
        JavaEditor;
        %LanguageObject - Java object representing programming language of Document.
        LanguageObject;
    end

    properties (Access = private, Hidden = true)
        ContentDirtiedEventListener
        ContentSavedEventListener
    end

    methods (Access = private, Hidden = true)
        %Document - Constructor for Document class.
        %   OBJ = Document(EDITOR)
        function obj = Document(Editor)
            assert(~isempty(Editor), ...
                   message('MATLAB:Editor:Document:EmptyEditor'));
            obj.Editor = Editor;
            obj.ContentDirtiedEventListener = addlistener(obj.Editor, ...
                'ContentDirtied', @obj.notifyEvent);
            obj.ContentSavedEventListener = addlistener(obj.Editor, ...
                'ContentSaved', @obj.notifyEvent);
        end

        function notifyEvent(obj, ~, eventData)
            notify(obj, eventData.EventName);
        end
    end

    %% Static constructors
    %These should only be called from matlab.desktop.editor functions
    methods (Static, Hidden)
        function obj = findEditor(fname)
        %findEditor Return Document instance for matching file name.
        %
        % This is a private constructor method to be used from
        % matlab.desktop.editor.findOpenDocument(filename).
        %
        % It is an error to use this function to find an unopened Document.
        %
        % Document = findEditor(filename) for a given file name, returns the
        % Document object that corresponds to the open file. Ideally, FILENAME is a
        % fully qualified path to the file. However, MATLAB tries to find the
        % Document if FILENAME specifies a partial path by matching the specified
        % file name to the names of the open documents. If MATLAB finds no match,
        % it returns an empty Document object.
        %

            editorObj = matlab.desktop.editor.DocumentUtils.findEditor(fname);
            if isempty(editorObj)
                obj = createEmptyReturnValue;
            else
                obj = matlab.desktop.editor.Document(editorObj);
            end
        end

        function obj = openEditor(filename)
        %openEditor Attempt to open named file in Editor.
        % This is an undocumented private constructor that might result in the
        % display of a dialog box (if the file name does not exist).
        %
        % Document = openEditor(filename) opens the MATLAB Editor for the given file
        % name and returns the resulting Document object. If no file with the given
        % file name exists on disk, the user might be prompted to create it. This
        % method requires a fully qualified path to the file. Otherwise, MATLAB
        % throws a MATLAB:Editor:Document:PartialPath exception. If the file does
        % not exist, and the user did not choose to create it, MATLAB returns an
        % empty Document array.
        %
        % See also matlab.desktop.editor.openDocument.

            editorObj = matlab.desktop.editor.DocumentUtils.openEditor(filename);
            if isempty(editorObj)
                obj = createEmptyReturnValue;
            else
                obj = matlab.desktop.editor.Document(editorObj);
            end
        end

        function obj = openEditorForExistingFile(filename, varargin)
        %openEditorForExistingFile Open named file in Editor.
        % This is a private constructor method to be used from
        % matlab.desktop.editor.openDocument(filename).
        %
        % Document = openEditorForExistingFile(filename) opens an Editor for the
        % given FILENAME and returns the resulting Document object. This method
        % requires a fully qualified path to the file, otherwise MATLAB throws a
        % MATLAB:Editor:Document:PartialPath exception. If the file does not exist,
        % MATLAB returns an empty Document array. This method does not display a
        % dialog box.
        %
        % See also matlab.desktop.editor.openDocument.
            editorObj = matlab.desktop.editor.DocumentUtils.openEditorForExistingFile(filename, varargin{:});
            if isempty(editorObj)
                obj = createEmptyReturnValue;
            else
                obj = matlab.desktop.editor.Document(editorObj);
            end
        end
    end

    %% Static accessor methods
    % matlab.desktop.editor uses these methods to obtain information
    % about existing documents. Because the return type is a Document
    % object, these methods must access the constructor.
    methods (Static, Hidden)
        function objs = getAllOpenEditors
        %getAllOpenEditors Return list of all open Documents.
            [rtcEditors, javaEditors] = matlab.desktop.editor.DocumentUtils.getAllOpenEditors;
            totalEditors = numel(rtcEditors) + numel(javaEditors);
            if totalEditors == 0
                objs = createEmptyReturnValue;
            else
                objs = matlab.desktop.editor.Document.empty(0, totalEditors);
                idx = 1;
                for ec = 1:numel(rtcEditors)
                    objs(idx) = matlab.desktop.editor.Document(rtcEditors(ec));
                    idx = idx + 1;
                end
                for ec = 1:numel(javaEditors)
                    objs(idx) = matlab.desktop.editor.Document(javaEditors(ec));
                    idx = idx + 1;
                end
            end
        end

        
        function obj = getActiveEditor
        % getActiveEditor 返回激活Matlab编辑器的文档对象
            editorObj = matlab.desktop.editor.DocumentUtils.getActiveEditor;
            if isempty(editorObj)
                obj = createEmptyReturnValue;
            else
                obj = matlab.desktop.editor.Document(editorObj);
            end
        end

        function obj = new(bufferText, varargin)
        %NEW Create new document containing the specified text and return Document
        %object, which references that untitled object.
            editorObj = matlab.desktop.editor.DocumentUtils.new(bufferText, varargin{:});
            if isempty(editorObj)
                obj = createEmptyReturnValue;
            else
                obj = matlab.desktop.editor.Document(editorObj);
            end
        end
    end

    %% Public instance methods
    methods
        function save(obj)
        %save Save Document text to disk.
        %   EDITOROBJ.save saves the contents of the open document associated with
        %   EDITOROBJ. This method does not display a dialog box.
        %
        %   Note: If EDITOROBJ represents an untitled buffer, or the associated
        %   file is read only, or any error occurs during the save operation, then
        %   MATLAB throws a MATLAB:Editor:Document:SaveFailed exception. If the
        %   operation returns without MATLAB throwing an exception, assume that the
        %   save operation succeeded.
        %
        %   Example: Open an existing document, modify it, and then save it.
        %
        %      doc = matlab.desktop.editor.openDocument('C:\myfile.m');
        %      doc.appendText('modified');
        %      doc.save;
        %
        %   See also matlab.desktop.editor.Document/saveAs,
        %   matlab.desktop.editor.Document/closeNoPrompt,
        %   matlab.desktop.editor.Document.Modified,
        %   matlab.desktop.editor.Document/reload.
            assertOpen(obj);
            for i=1:numel(obj)
                obj(i).Editor.save;
            end
        end

        function saveAs(obj, filename)
        %saveAs Save Document text to disk using specified file name.
        %   EDITOROBJ.saveAs(FILENAME) saves the contents of the open document
        %   associated with EDITOROBJ to the specified FILENAME. This method does
        %   not display a dialog box. This method works for scalar input only.
        %
        %   Note: If the specified FILENAME is read only, or if the FILENAME is
        %   currently being debugged, or any error occurs during the saveAs
        %   operation, MATLAB throws a MATLAB:Editor:Document:SaveAsFailed
        %   exception. If the operation returns without an exception being thrown,
        %   assume that the operation succeeded.
        %
        %   Example: Open a new document and save it.
        %
        %      doc = matlab.desktop.editor.newDocument('function myfile');
        %      doc.saveAs('C:\myfile.m');
        %
        %   See also matlab.desktop.editor.Document/save,
        %   matlab.desktop.editor.Document/closeNoPrompt,
        %   matlab.desktop.editor.Document.Modified,
        %   matlab.desktop.editor.Document/reload.
            assertScalar(obj);
            assertOpen(obj);
            filename = convertStringsToChars(filename);
            obj.Editor.saveAs(filename);
        end

        function goToLine(obj, line)
        %goToLine Move cursor to specified line in Editor document.
        %   EDITOROBJ.goToLine(LINENUMBER) moves the cursor to the beginning of the
        %   specified line of an open document in the MATLAB Editor, and highlights
        %   the line. EDITOROBJ is a scalar Document object associated with the
        %   open document. If LINENUMBER is past the end of the document, goToLine
        %   places the cursor at the last line. If the document does not contain
        %   MATLAB code, this method does nothing. goToLine does not change which
        %   Editor document is active.
        %
        %   Example: Go to the 20th line of the active Editor document.
        %
        %      activeDoc = matlab.desktop.editor.getActive;
        %      if ~isempty(activeDoc)
        %          activeDoc.goToLine(20);
        %      end
        %
        % See also matlab.desktop.editor.Document/goToFunction,
        % matlab.desktop.editor.openDocument,
        % matlab.desktop.editor.openAndGoToFunction,
        % matlab.desktop.editor.openAndGoToLine,
        % matlab.desktop.editor.Document/goToPositionInLine,
        % matlab.desktop.editor.Document/makeActive.
            assertScalar(obj);
            assertPositiveLessEqualInt32Max(line, 'LINENUMBER');
            assertOpen(obj);
            obj.Editor.goToLine(line);
        end

        function goToPositionInLine(obj, line, position)
        %goToPositionInLine Move to specified position within line.
        %   EDITOROBJ.goToPositionInLine(LINE, POSITION) moves the cursor to the
        %   specified character position within a line of an open document in the
        %   MATLAB Editor. EDITOROBJ is a scalar Document object associated with
        %   the open document. If LINE or POSITION is out of the range of the
        %   document, then goToPositionInLine places the cursor at the closest
        %   valid position. If the document does not contain MATLAB code, this
        %   method does nothing. goToPositionInLine does not change which Editor
        %   document is active.
        %
        %   Note: A tab character is treated as a single character position within
        %   a line. Therefore, the position within a line might differ from the column
        %   number displayed in the Editor status bar.
        %
        %   Example: Go to the 11th character position of the 20th line of the
        %   active document.
        %
        %      activeDoc = matlab.desktop.editor.getActive;
        %      if ~isempty(activeDoc)
        %          activeDoc.goToPositionInLine(20,11);
        %      end
        %
        %   See also matlab.desktop.editor.Document/goToFunction,
        %   matlab.desktop.editor.openDocument,
        %   matlab.desktop.editor.openAndGoToFunction,
        %   matlab.desktop.editor.openAndGoToLine,
        %   matlab.desktop.editor.Document/goToLine,
        %   matlab.desktop.editor.Document/makeActive.
            assertScalar(obj);
            assertPositiveLessEqualInt32Max(line, 'LINE');
            assertLessEqualInt32Max(position, 'POSITION');
            assertOpen(obj);

            obj.Editor.goToPositionInLine(line, position);
        end

        function goToFunction(obj, functionName)
        %goToFunction Move to function in MATLAB program.
        %   EDITOROBJ.goToFunction(FUNCTION) highlights the first line of FUNCTION
        %   in the scalar open Editor document associated with EDITOROBJ. If the
        %   document contains more than one function with the same name,
        %   goToFunction scrolls to the first occurrence. If the document does not
        %   contain MATLAB code or if FUNCTION does not exist, this method does
        %   nothing.
        %
        %   Example: Open taxdemo.m and highlight the computeTax function.
        %
        %      taxDoc = matlab.desktop.editor.openDocument(which('taxdemo.m'));
        %      taxDoc.goToFunction('computeTax');
        %
        %   See also matlab.desktop.editor.openAndGoToFunction,
        %   matlab.desktop.editor.Document/goToLine.

            assertScalar(obj);
            assertOpen(obj);
            functionName = convertStringsToChars(functionName);
            obj.Editor.goToFunction(functionName);
        end

        function smartIndentContents(obj)
        %smartIndentContents Apply smart indenting to code.
        %   EDITOROBJ.smartIndentContents applies smart indenting to the open
        %   Editor document associated with EDITOROBJ. This method is supported for
        %   MATLAB code, Java code, C/C++ code, and XML code. If the document
        %   contains plain text or is in a language that does not have smart indent
        %   support, this method does nothing.
        %
        %   To apply smart indenting interactively, select Text > Smart Indent in
        %   the MATLAB Editor.
        %
        %   Example: Add code to a new buffer in the Editor, and apply smart
        %   indenting.
        %
        %      newDoc = matlab.desktop.editor.newDocument('% Sample document');
        %
        %      % Each 10 moves to a new line
        %      newDoc.appendText([10 'if true']);
        %      newDoc.appendText([10 'disp(''Hello'')']);
        %      newDoc.appendText([10 'end']);
        %
        %      newDoc.smartIndentContents;
        %
        %   See also matlab.desktop.editor.Document/appendText,
        %   matlab.desktop.editor.Document/insertTextAtPositionInLine.

            for i=1:numel(obj)
                obj(i).Editor.smartIndentContents;
            end
        end

        function close(obj)
        %close Close document in Editor.
        %   EDITOROBJ.close closes the MATLAB Editor buffer and pane corresponding
        %   to the EditorDocument object EDITOROBJ.  Closing invalidates EDITOROBJ.
        %
        %   If the buffer contains unsaved changes (that is, the EDITOROBJ.Modified
        %   property is TRUE), then MATLAB displays a dialog box that provides the
        %   option to save.  In this case, the CLOSE method does not resume until
        %   you click YES or NO to save or discard the changes. Clicking CANCEL
        %   ends the operation and does not close the Editor buffer.
        %
        %
        %   Example: Create a file in the Editor. Add text without saving, and then
        %   attempt to close the file. When the confirmation dialog box appears,
        %   click YES or NO to save or discard the buffer contents. Alternatively,
        %   click CANCEL to abort the operation.
        %
        %      newDoc = matlab.desktop.editor.newDocument('This is a test.');
        %      newDoc.close;
        %
        %   See also matlab.desktop.editor.Document/closeNoPrompt,
        %   matlab.desktop.editor.Document.Modified,
        %   matlab.desktop.editor.Document/reload,
        %   matlab.desktop.editor.Document/save.
            for i=1:numel(obj)
                obj(i).Editor.close;
            end
        end

        function closeNoPrompt(obj)
        %closeNoPrompt Close document in Editor, discarding unsaved changes.
        %   EDITOROBJ.closeNoPrompt closes the MATLAB Editor buffer and pane
        %   corresponding to the Document object EDITOROBJ. The closeNoPrompt
        %   method discards any unsaved changes made to the document, and does not
        %   display a confirmation dialog box. Closing the buffer invalidates the
        %   associated EDITOROBJ.
        %
        %   Example: Create a file in the temporary folder for your system. Save
        %   the initial contents. Add text without saving, and then close.
        %
        %      tempfile = [tempname '.m'];
        %
        %      newDoc = matlab.desktop.editor.newDocument;
        %      newDoc.appendText('% Testing CloseNoPrompt');
        %      newDoc.saveAs(tempfile);
        %
        %      newDoc.appendText('... will discard this text');
        %      newDoc.closeNoPrompt;
        %
        %      % View the contents of the file
        %      type(tempfile)
        %
        %   See also matlab.desktop.editor.Document/close.

            for i=1:numel(obj)
                obj(i).Editor.closeNoPrompt;
            end
        end

        function reload(obj)
        %RELOAD Revert to saved version of Editor document.
        %   EDITOROBJ.RELOAD replaces the contents of an open document in the
        %   MATLAB Editor with the saved version of the file. EDITOROBJ is a
        %   Document object associated with the open document. If you attempt to
        %   reload an untitled buffer or an Editor whose underlying file has been
        %   deleted, MATLAB throws a MATLAB:Editor:Document:ReloadFailed exception.
        %
        %   Example: Create and save a file in the temporary folder on your system.
        %   Modify the document, but do not save the changes. Reload the file.
        %
        %      tempfile = [tempname '.m'];
        %
        %      tempDoc = matlab.desktop.editor.newDocument;
        %      tempDoc.appendText('% Testing reload');
        %      tempDoc.saveAs(tempfile);
        %      tempDoc.appendText(' ... will discard this text');
        %
        %      % View contents before reload
        %      disp('Before reload:');
        %      tempDoc.Text
        %
        %      tempDoc.reload;
        %
        %      % View contents after reload
        %      disp('After reload:');
        %      tempDoc.Text
        %
        %   See also matlab.desktop.editor.newDocument,
        %   matlab.desktop.editor.openDocument.
            assertOpen(obj);
            for i=1:numel(obj)
                obj(i).Editor.reload;
            end
        end

        function appendText(obj, textToAppend)
        %appendText Append text to document in Editor.
        %   EDITOROBJ.appendText(TEXT) adds the specified text to the end of the
        %   open document associated with the scalar Document object EDITOROBJ.
        %   If the last line in the document is a code line, then the input text
        %   is appended to that line. If the last line is not a code line, then
        %   a new code line containing the input text is inserted at the end of
        %   the document.
        %
        %   Example: Create a document and append a line of text.
        %
        %      newline = 10;
        %      newDoc = matlab.desktop.editor.newDocument('Initial text in new document');
        %      newDoc.appendText([newline 'Appended text']);
        %
        %   See also matlab.desktop.editor.Document/closeNoPrompt,
        %   matlab.desktop.editor.newDocument, matlab.desktop.editor.openDocument,
        %   matlab.desktop.editor.Document/insertTextAtPositionInLine,
        %   matlab.desktop.editor.Document/save.
            assertScalar(obj);
            textToAppend = convertStringsToChars(textToAppend);
            assertChar(textToAppend);
            assertOpen(obj);
            assertEditable(obj);
            obj.Editor.appendText(textToAppend);
        end

        function set.Text(obj, textToSet)
        %set.Text Set the text in the Document buffer.
            textToSet = convertStringsToChars(textToSet);
            assertChar(textToSet);
            assertOpen(obj);
            assertEditable(obj);
            obj.Editor.Text = textToSet;
        end

        function makeActive(obj)
        %makeActive Make document active in Editor.
        %   EDITOROBJ.makeActive Among all documents open in the MATLAB Editor,
        %   gives focus to the one associated with the scalar Document object,
        %   EDITOROBJ.
        %
        %   Example: Open several files and make fft.m the document with focus.
        %
        %      fftDoc = matlab.desktop.editor.openDocument(which('fft.m'));
        %      matlab.desktop.editor.openDocument(which('fftn.m'));
        %      matlab.desktop.editor.openDocument(which('fftw.m'));
        %      fftDoc.makeActive;
        %
        %   See also matlab.desktop.editor.Document.getActive,
        %   matlab.desktop.editor.openDocument.
            assertScalar(obj);
            obj.Editor.makeActive;
        end

        function newObjs = setdiff(newObjsList, originalObjList)
        %setdiff Compare lists of Editor Documents.
        %   NEWOBJECTS = SETDIFF(NEWLIST, ORIGLIST) returns an array of Document
        %   objects that are in NEWLIST, but not in ORIGLIST.
        %
        %   Example: Get a list of all open documents in the MATLAB Editor. Open an
        %   additional document. Identify the new document.
        %
        %      originalSet = matlab.desktop.editor.getAll;
        %      fft = matlab.desktop.editor.openDocument(which('fft.m'));
        %      laterSet = matlab.desktop.editor.getAll;
        %
        %      newDocs = setdiff(laterSet, originalSet);
        %
        %      % List the files associated with new documents
        %      if ~isempty(newDocs)
        %         disp('New documents opened:');
        %         for k = 1:length(newDocs)
        %             newDocs(k).Filename
        %         end
        %      end
        %
        %   See also matlab.desktop.editor.getAll.
            newObjs = createEmptyReturnValue;
            for i = 1:numel(newObjsList)
                currentNewEditor = newObjsList(i);
                if ~ismember(currentNewEditor, originalObjList,'legacy')
                    newObjs(end+1) = currentNewEditor; %#ok<AGROW>
                end
            end
        end

        function filename = get.Filename(obj)
            filename = obj.Editor.Filename;
        end

        function text = get.Text(obj)
            assertOpen(obj);
            text = obj.Editor.Text;
        end

        function selection = get.Selection(obj)
            assertOpen(obj);
            selection = obj.Editor.Selection;
        end

        function set.Selection(obj, position)
            assertOpen(obj);
            assert(isnumeric(position) && length(position) == 4, ...
                   message('MATLAB:Editor:Document:InvalidSelection'));

            obj.Editor.Selection = position;
        end

        function text = get.SelectedText(obj)
            assertOpen(obj);
            text = obj.Editor.SelectedText;
        end

        function extendedSelection = get.ExtendedSelection(obj)
            assertOpen(obj);
            extendedSelection = obj.Editor.ExtendedSelection;
        end

        function extendedSelectedText = get.ExtendedSelectedText(obj)
            assertOpen(obj);
            extendedSelectedText = obj.Editor.ExtendedSelectedText;
        end

        function editable = get.Editable(obj)
            assertOpen(obj);
            editable = obj.Editor.Editable;
        end

        function set.Editable(obj, editable)
            assertOpen(obj);
            obj.Editor.Editable = editable;
        end

        function lang = get.Language(obj)
            assertOpen(obj);
            lang = obj.Editor.Language;
        end

        function insertTextAtPositionInLine(obj, text, line, position)
        %insertTextAtPositionInLine Insert text in Editor document at position specified.
        %   EDITOROBJ.insertTextAtPositionInLine(TEXT, LINE, POSITION) inserts text
        %   at the specified character position within a line of an open document
        %   in the MATLAB Editor. EDITOROBJ is a scalar Document object associated
        %   with the open document. TEXT cannot be null or empty.
        %   If LINE or POSITION is out of the range of the
        %   document, insertTextAtPositionInLine inserts the text at the closest
        %   valid position. If a valid position does not exist in the document, an
        %   error is thrown. insertTextAtPositionInLine does not change which Editor
        %   document is active.
        %
        %   Note: A tab character is treated as a single character position within
        %   a line. Therefore, the position within a line might differ from the
        %   column number displayed in the Editor status bar.
        %
        %   Example:  Create a document and insert text.
        %
        %      newline = 10;
        %
        %      % Start with two lines of text:
        %      firstline = ['First line of text' newline];
        %      secondline = ['Second line of text'];
        %      newDoc = matlab.desktop.editor.newDocument([firstline secondline]);
        %
        %      % Insert a new line between the first and second lines:
        %      newtext = ['Insert this line' newline];
        %      newDoc.insertTextAtPositionInLine(newtext, 2, 1);
        %
        %   See also matlab.desktop.editor.Document/appendText,
        %   matlab.desktop.editor.newDocument.
            assertScalar(obj);
            text = convertStringsToChars(text);
            assertChar(text);
            assertEditable(obj);
            obj.Editor.insertTextAtPositionInLine(text, line, position);
        end

        function isopen = get.Opened(obj)
            isopen = obj.Editor.Opened;
        end

        function bool = get.Modified(obj)
            assertOpen(obj);
            bool = obj.Editor.Modified;
        end

        function javaEditor = get.JavaEditor(obj)
            assertOpen(obj);
            javaEditor = obj.Editor.JavaEditor;
        end

        function langObj = get.LanguageObject(obj)
            assertOpen(obj);
            langObj = obj.JavaEditor.getLanguage;
        end

        function bool = eq(obj1, obj2)
        %eq Overloads the == operator to compare two Document objects.
        %
        % This method returns true if the two Document objects refer to the same
        % open window in the MATLAB Editor.

        % Only compute equals if one of the objects is scalar, or both are same
        % size.
            n1 = numel(obj1);
            n2 = numel(obj2);

            assert(n1 == 1 || n2 == 1 || any(size(obj1) == size(obj2)), ...
                   message('MATLAB:Editor:Document:InvalidMatrixDimensions'));

            % Make sure that at least one object is not empty.
            if isempty(obj1) || isempty(obj2)
                bool = false;
            else

                % Loop over the larger array.
                if n2 > n1
                    bool = loopEq(obj2, obj1);
                else
                    bool = loopEq(obj1, obj2);
                end
            end


            function bool = loopEq(obj1, obj2)
                bool = false(size(obj1));
                num2 = numel(obj2);
                for i=1:numel(obj1)
                    if num2 > 1
                        e2 = obj2(i).Editor;
                    else
                        e2 = obj2.Editor;
                    end
                    bool(i) = strcmp(class(obj1(i).Editor), class(e2)) && obj1(i).Editor == e2;
                end
            end

        end

        function bool = isequal(obj1, obj2)
        % Test two (possibly arrays of) Documents for equality.
            bool = isequal(size(obj1),size(obj2)) && all(eq(obj1, obj2));
        end
    end

    methods (Hidden)
        function [line, position] = indexToPositionInLine(obj, index)
            [line, position] = obj.Editor.indexToPositionInLine(index);
        end

        function index = positionInLineToIndex(obj, line, position)
            index = obj.Editor.positionInLineToIndex(line, position);
        end

        function delete(obj)
            delete(obj.ContentDirtiedEventListener);
            delete(obj.ContentSavedEventListener);
        end
    end
end

function assertScalar(obj)
% assertScalar Check that Document is scalar.
    matlab.desktop.editor.EditorUtils.assertScalar(obj);
end

function assertChar(text)
% assertScalar Check that input text is 1-by-n char vector.
    matlab.desktop.editor.EditorUtils.assertChar(text, 'TEXT');
end

function assertOpen(obj)
% assertOpen Check that Document is open.
    matlab.desktop.editor.EditorUtils.assertOpen(obj, 'DOCUMENT');
end

function assertEditable(obj)
% assertEditable Check that Document is editable.
    assert(all([obj.Editable]), message('MATLAB:Editor:Document:Uneditable'));
end

function assertLessEqualInt32Max(input, variablename)
% assertLessEqualInt32Max Check that input number is not greater than maximum of 32-bit integer.
    matlab.desktop.editor.EditorUtils.assertLessEqualInt32Max(input, variablename);
end

function assertPositiveLessEqualInt32Max(input, variablename)
% assertPositiveLessEqualInt32Max Check that input number is positive and not greater than maximum of 32-bit integer.
    matlab.desktop.editor.EditorUtils.assertPositiveLessEqualInt32Max(input, variablename);
end

function emptyDocs = createEmptyReturnValue
% createEmptyReturnValue Return 1x0 empty Document array.
    emptyDocs = matlab.desktop.editor.Document.empty(1,0);
end
