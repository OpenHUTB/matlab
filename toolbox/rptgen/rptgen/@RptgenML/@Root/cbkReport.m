function rptName=cbkReport(this,rpt,varargin)















    try
        rptName='';
        this.getDisplayClient();

        if((nargin<2)||isempty(rpt))
            rpt=this.getCurrentRpt(true);
            rptName=locRunReport(this,rpt,varargin);

        elseif ischar(rpt)
            if strcmp(rpt,'-stop')
                locStop(this);

            elseif strcmp(rpt,'-rundeferred')
                runDeferredReport(this,varargin);

            else


                rptName=rpt;
                rpt=this.findRptByName(rptName);
                if isempty(rpt)
                    rptgen.displayMessage(getString(message('rptgen:RptgenML_Root:loadingLabel',rptName)),2);


                    rpt=this.addReport(rptName);
                    rptName=locRunReport(this,rpt,varargin);
                    this.closeReport(rpt,true);
                else
                    rptName=locRunReport(this,rpt,varargin);
                end
            end

        else
            rptName=locRunReport(this,rpt,varargin);
        end

    catch ME

        rptgen.displayMessage(ME.message,1);


        this.getDisplayClient().enableFilterList();
        locRecoverEditor(this,rpt);
        throwAsCaller(ME);
    end


    function rptName=locRunReport(this,rpt,options)

        if isempty(rpt)
            error(message('rptgen:RptgenML_Root:noReportLabel'));
        end

        if~isa(rpt,'rptgen.coutline')
            error(message('rptgen:RptgenML_Root:unexpectedObject',class(rpt)));
        end

        rptgen.internal.gui.GenerationDisplayClient.staticClearMessages;
        rptgen.displayMessage(getString(message('rptgen:RptgenML_Root:beginningReportLabel')),2);


        isStylesheetOk=warnDirtyStylesheet(RptgenML.StylesheetRoot,rpt.Stylesheet);

        locApplyChanges(this);
        isSaveOk=locAutoSave(rpt);

        if(isSaveOk&&isStylesheetOk)

            for i=1:2:length(options)-1
                set(rpt,options{i},options{i+1});
            end

            locCollapseAllOtherReports(this,rpt);
            locDisableTreeListener(this);
            locDisableMenuItem(this);
            locUpdateListView(this);
            locDisableDialog(this);


            rptName=execute(rpt);
        else
            rptgen.displayMessage(getString(message('rptgen:RptgenML_Root:cancellingLabel')),2);
            rptName='';
        end

        locRecoverEditor(this,rpt);


        function isSaveOk=locAutoSave(rpt)

            isSaveOk=true;
            if rpt.isAutoSaveOnGenerate
                rptgen.displayMessage(getString(message('rptgen:RptgenML_Root:savingReportLabel')),3);
                try
                    savedFileName=doSave(rpt,false);
                    if isempty(savedFileName)
                        isSaveOk=false;
                        rptgen.displayMessage(getString(message('rptgen:RptgenML_Root:cannotSaveMsg')),2);
                    end
                catch ME
                    isSaveOk=false;
                    rptgen.displayMessage(getString(message('rptgen:RptgenML_Root:cannotSaveMsg')),2);
                    rptgen.displayMessage(ME.message,5);
                end
            end


            function locApplyChanges(this)


                dlgH=this.getCurrentDialog();
                if~isempty(dlgH)
                    dlgH.apply();
                end


                function locDisableDialog(this)


                    dlgH=this.getCurrentDialog();
                    if~isempty(dlgH)
                        delete(dlgH);
                    end


                    function locDisableTreeListener(this)


                        treeListener=find(this.Listeners,'EventType','METreeSelectionChanged');
                        set(treeListener,'Enabled','off');


                        function locCollapseAllOtherReports(this,rpt)


                            openedReports=find(this.getHierarchicalChildren,'-isa','rptgen.coutline');
                            otherReports=openedReports(openedReports~=rpt);
                            ime=DAStudio.imExplorer(this.getEditor());
                            for i=1:length(otherReports)
                                ime.collapseTreeNode(otherReports(i));
                            end


                            function locUpdateListView(this)


                                this.PrevLibrary=this.Library;
                                this.Library=RptgenML.Message(getString(message('rptgen:RptgenML_Root:generatingReportEllipsisLabel')),...
                                getString(message('rptgen:RptgenML_Root:generatingReportLabel')));
                                ed=DAStudio.EventDispatcher;
                                ed.broadcastEvent('ListChangedEvent')


                                function locDisableMenuItem(this)


                                    this.enableActions(false);
                                    if strcmp(get(this.Actions.Report,'Callback'),'cbkReport(RptgenML.Root,''-stop'');')
                                        set(this.Actions.Report,'Enabled','on');
                                    end


                                    function locStop(this)

                                        if strcmp(this.Actions.Report.Callback,'cbkReport(RptgenML.Root,''-stop'');')
                                            set(this.Actions.Report,...
                                            'Enabled','off');
                                            set(rptgen.appdata_rg,'HaltGenerate',true);
                                        end


                                        function locRecoverEditor(this,rpt)





                                            if ischar(rpt)
                                                rpt=this.findRptByName(rpt);
                                            end

                                            if isempty(rpt)
                                                rpt=this.getCurrentRpt(false);
                                            end

                                            if isa(rpt,'rptgen.coutline')
                                                restoreState(rptgen.ReportState(rpt));
                                            else
                                                restoreState(rptgen.ReportState(this));
                                            end







                                            function runDeferredReport(this,options)




                                                set(this.Actions.Report,...
                                                'Text',getString(message('rptgen:RptgenML_Root:stopReportLabel')),...
                                                'Callback','cbkReport(RptgenML.Root,''-stop'');',...
                                                'Icon',fullfile(toolboxdir('rptgen'),'resources','stop.png'),...
                                                'StatusTip',getString(message('rptgen:RptgenML_Root:stopSetupFileLabel')),...
                                                'Enabled','on');

                                                t=timer;
                                                t.TimerFcn=[{@locCallbackRunReport,this},options{:}];
                                                t.stopFcn={@dlgStopTimer};
                                                t.StartDelay=0.1;
                                                start(t);


                                                function locCallbackRunReport(obj,event,this,varargin)%#ok
                                                    try
                                                        this.cbkReport([],varargin{:});
                                                    catch ex

                                                        if(~strcmp(ex.identifier,'MATLAB:UDD:DBQUIT'))
                                                            rethrow(ex);
                                                        else
                                                            rptgen.displayMessage(getString(message('rptgen:RptgenML_Root:cancellingLabel')),4);
                                                        end
                                                    end



                                                    function dlgStopTimer(obj,event)%#ok

                                                        delete(obj);
