classdef polariAntenna<handle















    properties
hLobes
polariObj
Listeners



        DatasetComputed=[]
        LobeInfo=[]


Marker1
Marker2


        FillLobes=true
    end

    properties(SetAccess=private)






        LastSpanType='none'
    end

    properties(Access=private)

        pReadoutContextMenuCreated=false
    end

    properties(Constant)
        DeleteMarkersWhenHidingLobes=false
        SymbolDegree=char(176)
    end

    methods
        function a=polariAntenna(polariObj)
            if nargin>0




                init(a,polariObj);
            end
        end

        function set.FillLobes(a,val)
            validateattributes(val,{'numeric','logical'},...
            {'scalar','real'},'polariAntenna','FillLobes');

            a.FillLobes=val~=0;
            updateLobeVis(a,false);
        end

        function y=areLobesVisible(a,datasetIndex)






            y=~isempty(a.hLobes);
            if y&&(nargin>1)
                y=isequal(a.DatasetComputed,datasetIndex);
            end
        end

        function hideLobes(a)




            if a.DeleteMarkersWhenHidingLobes
                deleteSpanMarkers(a);
            end
            deleteLobeVis(a);
        end

        function delete(a)

            deleteListeners(a);
            deleteLobeInfo(a);
        end

        function markDirty(a)





            a.DatasetComputed=[];
        end

        function showLobes(a,datasetIdx)








            findLobes(a,datasetIdx);


            updateLobeVis(a,true);
        end

        function updateAll(a)




            if~isempty(a.hLobes)
                datasetIdx=a.DatasetComputed;
                if~isempty(datasetIdx)
                    markDirty(a);
                    showLobes(a,datasetIdx);



                    updateLobeSpan(a);
                end
            end
        end

        function showPeaks(a,datasetIndex,Npeaks)



            if nargin<3
                Npeaks=2;
            end
            p=a.polariObj;
            if nargin<2
                datasetIndex=p.pCurrentDataSetIndex;
            end


            if~isempty(datasetIndex)




                Nd=getNumDatasets(p);
                pk=zeros(1,Nd);
                pk(datasetIndex)=Npeaks;
                p.Peaks=pk;
            end
        end

        function removeLobeMarkers(a)

            p=a.polariObj;
            showAngleSpan(p,false);
            removeAngleMarkers(p);




            changeMouseBehavior(p,'general');

            a.LastSpanType='none';
        end

        function L=findLobes(a,datasetIndex,forceRecompute)













































            p=a.polariObj;

            if isequal(a.DatasetComputed,datasetIndex)&&(nargin<3||~forceRecompute)


                if nargout>0
                    L=a.LobeInfo;
                end
            else


                pdata=getDataset(p,datasetIndex);
                if any(~isfinite(pdata.mag))
                    warning(message('siglib:polarpattern:FindLobesFinite'))
                end
                L=internal.measureLobes(pdata.ang,pdata.mag,p.DisplayUnits);
                a.LobeInfo=L;



                a.DatasetComputed=datasetIndex;
            end
        end

        function updateLobeSpan(a)



            showLobeSpan(a,a.LastSpanType);
        end

        function showLobeSpan(a,mtype,datasetIdx,L1)










            L=a.LobeInfo;
            if isempty(L)&&nargin<=3
                return
            end


            a.LastSpanType=mtype;

            floating=false;
            switch mtype
            case 'fb'
                ext=L.FBIdx;
            case 'sll'
                ext=L.SLLIdx;
            case 'hpbw'
                ext=L.HPBWIdx;
                ang=L.HPBWAng;

            case 'fnbw'



                ext=L.FNBWIdx;
            case 'bw'
                ext=L1.BWIdx;

            case 'none'


                return
            end


            p=a.polariObj;
            if isempty(ext)
                showSpan(p,false);
                return
            end

            if nargin<3
                datasetIdx=p.pCurrentDataSetIndex;
            end

            ext=round(ext);
            m1=a.Marker1;
            if isempty(m1)||~isvalid(m1)
                m1=addCursorAllArgs(p,ext(1),datasetIdx);
                a.Marker1=m1;
            end
            m1.Floating=floating;



            m1.DataIndex=ext(1);


            m2=a.Marker2;
            if isempty(m2)||~isvalid(m2)
                m2=addCursorAllArgs(p,ext(2),datasetIdx);
                a.Marker2=m2;
            end
            m2.Floating=floating;



            m2.DataIndex=ext(2);





            if strcmpi(p.AngleDirection,'ccw')
                c1=m1.ID;
                c2=m2.ID;
            else
                c1=m2.ID;
                c2=m1.ID;
            end
            showSpan(p,c1,c2);
        end
    end

    methods
        function updatePosition(a,newPos)


            hr=a.hLobes;
            if~isempty(hr)
                updatePosition(hr.textReadout,newPos);
            end
        end

        function hoverOverReadoutChange(a,event)




            hr=a.hLobes;
            if~isempty(hr)
                hoverOverReadoutChange(hr.textReadout,event);
            end
        end
    end

    methods(Access=private)
        function init(a,p)

            a.polariObj=p;


            initListeners(a);
        end

        function initListeners(a)



            deleteListeners(a);

            p=a.polariObj;




            lis.PolariDataUnits=addlistener(p,...
            'DataUnitsChanged',@(~,~)updateAll(a));


            lis.PolariAngleProps=addlistener(p,...
            {'AngleAtTop','AngleDirection','AngleDrag_Delta',...
            'MagnitudeLim','MagnitudeLimMode'},...
            'PostSet',@(~,~)updateLobeVis(a,false));

            lis.MagLim=addlistener(p,'MagnitudeLimChanged',...
            @(~,~)updateLobeVis(a,false));





            a.Listeners=lis;
        end

        function deleteListeners(a)


            a.Listeners=internal.polariCommon.deleteListenerStruct(a.Listeners);
        end

        function deleteLobeInfo(a)




            deleteLobeVis(a);


            a.LobeInfo=[];
            a.DatasetComputed=[];
        end

        function deleteLobeVis(a)




            s=a.hLobes;
            if~isempty(s)
                delete(s.mainLobe);
                delete(s.backLobe);
                delete(s.sideLobes);
                delete(s.textReadout);
                a.hLobes=[];



                a.pReadoutContextMenuCreated=false;
            end
        end

        function deleteSpanMarkers(a)





            spanVis=false;
            p=a.polariObj;

            m1=a.Marker1;
            if~isempty(m1)
                if isvalid(m1)

                    removeCursors(p,m1.Index);
                    spanVis=true;
                end
                a.Marker1=[];
            end

            m2=a.Marker2;
            if~isempty(m2)
                if isvalid(m2)

                    removeCursors(p,m2.Index);
                    spanVis=true;
                end
                a.Marker2=[];
            end

            if spanVis
                p.Span=false;
            end
        end

        function hp=recreateLobePatchesIfDirty(a)






            hp=a.hLobes;
            if~isempty(hp)

                if isvalid(hp.mainLobe)
                    return
                end




                deleteLobeVis(a);
            end


            L=a.LobeInfo;
            assert(~isempty(L))


            color.mainLobe=[.8,.4,.4];
            color.sideLobes=[.8,.8,.8];
            color.backLobe=[.6,.6,.6];


            faceAlpha=0.65;
            p=a.polariObj;

            ctx=createContextMenus(a);

            tag=sprintf('polariLobe%d',p.pAxesIndex);

            for i=1:3
                hp_i=[];
                if i==1

                    e=L.mainLobe.extent;
                    faceColor=color.mainLobe;
                    cm=ctx.mainLobeMenu;
                    typ='Main';
                elseif i==2

                    e=L.backLobe.extent;
                    faceColor=color.backLobe;
                    cm=ctx.backLobeMenu;
                    typ='Back';
                else

                    e=L.sideLobes.extent;
                    faceColor=color.sideLobes;
                    cm=ctx.sideLobeMenu;
                    typ='Side';
                end


                for j=1:size(e,1)
                    hp_j=patch(...
                    'Parent',p.hAxes,...
                    'Tag',[tag,typ],...
                    'FaceColor',faceColor,...
                    'FaceAlpha',faceAlpha,...
                    'EdgeColor','none');
                    hp_j.Annotation.LegendInformation.IconDisplayStyle='off';

                    set(hp_j,'uicontextmenu',cm);


                    b=hggetbehavior(hp_j,'DataCursor');
                    b.Enable=false;
                    b=hggetbehavior(hp_j,'PlotEdit');
                    b.Enable=false;

                    if isempty(hp_i)
                        hp_i=hp_j;
                    else
                        hp_i=[hp_i;hp_j];%#ok<AGROW>
                    end
                end
                if i==1
                    hp.mainLobe=hp_i;
                elseif i==2
                    hp.backLobe=hp_i;
                else
                    hp.sideLobes=hp_i;
                end
            end


            hr=internal.polariReadout(a.polariObj);
            hp.textReadout=hr;
            hr.FontName='Courier';
            hr.FontRelSize=-2;
            hr.NormalForegroundColor='w';
            hr.TagName='polariAntennaReadout';
            hr.ReadoutPositionPriority=3;
            hr.NormalBackgroundColor=color.mainLobe;
            hr.ContextMenuFcn=@(hMenu,ev)updateReadoutContextMenu(a,hMenu);
            hr.Visible='on';


            a.hLobes=hp;
        end

        function updateReadoutContextMenu(a,hMenu)

            if~a.pReadoutContextMenuCreated
                a.pReadoutContextMenuCreated=true;
                createContextMenuLobe(a,'readout',hMenu);
            end
        end

        function updateMetricsReadout(a)


            L=a.LobeInfo;
            if isempty(L)
                return
            end
            hp=a.hLobes;
            ht=hp.textReadout;
            deg=a.SymbolDegree;

            if isempty(L.HPBW)
                tHPBW='-';
            else
                tHPBW=internal.polariCommon.sprintfNumTotalDigits(L.HPBW,3);
            end
            if isempty(L.FNBW)
                tFNBW='-';
            else
                tFNBW=internal.polariCommon.sprintfNumTotalDigits(L.FNBW,3);
            end
            if isempty(L.FB)
                tFB='-';
            else
                tFB=internal.polariCommon.sprintfNumTotalDigits(L.FB,3);
            end
            if isempty(L.SLL)
                tSLL='-';
            else
                tSLL=internal.polariCommon.sprintfNumTotalDigits(L.SLL,3);
            end

            mainPeak=internal.polariCommon.sprintfMaxNumTotalDigits(L.mainLobe.magnitude,3);
            mainAngle=internal.polariCommon.sprintfMaxNumTotalDigits(L.mainLobe.angle,3);
            backPeak=internal.polariCommon.sprintfMaxNumTotalDigits(L.backLobe.magnitude,3);
            backAngle=internal.polariCommon.sprintfMaxNumTotalDigits(L.backLobe.angle,3);

            ht.Text=sprintf([...
            'HPBW: %s%c\n',...
            'FNBW: %s%c\n',...
            ' F/B: %s dB\n',...
            ' SLL: %s dB\n',...
            'Main: %s dB @ %s%c\n',...
            'Back: %s dB @ %s%c'],...
            tHPBW,deg,tFNBW,deg,tFB,tSLL,...
            mainPeak,mainAngle,deg,...
            backPeak,backAngle,deg);
        end

        function updateLobeVis(a,forceVisToAppear)













            L=a.LobeInfo;
            if isempty(L)
                return
            end

            hp=a.hLobes;
            if isempty(hp)&&~forceVisToAppear
                return
            end


            hp=recreateLobePatchesIfDirty(a);
            updateMetricsReadout(a);

            fill_lobes=a.FillLobes;
            p=a.polariObj;

            if strcmpi(p.Style,'line')
                zplane=0.06;
            else
                zplane=0.205;
            end
            pdata=getDataset(p,a.DatasetComputed);
            Npts=numel(pdata.ang);

            for i=1:3
                if i==1

                    e=L.mainLobe.extent;
                    hp_i=hp.mainLobe;
                elseif i==2

                    e=L.backLobe.extent;
                    hp_i=hp.backLobe;
                else

                    e=L.sideLobes.extent;
                    hp_i=hp.sideLobes;
                end


                for j=1:size(e,1)



                    e1=e(j,1);
                    e2=e(j,2);


                    if e1>e2

                        r0=pdata.mag([e1:end,1:e2]);
                        th0=pdata.ang([e1:end,1:e2]);
                        NptsInLobe=e2-e1+1+Npts;
                    else

                        r0=pdata.mag(e1:e2);
                        th0=pdata.ang(e1:e2);
                        NptsInLobe=e2-e1+1;
                    end


                    r=getNormalizedMag(p,r0);
                    th=getNormalizedAngle(p,th0);




                    if NptsInLobe<Npts
                        r=[r;0];%#ok<AGROW>
                        th=[th;th(end)];%#ok<AGROW>
                    end








                    r(r<=0)=0;

                    x=r.*cos(th);
                    y=r.*sin(th);
                    z=zplane*ones(size(x));

                    set(hp_i(j),...
                    'XData',x,...
                    'YData',y,...
                    'ZData',z);
                end


                set(hp_i,'Visible',internal.LogicalToOnOff(fill_lobes));

                if i==1
                    hp.mainLobe=hp_i;
                elseif i==2
                    hp.backLobe=hp_i;
                else
                    hp.sideLobes=hp_i;
                end
            end
        end

        function ctx=createContextMenus(a)

            ctx.mainLobeMenu=createContextMenuLobe(a,'main');
            ctx.backLobeMenu=createContextMenuLobe(a,'back');
            ctx.sideLobeMenu=createContextMenuLobe(a,'side');
        end

        function hc=createContextMenuLobe(a,typ,hc)


            p=a.polariObj;
            if nargin<3
                hc=uicontextmenu(...
                'Parent',p.Parent,...
                'HandleVisibility','off');
            end

            switch typ
            case 'main'
                dTitle='MAIN LOBE';
                i=1+2+4;
            case 'back'
                dTitle='BACK LOBE';

                i=1+2+4;
            case 'side'
                dTitle='SIDE LOBE';

                i=1+2+4;
            case 'readout'
                dTitle='ANTENNA METRICS';
                i=1+2+4;
            end
            str2=sprintf('DATASET %d',a.DatasetComputed);
            label=['<html><b>',dTitle,'</b><br>'...
            ,'<font size=3><i>',str2,'</i></font></html>'];
            opts={hc,label,'','Enable','off'};
            internal.ContextMenus.createContext(opts);

            sep=true;
            if bitand(i,1)
                internal.ContextMenus.createContext(...
                {hc,'Half-Power Beamwidth',@(~,~)m_ShowLobeSpan(a,'hpbw'),...
                'separator',internal.LogicalToOnOff(sep)});
                internal.ContextMenus.createContext(...
                {hc,'First-Null Beamwidth',@(~,~)m_ShowLobeSpan(a,'fnbw')});
                if sep,sep=false;end
            end
            if bitand(i,2)
                internal.ContextMenus.createContext(...
                {hc,'Front-Back Ratio',@(~,~)m_ShowLobeSpan(a,'fb'),...
                'separator',internal.LogicalToOnOff(sep)});
                if sep,sep=false;end
            end
            if bitand(i,4)
                internal.ContextMenus.createContext(...
                {hc,'Side Lobe Level',@(~,~)m_ShowLobeSpan(a,'sll'),...
                'separator',internal.LogicalToOnOff(sep)});
            end








            h1=internal.ContextMenus.createContext({hc,...
            'Antenna Metrics',@(~,~)m_Remove(a,true),...
            'separator','on'});
            h1.Checked='on';
            internal.ContextMenus.createContext({hc,...
            'Export Metrics',@(~,~)m_Export(a)});
        end

        function m_Export(a)


            p=a.polariObj;


            L=a.LobeInfo;
            E.Dataset=a.DatasetComputed;
            E.HPBW=L.HPBW;
            E.FNBW=L.FNBW;
            E.FB=L.FB;
            E.SLL=L.SLL;
            E.Main=L.mainLobe.magnitude;
            E.Back=L.backLobe.magnitude;
            E.Cursors=p.CursorMarkers;
            E.Peaks=p.PeakMarkers;
            assignin('base','metrics',E);
            str='Exported <a href="matlab:eval(''metrics'')">metrics</a> to the base workspace.';
            disp(str);

            if p.ToolTips
                showBannerMessage(p,...
                'Exported ''metrics'' variable to the base workspace.');
            end
        end

        function m_Remove(a,alsoRemoveMarkers)


            if alsoRemoveMarkers
                removeLobeMarkers(a);
            end
            hideLobes(a);
        end

        function m_ShowLobeSpan(a,mtype)


            showLobeSpan(a,mtype);
        end
    end
end


