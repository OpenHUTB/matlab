function convertToCSRef(mdl,csName,saveToFile,fileName,fileType)




    if isa(mdl,'char')
        load_system(mdl);
    elseif isa(mdl,'Simulink.BlockDiagram')
        mdl=mdl.Name;
    end

    cs=getActiveConfigSet(mdl);

    if nargin<2
        csName=cs.Name;
    end
    if nargin<3
        saveToFile=false;
    end
    if nargin<4
        fileName=csName;
    end
    if nargin<5
        fileType=1;
    end

    if isa(cs,'Simulink.ConfigSet')
        assignin('base',csName,cs.copy);

        csref=Simulink.ConfigSetRef;
        csref.SourceName=csName;

        attachConfigSet(mdl,csref,true);
        setActiveConfigSet(mdl,csref.Name);
        detachConfigSet(mdl,cs.Name);

        if saveToFile
            if fileType==1
                evalstr=strcat('save(''',fileName,''', ''',csName,''')');
            else
                evalstr=strcat(csName,'.saveAs(''',fileName,''', ''-varname'', ''',csName,''')');
            end
            evalin('base',evalstr);
        end
    end


