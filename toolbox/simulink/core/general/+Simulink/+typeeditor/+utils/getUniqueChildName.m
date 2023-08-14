function newName=getUniqueChildName(varargin)








    narginchk(1,2);
    addType=(nargin==1)&&(numel(varargin{1})>1);
    if nargin==1
        if addType
            parent=varargin{1}{1};
        else
            parent=varargin{1};
        end
    else
        parent=varargin{1};
    end
    ed=parent.getEditor;
    if isa(parent,'Simulink.typeeditor.app.Source')
        editorTypes=ed.AcceptableTypes;
        if addType
            addType=varargin{1}{2};
            isType=strcmp(addType,editorTypes(:,1)');
            prefix=editorTypes{isType,2};
        end
        isType=true;
    elseif isa(parent,'Simulink.typeeditor.app.Object')
        prefix=ed.DefaultElementPrefix;
        isType=false;
    end
    if nargin==2
        newName=Simulink.typeeditor.utils.renameForPaste(parent,varargin{2},isType);
        return;
    end
    newName=Simulink.typeeditor.utils.getNextValidChildName(parent,prefix,isType);