
































classdef Highlighter<handle

    properties(GetAccess=public,SetAccess=public)

        LastWindowType;
        LastWindow;



        LastStateflowPosition;
        LastSimulinkPosition;
        ConfigSet;

        DefaultPositions;
        UnhighlightAction;
SLEditorStyler
    end


    methods(Access=public)

        function obj=Highlighter(defaultPositions,varargin)
            obj.DefaultPositions=defaultPositions;
            obj.LastWindowType='';
            obj.LastWindow='';
            obj.LastStateflowPosition=obj.DefaultPositions.Stateflow;
            obj.LastSimulinkPosition=obj.DefaultPositions.Simulink;
            if nargin>1
                obj.SLEditorStyler=varargin{1};
            else
                obj.SLEditorStyler=[];
            end
        end

        function highlightLocation(obj,type,itemPath)
            import slxmlcomp.internal.highlight.StringLocation
            location=StringLocation(type,itemPath);


            obj.pUnhighlight();



            [window,window_type]=obj.pGetWindow(location);


            is_same_window=isSameWindow(obj,window,window_type);


            prev_is_visible=obj.pIsVisible();

            if~is_same_window
                obj.closeTestHarnessesForModel(location);
                if prev_is_visible
                    obj.pHide();
                end
            end

            obj.pShow(location,window);

        end

        function isSame=isSameWindow(obj,window,window_type)


            isSameSLSF=ismember(window_type,{'Simulink','Stateflow'})&&...
            ismember(obj.LastWindowType,{'Simulink','Stateflow'})&&...
            strcmp(strtok(window,'/'),strtok(obj.LastWindow,'/'));



            isSameConfigSet=strcmp('ConfigSet',obj.LastWindowType)&&...
            strcmp(window,obj.LastWindow);

            isSame=isSameSLSF||isSameConfigSet;
        end




        function pHide(obj)
            if~isempty(obj.LastWindow)&&...
                bdIsLoaded(strtok(obj.LastWindow,'/'))
                switch obj.LastWindowType
                case 'Simulink'
                    try
                        modelName=strtok(obj.LastWindow,'/');
                        if Simulink.harness.isHarnessBD(modelName)
                            bdclose(modelName);
                        else
                            set_param(obj.LastWindow,'Open','off');
                        end
                    catch E
                        warning(E.identifier,'%s',E.message);
                    end
                case 'Stateflow'
                    try
                        x=slxmlcomp.internal.stateflow.chart.get(obj.LastWindow);
                        x.Visible=false;
                    catch E
                        warning(E.identifier,'%s',E.message);
                    end
                case 'ConfigSet'
                    if~isempty(obj.ConfigSet)
                        obj.ConfigSet.hideDialog;
                    end
                otherwise
                    assert(false,'Bad state');
                end
            end
        end




        function is_visible=pIsVisible(obj)
            is_visible=false;
            if~isempty(obj.LastWindow)&&bdIsLoaded(strtok(obj.LastWindow,'/'))
                switch obj.LastWindowType
                case 'Simulink'
                    try
                        is_visible=strcmp(get_param(obj.LastWindow,'Open'),'on');
                        if is_visible
                            obj.LastSimulinkPosition=get_param(obj.LastWindow,'Location');
                        else

                            obj.pResetPositions();
                        end
                    catch E
                        warning(E.identifier,'%s',E.message);
                    end
                case 'Stateflow'
                    try
                        x=slxmlcomp.internal.stateflow.chart.get(obj.LastWindow);
                        if isempty(x)
                            obj.pResetPositions();
                            return;
                        end
                        is_visible=x.Visible;
                        if is_visible
                            obj.LastStateflowPosition=x.Editor.WindowPosition;
                        else

                            obj.pResetPositions();
                        end
                    catch E
                        warning(E.identifier,'%s',E.message);
                    end
                case 'ConfigSet'
                    if~isempty(obj.ConfigSet)
                        dialog=obj.ConfigSet.getDialogHandle;
                        is_visible=~isempty(dialog);
                        if is_visible
                            pos=dialog.position;
                            obj.LastSimulinkPosition=[pos(1),pos(2),pos(1)+pos(3),pos(2)+pos(4)];
                        end
                    end
                otherwise
                    assert(false,'Bad state');
                end
            elseif~isempty(obj.LastWindow)

                obj.pResetPositions();
            end
        end


        function pResetPositions(obj)
            obj.LastSimulinkPosition=obj.DefaultPositions.Simulink;
            obj.LastStateflowPosition=obj.DefaultPositions.Stateflow;
        end

        function[window,window_type]=pGetWindow(obj,locationObj)
            location=char(locationObj.Location);
            switch locationObj.Type
            case{'System'}
                window=location;
                window_type='Simulink';
            case 'Annotation'
                annotation=slxmlcomp.internal.annotation.find(...
                slxmlcomp.internal.annotation.highlightPathToStruct(location)...
                );
                window=get_param(annotation,'Parent');
                window_type='Simulink';
            case 'Block'
                window=obj.pGetParent(location);
                window_type='Simulink';
            case 'Line'
                slashes=strfind(location,'/');
                assert(~isempty(slashes));
                window=location(1:slashes(end)-1);
                window_type='Simulink';
            case{'chart','state','transition','junction','SFBlock',...
                'SimulinkTruthTable','StateflowTruthTable','StateflowMatlabFunction','EMLChart',...
                'SimulinkMatlabFunction','TruthTableChart',...
                'TestSequenceChart','ConditionTable'}
                window=location;
                window_type='Stateflow';
            case 'ConfigSet'
                window_type='ConfigSet';
                window=obj.pGetConfigSetWindow(location);
            otherwise
                slxmlcomp.internal.error(...
                'reverseannotation:UnknownLocationType',...
                locationObj.Type...
                );
            end
        end


        function pShow(obj,locationObj,new_window)
            import slxmlcomp.internal.highlight.StringLocation

            obj.LastWindow='';
            obj.LastWindowType='';
            location=locationObj.Location;
            switch(locationObj.Type)
            case{'System','Annotation','Block','Line'}
                obj.pShowSimulink(locationObj,new_window);

            case 'ConfigSet'
                obj.pShowConfigSet(char(locationObj.Location));

            case "StateflowTruthTable"
                stateflowInfo=slxmlcomp.internal.stateflow.stateflowPathToStruct(location);
                truthTable=slxmlcomp.internal.stateflow.chart.get(stateflowInfo.Block);
                obj.pShowTruthTable(truthTable)

            case{"ConditionTable","TruthTableChart","SimulinkTruthTable"}
                stateflowInfo=slxmlcomp.internal.stateflow.stateflowPathToStruct(location);
                truthTable=slxmlcomp.internal.stateflow.chart.get(stateflowInfo.Block,'Stateflow.TruthTable');
                obj.pShowTruthTable(truthTable)

            case "SimulinkMatlabFunction"
                stateflowInfo=slxmlcomp.internal.stateflow.stateflowPathToStruct(location);
                x=slxmlcomp.internal.stateflow.chart.get(stateflowInfo.Block,'Stateflow.EMChart');
                import slxmlcomp.internal.highlight.StringLocation
                newLocation=StringLocation("Block",x.Path);
                obj.pShowSimulink(newLocation,get_param(x.Path,'Parent'));

            case "StateflowMatlabFunction"
                stateflowInfo=slxmlcomp.internal.stateflow.stateflowPathToStruct(location);
                x=slxmlcomp.internal.stateflow.chart.get(stateflowInfo.Block);
                obj.pShowChart(x,location);

            case "EMLChart"




                stateflowInfo=slxmlcomp.internal.stateflow.stateflowPathToStruct(location);
                x=slxmlcomp.internal.stateflow.chart.get(stateflowInfo.Block,'Stateflow.EMChart');
                obj.pShowSimulink(StringLocation('Block',x.Path),get_param(x.Path,'Parent'));

            case "TestSequenceChart"
                stateflowInfo=slxmlcomp.internal.stateflow.stateflowPathToStruct(location);
                x=slxmlcomp.internal.stateflow.chart.get(stateflowInfo.Block,'Stateflow.ReactiveTestingTableChart');
                obj.pShowSimulink(StringLocation('Block',x.Path),get_param(x.Path,'Parent'));

            otherwise

                stateflowInfo=slxmlcomp.internal.stateflow.stateflowPathToStruct(location);
                x=slxmlcomp.internal.stateflow.chart.get(stateflowInfo.Block);

                if~isempty(x)
                    obj.pShowChart(x,location,locationObj.Type);
                else
                    x=slxmlcomp.internal.stateflow.chart.get(stateflowInfo.Block,'Stateflow.StateTransitionTableChart');
                    if~isempty(x)
                        obj.pShowChart(x,stateflowInfo.Block,locationObj.Type);
                    else
                        slxmlcomp.internal.error('reverseannotation:ChartNotFound',stateflowInfo.Block);
                    end
                end
            end
        end

        function pCloseWindowsUponReset(obj)

            switch obj.LastWindowType
            case 'ConfigSet'
                if~isempty(obj.ConfigSet)
                    try
                        obj.ConfigSet.closeDialog;
                    catch E
                        warning(E.identifier,'%s',E.message);
                    end
                end
            end
        end




        function pUnhighlight(obj)
            if isempty(obj.UnhighlightAction)
                return;
            else
                obj.UnhighlightAction();
                obj.UnhighlightAction=[];
            end
        end

        function pShowSimulink(obj,location,new_window)

            obj.LastWindow=new_window;
            obj.LastWindowType='Simulink';
            thismodel=strtok(location.Location,'/');

            slxmlcomp.internal.highlight.hideAllBdScopes(thismodel,obj.LastWindow);



            window_position=obj.LastSimulinkPosition;
            set_param(obj.LastWindow,'Location',window_position);

            resolver=slxmlcomp.internal.highlight.SimulinkHandleResolver();
            objectHandle=resolver.resolve(location);

            obj.SLEditorStyler.applyAttentionStyle(location);
            Simulink.scrollToVisible(objectHandle);
            if(get_param(obj.LastWindow,'Open')~="on")
                set_param(obj.LastWindow,'Open','on');
            end

            function unHighlight()
                if(slxmlcomp.internal.highlight.SimulinkHandleResolver.isModelLoaded(location.Location))
                    obj.SLEditorStyler.removeAttentionStyle(location);
                end
            end
            obj.UnhighlightAction=@unHighlight;



            set_param(obj.LastWindow,'Location',window_position);

        end

        function pShowChart(obj,chart,location,type)
            thismodel=strtok(location,'/');
            obj.LastWindow=chart.Path;
            obj.LastWindowType='Stateflow';




            slxmlcomp.internal.highlight.hideAllBdScopes(thismodel,obj.LastWindow);

            handle=[];
            if~strcmp(type,'chart')

                handle=sfprivate('ssIdToHandle',location);
            end

            obj.openChartFitToView(chart,handle);

            import slxmlcomp.internal.highlight.StringLocation
            locationObj=StringLocation('stateflow',location);
            function unHighlight()
                if(slxmlcomp.internal.highlight.SimulinkHandleResolver.isModelLoaded(location))
                    obj.SLEditorStyler.removeAttentionStyle(locationObj);
                end
            end


            if~isempty(handle)
                obj.SLEditorStyler.applyAttentionStyle(locationObj);

                obj.UnhighlightAction=@unHighlight;
            end
        end

        function openChartFitToView(obj,chart,handle)
            if~isempty(handle)



                if isprop(handle,'Subviewer')&&~isempty(handle.Subviewer)
                    viewer=handle.Subviewer;
                else
                    viewer=chart;
                end


                sf('Select',chart.Id,[]);

                if isa(viewer,'Stateflow.StateTransitionTableChart')
                    sf('ViewContent',viewer.Id);
                else
                    sf('Open',viewer.Id);
                end

            else






                sf('Select',chart.Id,[]);

                if isa(chart,'Stateflow.StateTransitionTableChart')
                    sf('ViewContent',chart.Id);
                else
                    sf('Open',chart.Id);
                end
                viewer=chart;
            end
            editor=StateflowDI.SFDomain.getLastActiveEditorFor(viewer.Id);

            obj.setSFStudioPosition(editor,obj.LastStateflowPosition);
            obj.pFitToView(viewer);



            if(~isempty(handle))
                try %#ok<TRYNC>
                    handle.fitToView;
                end
            end

        end

        function setSFStudioPosition(~,editor,position)
            studio=editor.getStudio();
            studio.setStudioPosition(position);


            if any(studio.getStudioPosition()~=position)
                studio.setStudioPosition(position);
            end
        end

        function pShowConfigSet(obj,location)
            obj.LastWindowType='ConfigSet';



            parts=regexp(location,'(?<!/)/(?!/)','split');
            if numel(parts)<2
                return
            end

            obj.LastWindow=[parts{1},'/',parts{2}];
            cs=getConfigSet(parts{1},parts{2});
            obj.ConfigSet=cs;
            if isempty(cs)
                return
            end
            slCfgPrmDlg(cs,'Open');

            if numel(parts)>=3
                try


                    layout=configset.layout.MetaConfigLayout.getInstance;
                    if~isempty(find(cellfun(@(x)strcmp(message(x.Key).getString(),strrep(parts{3},'//','/')),layout.TopLevelPanes),1))
                        slCfgPrmDlg(cs,'TurnToPage',parts{3});
                    end
                catch E %#ok<NASGU>

                end
            end

            pos=obj.LastSimulinkPosition;
            pos(3)=pos(3)-pos(1);
            pos(4)=pos(4)-pos(2);

            dialog=cs.getDialogHandle;
            if~isempty(dialog)&&~isempty(pos)
                dialog.position=pos;
            end
        end

        function pShowTruthTable(obj,truthtable)
            truthtable.view;

            chartId=sfprivate('getChartOf',truthtable.Id);
            chart=sf('IdToHandle',chartId);
            if isa(chart,'Stateflow.Chart')
                editor=StateflowDI.SFDomain.getLastActiveEditorFor(truthtable.Id);
            elseif isa(chart,'Stateflow.TruthTableChart')
                editor=StateflowDI.SFDomain.getLastActiveEditorForChart(chartId);
            end

            obj.setSFStudioPosition(editor,obj.LastStateflowPosition);

            obj.LastWindowType='Simulink';
            obj.LastWindow=truthtable.Path;
            obj.UnhighlightAction=[];
        end

        function[block,ssid]=pDecodeSF(~,location)
            stateflowInfo=slxmlcomp.internal.stateflow.stateflowPathToStruct(location);
            block=stateflowInfo.Block;
            ssid=stateflowInfo.SSID;
        end

        function sys=pGetParent(~,block)
            sys=get_param(block,'Parent');
        end

        function window=pGetConfigSetWindow(~,location)
            parts=regexp(location,'(?<!/)/(?!/)','split');
            if numel(parts)<1
                window='';
            elseif numel(parts)<2
                window=parts{1};
            else
                window=[parts{1},'/',parts{2}];
            end
        end

        function pFitToView(~,viewer)


            editors=GLUE2.Util.findAllEditors(viewer.path);
            if~isempty(editors)
                editor=editors(1);
                editor.getCanvas.zoomToSceneRect;
                return
            end

            try
                viewer.fitToView;
            catch E %#ok<NASGU>

            end
        end

    end


    methods(Access=private)

        function closeTestHarnessesForModel(~,location)
            modelName=strtok(location.Location,'/');
            slxmlcomp.internal.testharness.closeAll(modelName,{});
        end

    end

end
