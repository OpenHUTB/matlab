




classdef SimulationPacingDialog<handle





    properties(SetObservable=true)


        modelHandle='';
        mdlName='';
        simStatusChangelistener=[];
        propertyChangelistener=[];
        dlgInstance={};

        Position=[100,100];


        pacingFeatureValue=slfeature('SimulationPacing');
    end

    properties(Hidden)
        Url;
        showHelpSub;
        channelPrefix;
        handleStr;
    end

    methods

        function pacingDlg=SimulationPacingDialog(modelH)

            pacingDlg=pacingDlg@handle;
            pacingDlg.modelHandle=modelH;
            pacingDlg.handleStr=sprintf('%.15f',pacingDlg.modelHandle);
            pacingDlg.handleStr=strrep(pacingDlg.handleStr,'.','_');
            pacingDlg.channelPrefix=['/SimulationPacing/',pacingDlg.handleStr];
            pacingDlg.simStatusChangelistener=handle.listener(...
            DAStudio.EventDispatcher,...
            'SimStatusChangedEvent',...
            {@refreshPacingDialog,pacingDlg});
            pacingDlg.propertyChangelistener=handle.listener(...
            DAStudio.EventDispatcher,...
            'PropertyChangedEvent',...
            {@refreshPacingDialogTitle,pacingDlg});
        end


        function setPositionWrtModelWindow(obj)



            pos=get_param(obj.modelHandle,'Location');

            obj.Position=round([pos(1)+(pos(3)/10),pos(2)+(pos(4)/10)]);
        end


        function showPacingDialog(obj)
            if isempty(obj.dlgInstance)
                obj.dlgInstance=DAStudio.Dialog(obj);


                connector.ensureServiceOn;

                obj.showHelpSub=message.subscribe(...
                [obj.channelPrefix,'/showHelp'],...
                @(msg)obj.showHelpHandler(msg));

            else
                obj.dlgInstance.refresh;
                obj.dlgInstance.show;
            end
        end

        function closePacingDialog(obj,~)
            message.unsubscribe(obj.showHelpSub);
            if~isempty(obj.dlgInstance)
                delete(obj.dlgInstance);
                obj.dlgInstance={};
            end
        end

        function deleteDialog(obj,~)
            if~isempty(obj.dlgInstance)
                message.unsubscribe(obj.showHelpSub);
                delete(obj.dlgInstance);
                obj.dlgInstance={};
            end
        end

        function showHelpHandler(obj,~)
            helpview(...
            fullfile(docroot,'simulink','helptargets.map'),...
            'simulationpacing','CSHelpWindow');
        end


        function dlgstruct=getDialogSchema(obj)

            obj.mdlName=get_param(obj.modelHandle,'Name');

            if ismac
                dlgSize=[400,170];
            else
                dlgSize=[420,185];
            end

            hostInfo=connector.ensureServiceOn;


            dlgstruct.DialogTitle=...
            DAStudio.message('Simulink:studio:SimulationPacingOptions',...
            obj.mdlName);

            if obj.pacingFeatureValue>2
                webbrowser.Debug=true;
                destinationHTML='index-debug.html';
            else
                webbrowser.Debug=false;
                destinationHTML='index.html';
            end


            slInternal('initialiseSimulationPacingService',get_param(obj.modelHandle,'Name'));

            webbrowser.Type='webbrowser';
            obj.Url=[connector.getBaseUrl(...
            ['/toolbox/simulation_pacing/dialog/web/',destinationHTML]),'?modelHdl=',...
            obj.handleStr];
            webbrowser.Url=connector.applyNonce(obj.Url);
            webbrowser.WebKit=true;
            webbrowser.DisableContextMenu=true;
            webbrowser.EnableZoom=false;
            webbrowser.ClearCache=true;
            webbrowser.Enabled=true;
            webbrowser.MinimumSize=dlgSize;


            if obj.pacingFeatureValue>2
                disp(webbrowser.Url);
            end

            dlgstruct.CloseMethod='closePacingDialog';
            dlgstruct.CloseMethodArgs={'%closeaction'};
            dlgstruct.CloseMethodArgsDT={'string'};
            dlgstruct.HelpMethod='doc';
            dlgstruct.HelpArgs={'sim'};
            dlgstruct.LayoutGrid=[1,1];
            dlgstruct.Items={webbrowser};
            dlgstruct.StandaloneButtonSet={''};
            dlgstruct.IsScrollable=false;
            setPositionWrtModelWindow(obj);
            dlgstruct.Geometry=[obj.Position,dlgSize];
            dlgstruct.MinMaxButtons=false;
            dlgstruct.DialogStyle='normal';

        end

        function registerDAListeners(obj)
            bd=get_param(obj.modelHandle,'Object');
            bd.registerDAListeners;
        end

    end
end


function refreshPacingDialog(~,~,obj)
    if~isempty(obj.dlgInstance)
        slInternal('refreshPacingDialog',get_param(obj.modelHandle,'Name'));
    end
end

function refreshPacingDialogTitle(~,~,obj)
    if~isempty(obj.dlgInstance)&&~strcmp(get_param(obj.modelHandle,'Name'),obj.mdlName)
        obj.dlgInstance.refresh;
    end
end

