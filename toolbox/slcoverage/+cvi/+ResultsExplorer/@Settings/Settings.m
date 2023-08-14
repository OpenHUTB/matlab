classdef Settings<handle

    properties(SetObservable=true)
        name=''
        interface=[]
        resultsExplorer=[]
        optionsChanged=[]
    end
    methods(Static=true)
        function settings=create(resultsExplorer)
            settings=cvi.ResultsExplorer.Settings(resultsExplorer);
            settings.interface=SlCovResultsExplorer.Data(resultsExplorer,settings);
        end
    end

    methods


        function settings=Settings(resultsExplorer)
            settings.name=getString(message('Slvnv:simcoverage:cvresultsexplorer:Settings'));
            settings.resultsExplorer=resultsExplorer;

        end


        function label=getDisplayLabel(obj)
            label=obj.name;
        end

        function retVal=getPropertyStyle(~,~)
            retVal=DAStudio.PropertyStyle;
            retVal.Tooltip=getString(message('Slvnv:simcoverage:cvresultsexplorer:Settings'));

        end


        function icon=getDisplayIcon(~)
            icon=fullfile(matlabroot,'toolbox','slcoverage','+cvi','+ResultsExplorer','@ResultsExplorer','icons','Settings.png');

        end

        function cm=getContextMenu(~)
            try
                cm=[];
            catch MEx
                display(MEx.stack(1));
            end
        end

        function optionsChangeCallback(obj,value,fieldName)
            obj.optionsChanged.(fieldName)=value;
        end

        function[status,id]=optionsApplyCallback(obj,~)
            status=true;
            id='';
            obj.resultsExplorer.setOptions(obj.optionsChanged);
        end


        function dlg=getDialogSchema(obj,~)
            tag='Settings_';
            dlg.DialogTitle=getString(message('Slvnv:simcoverage:cvresultsexplorer:Settings'));
            dlg.LayoutGrid=[4,3];
            dlg.Items={obj.getOptionsTab(tag)};
            dlg.Sticky=true;
            dlg.DialogTag=[tag,'dialog'];
            dlg.PostApplyArgs={obj,'%dialog'};
            dlg.PostApplyCallback='optionsApplyCallback';
            dlg.HelpArgs={dlg.DialogTag};
            dlg.HelpMethod='cvi.ResultsExplorer.ResultsExplorer.helpFcn';
        end


    end

end