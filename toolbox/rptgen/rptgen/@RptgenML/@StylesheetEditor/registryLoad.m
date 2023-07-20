function registryLoad(this,id,srcFile)






    if nargin<2||isempty(id)

        this.ErrorMessage=getString(message('rptgen:RptgenML_StylesheetEditor:cannotLoadEmptyStylesheet'));

    elseif ischar(id)
        if strncmp(id,'-NEW_',5)

            try
                if rptgen.use_java
                    ssMaker=eval(['com.mathworks.toolbox.rptgen.xml.StylesheetEditor.',id(2:end)]);
                else
                    ssMaker=eval(['mlreportgen.re.internal.ui.StylesheetEditor.',id(2:end)]);
                end
            catch ME
                this.ErrorMessage=ME.message;
                return;
            end
        else
            if exist(id,'file')&&...
                endsWith(java.lang.String(id),com.mathworks.toolbox.rptgencore.tools.StylesheetMaker.FILE_EXT_SS)
                registryFile=rptgen.findFile(id);
                id=[];
            else
                registryFile=rptgen.findFile([id,char(com.mathworks.toolbox.rptgencore.tools.StylesheetMaker.FILE_EXT_SS)]);
                if isempty(registryFile)
                    if nargin>2&&~isempty(srcFile)
                        registryFile=srcFile;
                    else
                        registryFile=which('rptstylesheets.xml','-all');
                    end
                else
                    id=[];
                end
            end


            try
                if rptgen.use_java
                    ssMaker=com.mathworks.toolbox.rptgen.xml.StylesheetEditor(id,...
                    registryFile);
                else
                    ssMaker=mlreportgen.re.internal.ui.StylesheetEditor(id,...
                    registryFile);
                end
            catch ME
                this.ErrorMessage=ME.message;
                return;
            end
        end

        registryLoad(this,ssMaker);

    elseif isa(id,'com.mathworks.toolbox.rptgen.xml.StylesheetEditor')...
        ||isa(id,'mlreportgen.re.internal.ui.StylesheetEditor')
        try
            this.JavaHandle=id;
            codeEl=id.getCode;
            if~isempty(codeEl)
                codeNode=codeEl.getFirstChild;
                while~isempty(codeNode)
                    if(rptgen.use_java&&isa(codeNode,'org.w3c.dom.Element'))||...
                        isa(codeNode,'matlab.io.xml.dom.Element')
                        this.addData(codeNode,'-last');
                    end
                    codePrev=codeNode;
                    codeNode=codeNode.getNextSibling;
                    if(rptgen.use_java&&isa(codePrev,'org.w3c.dom.Text'))||...
                        isa(codePrev,'matlab.io.xml.dom.Text')


                        codePrev.getParentNode.removeChild(codePrev);
                    end
                end
            end
            this.ErrorMessage='';
        catch ME
            this.ErrorMessage=ME.message;
        end

        r=this.up;
        if isa(r,'RptgenML.Root')


            r.expandChildren(this);

            r.enableActions;


            ed=DAStudio.EventDispatcher;
            ed.broadcastEvent('HierarchyChangedEvent',this);
        end

    elseif isa(id,'com.mathworks.toolbox.rptgen.xml.StylesheetEditor$StylesheetEditorInitializationType')...
        ||isa(id,'mlreportgen.re.internal.ui.StylesheetEditorInitializationType')




        if rptgen.use_java
            sm=com.mathworks.toolbox.rptgen.xml.StylesheetEditor(id);
        else
            sm=mlreportgen.re.internal.ui.StylesheetEditor(id);
        end
        registryLoad(this,sm);
    elseif isa(id,'rptgen.coutline')
        this.clearStylesheet;
        registryLoad(this,id.Stylesheet);
    elseif isa(id,'rpt_xml.db_output')
        this.clearStylesheet;
        registryLoad(this,id.getStylesheetID);
    elseif isa(id,'RptgenML.StylesheetEditor')
        this.clearStylesheet;
        registryLoad(this,id.ID,id.Registry);
    end

