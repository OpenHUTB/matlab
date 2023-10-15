function interfaces = getSelectedInterfaces( bdName )

arguments
    bdName = '';
end

if isempty( bdName )
    bdName = bdroot;
end

interfaces = systemcomposer.InterfaceEditor.SelectedInterfaces( bdName );

end

