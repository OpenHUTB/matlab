function addPlotType(obj,varargin)





    import matlab.ui.internal.toolstrip.*
    import matlab.ui.container.internal.appcontainer.*;
    import matlab.ui.container.internal.AppContainer;
    import matlab.ui.internal.*;


    evt=varargin{2};
    toolStrip=obj.ToolStripDisplay;


    arr=obj.CurrentArray;
    if~obj.IsSubarray
        arr.Element=obj.CurrentElement;
    else
        if isa(obj.CurrentArray,'phased.PartitionedArray')
            arr.Array.Element=obj.CurrentElement;
        else
            arr.Subarray.Element=obj.CurrentElement;
        end
    end


    w=computeWeights(obj);
    propSpeed=obj.PropagationSpeed;
    steerAng=obj.SteeringAngle;
    subarraySteerAng=obj.SubarraySteeringAngle;

    if strcmp(obj.Container,'ToolGroup')
        figClients=getFiguresDropTargetHandler(obj.ToolGroup);

        for i=1:numel(figClients.CloseListeners)
            clientFigTag=figClients.CloseListeners(i).Source{1}.Tag;
            clientFig=figClients.CloseListeners(i).Source{1};

            drawnow();
            if any(strcmp(clientFigTag,evt.RequestedPlotTag))
                newPlotFig=true;
                hfig=clientFig;
                break;
            else
                newPlotFig=false;
                continue;
            end
        end



        if~newPlotFig
            Fig=figure('Visible','off','IntegerHandle','off',...
            'NumberTitle','off','HandleVisibility','off');

            figHandle=Fig;


            if strcmp(evt.RequestedPlotTag,'azPatternFig')
                toolStrip.CutAngleEditAz=[];
                toolStrip.CoordDropDown2DAz=[];
            end

            if strcmp(evt.RequestedPlotTag,'elPatternFig')
                toolStrip.CutAngleEditEl=[];
                toolStrip.CoordDropDown2DEl=[];
            end

            if strcmp(evt.RequestedPlotTag,'pattern3DFig')
                toolStrip.CoordDropDown3D=[];
            end

            if strcmp(evt.RequestedPlotTag,'gratingLobeFig')
                toolStrip.FreqDropDownGrating=[];
            end

            if strcmp(evt.RequestedPlotTag,'arrayGeoFig')
                toolStrip.IdxCheck=[];
                toolStrip.NormalCheck=[];
                toolStrip.TaperCheck=[];
            end

            if strcmp(evt.RequestedPlotTag,'uPatternFig')
                toolStrip.TypeDropDownUV=[];
                toolStrip.NormalizeCheck=[];
                toolStrip.PolarizationDropDownUV=[];
                toolStrip.PlotStyleDropDownUV=[];
            end
        else
            figHandle=hfig;
        end

        switch evt.RequestedPlotTag
        case 'arrayGeoFig'


            name=getString(message('phased:apps:arrayapp:arrayGeometryfigure'));
            tag='arraytab';


            if(isempty(toolStrip.IdxCheck)||...
                isempty(toolStrip.NormalCheck)||...
                isempty(toolStrip.TaperCheck))
                toolStrip.Props=...
                buildPlotPropSection(toolStrip,'arrayGeoFig');
            end

            obj.ArrayGeometryFig=viewArraySettings(obj,toolStrip,figHandle,arr);

        case 'pattern3DFig'


            name=getString(message('phased:apps:arrayapp:array3D'));
            tag='3dpattab';


            if(isempty(toolStrip.FreqDropDown3D)||...
                isempty(toolStrip.CoordDropDown3D)||isempty(toolStrip.TypeDropDown))
                toolStrip.Props=buildPlotPropSection(toolStrip,...
                'pattern3DFig');
            end

            obj.Pattern3DFig=pattern3DSettings(obj,toolStrip,figHandle,...
            arr,w,propSpeed,steerAng,subarraySteerAng);

        case{'azPatternFig','elPatternFig'}


            if strcmp(evt.RequestedPlotTag,'azPatternFig')
                name=getString(message('phased:apps:arrayapp:azimuthPattern'));
                tag='2DAzpattab';


                if(isempty(toolStrip.CutAngleEditAz)||...
                    isempty(toolStrip.CoordDropDown2DAz))
                    toolStrip.Props=...
                    buildPlotPropSection(toolStrip,evt.RequestedPlotTag);
                end

                freq=getOrderedFrequency(obj);
                legendStr=getLegendString(obj);
                obj.AzPatternFig=azPatternSettings(obj,toolStrip,...
                figHandle,arr,w,propSpeed,subarraySteerAng,freq,legendStr);
            else

                name=getString(message('phased:apps:arrayapp:elevationPattern'));
                tag='2DElpattab';


                if(isempty(toolStrip.CutAngleEditEl)||...
                    isempty(toolStrip.CoordDropDown2DEl))
                    toolStrip.Props=...
                    buildPlotPropSection(toolStrip,evt.RequestedPlotTag);
                end

                freq=getOrderedFrequency(obj);
                legendStr=getLegendString(obj);
                obj.ElPatternFig=elPatternSettings(obj,toolStrip,...
                figHandle,arr,w,propSpeed,subarraySteerAng,freq,legendStr);
            end

        case 'uPatternFig'


            name=getString(message('phased:apps:arrayapp:uPattern'));
            tag='2DUcuttab';

            freq=getOrderedFrequency(obj);
            legendStr=getLegendString(obj);
            if(isempty(toolStrip.TypeDropDownUV)||...
                isempty(toolStrip.PolarizationDropDownUV))
                toolStrip.Props=...
                buildPlotPropSection(toolStrip,evt.RequestedPlotTag);
            end

            obj.UPatternFig=uPatternSettings(obj,toolStrip,figHandle,...
            arr,w,propSpeed,subarraySteerAng,freq,legendStr);
        case 'gratingLobeFig'


            name=getString(message('phased:apps:arrayapp:gratingLobeDiagram'));
            tag='LobeDiagTab';


            if(isempty(toolStrip.FreqDropDownGrating))
                toolStrip.Props=...
                buildPlotPropSection(toolStrip,'gratingLobeFig');
            end

            obj.GratingLobeFig=lobeDiagramSettings(obj,toolStrip,...
            figHandle,arr,propSpeed,steerAng);
        end



        atgName=obj.ToolGroup.Name;
        matDsk=com.mathworks.mlservices.MatlabDesktopServices.getDesktop();

        loc=com.mathworks.widgets.desk.DTLocation.create(1);

        if~newPlotFig



            tabGroup=TabGroup();

            contextualTab=Tab(name);
            contextualTab.Tag=tag;
            contextualTab.add(toolStrip.Props);
            add(tabGroup,contextualTab);


            toolStrip.ContextualPlotsTab=contextualTab;
            obj.ToolGroup.addClientTabGroup(figHandle,tabGroup);

            obj.ToolGroup.SelectedTab=contextualTab.Tag;


            figHandle.Visible='on';

            drawnow;

            matDsk.setClientLocation(figHandle.Name,atgName,loc);
        end


        prop=com.mathworks.widgets.desk.DTClientProperty.PERMIT_USER_CLOSE;
        state=java.lang.Boolean.FALSE;
        matDsk.getClient(...
        figHandle.Name,obj.ToolGroup.Name).putClientProperty(prop,state);
    else

        if strcmp(evt.RequestedPlotTag,'azPatternFig')
            if~has(obj.ToolGroup,"DOCUMENT","2DAzpattab_group","2DAzpattab")
                toolStrip.CutAngleEditAz.Value=mat2str(0);
                toolStrip.CoordDropDown2DAz.SelectedIndex=1;
                toolStrip.TypeDropDown2DAz.SelectedIndex=1;
                toolStrip.PlotStyleDropDown2DAz.SelectedIndex=1;
                toolStrip.NormalizeCheck2DAz.Enabled=false;
                toolStrip.PolarizationDropDown2DAz.SelectedIndex=1;
            end
        end
        if strcmp(evt.RequestedPlotTag,'elPatternFig')
            if~has(obj.ToolGroup,"DOCUMENT","2DElpattab_group","2DElpattab")
                toolStrip.CutAngleEditEl.Value=mat2str(0);
                toolStrip.CoordDropDown2DEl.SelectedIndex=1;
                toolStrip.TypeDropDown2DEl.SelectedIndex=1;
                toolStrip.PlotStyleDropDown2DEl.SelectedIndex=1;
                toolStrip.NormalizeCheck2DEl.Enabled=false;
                toolStrip.PolarizationDropDown2DEl.SelectedIndex=1;
            end
        end
        if strcmp(evt.RequestedPlotTag,'pattern3DFig')
            if~has(obj.ToolGroup,"DOCUMENT","3dpattab_group","3dpattab")
                toolStrip.CoordDropDown3D.SelectedIndex=1;
                toolStrip.FreqList{1}.Value=true;
                toolStrip.OrientationEdit.Value=mat2str([0;0;0]);
                toolStrip.ArrayCheck.Value=false;
                toolStrip.LocalCoordinateArrayCheck.Value=true;
                toolStrip.ColorbarCheck.Value=true;
                toolStrip.ArrayOrientationEdit.Value=mat2str([0;0;0]);
                toolStrip.TypeDropDown.SelectedIndex=1;
                toolStrip.PolarizationDropDown.SelectedIndex=1;
            end
        end
        if strcmp(evt.RequestedPlotTag,'gratingLobeFig')
            if~has(obj.ToolGroup,"DOCUMENT","LobeDiagTab_group","LobeDiagTab")
                toolStrip.FreqListGrating{1}.Value=true;
            end
        end
        if strcmp(evt.RequestedPlotTag,'arrayGeoFig')
            if~has(obj.ToolGroup,"DOCUMENT","arraytab_group","arraytab")
                toolStrip.IdxCheck.Value=false;
                toolStrip.NormalCheck.Value=false;
                toolStrip.TaperCheck.Value=false;
                toolStrip.AnnotationCheck.Value=false;
                toolStrip.LocalCoordinateArrayCheck.Value=true;
                toolStrip.ArrayOrientationEdit.Value=mat2str([0;0;0]);
            end
        end
        if strcmp(evt.RequestedPlotTag,'UPatternFig')
            if~has(obj.AppHandle.ToolGroup,"DOCUMENT","2DUcuttab_group","2DUcuttab")
                toolStrip.TypeDropDownUV.SelectedIndex=1;
                toolStrip.NormalizeCheckUV.Value=1;
                toolStrip.PlotStyleDropDownUV.SelectedIndex=1;
                toolStrip.PolarizationDropDownUV.SelectedIndex=1;
            end
        end

        switch evt.RequestedPlotTag
        case 'arrayGeoFig'

            name=getString(message('phased:apps:arrayapp:arrayGeometryfigure'));
            tag='arraytab';

            if isempty(obj.ArrayGeometryFig)
                [obj.ArrayGeometryTab,obj.ArrayGeometryDoc]=...
                createContextualComponents(obj,toolStrip,'arrayGeoFig',name,tag);
            end

            if~has(obj.ToolGroup,"DOCUMENT","arraytab_group","arraytab")

                document=FigureDocument();
                document.DocumentGroupTag=obj.ArrayGeometryDoc.Tag;
                document.Tag=tag;
                document.Title=name;
                document.Closable=false;
                obj.ToolGroup.add(document);

                figHandle=document.Figure;
            else
                figHandle=obj.ArrayGeometryFig;
            end

            figHandle.Internal=false;
            enableLegacyExplorationModes(figHandle);
            obj.ArrayGeometryFig=viewArraySettings(obj,toolStrip,figHandle,arr);
        case 'pattern3DFig'

            name=getString(message('phased:apps:arrayapp:array3D'));
            tag='3dpattab';

            if isempty(obj.Pattern3DFig)
                [obj.Pattern3DTab,obj.Pattern3DDoc]=...
                createContextualComponents(obj,toolStrip,'pattern3DFig',name,tag);
            end

            if~has(obj.ToolGroup,"DOCUMENT","3dpattab_group","3dpattab")

                document=FigureDocument();
                document.DocumentGroupTag=obj.Pattern3DDoc.Tag;
                document.Tag=tag;
                document.Title=name;
                document.Closable=false;
                obj.ToolGroup.add(document);

                figHandle=document.Figure;
            else
                figHandle=obj.Pattern3DFig;
            end
            figHandle.Internal=false;

            obj.Pattern3DFig=pattern3DSettings(obj,toolStrip,figHandle,...
            arr,w,propSpeed,steerAng,subarraySteerAng);
        case{'azPatternFig','elPatternFig'}

            if strcmp(evt.RequestedPlotTag,'azPatternFig')
                name=getString(message('phased:apps:arrayapp:azimuthPattern'));
                tag='2DAzpattab';
            elseif strcmp(evt.RequestedPlotTag,'elPatternFig')
                name=getString(message('phased:apps:arrayapp:elevationPattern'));
                tag='2DElpattab';
            end

            if isempty(obj.AzPatternFig)&&strcmp(evt.RequestedPlotTag,'azPatternFig')
                [obj.AzPatternTab,obj.AzPatternDoc]=...
                createContextualComponents(obj,toolStrip,'azPatternFig',name,tag);
            end

            if isempty(obj.ElPatternFig)&&strcmp(evt.RequestedPlotTag,'elPatternFig')
                [obj.ElPatternTab,obj.ElPatternDoc]=...
                createContextualComponents(obj,toolStrip,'elPatternFig',name,tag);
            end

            if strcmp(evt.RequestedPlotTag,'azPatternFig')
                if~has(obj.ToolGroup,"DOCUMENT","2DAzpattab_group","2DAzpattab")

                    document=FigureDocument();
                    document.DocumentGroupTag=obj.AzPatternDoc.Tag;
                    document.Tag=tag;
                    document.Title=name;
                    document.Closable=false;
                    obj.ToolGroup.add(document);
                    figHandle=document.Figure;
                else
                    figHandle=obj.AzPatternFig;
                end
            end
            if strcmp(evt.RequestedPlotTag,'elPatternFig')
                if~has(obj.ToolGroup,"DOCUMENT","2DElpattab_group","2DElpattab")

                    document=FigureDocument();
                    document.DocumentGroupTag=obj.ElPatternDoc.Tag;
                    document.Tag=tag;
                    document.Title=name;
                    document.Closable=false;
                    obj.ToolGroup.add(document);
                    figHandle=document.Figure;
                else
                    figHandle=obj.ElPatternFig;
                end

            end
            figHandle.Internal=false;

            freq=getOrderedFrequency(obj);
            legendStr=getLegendString(obj);

            if strcmp(evt.RequestedPlotTag,'azPatternFig')
                obj.AzPatternFig=azPatternSettings(obj,toolStrip,...
                figHandle,arr,w,propSpeed,subarraySteerAng,freq,legendStr);
            else
                obj.ElPatternFig=elPatternSettings(obj,toolStrip,...
                figHandle,arr,w,propSpeed,subarraySteerAng,freq,legendStr);
            end
        case 'uPatternFig'

            name=getString(message('phased:apps:arrayapp:uPattern'));
            tag='2DUcuttab';

            if isempty(obj.UPatternFig)
                [obj.UPatternTab,obj.UPatternDoc]=...
                createContextualComponents(obj,toolStrip,'uPatternFig',name,tag);
            end


            if~has(obj.ToolGroup,"DOCUMENT","2DUcuttab_group","2DUcuttab")

                document=FigureDocument();
                document.DocumentGroupTag=obj.UPatternDoc.Tag;
                document.Tag=tag;
                document.Title=name;
                document.Closable=false;
                obj.ToolGroup.add(document);
                figHandle=document.Figure;
            else
                figHandle=obj.UPatternFig;
            end

            figHandle.Internal=false;

            freq=getOrderedFrequency(obj);
            legendStr=getLegendString(obj);
            obj.UPatternFig=uPatternSettings(obj,toolStrip,figHandle,...
            arr,w,propSpeed,subarraySteerAng,freq,legendStr);
        case 'gratingLobeFig'

            name=getString(message('phased:apps:arrayapp:gratingLobeDiagram'));
            tag='LobeDiagTab';

            if isempty(obj.GratingLobeFig)
                [obj.GratingLobeTab,obj.GratingLobeDoc]=...
                createContextualComponents(obj,toolStrip,'gratingLobeFig',name,tag);
            end
            if~has(obj.ToolGroup,"DOCUMENT","LobeDiagTab_group","LobeDiagTab")

                document=FigureDocument();
                document.DocumentGroupTag=obj.GratingLobeDoc.Tag;
                document.Tag=tag;
                document.Title=name;
                document.Closable=false;
                obj.ToolGroup.add(document);
                figHandle=document.Figure;
            else
                figHandle=obj.GratingLobeFig;
            end
            figHandle.Internal=false;

            obj.GratingLobeFig=lobeDiagramSettings(obj,toolStrip,...
            figHandle,arr,propSpeed,steerAng);
        end
        figHandle.AutoResizeChildren="off";
        obj.ToolGroup.SelectedChild=struct("tag",tag,"documentGroupTag",strcat(tag,"_group"));
    end

    if strcmp(evt.RequestedPlotTag,'arrayGeoFig')

        if isempty(obj.BannerMessage)
            if strcmp(obj.Container,'ToolGroup')
                obj.BannerMessage=matlabshared.application.Banner(obj.ArrayGeometryFig);
            else
                obj.BannerMessage=matlabshared.application.Banner(obj.ArrayGeometryFig);
                obj.BannerMessage.IsWebFigure=true;
            end
        end
    end
end

function legendString=getLegendString(obj)

    w=computeWeights(obj);
    freq=obj.SignalFrequencies;
    steerAng=obj.SteeringAngle;
    phaseBits=getCurrentPhaseQuanBits(obj);




    NumSA=size(steerAng,2);
    NumF=length(freq);
    NumPSB=length(phaseBits);
    NumPlots=size(w,2);


    [steerAng,freq,phaseBits]=obj.makeEqualLength(steerAng,freq,phaseBits,NumSA,NumF,NumPSB);


    [NumRefPlots,RefPlotAtEndFlag]=obj.computeNumReferencePlots(phaseBits,NumSA,NumF,NumPSB);


    legendString=cell(1,NumPlots);
    legendIdx=1;
    for idx=1:length(freq)
        [Fval,~,Fletter]=engunits(freq(idx));
        if any(any(steerAng~=0))
            if size(steerAng,2)==1
                az_str=num2str(steerAng(1,1));
                elev_str=num2str(steerAng(2,1));
            else
                az_str=num2str(steerAng(1,idx));
                elev_str=num2str(steerAng(2,idx));
            end
            if phaseBits(idx)>0
                legendString{legendIdx}=[num2str(Fval),Fletter,getString(message('phased:apps:arrayapp:Hz')),';'...
                ,getString(message('phased:apps:arrayapp:azel',az_str,elev_str)),'; ',num2str(phaseBits(idx)),'-bit Quantized'];

                if(NumRefPlots>0)&&((~RefPlotAtEndFlag)||(RefPlotAtEndFlag&&(idx==length(freq))))
                    legendString{legendIdx+1}=[num2str(Fval),Fletter,getString(message('phased:apps:arrayapp:Hz')),';'...
                    ,getString(message('phased:apps:arrayapp:azel',az_str,elev_str)),'; ','Reference'];
                    legendIdx=legendIdx+1;
                end
            else
                legendString{legendIdx}=[num2str(Fval),Fletter,getString(message('phased:apps:arrayapp:Hz')),';'...
                ,getString(message('phased:apps:arrayapp:azel',az_str,elev_str))];
            end
        else
            legendString{idx}=[num2str(Fval),Fletter,getString(message('phased:apps:arrayapp:Hz')),';'...
            ,getString(message('phased:apps:arrayapp:NoSteering'))];
        end
        legendIdx=legendIdx+1;
    end
end

function Freq=getOrderedFrequency(obj)

    w=computeWeights(obj);
    Freq=obj.SignalFrequencies;
    phaseBits=getCurrentPhaseQuanBits(obj);

    NumF=length(obj.SignalFrequencies);
    NumSA=size(obj.SteeringAngle,2);
    NumPSB=length(phaseBits);
    NumPlots=size(w,2);

    NumNonRefPlots=max([NumF,NumSA,NumPSB]);
    NumRefPlots=NumPlots-NumNonRefPlots;


    if(NumRefPlots>0)&&(NumF>1)
        if NumPSB>1
            F_tmp=zeros(1,NumPlots);
            plotIdx=1;
            for idx=1:NumF
                F_tmp(plotIdx)=Freq(idx);
                if phaseBits(idx)>0
                    F_tmp(plotIdx+1)=Freq(idx);
                    plotIdx=plotIdx+1;
                end
                plotIdx=plotIdx+1;
            end
            Freq=F_tmp;
        else
            F_tmp=[Freq;Freq];
            Freq=F_tmp(:).';
        end
    end
end
