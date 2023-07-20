classdef DialogSource<imported.DAStudio.DialogSource

    methods
        function obj=DialogSource(varargin)
            obj@imported.DAStudio.DialogSource(varargin);
        end
        function dlgstruct=getDialogSchema(obj,name)
            item1.Name='My list';
            item1.Type='listbox';
            item1.Entries={'list item 1','list item 2',...
            'list item 3','list item 4'};
            dlgstruct.DialogTitle='Block parameters: Gain';
            dlgstruct.Items={item1};
        end
    end
end