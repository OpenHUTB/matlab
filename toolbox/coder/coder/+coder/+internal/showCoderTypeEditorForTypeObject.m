function showCoderTypeEditorForTypeObject(~,name)





    narginchk(1,2);
    if nargin<2

        try
            name=inputname(1);
        catch


            name='';
        end
    end
    name=char(name);
    if isempty(name)
        return;
    end
    coderTypeEditor(name);
end
