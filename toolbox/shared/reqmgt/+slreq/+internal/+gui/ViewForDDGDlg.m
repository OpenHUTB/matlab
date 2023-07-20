classdef ViewForDDGDlg<handle


















































    properties(Constant)
        TAG_PREFIX='slreq_propertyinspector_';
        TAG_POSTFIX_FOR_STANDLONE='#?#standalone#?#';
        TAG_STANDALONE='slreq_propertyinspector_#?#standalone#?#';
        CALLER_STANDALONE='standalone';
    end

    properties

        tag;
        caller;
        displayComment=false;
        displayChangeInformation=true;


        enableOuterPanel=true;
        view;
appManager
    end

    methods

        function this=ViewForDDGDlg(appManager)
            this.appManager=appManager;
            this.refreshViewInfo();
        end
    end

    methods(Access=private)

        function this=refreshViewInfo(this)

            this.refreshCallerAndTag();
            this.refreshViewOptions();
        end


        function refreshCallerAndTag(this)
            tFlags=slreq.internal.TempFlags.getInstance;
            this.tag=tFlags.get('CurrentDASDDGTag');
            if isempty(this.tag)
                this.refreshTagCallerFromCurrentView();
            else
                this.refreshCallerFromTag();
                this.refreshView()
            end
        end


        function refreshTagCallerFromCurrentView(this)
            this.view=this.appManager.getCurrentView;
            if slreq.utils.isValidView(this.view)
                this.caller=this.view.sourceID;
                this.refreshTagFromCaller();
            end
        end


        function refreshTagFromCaller(this)


            if this.isStandaloneCaller()
                this.tag=this.TAG_STANDALONE;
            else
                this.tag=[this.TAG_PREFIX,this.caller];
            end
        end


        function refreshCallerFromTag(this)


            if this.isStandaloneTag()
                this.caller=this.CALLER_STANDALONE;
            else
                this.caller=strrep(this.tag,this.TAG_PREFIX,'');
            end
        end


        function refreshViewOptions(this)
            currentView=this.view;
            if slreq.utils.isValidView(currentView)
                this.displayComment=currentView.displayComment;
                this.displayChangeInformation=currentView.displayChangeInformation;
                this.enableOuterPanel=slreq.gui.SelectionStatus.enableOuterPanel(currentView);
            end
        end

        function out=isStandaloneCaller(this)
            out=strcmpi(this.caller,this.CALLER_STANDALONE);
        end

        function out=isStandaloneTag(this)
            out=strcmpi(this.tag,this.TAG_STANDALONE);
        end

        function refreshView(this)
            if this.isStandaloneTag()
                this.view=this.appManager.requirementsEditor;
            elseif isvarname(this.caller)&&dig.isProductInstalled('Simulink')&&is_simulink_loaded&&bdIsLoaded(this.caller)
                this.view=this.appManager.getCurrentView(this.caller);
            else


                this.refreshTagCallerFromCurrentView();
            end


            if~slreq.utils.isValidView(this.view)






























                this.view=this.appManager.getCurrentView;
            end
        end

    end

    methods(Static)
        function refreshDDGDialogs(dlgs)

















            for n=1:length(dlgs)
                cDlg=dlgs(n);
                try
                    cachedTag=slreq.internal.TempFlags.changeFlag('CurrentDASDDGTag',cDlg.dialogTag);%#ok<NASGU>

                    cDlg.refresh();

                    clear('cachedTag')
                catch ex %#ok<NASGU>  in case of dialog is invalid already. 
                    clear('cachedTag')
                    continue;
                end
            end
        end
    end
end




