function varargout=refreshColumnsCategory(varargin)




    ed=Simulink.typeeditor.app.Editor.getInstance;
    outputVal=[];
    if~isempty(ed.getStudio)&&ed.isVisible
        entryID=ed.getColumnView;
        switch entryID
        case 'Simulink:busEditor:ColumnsDefaultView'
            columnSet='columnsDefault';
        case 'Simulink:busEditor:ColumnsAtomicTypeView'
            columnSet='columnsAtomicTypes';
        case 'Simulink:busEditor:ColumnsDataTypeView'
            columnSet='columnsDataTypes';
        otherwise
            assert(false);
        end
        if nargin==2
            varargin{2}.selectedItem=entryID;
        end
        outputVal=columnSet;
    end
    if nargout>0
        varargout{1}=outputVal;
    end
end