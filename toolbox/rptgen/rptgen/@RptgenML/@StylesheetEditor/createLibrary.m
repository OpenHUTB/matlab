function this=createLibrary(ss)






    copyProps={
'Registry'
'ID'
'TransformType'
'Description'
'Filename'
'DisplayName'
    };


    if isa(ss,'com.mathworks.toolbox.rptgencore.tools.StylesheetMaker')
        this=RptgenML.StylesheetEditor;

        for i=1:length(copyProps)
            ssVal=feval(['get',copyProps{i}],ss);
            if isa(ssVal,'java.io.File')
                ssVal=getAbsolutePath(ssVal);
            end
            set(this,copyProps{i},char(ssVal));
        end
    elseif isa(ss,'RptgenML.StylesheetEditor')
        this=RptgenML.StylesheetEditor;

        for i=1:length(copyProps)
            set(this,copyProps{i},get(ss,copyProps{i}));
        end

    elseif ischar(ss)

        if strncmp(ss,'-NEW_',5)
            ssEd=eval(['com.mathworks.toolbox.rptgen.xml.StylesheetEditor.',ss(2:end)]);
            ssEd=com.mathworks.toolbox.rptgen.xml.StylesheetEditor(ssEd);

            ssEd.setID(ss);
            this=RptgenML.StylesheetEditor.createLibrary(ssEd);
        else
            ss=com.mathworks.toolbox.rptgen.xml.StylesheetEditor(ss,...
            which('rptstylesheets.xml','-all'));
            this=RptgenML.StylesheetEditor.createLibrary(ss);
        end

    end
