classdef(Hidden,Sealed)SensorArrayApp<handle





    properties(Access=protected)

        FullyRendered=false;
        ListRatio=0.26
Listeners
    end

    properties(Hidden,Transient,SetAccess=private,GetAccess=public)
ToolGroup
    end

    properties(Hidden)


ToolStripDisplay



ParametersPanel
ParametersFig


SubarrayPartitionFig
SubarrayLabels


ArrayCharTable
ArrayCharacteristicFig
ArrayCharacteristics
ArrayDir
XSpan
YSpan
ZSpan
AzLobe
ElLobe
ElementPolarization


ArrayGeometryFig
Pattern3DFig
AzPatternFig
ElPatternFig
UPatternFig
GratingLobeFig


CurrentArray
CurrentElement


PropagationSpeed
SignalFrequencies
        SteeringAngle=[0;0]
        PhaseQuanBits=0
CurrentWeights

        IsSubarray=false
        SubarraySteeringAngle=[0;0]
        SubarrayPhaseQuanBits=3
        SubarrayPhaseShifterFreq=3e8
        ElementWeights=1
ElementIndex
SubarrayElementWeights


        IsStale=false



        IsChanged=false;

        DefaultSaveName='SensorArraySession'
DefaultSessionName
        MatFilePath=''


StoreData
StoreDataIndex
StoreNames


BannerMessage
BannerMessage3D


Container


ParametersFigGroup
ArrayCharacteristicFigGroup


ParametersDoc
ArrayCharacteristicsPanel
DefineSubarrayDoc

ArrayGeometryDoc
Pattern3DDoc
AzPatternDoc
ElPatternDoc
UPatternDoc
GratingLobeDoc

ArrayGeometryTab
Pattern3DTab
AzPatternTab
ElPatternTab
GratingLobeTab
UPatternTab
importData
    end

    properties(Hidden,SetAccess=private)


pSysObj
        pFromSimulink=false
        pFromCommandLine=false
    end

    methods

        function obj=SensorArrayApp(varargin)

            import matlab.ui.container.internal.AppContainer;
            import matlab.ui.internal.*;

            defaultSensorData=[];
            defaultContainer='AppContainer';
            params=inputParser;
            addOptional(params,'SensorData',defaultSensorData,@(x)obj.validateSensorData(x));
            addParameter(params,'Container',defaultContainer);
            parse(params,varargin{:});

            sensorData=params.Results.SensorData;
            container=params.Results.Container;

            obj.Container=container;




            if(~isempty(sensorData)&&...
                isa(sensorData,'phased.internal.AbstractSensorOperation'))

                obj.pFromSimulink=true;
                obj.pSysObj=varargin{1};
            elseif~isempty(sensorData)
                obj.pFromCommandLine=true;
            end

            if strcmp(obj.Container,'ToolGroup')

                obj.ToolGroup=matlab.ui.internal.desktop.ToolGroup(...
                getString(message('phased:apps:arrayapp:title')));



                obj.ToolGroup.setClosingApprovalNeeded(true);



                group=obj.ToolGroup.Peer.getWrappedComponent;

                group.putGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.APPEND_DOCUMENT_TITLE,false);


                obj.setFrameSize();


                obj.ToolGroup.hideViewTab();
                obj.ToolGroup.disableDataBrowser();


                obj.ToolStripDisplay=phased.apps.internal.ToolStripInitialize(obj);


                obj.ToolGroup.open();



                setAppStatus(obj,true);


                obj.ParametersFig=figure('Name',...
                getString(message('phased:apps:arrayapp:Parameters')),...
                'Visible','on','NumberTitle','off',...
                'HandleVisibility','off','IntegerHandle','off',...
                'Tag','arrayParamsFig','DeleteFcn',@(src,event)FiguresBeingDestroyed(obj));
                obj.ToolGroup.addFigure(obj.ParametersFig);


                obj.ParametersPanel=phased.apps.internal.Parameters(obj);


                createListeners(obj)


                initDefault(obj,false)


                md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
                prop=com.mathworks.widgets.desk.DTClientProperty.PERMIT_USER_CLOSE;
                state=java.lang.Boolean.FALSE;
                md.getClient(obj.ParametersFig.Name,obj.ToolGroup.Name).putClientProperty(prop,state);


                if obj.pFromSimulink


                    obj.ParametersFig.Visible='off';
                    importAction(obj,'Simulink')
                else


                    if obj.pFromCommandLine
                        if ischar(varargin{1})||isstring(varargin{1})


                            [pathName,obj.DefaultSessionName,~]=...
                            fileparts(convertStringsToChars(varargin{1}));
                            obj.MatFilePath=[pathName,obj.DefaultSessionName,'.mat'];

                            setAppTitle(obj,obj.DefaultSessionName);
                            tempData=load(varargin{1});
                            data=tempData.arrayAppSession;
                        else
                            data=varargin{1};
                        end
                        importAction(obj,'commandLine',data)
                    end
                end



                disablAndEnableGratingLobe(obj);



                setContextualHelpCallback(obj.ToolGroup,...
                @(h,e)helpview(fullfile(docroot,'phased','helptargets.map'),...
                'array_app'))



                obj.FullyRendered=true;
                setAppStatus(obj,false);



                md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
                md.showClient(obj.ArrayGeometryFig.Name,obj.ToolGroup.Name);


                obj.ToolGroup.SelectedTab='analyzetab';

                approveClose(obj.ToolGroup);
            else

                appOptions.Tag="sensorarrayapp"+"_"+matlab.lang.internal.uuid;
                appOptions.Title=getString(message('phased:apps:arrayapp:title'));

                obj.ToolGroup=AppContainer(appOptions);

                obj.ParametersFigGroup=FigureDocumentGroup();
                obj.ParametersFigGroup.Tag='parameterSettings';
                obj.ArrayCharacteristicFigGroup=FigureDocumentGroup();
                obj.ArrayCharacteristicFigGroup.Tag='arrayCharTable';
                obj.ToolGroup.add(obj.ParametersFigGroup);
                obj.ToolGroup.add(obj.ArrayCharacteristicFigGroup);


                obj.ToolGroup.CanCloseFcn=@(src,event)closeCallbackAC(obj);


                obj.ToolStripDisplay=phased.apps.internal.ToolStripInitialize(obj);
                obj.ToolGroup.Visible=true;

                waitfor(obj.ToolGroup,'State',...
                matlab.ui.container.internal.appcontainer.AppState.RUNNING);


                obj.ToolGroup.Busy=true;

                paramDocOptions.Title=getString(message('phased:apps:arrayapp:Parameters'));
                paramDocOptions.Tag='arrayParamsFig';
                paramDocOptions.DocumentGroupTag=obj.ParametersFigGroup.Tag;
                paramDocOptions.Closable=false;

                obj.ParametersDoc=FigureDocument(paramDocOptions);
                obj.ParametersFig=obj.ParametersDoc.Figure;
                obj.ParametersFig.AutoResizeChildren="off";
                obj.ParametersFig.Internal=false;
                obj.ToolGroup.add(obj.ParametersDoc);


                obj.ParametersPanel=phased.apps.internal.Parameters(obj);


                createListeners(obj)


                initDefault(obj,false)


                if obj.pFromSimulink


                    obj.ParametersDoc.Phantom=true;
                    importAction(obj,'Simulink')
                else


                    if obj.pFromCommandLine
                        if ischar(varargin{1})||isstring(varargin{1})


                            [pathName,obj.DefaultSessionName,~]=...
                            fileparts(convertStringsToChars(varargin{1}));
                            obj.MatFilePath=[pathName,obj.DefaultSessionName,'.mat'];

                            setAppTitle(obj,obj.DefaultSessionName);
                            tempData=load(varargin{1});
                            data=tempData.arrayAppSession;
                        else
                            data=varargin{1};
                        end
                        importAction(obj,'commandLine',data)
                    end
                end



                disablAndEnableGratingLobe(obj);



                helpButton=matlab.ui.internal.toolstrip.qab.QABHelpButton();
                helpButton.DocName='phased/array_app';
                obj.ToolGroup.add(helpButton);



                obj.FullyRendered=true;


                obj.ToolGroup.SelectedToolstripTab=struct('tag','analyzetab');


                obj.ToolGroup.Busy=false;
            end
        end

        function setAppTitle(obj,appName)
            if~obj.pFromSimulink
                mainTitle=strcat(...
                {getString(message('phased:apps:arrayapp:title'))}...
                ,{' - '},{appName});
                if obj.IsChanged
                    mainTitle=strcat(mainTitle,{'*'});
                end
                obj.ToolGroup.Title=mainTitle{1};
            end
        end

        function setFrameSize(obj)

            screenSize=get(groot,'Screensize');



            obj.ToolGroup.setPosition(0.1*screenSize(3),...
            0.1*screenSize(4),0.7*screenSize(3),0.75*screenSize(4));
        end
    end

    methods(Access=?phased.apps.internal.ToolStripInitialize)

        function initDefault(obj,isNewSession)


            import matlab.ui.internal.toolstrip.*
            import matlab.ui.container.internal.AppContainer;
            import matlab.ui.internal.*;
            if isNewSession&&obj.IsChanged
                if strcmp(obj.Container,'ToolGroup')
                    selection=questdlg([getString(message('phased:apps:arrayapp:newquest')),'?'],...
                    getString(message('phased:apps:arrayapp:title')),...
                    getString(message('phased:apps:arrayapp:yes')),...
                    getString(message('phased:apps:arrayapp:no')),...
                    getString(message('phased:apps:arrayapp:cancel')),...
                    getString(message('phased:apps:arrayapp:yes')));
                else
                    selection=uiconfirm(obj.ToolGroup,[getString(message('phased:apps:arrayapp:newquest')),'?'],...
                    getString(message('phased:apps:arrayapp:title')),...
                    'Options',{getString(message('phased:apps:arrayapp:yes')),...
                    getString(message('phased:apps:arrayapp:no')),...
                    getString(message('phased:apps:arrayapp:cancel'))},...
                    'DefaultOption',getString(message('phased:apps:arrayapp:yes')));
                end




                switch selection
                case getString(message('phased:apps:arrayapp:yes'))
                    saveFlag=true;
                case getString(message('phased:apps:arrayapp:no'))
                    saveFlag=false;
                otherwise
                    return;
                end


                if saveFlag
                    saveSucceed=saveAction(obj,'saveitem');
                    if~saveSucceed
                        return;
                    end
                end
            end


            if strcmp(obj.Container,'ToolGroup')
                if isempty(obj.ArrayCharacteristicFig)
                    obj.ArrayCharacteristicFig=figure('Name',...
                    getString(message('phased:apps:arrayapp:ACPanelTitle')),...
                    'Visible','on','NumberTitle','off',...
                    'HandleVisibility','off','IntegerHandle','off',...
                    'Tag','arrayCharaFig','DeleteFcn',@(src,event)FiguresBeingDestroyed(obj));
                    obj.ToolGroup.addFigure(obj.ArrayCharacteristicFig);
                end
            else
                if isempty(obj.ArrayCharacteristicFig)
                    arrayCharFigOptions.Title=getString(message('phased:apps:arrayapp:ACPanelTitle'));
                    arrayCharFigOptions.Tag='arrayCharaFig';
                    arrayCharFigOptions.Region='right';

                    obj.ArrayCharacteristicsPanel=FigurePanel(arrayCharFigOptions);
                    obj.ToolGroup.add(obj.ArrayCharacteristicsPanel);
                    obj.ArrayCharacteristicFig=obj.ArrayCharacteristicsPanel.Figure;
                    obj.ArrayCharacteristicFig.Internal=false;
                end
            end


            selectArrayItem(obj.ToolStripDisplay,'ula')
            selectElementItem(obj.ToolStripDisplay,'isotropicantenna')




            if~isempty(obj.ParametersPanel.ArrayDialog)
                obj.ParametersPanel.ArrayType='';
            end
            obj.ParametersPanel.ArrayType='ula';

            if~isempty(obj.ParametersPanel.ElementDialog)
                obj.ParametersPanel.ElementType='';
            end
            obj.ParametersPanel.ElementType='isotropicantenna';



            if obj.IsSubarray


                obj.IsSubarray=false;

                obj.ToolStripDisplay.ArrayButton.Value=true;
                adjustLayout(obj);

                obj.SubarraySteeringAngle=[0;0];
                obj.SubarrayPhaseQuanBits=3;
                obj.SubarrayPhaseShifterFreq=3e8;
                obj.ElementWeights=1;

                obj.ToolStripDisplay.SubarrayAzSteerEdit.Value=mat2str(obj.SubarraySteeringAngle(1));
                obj.ToolStripDisplay.SubarrayElSteerEdit.Value=mat2str(obj.SubarraySteeringAngle(2));
                obj.ToolStripDisplay.SubarrayPhaseQuanEdit.Value=mat2str(obj.SubarrayPhaseQuanBits);
                obj.ToolStripDisplay.SubarrayPhaseQuanFreqEdit.Value=mat2str(obj.SubarrayPhaseShifterFreq);
                obj.ToolStripDisplay.SubarrayCustomWeightEdit.Value=mat2str(obj.ElementWeights);
            end
            updateElementObject(obj.ParametersPanel.ElementDialog);
            updateArrayObject(obj.ParametersPanel.ArrayDialog);

            obj.ParametersPanel.ArrayDialog.Panel.Title=...
            assignArrayDialogTitle(obj.ParametersPanel.ArrayDialog);

            disableSubarraySteeringOptions(obj);
            updatePropSpeedandFrequency(obj)


            obj.SteeringAngle=[0;0];
            obj.PhaseQuanBits=3;

            obj.ToolStripDisplay.AzSteerEdit.Value=mat2str(obj.SteeringAngle(1));
            obj.ToolStripDisplay.ElSteerEdit.Value=mat2str(obj.SteeringAngle(2));
            obj.ToolStripDisplay.PhaseShiftCheck.Value=false;
            obj.ToolStripDisplay.PhaseQuanEdit.Value=mat2str(obj.PhaseQuanBits);
            obj.ToolStripDisplay.PhaseQuanEdit.Enabled=false;


            updateArrayCharTable(obj);

            if strcmp(obj.Container,'ToolGroup')

                md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
                prop=com.mathworks.widgets.desk.DTClientProperty.PERMIT_USER_CLOSE;
                state=java.lang.Boolean.FALSE;
                md.getClient(obj.ArrayCharacteristicFig.Name,obj.ToolGroup.Name).putClientProperty(prop,state);
            end

            notify(obj.ToolStripDisplay,'NewPlotRequest',...
            phased.apps.internal.controller.NewPlotEventData(...
            'arrayGeoFig'));
            obj.ToolStripDisplay.PlotButtons{1}.Value=true;

            if strcmp(obj.Container,'ToolGroup')

                if(~isempty(obj.SubarrayPartitionFig)&&isvalid(obj.SubarrayPartitionFig))
                    close(obj.SubarrayPartitionFig);
                end

                figClients=getFiguresDropTargetHandler(obj.ToolGroup);



                plotTag=cell(numel(figClients.CloseListeners));
                plotFig=plotTag;


                for i=1:numel(figClients.CloseListeners)
                    plotTag{i}=figClients.CloseListeners(i).Source{1}.Tag;
                    plotFig{i}=figClients.CloseListeners(i).Source{1};
                end



                for i=1:numel(figClients.CloseListeners)
                    if~strcmp(plotTag{i},{'arrayGeoFig','arrayCharaFig',...
                        'arrayParamsFig','subarrayparamsfig'})
                        delete(plotFig{i});
                    end
                end
            else

                if~isempty(obj.SubarrayPartitionFig)&&isvalid(obj.SubarrayPartitionFig)
                    closeDocument(obj.ToolGroup,"parameterSettings","subarrayparamsfig");
                end
                removeAllMessages(obj.BannerMessage);



                if has(obj.ToolGroup,"DOCUMENT","3dpattab_group","3dpattab")
                    closeDocument(obj.ToolGroup,"3dpattab_group","3dpattab");
                end

                if has(obj.ToolGroup,"DOCUMENT","LobeDiagTab_group","LobeDiagTab")
                    closeDocument(obj.ToolGroup,"LobeDiagTab_group","LobeDiagTab");
                end

                if has(obj.ToolGroup,"DOCUMENT","2DAzpattab_group","2DAzpattab")
                    closeDocument(obj.ToolGroup,"2DAzpattab_group","2DAzpattab");
                end
                if has(obj.ToolGroup,"DOCUMENT","2DElpattab_group","2DElpattab")
                    closeDocument(obj.ToolGroup,"2DElpattab_group","2DElpattab");
                end
                if has(obj.ToolGroup,"DOCUMENT","2DUcuttab_group","2DUcuttab")
                    closeDocument(obj.ToolGroup,"2DUcuttab_group","2DUcuttab");
                end
            end

            obj.ToolStripDisplay.PlotButtons{2}.Value=false;
            obj.ToolStripDisplay.PlotButtons{4}.Value=false;
            obj.ToolStripDisplay.Plot2DItems{1}.Value=false;
            obj.ToolStripDisplay.Plot2DItems{2}.Value=false;
            obj.ToolStripDisplay.Plot2DItems{3}.Value=false;

            obj.DefaultSessionName='untitled';

            obj.MatFilePath='';

            obj.IsChanged=false;
            setAppTitle(obj,obj.DefaultSessionName);



            disablAndEnableGratingLobe(obj);



            disableAnalyzeButton(obj);


            generateAndApplyLayout(obj,obj.pFromSimulink)

        end
    end

    methods(Access=protected)
        function createListeners(obj)


            elemGalleryControl=...
            phased.apps.internal.controller.ElementGalleryController(obj);
            arrayGalleryControl=...
            phased.apps.internal.controller.ArrayGalleryController(obj);

            if strcmp(obj.Container,'ToolGroup')

                if~obj.pFromSimulink
                    addlistener(obj.ToolGroup,...
                    'GroupAction',@(src,event)closeCallback(obj,event));
                else


                    addlistener(obj.ToolGroup,...
                    'GroupAction',@(src,event)closeFromSimulinkCallback(obj,event));
                end
            end


            for i=1:length(obj.ToolStripDisplay.ArrayGalleryItems)
                tmpItem=obj.ToolStripDisplay.ArrayGalleryItems{i};
                addlistener(tmpItem,...
                'ValueChanged',...
                @(src,evt)arrayGalleryControl.execute(src,evt));
            end


            for i=1:length(obj.ToolStripDisplay.ElementGalleryItems)
                tmpItem=obj.ToolStripDisplay.ElementGalleryItems{i};
                addlistener(tmpItem,...
                'ValueChanged',...
                @(src,evt)elemGalleryControl.execute(src,evt));
            end
        end
    end

    methods(Access=?phased.apps.internal.ToolStripInitialize)
        function addTabGroup(obj,tabGroup)

            obj.ToolGroup.addTabGroup(tabGroup);
        end
    end

    methods(Hidden)
        function updatePropSpeedandFrequency(obj)

            obj.PropagationSpeed=obj.ParametersPanel.ElementDialog.PropSpeed;
            obj.SignalFrequencies=obj.ParametersPanel.ElementDialog.SignalFreq;
        end

        function enableAnalyzeButton(obj)

            obj.ParametersPanel.ApplyDialog.ApplyButton.Enable='on';
        end

        function disableAnalyzeButton(obj)

            obj.ParametersPanel.ApplyDialog.ApplyButton.Enable='off';
        end

        function disablAndEnableGratingLobe(obj)





            if~obj.pFromSimulink
                isULA=obj.ToolStripDisplay.ArrayGalleryItems{1}.Value;
                isURA=obj.ToolStripDisplay.ArrayGalleryItems{2}.Value;
                isUHA=obj.ToolStripDisplay.ArrayGalleryItems{4}.Value;
                isCircPlanar=obj.ToolStripDisplay.ArrayGalleryItems{5}.Value;
                isSubarray=isa(obj.CurrentArray,'phased.internal.AbstractSubarray');
                invalidforGLDiag=~isULA&&~isURA&&~isUHA&&~isCircPlanar;



                disableGLDiag=(~isSubarray&&invalidforGLDiag)||isSubarray;
            else
                disableGLDiag=isa(obj.CurrentArray,'phased.ConformalArray')...
                ||isa(obj.CurrentArray,'phased.UCA')||...
                isa(obj.CurrentArray,'phased.internal.AbstractSubarray');
            end

            if disableGLDiag

                obj.ToolStripDisplay.PlotButtons{4}.Value=false;
                obj.ToolStripDisplay.PlotButtons{4}.Enabled=false;



                if~isempty(obj.GratingLobeFig)&&isvalid(obj.GratingLobeFig)
                    if strcmp(obj.Container,'ToolGroup')
                        delete(obj.GratingLobeFig);
                    else
                        closeDocument(obj.ToolGroup,"LobeDiagTab_group","LobeDiagTab");
                    end
                end
            else

                obj.ToolStripDisplay.PlotButtons{4}.Enabled=true;
            end
        end

        function matFilePath=getMatFilePath(obj)

            if isempty(obj.MatFilePath)
                [matFile,pathName]=...
                uiputfile({'*.mat',...
                'Sensor Array Analyzer MAT-Files(*.mat)'},...
                getString(message('phased:apps:arrayapp:saveasdialog')),...
                [obj.DefaultSaveName,'.mat']);
            else
                [matFile,pathName]=...
                uiputfile('*.mat',...
                getString(message('phased:apps:arrayapp:saveasdialog')),...
                obj.MatFilePath);
            end

            isCanceled=isequal(matFile,0)||isequal(pathName,0);

            if isCanceled
                matFilePath=0;
                return;
            else
                matFilePath=[pathName,matFile];
            end

        end

        function approvalFlag=approveClose(obj)
            if strcmp(obj.Container,'ToolGroup')
                cond=isWaiting(obj.ToolGroup);
            else
                cond=obj.ToolGroup.Busy;
            end
            if~obj.pFromSimulink
                if~isempty(obj.ToolGroup)&&isvalid(obj.ToolGroup)
                    if~obj.FullyRendered||cond
                        if strcmp(obj.Container,'ToolGroup')
                            obj.ToolGroup.vetoClose();
                        end
                        approvalFlag=false;
                        return;
                    end

                    if obj.IsChanged


                        if strcmp(obj.Container,'ToolGroup')
                            selection=questdlg([getString(message('phased:apps:arrayapp:closequest')),'?'],...
                            getString(message('phased:apps:arrayapp:savebutton')),...
                            getString(message('phased:apps:arrayapp:yes')),...
                            getString(message('phased:apps:arrayapp:no')),...
                            getString(message('phased:apps:arrayapp:cancel')),...
                            getString(message('phased:apps:arrayapp:yes')));
                        else
                            selection=uiconfirm(obj.ToolGroup,[getString(message('phased:apps:arrayapp:closequest')),'?'],...
                            getString(message('phased:apps:arrayapp:title')),...
                            'Options',{getString(message('phased:apps:arrayapp:yes')),...
                            getString(message('phased:apps:arrayapp:no')),...
                            getString(message('phased:apps:arrayapp:cancel'))},...
                            'DefaultOption',getString(message('phased:apps:arrayapp:yes')));
                        end




                        switch selection
                        case getString(message('phased:apps:arrayapp:yes'))
                            approvalFlag=saveAction(obj,'saveitem');
                        case getString(message('phased:apps:arrayapp:no'))
                            approvalFlag=true;
                        otherwise
                            approvalFlag=false;
                        end
                    else
                        approvalFlag=true;
                    end
                end
            else
                if~isempty(obj.ToolGroup)&&isvalid(obj.ToolGroup)
                    if cond
                        if strcmp(obj.Container,'ToolGroup')
                            obj.ToolGroup.vetoClose();
                        end
                        approvalFlag=false;
                    else
                        approvalFlag=true;
                    end
                end
            end
        end

        function FiguresBeingDestroyed(obj)
            if isvalid(obj)
                if~obj.pFromSimulink
                    delete(obj);
                else
                    if~approveClose(obj)
                        obj.ToolGroup.vetoClose();
                    else
                        close(obj.ToolGroup);
                    end
                end
            end
        end

        function result=closeCallbackAC(obj)
            if~approveClose(obj)
                result=false;
            else
                if obj.pFromSimulink

                    obj.IsStale=true;
                end
                result=true;
            end
        end
        function closeCallback(obj,event)

            ET=event.EventData.EventType;
            if strcmp(ET,'CLOSING')
                if~approveClose(obj)
                    obj.ToolGroup.vetoClose();
                else
                    delete(obj.ParametersFig);
                end

            elseif strcmp(ET,'CLOSED')
                delete(obj);
            end
        end

        function closeFromSimulinkCallback(obj,event)

            ET=event.EventData.EventType;
            if strcmp(ET,'CLOSING')
                if~approveClose(obj)
                    obj.ToolGroup.vetoClose();
                else

                    if~isvalid(obj.ParametersFig)
                        close(obj.ToolGroup);
                    else
                        close(obj.ParametersFig)
                    end
                end

                obj.IsStale=true;
            elseif strcmp(ET,'CLOSED')
                if~isempty(obj.ToolGroup)&&isvalid(obj.ToolGroup)
                    delete(obj.ToolGroup)
                end
            end
        end

        function flag=isStale(obj)
            flag=obj.IsStale;
        end

        function delete(obj)

            if~isempty(obj.ToolGroup)&&isvalid(obj.ToolGroup)
                if strcmp(obj.Container,'ToolGroup')
                    obj.ToolGroup.setClosingApprovalNeeded(false);
                    obj.ToolGroup.approveClose();
                    obj.ToolGroup.close();
                end
                delete(obj.ToolGroup);
            end
        end

        function phaseBits=getCurrentPhaseQuanBits(obj)
            if~obj.pFromSimulink
                if obj.ToolStripDisplay.PhaseShiftCheck.Value
                    phaseBits=obj.PhaseQuanBits;
                else
                    phaseBits=0;
                end
            else
                phaseBits=0;
            end
        end

        function elemWeight=computeElementWeights(obj,weights)


            if isscalar(weights)&&~iscell(weights)
                if isa(obj.CurrentArray,'phased.PartitionedArray')
                    Ns=getNumSubarrays(obj.CurrentArray);
                    Nse=sum(logical(obj.CurrentArray.SubarraySelection),2);
                    Nsemax=max(Nse);
                    obj.ElementWeights=weights*ones(Nsemax,Ns);
                    for i=1:Ns
                        obj.ElementIndex{i}=find(obj.CurrentArray.SubarraySelection(i,:))';
                        obj.SubarrayElementWeights{i}=ones(1,numel(obj.ElementIndex{i}));
                    end
                else
                    Nse=getNumElements(obj.CurrentArray.Subarray);
                    Ns=getNumSubarrays(obj.CurrentArray);
                    obj.ElementWeights=weights*ones(Nse,Ns);
                end
            else
                obj.ElementWeights=weights;
            end
            elemWeight=obj.ElementWeights;
        end

        function disableSubarraySteeringOptions(obj)

            obj.ToolStripDisplay.SubarraySteerPopup.SelectedIndex=1;
            obj.ToolStripDisplay.SubarraySteerPopup.Enabled=false;
            obj.ToolStripDisplay.SubarraySteerTypeLabel.Enabled=false;
            obj.ToolStripDisplay.SubarraySteerPopup.Enabled=false;
            obj.ToolStripDisplay.SubarrayAzSteerLabel.Enabled=false;
            obj.ToolStripDisplay.SubarrayAzSteerEdit.Enabled=false;
            obj.ToolStripDisplay.SubarrayElSteerLabel.Enabled=false;
            obj.ToolStripDisplay.SubarrayElSteerEdit.Enabled=false;
            obj.ToolStripDisplay.SubarrayPhaseQuanLabel.Enabled=false;
            obj.ToolStripDisplay.SubarrayPhaseQuanEdit.Enabled=false;
            obj.ToolStripDisplay.SubarrayPhaseQuanFreqLabel.Enabled=false;
            obj.ToolStripDisplay.SubarrayPhaseQuanFreqEdit.Enabled=false;
            obj.ToolStripDisplay.SubarrayCustomWeightLabel.Enabled=false;
            obj.ToolStripDisplay.SubarrayCustomWeightEdit.Enabled=false;


            obj.SubarraySteeringAngle=[0;0];
            obj.SubarrayPhaseQuanBits=3;
            obj.SubarrayPhaseShifterFreq=3e8;

            obj.ToolStripDisplay.SubarrayAzSteerEdit.Value='0';
            obj.ToolStripDisplay.SubarrayElSteerEdit.Value='0';
            obj.ToolStripDisplay.SubarrayPhaseQuanEdit.Value=mat2str(obj.SubarrayPhaseQuanBits);
            obj.ToolStripDisplay.SubarrayPhaseQuanFreqEdit.Value=mat2str(obj.SubarrayPhaseShifterFreq);
            obj.ToolStripDisplay.SubarrayCustomWeightEdit.Value='1';
        end

        function enableSubarraySteeringOptions(obj)

            obj.ToolStripDisplay.SubarraySteerTypeLabel.Enabled=true;
            obj.ToolStripDisplay.SubarraySteerPopup.Enabled=true;
            obj.ToolStripDisplay.SubarrayAzSteerLabel.Enabled=false;
            obj.ToolStripDisplay.SubarrayAzSteerEdit.Enabled=false;
            obj.ToolStripDisplay.SubarrayElSteerLabel.Enabled=false;
            obj.ToolStripDisplay.SubarrayElSteerEdit.Enabled=false;
            obj.ToolStripDisplay.SubarrayPhaseQuanLabel.Enabled=false;
            obj.ToolStripDisplay.SubarrayPhaseQuanEdit.Enabled=false;
            obj.ToolStripDisplay.SubarrayPhaseQuanFreqLabel.Enabled=false;
            obj.ToolStripDisplay.SubarrayPhaseQuanFreqEdit.Enabled=false;
            obj.ToolStripDisplay.SubarrayCustomWeightLabel.Enabled=false;
            obj.ToolStripDisplay.SubarrayCustomWeightEdit.Enabled=false;
            switch obj.ToolStripDisplay.SubarraySteerPopup.Value
            case getString(message('phased:apps:arrayapp:nosubarraysteering'))
                obj.SubarraySteeringAngle=[0;0];
                obj.SubarrayPhaseQuanBits=3;
                obj.SubarrayPhaseShifterFreq=3e8;

                obj.ToolStripDisplay.SubarrayAzSteerEdit.Value='0';
                obj.ToolStripDisplay.SubarrayElSteerEdit.Value='0';
                obj.ToolStripDisplay.SubarrayPhaseQuanEdit.Value=mat2str(obj.SubarrayPhaseQuanBits);
                obj.ToolStripDisplay.SubarrayPhaseQuanFreqEdit.Value=mat2str(obj.SubarrayPhaseShifterFreq);
                obj.ToolStripDisplay.SubarrayCustomWeightEdit.Value='1';
            case getString(message('phased:apps:arrayapp:timesubarraysteering'))
                obj.ToolStripDisplay.SubarrayAzSteerLabel.Enabled=true;
                obj.ToolStripDisplay.SubarrayAzSteerEdit.Enabled=true;
                obj.ToolStripDisplay.SubarrayElSteerLabel.Enabled=true;
                obj.ToolStripDisplay.SubarrayElSteerEdit.Enabled=true;


                obj.SubarrayPhaseQuanBits=3;
                obj.SubarrayPhaseShifterFreq=3e8;

                obj.ToolStripDisplay.SubarrayPhaseQuanEdit.Value=mat2str(obj.SubarrayPhaseQuanBits);
                obj.ToolStripDisplay.SubarrayPhaseQuanFreqEdit.Value=mat2str(obj.SubarrayPhaseShifterFreq);
                obj.ToolStripDisplay.SubarrayCustomWeightEdit.Value='1';
            case getString(message('phased:apps:arrayapp:phasesubarraysteering'))
                obj.ToolStripDisplay.SubarrayAzSteerLabel.Enabled=true;
                obj.ToolStripDisplay.SubarrayAzSteerEdit.Enabled=true;
                obj.ToolStripDisplay.SubarrayElSteerLabel.Enabled=true;
                obj.ToolStripDisplay.SubarrayElSteerEdit.Enabled=true;
                obj.ToolStripDisplay.SubarrayPhaseQuanLabel.Enabled=true;
                obj.ToolStripDisplay.SubarrayPhaseQuanEdit.Enabled=true;
                obj.ToolStripDisplay.SubarrayPhaseQuanFreqLabel.Enabled=true;
                obj.ToolStripDisplay.SubarrayPhaseQuanFreqEdit.Enabled=true;


                obj.ToolStripDisplay.SubarrayCustomWeightEdit.Value='1';
            case getString(message('phased:apps:arrayapp:customsubarraysteering'))
                obj.ToolStripDisplay.SubarrayCustomWeightLabel.Enabled=true;
                obj.ToolStripDisplay.SubarrayCustomWeightEdit.Enabled=true;


                obj.SubarraySteeringAngle=[0;0];
                obj.SubarrayPhaseQuanBits=3;
                obj.SubarrayPhaseShifterFreq=3e8;

                obj.ToolStripDisplay.SubarrayAzSteerEdit.Value='0';
                obj.ToolStripDisplay.SubarrayElSteerEdit.Value='0';
                obj.ToolStripDisplay.SubarrayPhaseQuanEdit.Value=mat2str(obj.SubarrayPhaseQuanBits);
                obj.ToolStripDisplay.SubarrayPhaseQuanFreqEdit.Value=mat2str(obj.SubarrayPhaseShifterFreq);
            end
        end

        function updateSubarraySteering(obj)

            if obj.IsSubarray
                if isa(obj.CurrentArray,'phased.internal.AbstractSubarray')
                    switch obj.ToolStripDisplay.SubarraySteerPopup.Value
                    case getString(message('phased:apps:arrayapp:nosubarraysteering'))
                        obj.CurrentArray.SubarraySteering='None';
                    case getString(message('phased:apps:arrayapp:timesubarraysteering'))
                        obj.CurrentArray.SubarraySteering='Time';
                    case getString(message('phased:apps:arrayapp:phasesubarraysteering'))
                        obj.CurrentArray.SubarraySteering='Phase';
                        obj.CurrentArray.NumPhaseShifterBits=...
                        obj.SubarrayPhaseQuanBits;
                        obj.CurrentArray.PhaseShifterFrequency=...
                        obj.SubarrayPhaseShifterFreq;
                    case getString(message('phased:apps:arrayapp:customsubarraysteering'))
                        obj.CurrentArray.SubarraySteering='Custom';
                        computeElementWeights(obj,obj.ElementWeights);
                    end
                end
            end
        end

        function validateElementWeights(obj,ws)




            cond=(~iscell(ws)&&~ismatrix(ws))||isempty(ws);
            if cond
                error(getString(message('phased:phased:expectedCellOrMatrix',...
                getString(message('phased:apps:arrayapp:subarrayelementweights')))));
            end

            if isa(obj.CurrentArray,'phased.PartitionedArray')
                Ns=getNumSubarrays(obj.CurrentArray);
                Nse=sum(logical(obj.CurrentArray.SubarraySelection),2);

                if iscell(ws)
                    cond1=~isrow(ws)||(numel(ws)~=Ns);

                    if cond1
                        error(getString(message('phased:phased:expectedMatrixSize',...
                        getString(message('phased:apps:arrayapp:subarrayelementweights')),1,Ns)));
                    end
                    for m=1:Ns
                        cond2=~iscolumn(ws{m})||(numel(ws{m})~=Nse(m));
                        if cond2
                            error(getString(message('phased:system:array:SubarrayElementWeightsSizeMismatch',m,...
                            getString(message('phased:apps:arrayapp:subarrayelementweights')),Nse(m))));
                        end
                        cond3=~isa(ws{m},'double');
                        if cond3
                            error(getString(message('phased:system:array:SubarrayElementWeightsInvalidDataType',m,...
                            getString(message('phased:apps:arrayapp:subarrayelementweights')),'double')));
                        end
                        cond4=any(~isfinite(ws{m}));
                        if cond4
                            validateattributes(ws{m},{'double'},{'finite'},'',...
                            getString(message('phased:apps:arrayapp:subarrayelementweights')));
                        end
                    end
                else
                    sz_ws=size(ws);
                    Nsemax=max(Nse);
                    cond1=~isequal(sz_ws,[Nsemax,Ns]);
                    if cond1
                        error(getString(message('phased:phased:expectedMatrixSize',...
                        getString(message('phased:apps:arrayapp:subarrayelementweights')),Nsemax,Ns)));
                    end
                end
            else
                Nse=getNumElements(obj.CurrentArray.Subarray);
                Ns=getNumSubarrays(obj.CurrentArray);
                sz_ws=size(ws);

                cond1=~isequal(sz_ws,[Nse,Ns]);
                if cond1
                    error(getString(message('phased:phased:expectedMatrixSize',...
                    getString(message('phased:apps:arrayapp:subarrayelementweights')),Nse,Ns)));
                end
            end
        end

        function adjustLayout(obj)
            if strcmp(obj.Container,'ToolGroup')
                if obj.IsSubarray
                    removeAll(obj.ParametersPanel.Layout);

                    obj.ParametersPanel.Layout.VerticalWeights=[0,0,0,1];
                    obj.ParametersPanel.AdditionalConfigDialog.Panel.Visible='on';

                    add(obj.ParametersPanel.Layout,...
                    obj.ParametersPanel.ApplyDialog.Panel,4,1,...
                    'MinimumWidth',obj.ParametersPanel.ApplyDialog.Width,...
                    'Fill','Horizontal',...
                    'MinimumHeight',obj.ParametersPanel.ApplyDialog.Height,...
                    'Anchor','North')


                    add(obj.ParametersPanel.Layout,...
                    obj.ParametersPanel.ElementDialog.Panel,3,1,...
                    'MinimumWidth',obj.ParametersPanel.ElementDialog.Width,...
                    'Fill','Horizontal',...
                    'MinimumHeight',obj.ParametersPanel.ElementDialog.Height,...
                    'Anchor','North')


                    add(obj.ParametersPanel.Layout,...
                    obj.ParametersPanel.AdditionalConfigDialog.Panel,2,1,...
                    'MinimumWidth',obj.ParametersPanel.AdditionalConfigDialog.Width,...
                    'Fill','Horizontal',...
                    'MinimumHeight',obj.ParametersPanel.AdditionalConfigDialog.Height,...
                    'Anchor','North')


                    add(obj.ParametersPanel.Layout,...
                    obj.ParametersPanel.ArrayDialog.Panel,1,1,...
                    'MinimumWidth',obj.ParametersPanel.ArrayDialog.Width,...
                    'Fill','Horizontal',...
                    'MinimumHeight',obj.ParametersPanel.ArrayDialog.Height,...
                    'Anchor','North')
                else

                    if size(obj.ParametersPanel.Layout.Grid,1)==4


                        if~isnan(obj.ParametersPanel.Layout.Grid(4))
                            remove(obj.ParametersPanel.Layout,4,1);
                            obj.ParametersPanel.Layout.VerticalWeights=[0,0,1];
                            delete(obj.ParametersPanel.AdditionalConfigDialog.Panel);
                        end
                    end
                    removeAll(obj.ParametersPanel.Layout);

                    add(obj.ParametersPanel.Layout,...
                    obj.ParametersPanel.ApplyDialog.Panel,3,1,...
                    'MinimumWidth',obj.ParametersPanel.ApplyDialog.Width,...
                    'Fill','Horizontal',...
                    'MinimumHeight',obj.ParametersPanel.ApplyDialog.Height,...
                    'Anchor','North')


                    add(obj.ParametersPanel.Layout,...
                    obj.ParametersPanel.ElementDialog.Panel,2,1,...
                    'MinimumWidth',obj.ParametersPanel.ElementDialog.Width,...
                    'Fill','Horizontal',...
                    'MinimumHeight',obj.ParametersPanel.ElementDialog.Height,...
                    'Anchor','North')


                    add(obj.ParametersPanel.Layout,...
                    obj.ParametersPanel.ArrayDialog.Panel,1,1,...
                    'MinimumWidth',obj.ParametersPanel.ArrayDialog.Width,...
                    'Fill','Horizontal',...
                    'MinimumHeight',obj.ParametersPanel.ArrayDialog.Height,...
                    'Anchor','North')
                end

                update(obj.ParametersPanel.Layout,'force');
            else
                if obj.IsSubarray
                    obj.ParametersPanel.ArrayDialog.Panel.Layout=...
                    matlab.ui.layout.GridLayoutOptions('Row',1,'Column',1);
                    obj.ParametersPanel.AdditionalConfigDialog.Panel.Layout=...
                    matlab.ui.layout.GridLayoutOptions('Row',2,'Column',1);
                    obj.ParametersPanel.ElementDialog.Panel.Layout=...
                    matlab.ui.layout.GridLayoutOptions('Row',3,'Column',1);
                    obj.ParametersPanel.ApplyDialog.Panel.Layout=...
                    matlab.ui.layout.GridLayoutOptions('Row',4,'Column',1);
                    obj.ParametersPanel.AdditionalConfigDialog.Panel.Visible='on';
                    obj.ParametersPanel.Layout.RowHeight={'fit','fit','fit','fit'};
                else
                    obj.ParametersPanel.ArrayDialog.Panel.Layout=...
                    matlab.ui.layout.GridLayoutOptions('Row',1,'Column',1);
                    obj.ParametersPanel.ElementDialog.Panel.Layout=...
                    matlab.ui.layout.GridLayoutOptions('Row',2,'Column',1);
                    obj.ParametersPanel.ApplyDialog.Panel.Layout=...
                    matlab.ui.layout.GridLayoutOptions('Row',3,'Column',1);
                    if~isempty(obj.ParametersPanel.AdditionalConfigDialog)
                        delete(obj.ParametersPanel.AdditionalConfigDialog.Panel);
                        obj.ParametersPanel.AdditionalConfigDialog=[];
                    end
                    obj.ParametersPanel.Layout.RowHeight={'fit','fit','fit'};
                end
            end
        end
        function setAppStatus(obj,busystate)
            if strcmp(obj.Container,'ToolGroup')
                obj.ToolGroup.setWaiting(busystate);
            else
                obj.ToolGroup.Busy=busystate;
            end
        end
        function throwError(obj,exception)
            if strcmp(exception.identifier,'MATLAB:m_incomplete_statement')

                msg=getString(message('phased:apps:arrayapp:editempty'));
            else
                msg=exception.message;
            end
            if strcmp(obj.Container,'ToolGroup')
                h=errordlg(msg,getString(message(...
                'phased:apps:arrayapp:errordlg')),'modal');
                uiwait(h)
            else
                uialert(obj.ToolGroup,msg,getString(message(...
                'phased:apps:arrayapp:errordlg')))
            end
        end
    end

    methods(Static,Hidden)
        function validateSensorData(x)
            if ischar(x)||isstring(x)
                loadedData=load(x);
                data=loadedData.arrayAppSession;
            else
                if~(isa(x,'phased.Radiator')||isa(x,'phased.Collector'))
                    data=x;
                else
                    data=x.Sensor;
                end
            end
            phased.apps.internal.SensorArrayApp.verifySensorArray(data);
        end
        function isValidSensor=verifySensorArray(sensorArray)

            if phased.apps.internal.SensorArrayApp.isValidSensorArray(sensorArray)
                isValidSensor=true;
            else
                isValidSensor=false;
                errHandle=errordlg(getString(message('phased:apps:arrayapp:invalidimport')));
                set(errHandle,'Tag','ErrorDialogTag');
                return;
            end


            try
                phased.apps.internal.SensorArrayApp.crossValidation(sensorArray);
            catch me
                isValidSensor=false;
                errHandle=errordlg(me.message);
                set(errHandle,'Tag','ErrorDialogTag');
            end
        end
        function[SA,F,PSB]=makeEqualLength(SA,F,PSB,NumSA,NumF,NumPSB)



            maxVectorLength=max([NumF,NumSA,NumPSB]);

            if NumSA==1
                SA=repmat(SA,1,maxVectorLength);
            end
            if NumF==1
                F=F*ones(1,maxVectorLength);
            end
            if NumPSB==1
                PSB=PSB*ones(1,maxVectorLength);
            end
        end
        function[az,el]=makeAnglesOfEqualLength(az,el)

            NumAz=numel(az);
            NumEl=numel(el);
            maxLength=max([NumAz,NumEl]);
            if NumAz==1
                az=az*ones(1,maxLength);
            end
            if NumEl==1
                el=el*ones(1,maxLength);
            end
        end

        function[NumRefPlots,RefPlotAtEndFlag]=computeNumReferencePlots(PSB,NumSA,NumF,NumPSB)

            idx_forRefPlot=find(PSB);


            RefPlotAtEndFlag=0;

            if(NumF==1)&&(NumSA==1)

                if(length(idx_forRefPlot)==NumPSB)
                    NumRefPlots=1;

                    RefPlotAtEndFlag=1;
                else


                    NumRefPlots=0;
                end
            else

                NumRefPlots=length(idx_forRefPlot);
            end
        end

        function isValidSensorArray=isValidSensorArray(sensorArray)


            if isa(sensorArray,'phased.internal.AbstractArray')||...
                isa(sensorArray,'phased.internal.AbstractSubarray')
                if isa(sensorArray,'phased.internal.AbstractSubarray')&&...
                    isa(sensorArray,'phased.ReplicatedSubarray')
                    data=sensorArray.Subarray;
                elseif isa(sensorArray,'phased.internal.AbstractSubarray')&&...
                    isa(sensorArray,'phased.PartitionedArray')
                    data=sensorArray.Array;
                else
                    data=sensorArray;
                end
                isHomogeneousArray=isa(data,'phased.internal.AbstractHomogeneousArray');
            else
                isHomogeneousArray=false;
            end

            if isHomogeneousArray

                if~isa(sensorArray,'phased.internal.AbstractSubarray')
                    data=sensorArray;
                else
                    if isa(sensorArray,'phased.ReplicatedSubarray')
                        data=sensorArray.Subarray;
                    else
                        data=sensorArray.Array;
                    end
                end
                isValidArray=((isa(data,'phased.internal.AbstractArray')));
            else
                isValidArray=false;
            end

            isValidElement=(isa(sensorArray,'phased.internal.AbstractElement')...
            ||isa(sensorArray,'em.Antenna'));

            isValidSensorArray=isValidArray||isValidElement;
        end

        function crossValidation(data)

            if(~isa(data,'phased.internal.AbstractArray')&&...
                ~isa(data,'phased.internal.AbstractSubarray')&&...
                ~isa(data,'em.Antenna'))...
                ||(isa(data,'phased.internal.AbstractArray')...
                &&~isa(data.Element,'em.Antenna'))
                step(data,0,0);
            elseif isa(data,'phased.internal.AbstractSubarray')
                if strcmp(data.SubarraySteering,'None')
                    step(data,0,0,1);
                elseif strcmp(data.SubarraySteering,'Custom')
                    if isa(data,'phased.PartitionedArray')
                        Ns=getNumSubarrays(data);
                        Nse=sum(logical(data.SubarraySelection),2);
                        Nsemax=max(Nse);
                        weights=ones(Nsemax,Ns);
                    else
                        Nse=getNumElements(data.Subarray);
                        Ns=getNumSubarrays(data);
                        weights=ones(Nse,Ns);
                    end
                    step(data,0,0,1,weights);
                else
                    step(data,0,0,1,[0;0]);
                end
            end
        end
        function stringValues=ndmat2str(numericValues,varargin)




            mustBeNumericOrLogical(numericValues);

            if ismatrix(numericValues)

                stringValues=mat2str(numericValues,varargin{:});
            else

                stringValues=['reshape(',phased.apps.internal.SensorArrayApp.ndmat2str(numericValues(:),varargin{:}),',',mat2str(size(numericValues)),')'];
            end
        end
    end
end
