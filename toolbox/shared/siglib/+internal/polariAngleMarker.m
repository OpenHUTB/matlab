classdef polariAngleMarker<handle&hgsetget





















    events
MarkerChanged
MarkerChangedActiveTrace
    end

    properties(Hidden)
PolariObj
    end

    properties(Access=private)
Listeners
    end

    properties(Hidden,Dependent)









DataSetConnect
    end

    properties(AbortSet)
ContextMenuFcn

        DataIndex=[]
        MagIndex=[]


        DataSetMode='auto'




        Floating=false



        Visible=true


pMotionGuidance
    end

    properties(GetAccess=private)







        DataSetIndex=1
    end

    properties(Hidden)

        LocalAngle=0
    end

    properties(AbortSet)


        Type=''
        Index=[]




        DataDot=false



        DataDotText=true



        DataDotPeak='triangle'



        DataDotCursor='o'

        DataDotSize=6










        DataDotLegend=false

        DetailDataStr=''
        DetailIndexStr=''
        DetailTypeStr=''

        DetailWidth=1.0
    end
    properties(Dependent)
        EdgeColor='none'
    end
    properties
        EdgeColorMode='auto'
    end
    properties(AbortSet)
        FaceAlpha=1.0
    end
    properties(AbortSet)
        FaceColorMode='auto'
    end
    properties(Dependent)
FaceColor
    end
    properties(AbortSet)
        HiliteMarker=false

        Length=1.5

        OriginLineColorMode='auto'
        OriginLine=false

        ShowDetail=1

        StringDirection='length'

        Tip=0.25
        TipOverlap=false

        Width=0.5
        WidthMode='auto'

        Z=0
    end

    properties(Dependent,SetAccess=private)
ID
    end

    properties(Access=private)
hLocalXform
hBodyText
hDotText
hPatch
hIDText
hOriginLine
hDataDot
hDataDotLegend



        pFaceColor=[1,0,0]
        pFaceColorText=[1,1,1]
        pEdgeColor=[0,0,0]

pContextParent


pCache_getData







        pDisableUpdates=false
    end

    properties(Constant,Access=private)
        OriginLineWidth=1.0


        MarkerAngleOrientationThreshold=15
    end

    methods
        function m=polariAngleMarker(polariObj,varargin)

            setProps(m,polariObj,varargin{:});
            initListeners(m);
            addMarker(m);
        end

        function delete(mvec)


            deleteListeners(mvec);
            resetWidgetHandles(mvec);
        end

        function resetWidgetHandles(mvec)

            for i=1:numel(mvec)
                m=mvec(i);



                delete(m.hLocalXform);
                m.hLocalXform=[];
                m.hBodyText=[];
                m.hIDText=[];
                m.hPatch=[];
                m.hOriginLine=[];
                m.hDataDotLegend=[];
                m.hDataDot=[];
                m.hDotText=[];


                m.pFaceColor=[];
                m.pFaceColorText=[];
                m.pEdgeColor=[];


                delete(m.pContextParent);
                m.pContextParent=[];


                p.pDisableUpdates=false;
            end
        end

        function set.Visible(m,val)
            validateattributes(val,{'numeric','logical'},...
            {'scalar','real'},'polariAngleMarker','Visible');

            m.Visible=val;


            updateBodyVisible(m,val)
        end

        function set.LocalAngle(m,val)

            validateattributes(val,{'numeric'},...
            {'scalar','real','finite'},...
            'polariAngleMarker','LocalAngle');
            m.LocalAngle=val;

            if~m.pDisableUpdates
                changeMarker(m);
            end
        end

        function set.OriginLineColorMode(m,val)
            val=validatestring(val,{'auto','facecolor'},...
            'polari','OriginLineColorMode');
            m.OriginLineColorMode=val;
        end

        function set.DataIndex(m,val)





            m.DataIndex=val;
            if~m.pDisableUpdates

                changeMarker(m);



            end
        end

        function set.MagIndex(m,val)





            m.MagIndex=val;
            if~m.pDisableUpdates

                changeMarker(m);
            end
        end

        function set.Floating(m,val)

            validateattributes(val,{'numeric','logical'},...
            {'scalar','real'},'polariAngleMarker','Floating');



            if val




                d=getData(m);

                m.Floating=val;
                m.DataSetMode='auto';
                m.DataSetIndex=[];
                m.LocalAngle=d.ang;


                showBannerMessage(m.PolariObj,...
                'Interpolating cursors interpolate values and move with selected dataset');
            else






                ang=m.LocalAngle;
                didx=getDataSetIndex(m);
                m.pDisableUpdates=true;

                m.DataSetIndex=didx;


                m.Floating=val;

                p=m.PolariObj;
                th=getNormalizedAngle(p,ang);
                m.DataIndex=getDataIndexFromPoint(p,...
                [cos(th),sin(th)],didx);

                m.MagIndex=[];

                m.pDisableUpdates=false;


                updateMarkers(m);
            end
        end

        function set.DataSetMode(m,val)
            m.DataSetMode=validatestring(val,{'auto','manual'},...
            'internal.polariAngleMarker','DataSetMode');

            if~m.pDisableUpdates
                setWidgetIDs(m);
                updateMarkers(m);
            end
        end

        function set.DataSetIndex(m,val)
            if isempty(val)
                m.DataSetIndex=val;
            else
                validateattributes(val,{'numeric'},...
                {'scalar','positive','integer'},...
                'polariAngleMarker','DataSetIndex');
                m.DataSetIndex=val;


                oDisable=m.pDisableUpdates;%#ok<*MCSUP>
                m.pDisableUpdates=true;
                m.DataSetMode='manual';
                m.pDisableUpdates=oDisable;

                if~oDisable
                    setWidgetIDs(m);
                    updateMarkers(m);
                end
            end
        end

        function set.DataSetConnect(m,str)




            if strcmpi(str,'active dataset')



                m.DataSetMode='auto';
            else



                idx=sscanf(str(9:end),'%d');
                changeDataSetIndex(m,idx);
            end

        end

        function val=get.DataSetConnect(m)




            if strcmpi(m.DataSetMode,'auto')
                val='Active Dataset';
            else
                val=sprintf('Dataset %d',m.DataSetIndex);
            end
        end

        function set.DetailWidth(m,val)
            validateattributes(val,{'numeric'},...
            {'scalar','finite','real'},...
            'polariAngleMarker','DetailWidth');
            m.DetailWidth=val;
            changeMarker(m);
        end

        function set.EdgeColorMode(m,val)
            val=validatestring(val,{'auto','manual'},...
            'polari','EdgeColorMode');
            m.EdgeColorMode=val;

            updateAutoColor(m);
        end

        function set.EdgeColor(m,val)
            m.pEdgeColor=val;


            m.EdgeColorMode='manual';
        end

        function val=get.EdgeColor(m)
            val=m.pEdgeColor;
        end

        function set.FaceAlpha(m,val)
            m.FaceAlpha=val;
            changeMarker(m);
        end

        function set.FaceColorMode(m,val)
            val=validatestring(val,{'auto','manual'},...
            'polari','FaceColorMode');
            m.FaceColorMode=val;
            updateMarkers(m);
        end

        function set.FaceColor(m,val)


            m.pFaceColor=val;



            if~strcmpi(m.FaceColorMode,'manual')
                m.FaceColorMode='manual';
            else
                updateMarkers(m);
            end
        end

        function val=get.FaceColor(m)
            val=m.pFaceColor;
        end

        function set.HiliteMarker(m,val)
            m.HiliteMarker=val;

            updateMarkerColor(m);
        end

        function val=get.ID(m)




            if strcmpi(m.Type,'p')
                val=sprintf('%s%d.%d',m.Type,m.Index,getDataSetIndex(m));
            else
                val=sprintf('%s%d',m.Type,m.Index);
            end
        end

        function set.ShowDetail(m,val)
            m.ShowDetail=val;
            changeMarker(m);
        end

        function set.DataDot(m,val)
            m.DataDot=val;
            changeMarker(m);
        end

        function set.DataDotLegend(m,val)
            m.DataDotLegend=val;
            changeMarker(m);
        end

        function set.OriginLine(m,val)
            m.OriginLine=val;
            updateOriginLine(m);
        end

        function set.Length(m,val)
            validateattributes(val,{'numeric'},...
            {'scalar','finite','real'},...
            'polariAngleMarker','Length');
            m.Length=val;

            changeMarker(m);
        end

        function set.TipOverlap(m,val)
            validateattributes(val,{'logical'},...
            {'scalar'},...
            'polariAngleMarker','TipOverlap');
            m.TipOverlap=val;
            changeMarker(m);
        end

        function set.Tip(m,val)
            validateattributes(val,{'numeric'},...
            {'scalar','finite','real'},...
            'polariAngleMarker','Tip');
            m.Tip=val;
            changeMarker(m);
        end

        function set.DetailDataStr(m,val)
            if~ischar(val)&&~(isstring(val)&&isscalar(val))&&~strcmpi(class(val),'function_handle')
                error('DetailDataString must be a char or a function_handle');
            end
            m.DetailDataStr=val;
            changeMarker(m);
        end

        function set.DetailIndexStr(m,val)
            if~ischar(val)&&~(isstring(val)&&isscalar(val))&&~strcmpi(class(val),'function_handle')
                error('DetailIndexStr must be a char or a function_handle');
            end
            m.DetailIndexStr=val;
            changeMarker(m);
        end

        function set.DetailTypeStr(m,val)
            if~ischar(val)&&~(isstring(val)&&isscalar(val))&&~strcmpi(class(val),'function_handle')
                error('DetailTypeStr must be a char or a function_handle');
            end
            m.DetailTypeStr=val;
            changeMarker(m);
        end

        function set.StringDirection(m,val)
            val=validatestring(val,{'length','width'},...
            'polari','StringDirection');
            m.StringDirection=val;

            changeStringDirection(m);

        end

        function set.Width(m,val)
            validateattributes(val,{'numeric'},...
            {'scalar','finite','real'},...
            'polariAngleMarker','Width');
            m.Width=val;
            changeMarker(m);
        end

        function set.Z(m,val)
            validateattributes(val,{'numeric'},...
            {'scalar','finite','real'},...
            'polariAngleMarker','Z');
            m.Z=val;
            transformMarker(m);
        end
    end



    methods
        function old=disableUpdates(m_vec,val_vec)







            val_idx=1;

            N=numel(m_vec);
            old=false(N,1);
            for i=1:N
                m_i=m_vec(i);


                old(i)=m_i.pDisableUpdates;


                val_i=val_vec(val_idx);
                val_idx=val_idx+~isscalar(val_vec);

                m_i.pDisableUpdates=val_i;
                if~val_i


                    updateMarkers(m_i);
                end
            end
        end

        function setWidgetIDs(m)





            for i=1:numel(m)
                m_i=m(i);
                set([m_i.hPatch;
                m_i.hBodyText;
                m_i.hIDText;
                m_i.hOriginLine;
                m_i.hDataDot;
                m_i.hDotText;
                m_i.hDataDotLegend],'UserData',m_i.ID);
            end
        end

        function angVec=getAngleFromVec(mVec)



            N=numel(mVec);
            angVec=zeros(N,1);
            for i=1:N
                d=getData(mVec(i));
                angVec(i)=d.ang;
            end
        end

        function c=getComplexAngle(m)



            p=m.PolariObj;
            if m.Floating

                ang=m.LocalAngle;
            else

                ang=p.pData(getDataSetIndex(m)).ang(m.DataIndex);
            end
            th=getNormalizedAngle(p,ang);
            c=complex(cos(th),sin(th));
        end

        function d=getData(m)










            d=m.pCache_getData;
            if isempty(d)


                d=getData_updateCache(m);
            end
        end

        function d=getData_updateCache(m)













            p=m.PolariObj;
            datasetIndex=getDataSetIndex(m);
            pdata=p.pData(datasetIndex);



            if m.Floating


                d.idx=[];
                d.ang=m.LocalAngle;
            else


                idx=m.DataIndex;
                d.idx=idx;
                d.ang=pdata.ang(idx);
            end
            if nargin<2

                if strcmpi(p.AngleRange,'180')
                    d.ang=mod(d.ang+180,360)-180;
                    d.ang(d.ang==-180)=180;
                else
                    d.ang=mod(d.ang,360);
                end
            end



            d.scale=p.pMagnitudeScale;

            if m.Floating


                th=getNormalizedAngle(p,d.ang);
                if isIntensityData(p)



                    angIdx=getDataIndexFromPoint(p,...
                    [cos(th),sin(th)],datasetIndex);


                    max_i=m.MagIndex;
                    if isempty(max_i)

                        [d.intensity,max_i]=max(pdata.intensity(:,angIdx));
                    else
                        d.intensity=pdata.intensity(max_i,angIdx);
                    end
                    d.mag=pdata.mag(max_i);
                else
                    [~,d.mag]=getInterpMagFromPoint(p,...
                    [cos(th),sin(th)],datasetIndex);
                    d.intensity=[];
                end
            else


                if isIntensityData(p)

                    max_i=m.MagIndex;
                    if isempty(max_i)


                        [d.intensity,max_i]=max(pdata.intensity(:,idx));
                    else
                        d.intensity=pdata.intensity(max_i,idx);
                    end
                    d.mag=pdata.mag(max_i);
                else
                    d.mag=pdata.mag(idx);
                    d.intensity=[];
                end
            end




            uStr=p.MagnitudeUnits;
            dispUnitIsDb=strcmpi(p.DisplayUnits,'db');
            if isempty(uStr)&&d.scale==1

                if dispUnitIsDb
                    d.units='dB';
                else
                    d.units='';
                end
                d.userUnit=false;
            else



                mksUnit=p.pMagnitudeUnits;

                if isempty(uStr)



                    d.units=sprintf('e%g',log10(1/d.scale));
                    d.userUnit=false;
                else

                    if any(uStr=='%')

                        d.units=sprintf(uStr,mksUnit);
                    else

                        d.units=[mksUnit,uStr];
                    end
                    d.userUnit=true;
                end
            end


            m.pCache_getData=d;
        end

        function remove(mvec)






            for i=1:numel(mvec)
                m_i=mvec(i);
                h=m_i.hLocalXform;
                if~isempty(h)&&ishghandle(h)
                    delete(h);
                    m_i.hLocalXform=[];
                end
            end
        end

        function updateMarkers(m)









            for i=1:numel(m)
                m_i=m(i);




                updateAutoColor(m_i);
                changeMarker(m_i);
            end
        end

        function updateActiveTraceMarkers(m,newAngles,justActiveTrace)
















            if nargin<3
                justActiveTrace=true;
            end
            Nm=numel(m);
            if Nm>0
                p=m(1).PolariObj;
                theta=getNormalizedAngle(p,newAngles);

                o=disableUpdates(m,true);



                for i=1:Nm
                    m_i=m(i);
                    if~justActiveTrace||strcmpi(m_i.DataSetMode,'auto')


                        th=theta(i);

                        m_i.DataIndex=getDataIndexFromPoint(p,...
                        [cos(th),sin(th)],getDataSetIndex(m_i));
                    end
                end

                disableUpdates(m,o);

                if justActiveTrace


                    for i=1:Nm
                        m_i=m(i);
                        if strcmpi(m_i.DataSetMode,'auto')


                            notify(m_i,'MarkerChangedActiveTrace');
                        end
                    end
                end
            end
        end

        function hideDataDot(m,hide)









            N=numel(m);
            if hide
                for i=1:N
                    m(i).hDataDot.Visible='off';
                    m(i).hDotText.Visible='off';
                end
            else
                updateMarkers(m);
            end
        end

        function y=isDataMarker(m)


            y=any(strcmpi(m.Type,{'p','c'}));
        end

        function y=isAngleLimMarker(m)
            y=strcmpi(m.Type,'a');
        end

        function y=isCursor(m)
            y=strcmpi(m.Type,'c');
        end

        function y=isPeak(m)
            y=strcmpi(m.Type,'p');
        end

        function idx=getDataSetIndex(m)







            if isscalar(m)
                if strcmpi(m.DataSetMode,'auto')
                    idx=m.PolariObj.pCurrentDataSetIndex;
                else
                    idx=m.DataSetIndex;
                end
            else
                Nm=numel(m);
                if Nm==0
                    idx=[];
                else


                    activeTrace=m(1).PolariObj.pCurrentDataSetIndex;
                    idx=zeros(size(m));
                    for i=1:Nm
                        if strcmpi(m(i).DataSetMode,'auto')
                            idx(i)=activeTrace;
                        else
                            idx(i)=m(i).DataSetIndex;
                        end
                    end
                end
            end
        end

        function changeDataSetIndex(m,datasetIdx)





            if isCursor(m)






                d=getData(m);
                dataIdx=getDataIndexFromAngle(m.PolariObj,d.ang,datasetIdx);

                disableUpdates(m,true);
                m.DataSetIndex=datasetIdx;
                m.DataIndex=dataIdx;
                disableUpdates(m,false);

            elseif isPeak(m)
















                p=m.PolariObj;
                old_idx=getDataSetIndex(m);
                pks=p.Peaks;
                pks(datasetIdx)=pks(old_idx);
                pks(old_idx)=0;
                p.Peaks=pks;

            else



            end
        end

        function y=markerInfo(m)
































            N=numel(m);
            id=cell(N,1);
            num=cell(N,1);
            ds=cell(N,1);
            ele=cell(N,1);
            ang=cell(N,1);
            mag=cell(N,1);
            intensity=cell(N,1);
            for i=N:-1:1
                m_i=m(i);


                idStr=m_i.ID;
                if strcmpi(idStr(1),'p')
                    idStr=idStr(1:find(idStr=='.')-1);
                end


                id{i}=idStr;
                num{i}=m_i.Index;
                ds{i}=getDataSetIndex(m_i);
                ele{i}=m_i.DataIndex;


                d=getData(m_i);
                mag{i}=d.mag;
                ang{i}=d.ang;
                intensity{i}=d.intensity;
            end



            if isempty(m)
                magUnits='';
                intUnits='';
            else
                p=m.PolariObj;
                magUnits=p.MagnitudeUnits;
                intUnits=p.IntensityUnits;
            end

            y=struct(...
            'ID',id,...
            'number',num,...
            'dataset',ds,...
            'index',ele,...
            'angle',ang,...
            'angleUnits','deg',...
            'magnitude',mag,...
            'magnitudeUnits',magUnits,...
            'intensity',intensity,...
            'intensityUnits',intUnits);
        end
    end

    methods(Access=private)
        function initListeners(m)



            p=m.PolariObj;
            lis.PolariAxes=addlistener(p,...
            'hAxes','PostSet',@(~,~)changeParentAxes(m));


            lis.PolariDataUnits=addlistener(p,...
            'DataUnitsChanged',@(~,~)changeMarker(m));









            lis.PolariAngle1Props=addlistener(p,...
            'AngleDirection',...
            'PostSet',@(~,~)transformMarker(m));

            lis.PolariAngle2Props=addlistener(p,...
            {'AngleDrag_Delta','AngleAtTop'},...
            'PostSet',@(~,~)changeMarker(m));









            lis.PolariFontProps=addlistener(p,...
            {'FontName','FontSize','AngleRange'},...
            'PostSet',@(~,~)changeMarker(m));

            m.Listeners=lis;
        end

        function deleteListeners(mvec)

            N=numel(mvec);
            for i=1:N
                mvec(i).Listeners=...
                internal.polariCommon.deleteListenerStruct(mvec(i).Listeners);
            end
        end

        function setProps(m,polariObj,varargin)






            m.PolariObj=polariObj;
            N=numel(varargin);
            for i=1:2:N-1
                m.(varargin{i})=varargin{i+1};
            end
        end

        function addMarker(m)




            p=m.PolariObj;
            tagStr=sprintf('%s%d',mfilename,p.pAxesIndex);



            xfrm=hgtransform(...
            'Parent',p.hAxes,...
            'HandleVisibility','off',...
            'Tag',tagStr);
            m.hLocalXform=xfrm;


            b=hggetbehavior(xfrm,'DataCursor');
            b.Enable=false;
            b=hggetbehavior(xfrm,'Plotedit');
            b.Enable=false;


            figParent=ancestor(xfrm,'figure');

            hc=uicontextmenu(...
            'Parent',figParent,...
            'Callback',@(h,ev)updateContextMenu(m,h,ev),...
            'HandleVisibility','off');




            hp=patch(...
            'Parent',xfrm,...
            'Tag',tagStr,...
            'HandleVisibility','off',...
            'clipping','on',...
            'XData',[],...
            'YData',[],...
            'ZData',[]);
            m.hPatch=hp;
            set(hp,'uicontextmenu',hc);

            b=hggetbehavior(hp,'Plotedit');
            b.Enable=false;
            b=hggetbehavior(hp,'DataCursor');
            b.Enable=false;


            ht=text(...
            'Parent',xfrm,...
            'Tag',tagStr,...
            'HandleVisibility','off',...
            'FontName',p.FontName,...
            'FontSize',p.FontSize,...
            'clipping','on',...
            'Position',[0,0,0]);

            m.hIDText=ht;
            set(ht,'uicontextmenu',hc);


            ht=text(...
            'Parent',xfrm,...
            'Tag',tagStr,...
            'HandleVisibility','off',...
            'FontName',p.FontName,...
            'FontSize',p.FontSize,...
            'clipping','on',...
            'Position',[0,0,0]);

            m.hBodyText=ht;
            set(ht,'uicontextmenu',hc);


            hl=line(...
            'Parent',xfrm,...
            'Tag',tagStr,...
            'HandleVisibility','off',...
            'LineWidth',m.OriginLineWidth,...
            'XData',[0,1],...
            'YData',[0,0],...
            'ZData',[0,0],...
            'Clipping','on',...
            'Visible','off');
            m.hOriginLine=hl;
            set(hl,'uicontextmenu',hc);

            b=hggetbehavior(hl,'Plotedit');
            b.Enable=false;
            b=hggetbehavior(hl,'DataCursor');
            b.Enable=false;




...
...
...
...
...
...
...
...
...
...
            hd=patch(...
            'Parent',xfrm,...
            'Tag',tagStr,...
            'HandleVisibility','off',...
            'EdgeAlpha',1,...
            'XData',[],...
            'YData',[],...
            'ZData',[],...
            'Clipping','on',...
            'Visible','off');
            m.hDataDot=hd;
            set(hd,'uicontextmenu',hc);

            b=hggetbehavior(hd,'Plotedit');
            b.Enable=false;
            b=hggetbehavior(hd,'DataCursor');
            b.Enable=false;


            ht=text(...
            'Parent',xfrm,...
            'Tag',tagStr,...
            'HandleVisibility','off',...
            'HorizontalAlignment','center',...
            'FontName',p.FontName,...
            'FontSize',p.FontSize,...
            'clipping','on',...
            'Position',[0,0,0]);

            m.hDotText=ht;
            set(ht,'uicontextmenu',hc);




            hd=patch(...
            'Parent',xfrm,...
            'Tag',tagStr,...
            'HandleVisibility','off',...
            'EdgeAlpha',1,...
            'XData',[],...
            'YData',[],...
            'ZData',[],...
            'Clipping','on',...
            'Visible','off');
            m.hDataDotLegend=hd;
            set(hd,'uicontextmenu',hc);

            b=hggetbehavior(hd,'Plotedit');
            b.Enable=false;
            b=hggetbehavior(hd,'DataCursor');
            b.Enable=false;

            setWidgetIDs(m);



            updateMarkers(m);
        end

        function updateBodyVisible(m,vis)




















            vst=internal.LogicalToOnOff(vis);



            if ishghandle(m.hBodyText)
                m.hBodyText.Visible=vst;
            end
            if ishghandle(m.hIDText)
                m.hIDText.Visible=vst;
            end
            if ishghandle(m.hPatch)
                m.hPatch.Visible=vst;
            end
            if m.DataDotLegend&&ishghandle(m.hDataDotLegend)
                m.hDataDotLegend.Visible=vst;
            end





            m.hDotText.Visible=internal.LogicalToOnOff(~vis);
        end

        function updateContextMenu(m,h,ev)









            fcn=m.ContextMenuFcn;
            if~isempty(fcn)
                feval(m.ContextMenuFcn,h,ev);
            end
        end

        function updateAutoColor(m)






            hp=m.hPatch;
            if~isempty(hp)&&ishghandle(hp)




                if strcmpi(m.FaceColorMode,'auto')&&isDataMarker(m)

                    co=m.PolariObj.pColorOrder;


                    m.pFaceColor=...
                    co(1+mod(getDataSetIndex(m)-1,size(co,1)),:);
                end

                m.pFaceColorText=internal.ColorConversion.getBWContrast(m.pFaceColor);

                if strcmpi(m.EdgeColorMode,'auto')
                    m.pEdgeColor=m.pFaceColorText;
                end
            end
        end

        function str=getString(m)


            if m.ShowDetail==1
                str=m.DetailDataStr;
            elseif m.ShowDetail==2
                str=m.DetailIndexStr;
            else
                str=m.DetailTypeStr;
            end

            if~ischar(str)&&~(isstring(str)&&isscalar(str))

                str=feval(str,m);
                if~ischar(str)&&~iscellstr(str)&&~isstring(str)
                    warning('Function handle must return a string or cellstring');
                    str='?';
                end
            end
        end

        function updateMarkerColor(m)




            hp=m.hPatch;
            if~isempty(hp)
                if m.HiliteMarker

                    Cpatch=m.pFaceColorText;
                    Ctext=m.pFaceColor;
                else

                    Cpatch=m.pFaceColor;
                    Ctext=m.pFaceColorText;
                end
                Corigin=m.pFaceColor;

                p=m.PolariObj;

                set(m.hIDText,...
                'BackgroundColor',getBackgroundColorOfAxes(p),...
                'Color',m.pFaceColor);
                set(m.hBodyText,'Color',Ctext);
                set(hp,...
                'FaceColor',Cpatch,...
                'FaceAlpha',m.FaceAlpha,...
                'EdgeColor',Ctext);

                if strcmpi(m.Type,'p')
                    marker=m.DataDotPeak;
                else
                    marker=m.DataDotCursor;
                end
                if strcmpi(marker,'triangle')
                    Cddedge=Cpatch;
                else
                    Cddedge=Corigin;
                end



                if strcmpi(p.Style,'filled')
                    Cddedge='k';
                    Corigin='k';
                end

                set(m.hDataDot,...
                'FaceColor',Corigin,...
                'EdgeColor',Cddedge);
                set(m.hDotText,...
                'Color',Corigin);

                set(m.hDataDotLegend,...
                'FaceColor',Ctext,...
                'EdgeColor',Cpatch);

                set(m.hOriginLine,...
                'Color',Corigin);
            end
        end

        function changeMarker(m)

































            hp=m.hPatch;
            if isempty(hp)
                return
            end



            if m.HiliteMarker

                Cpatch=m.pFaceColorText;
                Ctext=m.pFaceColor;
            else

                Cpatch=m.pFaceColor;
                Ctext=m.pFaceColorText;
            end
            Corigin=m.pFaceColor;





            if isDataMarker(m)

                m.pCache_getData=[];

            end




            p=m.PolariObj;
            set(m.hBodyText,...
            'Rotation',0,...
            'Color',Ctext,...
            'FontName',p.FontName,...
            'FontSize',p.FontSize,...
            'String',getString(m));

            idStr=markerIDForDisplay(m);
            set(m.hIDText,...
            'BackgroundColor',getBackgroundColorOfAxes(p),...
            'Color',m.pFaceColor,...
            'Rotation',0,...
            'FontName',p.FontName,...
            'FontSize',p.FontSize,...
            'String',idStr);

            set(hp,...
            'FaceColor',Cpatch,...
            'FaceAlpha',m.FaceAlpha,...
            'EdgeColor',Ctext);










            if isDataMarker(m)


                d=getData(m);
                r=getNormalizedMag(p,d.mag);
                if isempty(r)||r<0
                    r=0;
                end
                if strcmpi(m.Type,'p')
                    marker=m.DataDotPeak;
                else
                    marker=m.DataDotCursor;
                end
            else


                r=0;
                marker=m.DataDotCursor;
            end



            switch lower(marker)
            case 'triangle'

                marker='none';
                Cddedge=Cpatch;
                markerSizeForLegend=m.DataDotSize;
                markerEdgeColor=Cpatch;
                d=.06;
                w=.03;
                xDot=[1-r-d;1-r;1-r-d];
                yDot=[w,0,-w];

                xLegend=(xDot-1+r)*.7-0.01;
                yLegend=yDot*.7;


            case 'arc'

                marker='none';
                Cddedge=Cpatch;
                markerSizeForLegend=m.DataDotSize;
                markerEdgeColor=Cpatch;

                xDot=1-r;
                yDot=0;

                xtra=.03;
                d=0.06;
                w=1;
                x1=1-r-d;
                x2=x1-d/2;
                y1=w;
                y2=-w;
                x=[x1,x2,x1];
                y=[y1,0,y2];
                xLegend=(x-1+r)*.7-0.01-xtra;
                yLegend=y*.7;

            otherwise

                Cddedge=Corigin;
                markerSizeForLegend=5;
                markerEdgeColor=Ctext;
                x=1-r;
                y=0;
                xDot=x;
                yDot=y;
                xLegend=(x-1+r)*.7-0.01;
                yLegend=y*.7;
            end







            zDot=-0.06*ones(size(xDot));



            if strcmpi(p.Style,'filled')
                Cddedge='k';
                Corigin='k';
            end
            set(m.hDataDot,...
            'FaceColor',Corigin,...
            'EdgeColor',Cddedge,...
            'Marker',marker,...
            'MarkerSize',m.DataDotSize,...
            'XData',xDot,...
            'YData',yDot,...
            'ZData',zDot,...
            'Visible',internal.LogicalToOnOff(...
            m.DataDot||m.OriginLine));








            xdt=min(xDot);
            if isPeak(m)&&(xdt>0.05)

                pos=[xdt-.005,0,zDot(1)];
                vert='bottom';
            else

                pos=[1-r+.01,0,zDot(1)];
                vert='top';
            end
            thd=getNormalizedMarkerAngle(m);
            if thd<0

                if strcmpi(vert,'bottom')
                    vert='top';
                else
                    vert='bottom';
                end
            end
            if isAngleLimMarker(m)


                idStr='';
            else
                idStr=sprintf('%d',m.Index);
            end








            if m.Visible
                dot_text_vis=false;
            else
                dot_text_vis=(m.DataDot||m.OriginLine)&&m.DataDotText;
            end
            set(m.hDotText,...
            'VerticalAlignment',vert,...
            'Position',pos,...
            'Rotation',0,...
            'Color',Corigin,...
            'FontName',p.FontName,...
            'FontSize',p.FontSize,...
            'String',idStr,...
            'Visible',internal.LogicalToOnOff(dot_text_vis));

            set(m.hDataDotLegend,...
            'FaceColor',Ctext,...
            'EdgeColor',Cpatch,...
            'Marker',marker,...
            'MarkerSize',markerSizeForLegend,...
            'MarkerEdgeColor',markerEdgeColor,...
            'XData',xLegend,...
            'YData',yLegend,...
            'ZData',zeros(size(xLegend)),...
            'Visible',internal.LogicalToOnOff(m.DataDotLegend&&m.Visible));









            z=(zDot(1)-0.01)*[1,1];
            set(m.hOriginLine,...
            'Color',Corigin,...
            'XData',[m.Tip,1-r],...
            'YData',[0,0],...
            'ZData',z);

            changeStringDirection(m);


            notify(m,'MarkerChanged');
        end

        function changeParentAxes(m)



            hx=m.hLocalXform;
            if~isempty(hx)&&ishghandle(hx)
                hx.Parent=m.PolariObj.hAxes;
            end
        end

        function changeStringDirection(m)


            ht=m.hBodyText;
            if isempty(ht)
                return
            end




            strIsCell=iscellstr(ht.String);





            thd=getNormalizedMarkerAngle(m);
            ang=mod(thd,360)-180;
            strdir=m.StringDirection;
            thresh=m.MarkerAngleOrientationThreshold;
            if abs(ang)<thresh||abs(ang-180)<thresh||abs(ang+180)<thresh
                if strcmpi(strdir,'length')
                    strdir='width';
                else
                    strdir='length';
                end
            end


            W=m.Width;
            if strcmpi(strdir,'width')
                if strcmpi(m.WidthMode,'auto')




                    t=ht.Parent;
                    isTrans=strcmpi(t.Type,'hgtransform');
                    if isTrans
                        mt=t.Matrix;
                        t.Matrix=eye(4);
                    end
                    ext=ht.Extent;
                    if isTrans
                        t.Matrix=mt;
                    end

                    txtHorz='center';


                    if m.ShowDetail<3
                        mult=1.2;
                    else
                        mult=1.5;
                    end
                    D=max(W,mult*ext(3));


                    L=1.15*ext(4);

                    if strIsCell
                        txtL=-L/2*1.075;
                    else

                        txtL=-ext(4)/2*1.075;
                    end
                    txtVert='middle';

                else
                    L=m.Length;
                    txtL=-L;
                    txtHorz='center';
                    txtVert='top';
                    if m.ShowDetail<3
                        D=m.DetailWidth;
                    else

                        D=W;
                    end
                end

            else


                if strcmpi(m.WidthMode,'auto')



                    t=ht.Parent;
                    isTrans=strcmpi(t.Type,'hgtransform');
                    if isTrans
                        mt=t.Matrix;
                        t.Matrix=eye(4);
                    end
                    ext=ht.Extent;
                    if isTrans
                        t.Matrix=mt;
                    end

                    txtHorz='center';
                    D=max(W,1.3*ext(4));
                    if strIsCell
                        L=max(0.1,ext(3)*1.2);
                        txtL=-L/2;
                    else
                        L=max(0.1,ext(3)*1.3);
                        txtL=-L/2;
                    end
                    txtVert='middle';

                else

                    if m.ShowDetail<3
                        D=m.DetailWidth;
                    else

                        D=W;
                    end
                    L=m.Length;
                    txtL=-L/2;
                    txtVert='middle';
                    txtHorz='center';
                end
            end




            T=m.Tip;
            if m.TipOverlap
                offset=0;
            else
                offset=-T;
            end



            set(ht,...
            'Position',[txtL+offset,0,0],...
            'VerticalAlignment',txtVert,...
            'HorizontalAlignment',txtHorz);


            set(m.hIDText,...
            'Position',[-L+offset,0,-0.005],...
            'VerticalAlignment','top',...
            'HorizontalAlignment','center');


















            hp=m.hPatch;
            set(hp,...
            'XData',[-L,0,0,T,0,0,-L]+offset,...
            'YData',[+D,+D,+W,0,-W,-D,-D]/2,...
            'ZData',zeros(1,7));





            hOrigin=m.hOriginLine;
            x0=hOrigin.XData(2);
            hOrigin.XData=[T+offset,x0];




            transformMarker(m);
        end

        function transformMarker(m)









            hgt=m.hLocalXform;
            if isempty(hgt)
                return
            end



















            thd=getNormalizedMarkerAngle(m);
            ct=cosd(thd);
            st=sind(thd);
...
...
...
...
...
...
...
...
...
...
...

            hgt.Matrix=[...
            -ct,st,0,ct;...
            -st,-ct,0,st;...
            0,0,1,m.Z;...
            0,0,0,1];




            hm=m.hDotText;
            if thd<0
                hm.Rotation=thd+90;
            else
                hm.Rotation=thd-90;
            end



            ang=mod(thd,360)-180;



            strdir=m.StringDirection;
            ang_id=ang;
            if strcmpi(strdir,'length')
                if ang_id<-90||ang_id>90
                    ang_id=ang_id+180;
                    va='top';
                else
                    va='bottom';
                end
            else

                ang_id=ang_id+90;
                if ang_id<-90||ang_id>90
                    ang_id=ang_id-180;
                    va='top';
                else
                    va='bottom';
                end
            end
            m.hIDText.Rotation=ang_id;
            m.hIDText.VerticalAlignment=va;







            thresh=m.MarkerAngleOrientationThreshold;
            strdir=m.StringDirection;
            if abs(ang)<thresh||abs(ang-180)<thresh||abs(ang+180)<thresh
                if strcmpi(strdir,'length')
                    strdir='width';
                else
                    strdir='length';
                end
            end



            if strcmpi(strdir,'length')
                if ang<-90||ang>90
                    ang=ang+180;
                end

            else

                ang=ang+90;
                if ang<-90||ang>90
                    ang=ang-180;
                end
            end
            m.hBodyText.Rotation=ang;
        end

        function updateOriginLine(m)






            newOriginVis=m.OriginLine&&m.Visible;
            st=internal.LogicalToOnOff(newOriginVis);
            m.hOriginLine.Visible=st;


            if m.DataDot
                st='on';
            end
            m.hDataDot.Visible=st;
        end

        function thd=getNormalizedMarkerAngle(m)



            if isDataMarker(m)
                if m.Floating
                    thd=m.LocalAngle;
                else
                    thd=m.PolariObj.pData(getDataSetIndex(m)).ang(m.DataIndex);
                end
            else

                thd=m.LocalAngle;
            end
            thd=getNormalizedAngleDeg(m.PolariObj,thd);
        end

        function idStr=markerIDForDisplay(m)





            if isAngleLimMarker(m)
                idStr='';
            else
                idStr=m.ID;
                if strcmpi(idStr(1),'p')
                    if getNumDatasets(m.PolariObj)<2
                        idStr=idStr(1:find(idStr=='.')-1);
                    end
                end
            end
        end
    end



    methods(Static)
        function str=angleLimCursorDataStrFcn(m)


            s_ang=internal.polariCommon.sprintfMaxNumFracDigits(m.LocalAngle,1);
            if strcmp(get(groot,'defaultTextInterpreter'),'latex')
                str=['$',s_ang,'^{\circ}$'];
            else
                str=[s_ang,char(176)];
            end
        end

        function str=markerDetailDataStrFcn(m,showUnits)

















            d=getData(m);
            s_ang=internal.polariCommon.sprintfMaxNumFracDigits(d.ang,1);
            s_mag=internal.polariCommon.sprintfMaxNumFracDigits(d.mag*d.scale,2);

            if isIntensityData(m.PolariObj)


                s_int=internal.polariCommon.sprintfMaxNumFracDigits(d.intensity,1);

                if~showUnits||isempty(d.units)
                    str={[s_ang,char(176)],s_mag,['[',s_int,']']};
                else

                    str={[s_ang,char(176)],[s_mag,' ',d.units],['[',s_int,']']};
                end
            else

                if~showUnits||isempty(d.units)

                    if strcmp(get(groot,'defaultTextInterpreter'),'latex')
                        str={['$',s_ang,'^{\circ}$'],s_mag};
                    else
                        str={[s_ang,char(176)],s_mag};
                    end
                else

                    str={[s_ang,char(176)],[s_mag,' ',d.units]};
                end
            end
        end

        function str=markerDetailMagOnlyStrFcn(m,showUnits)

            d=getData(m);
            s_mag=internal.polariCommon.sprintfMaxNumFracDigits(d.mag*d.scale,2);

            if isIntensityData(m.PolariObj)

                s_int=internal.polariCommon.sprintfMaxNumFracDigits(d.intensity,1);
                if~showUnits||isempty(d.units)
                    str={s_mag,['[',s_int,']']};
                else

                    str={[s_mag,' ',d.units],['[',s_int,']']};
                end
            else

                if~showUnits||isempty(d.units)
                    str=s_mag;
                else

                    str=[s_mag,' ',d.units];
                end
            end
        end

        function str=markerDetailIndexStrFcn(m)





            str={...
            sprintf('%s%d%s',m.Type,m.Index,getOptionalTraceInfoString(m)),...
            sprintf('%d',m.DataIndex)};
        end

        function str=markerDetailAngleStrFcn(m)



            d=getData(m);
            s_ang=internal.polariCommon.sprintfMaxNumFracDigits(d.ang,1);
            if strcmp(get(groot,'defaultTextInterpreter'),'latex')
                str=['$',s_ang,'^{\circ}$'];
            else
                str=[s_ang,char(176)];
            end
        end

        function str=markerDetailTypeStrFcn(m)



            str=sprintf('%s%d%s',m.Type,m.Index,getOptionalTraceInfoString(m));
        end
    end
end
