function varargout=addReport(this,rpt)







    if nargin<2||isempty(rpt)
        rpt=this.addReport('-new');
    elseif ischar(rpt)
        if strcmp(rpt,'-library')
            rpt=[];


        elseif strcmp(rpt,'-new')
            rpt=RptgenML.CReport;
            rpt=this.addReport(rpt);
        elseif strcmp(rpt,'-newform')
            rpt=RptgenML.CForm;
            rpt=this.addReport(rpt);

            rptgen.cform_component.updateInnerHoles(rpt);
        else
            if strcmp(rpt,'-open')
                if rptgen.use_java
                    fileExt=char(com.mathworks.toolbox.rptgencore.tools.StylesheetMaker.FILE_EXT_SS);%#ok<JAPIMATHWORKS> 
                else
                    fileExt=mlreportgen.re.internal.db.StylesheetMaker.FILE_EXT_SS;
                end
                [dlgFile,dlgPath]=uigetfile({
                '*.rpt',getString(message('rptgen:RptgenML_Root:reportSetupFilesLabel'))
                ['*',fileExt],getString(message('rptgen:RptgenML_Root:stylesheetLabel',fileExt))
                '*.*',getString(message('rptgen:RptgenML_Root:allFilesLabel'))},...
                getString(message('rptgen:RptgenML_Root:selectFileLabel')));

                if isequal(dlgFile,0)||isequal(dlgPath,0)
                    rpt=[];
                else
                    fileName=fullfile(dlgPath,dlgFile);
                end
            elseif isSimulinkModel(rpt,this)
                rpt=rptgen.findSlRptName(rpt);
                fileName=rptgen.findFile(rpt,'rpt');
            else
                fileName=rptgen.findFile(rpt,'rpt');
            end

            if isempty(rpt)
                rpt=[];
            elseif isempty(fileName)
                rptObj=this.findRptByName(rpt);
                if~isempty(rptObj)

                    rpt=this.viewChild(rptObj);
                else
                    rpt=RptgenML.CReport('RptFileName',rpt);
                    rpt=this.addReport(rpt);
                end
            elseif locIsStylesheet(fileName)

                rpt=rpteditstyle(fileName);
            else
                rpt=this.findRptByName(fileName);
                if~isempty(rpt)

                    rpt=this.addReport(rpt);
                else
                    try
                        rptActual=rptgen.loadRpt(fileName);
                        if isa(rptActual,'RptgenML.CForm')||isa(rptActual,'rptgen.cform_outline')
                            rpt=RptgenML.CForm('RptFileName',fileName,...
                            'Description',getString(message('rptgen:RptgenML_Root:loadingRptMsg',fileName)));
                        else
                            rpt=RptgenML.CReport('RptFileName',fileName,...
                            'Description',getString(message('rptgen:RptgenML_Root:loadingRptMsg',fileName)));
                        end

                        this.addReport(rpt);
                        rpt.copyReport(rptActual);
                        rpt.setDirty(false);
                    catch ME
                        set(rpt,'Description',getString(message('rptgen:RptgenML_Root:errorLoadingRptMsg',fileName,ME.message)));
                    end
                    if isa(this.Editor,'DAStudio.Explorer')
                        ed=DAStudio.EventDispatcher;
                        ed.broadcastEvent('HierarchyChangedEvent',this);
                        this.Editor.view(rpt);
                        this.expandChildren(rpt);
                    end
                end
            end
        end
    elseif strcmp(class(rpt),'rptgen.coutline')
        rpt=this.addReport(RptgenML.CReport(rpt));
    elseif strcmp(class(rpt),'rptgen.cform_outline')
        rpt=this.addReport(RptgenML.CForm(rpt));
    elseif isa(rpt,'RptgenML.CReport')||isa(rpt,'RptgenML.CForm')
        firstChild=this.down;
        if isempty(firstChild)
            connect(this,rpt,'down');
        elseif firstChild==rpt

        else
            connect(rpt,firstChild,'right');
        end
        if isa(this.Editor,'DAStudio.Explorer')
            ed=DAStudio.EventDispatcher;
            ed.broadcastEvent('HierarchyChangedEvent',this);
            this.Editor.view(rpt);
            this.expandChildren(rpt);
        end



        [rPath,rFile,rExt]=fileparts(rpt.RptFileName);
        if~isempty(rPath)


            this.findRptByName(rpt.RptFileName,true,false);
        end
        if isempty(rExt)
            rpt.RptFileName=fullfile(rPath,[rFile,'.rpt']);
        end
    else
        error(message('rptgen:RptgenML_Root:invalidInputArgument'));
    end

    if nargout>0
        varargout{1}=rpt;
    end


    function tf=locIsStylesheet(fileName)



        fileExtSs=char(com.mathworks.toolbox.rptgencore.tools.StylesheetMaker.FILE_EXT_SS);
        fileExtSsLength=length(fileExtSs);

        tf=length(fileName)>fileExtSsLength&&...
        strcmpi(fileName(end-fileExtSsLength+1:end),char(com.mathworks.toolbox.rptgencore.tools.StylesheetMaker.FILE_EXT_SS));


