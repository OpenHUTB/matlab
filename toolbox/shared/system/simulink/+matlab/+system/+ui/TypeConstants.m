classdef TypeConstants
    properties(Constant=true)
        ControlTypes={'group','tab','tabcontainer','panel','collapsiblepanel',...
        'table','listboxcontrol','treecontrol','lookuptablecontrol','hyperlink','pushbutton','text','image'};
        ContainerTypes={'tab','tabcontainer','panel','group','collapsiblepanel','table'};
        ParameterTypes={'edit','checkbox','popup','combobox','radiobutton','dial',...
        'slider','spinbox','textarea','listbox','min','max','unit','unidt','customtable',...
        'sysobject','datatypestr'};
    end
end