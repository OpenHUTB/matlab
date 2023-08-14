function checkenable(hObject)











    if isstruct(hObject),
        hCell=struct2cell(hObject);

        hCell=hCell(cellfun('isclass',hCell,'double'));
        hObject=[hCell{:}];
    end
    for k=1:length(hObject)
        if ishandle(hObject(k))&&strcmp(get(hObject(k),'Type'),'uicontrol'),
            if strcmp(get(hObject(k),'Enable'),'on')&&...
                any(strcmpi(get(hObject(k),'Style'),{'popupmenu','edit','listbox'}))

                set(hObject(k),'BackgroundColor','white')
            else
                set(hObject(k),'BackGroundColor','default');
            end
        end
    end