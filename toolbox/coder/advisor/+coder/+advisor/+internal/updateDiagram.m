function[cleanup,out]=updateDiagram(model)










    out=[];
    cleanup=[];
    codegenMgr=coder.internal.ModelCodegenMgr.getInstance(model);
    if isempty(codegenMgr)
        try

            if strcmp(get_param(model,'SystemTargetFile'),'autosar.tlc')
                if autosarinstalled()
                    autosar.mm.util.validateModel(model,'init');
                end
            end
            feval(model,[],[],[],'compileForRTW');
            cleanup=onCleanup(@()feval(model,[],[],[],'term'));
        catch ME
            errmsg=[getString(message('Simulink:tools:MAErrorOccurredCompile'))...
            ,'<p>',getString(message('ModelAdvisor:engine:additionalCGIRFailMsg')),'</p>'...
            ,'<p>',ME.message,'</p>'];
            if~isempty(ME.cause)
                cause=[];
                for i=1:length(ME.cause)
                    cause=[cause,sprintf('<font color="#FF0000"><li>%s</li></font>',ME.cause{i}.message)];%#ok
                end
                errmsg=[errmsg,getString(message('MATLAB:MException:CausedBy'))...
                ,'<ul>',cause,'</ul>'];
            end
            out=ModelAdvisor.FormatTemplate('ListTemplate');

            out.setSubResultStatusText(['<font color="#FF0000">',errmsg,'</font>']);

            out.setSubBar(false);

            try
                feval(model,[],[],[],'term');
            catch
            end
        end
    end
