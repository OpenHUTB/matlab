function[model,ret]=open(model)




    ret={};


    [filename,path]=uigetfile('*.xml');

    if~isequal(filename,0)
        ret.file=[path,filename];


        bd=model.topLevelElements;
        for i=1:length(bd)
            if isa(bd(i),'ssm.app.VizDebuggerSettings')
                bd(i).destroy();
                break;
            end
        end


        try
            parser=mf.zero.io.XmlParser;
            parser.Model=model;
            transaction=model.beginTransaction;

            bd=model.topLevelElements;
            parser.parseFile(ret.file);

            bd.destroy;
            transaction.commit;
        catch ME
            ret.errorTitle=message('ssm:genericUI:ErrorOpenFile').getString;
            ret.error=ME.message;
        end
    end
end