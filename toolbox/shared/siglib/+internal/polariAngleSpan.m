classdef polariAngleSpan<handle
















    properties(AbortSet)
        Visible=false
    end

    properties(AbortSet)
        Fill=true
    end

    properties(Hidden)


        PreserveReflexAngle=true
    end

    properties
PolariObj
hAxes
Listeners

hReadout

        AllCplx=[]
        AllIDs={}










AllLastChange






        SpanIDs={'',''}
        SpanCplx={[],[]}

        ZPlane=0
    end

    properties(Dependent)



SpanIDs_LiveUpdate
    end

    properties(Access=private)
hLocalXform
hSpan







        pLastSpanCCW=0










        pEndpointsWereChanged=false
    end

    properties(Constant)

        SpanAlpha=0.7


        MaxDigitsDeltaTheta=4
        MaxDigitsDeltaR=3


        CursorIDsInReadout=true





        SpanZPlaneMode=3

        SpanZPlane_UnderData=0.05
        SpanZPlane_OverData=0.21



        SymbolCCW=native2unicode([226,134,186],'UTF-8')
        SymbolCW=native2unicode([226,134,187],'UTF-8')
        SymbolDelta=char(916)
        SymbolTheta=char(952)
        SymbolDegree=char(176)




        ResetAfter360Span=false





    end



    methods
        function s=polariAngleSpan(p)

            if nargin>0
                init(s,p);
            end
        end

        function delete(s)


            deleteAllListeners(s);
            delete(s.hReadout);
            deleteWidgets(s);
        end

        function set.Visible(s,val)
            validateattributes(val,{'logical'},...
            {'scalar'},'polariAngleSpan','Visible');
            s.Visible=val;

            updateGraphicalSpanVis(s);
        end

        function set.Fill(s,val)
            validateattributes(val,{'logical'},...
            {'scalar'},'polariAngleSpan','Fill');
            s.Fill=val;

            updateGraphicalSpanVis(s);
        end

        function set.SpanIDs_LiveUpdate(s,val)






            s.SpanIDs=val;
            changeSpanEndpoints(s);
        end

        function val=get.SpanIDs_LiveUpdate(s)



            val=s.SpanIDs;
        end
    end

    methods

        function deleteAllListeners(s)


            s.Listeners=internal.polariCommon.deleteListenerStruct(s.Listeners);




        end

        function[c,c_display]=getListOfAngleMarkerIDsForEndpoints(s,thisEndpoint)













            otherEndpoint=3-thisEndpoint;





            allIDs=s.AllIDs;


            otherID=s.SpanIDs{otherEndpoint};
            allIDs(strcmpi(otherID,allIDs))=[];




            c=sort(allIDs);
            c_display=modifyIDsForContextMenuDisplay(s,c);
        end

        function ids=modifyIDsForContextMenuDisplay(s,ids)




            if getNumDatasets(s.PolariObj)==1
                for i=1:numel(ids)
                    id_i=ids{i};
                    if strcmpi(id_i(1),'p')
                        ids{i}=id_i(1:(find(id_i=='.',1)-1));
                    end
                end
            end
        end

        function updateSpanContextMenu(s,hMenu)



            delete(hMenu.Children);










            t=modifyIDsForContextMenuDisplay(s,s.SpanIDs);
            id1=t{1};
            id2=t{2};

            p=s.PolariObj;
            if strcmpi(p.AngleDirection,'ccw')
                label=['<html><b>ANGLE SPAN</b><br>'...
                ,'<font size=4>'...
                ,'<i>',id1,' ',s.SymbolCCW,' ',id2,'</i></font></html>'];
            else
                label=['<html><b>ANGLE SPAN</b><br>'...
                ,'<font size=4>'...
                ,'<i>',id2,' ',s.SymbolCW,' ',id1,'</i></font></html>'];
            end

            headerOpts={hMenu,label,'','Enable','off'};
            internal.ContextMenus.createContext(headerOpts);














            Ncursors=numel(s.PolariObj.hCursorAngleMarkers);
            make=true;
            sep=true;
            [startVals,startVals_display]=getListOfAngleMarkerIDsForEndpoints(s,2);
            h2=internal.ContextMenus.createContextSubmenu(s,make,sep,hMenu,...
            'Start Point',startVals_display,{'SpanIDs_LiveUpdate',2},...
            startVals);

            if numel(startVals)>Ncursors&&Ncursors>0
                h2(Ncursors+1).Separator='on';
            end

            [endVals,endVals_display]=getListOfAngleMarkerIDsForEndpoints(s,1);
            h2=internal.ContextMenus.createContextSubmenu(s,make,false,hMenu,...
            'End Point',endVals_display,{'SpanIDs_LiveUpdate',1},...
            endVals);

            if numel(endVals)>Ncursors&&Ncursors>0
                h2(Ncursors+1).Separator='on';
            end

            opts={hMenu,'Swap Endpoints',@(~,~)m_SwapEndpoints(s),'separator','on'};
            internal.ContextMenus.createContext(opts);

            internal.ContextMenus.createContext({hMenu,'Remove Span',...
            @(~,~)showAngleSpan(p,false)});

            internal.ContextMenus.createContext({hMenu,'Export Span',...
            @(~,~)m_ExportSpan(s)});

...
...
...
...
...
...
...
        end

        function changeSpanEndpoints(s,ID1,ID2)






            passedIDs=nargin>1;
            if passedIDs

                spanIDs={ID1,ID2};
            else



                spanIDs=s.SpanIDs;
            end




            [present,locb]=ismember(upper(spanIDs),s.AllIDs);
            if~all(present)
                if~present(1)
                    invalidID=spanIDs{1};
                else
                    invalidID=spanIDs{2};
                end
                error('Invalid marker ID "%s".',invalidID);
            end
            if locb(1)==locb(2)
                if~passedIDs




                    s.SpanIDs={'',''};
                    s.SpanCplx={[],[]};
                    hideSpan(s);
                end
                error('Distinct markers must be specified for each span endpoint.');
            end

            if passedIDs

                s.SpanIDs=spanIDs;
            end


            s.SpanCplx={s.AllCplx(locb(1)),s.AllCplx(locb(2))};






            s.pEndpointsWereChanged=true;
            updateGraphicalSpanVis(s);
            s.pEndpointsWereChanged=false;
        end

        function revertSpanEndpoints(s)

            updateWidgets(s);
        end

        function m_SwapEndpoints(s)




            if~any(cellfun(@isempty,s.SpanIDs))

                s.PreserveReflexAngle=true;


                s.SpanIDs_LiveUpdate={s.SpanIDs{2},s.SpanIDs{1}};



            end
        end

        function m_ExportSpan(s)
















            assignin('base','span',spanDetails(s));
            str='Exported <a href="matlab:eval(''span'')">span</a> variable to the base workspace.';
            disp(str);
            showBannerMessage(s.PolariObj,...
            'Exported ''span'' variable to the base workspace.');
        end

        function y=spanDetails(s)
























            p=s.PolariObj;
            if isempty(s)


                minfo=markerInfo(internal.polariAngleMarker.empty);
                adiff=[];
                mdiff=[];
                idiff=[];
            else

                sID1=s.SpanIDs{1};
                sID2=s.SpanIDs{2};
                if~s.Visible||isempty(sID1)||isempty(sID2)

                    minfo=markerInfo(internal.polariAngleMarker.empty);
                    adiff=[];
                    mdiff=[];
                    idiff=[];
                else

                    m2=findAngleMarkerByID(p,s.SpanIDs{2});
                    m1=findAngleMarkerByID(p,s.SpanIDs{1});
                    minfo=markerInfo([m1;m2]);


                    is_ccw=strcmpi(p.AngleDirection,'ccw');

                    adiff=internal.polariCommon.cangleDiff(...
                    s.SpanCplx{1},s.SpanCplx{2})*180/pi;

                    if is_ccw

                        mdiff=minfo(2).magnitude-minfo(1).magnitude;
                        idiff=minfo(2).intensity-minfo(1).intensity;
                    else

                        mdiff=minfo(1).magnitude-minfo(2).magnitude;
                        idiff=minfo(1).intensity-minfo(2).intensity;
                    end
                end
            end
            aunits='deg';
            munits=p.MagnitudeUnits;
            iunits=p.IntensityUnits;

            y=struct(...
            'angleDiff',adiff,...
            'angleUnits',aunits,...
            'magnitudeDiff',mdiff,...
            'magnitudeUnits',munits,...
            'intensityDiff',idiff,...
            'intensityUnits',iunits,...
            'markers',minfo);
        end

        function init(s,p)


            s.PolariObj=p;
            s.hAxes=p.hAxes;






            s.pLastSpanCCW=0;

            initListeners(s);
            updateAngleMarkersList(s);
            changedPolarStyle(s);
            initReadout(s);
        end

        function initLurking(s,p)





            init(s,p);
            createWidgets(s);
            s.hLocalXform.Visible='on';
            s.Visible=true;
            updateWidgets(s);
        end

        function updateAngleMarkersList(s)












            rebuildMarkerList(s);
            anyChange=selectNewEndpointsIfEmpty(s);

            if anyChange
                updateGraphicalSpanVis(s);
            else
                updateWidgets(s);
            end
        end

        function updatePosition(s,newPos)


            hr=s.hReadout;
            if~isempty(hr)
                updatePosition(hr,newPos);
            end
        end

        function hoverOverReadoutChange(s,event)




            hr=s.hReadout;
            if~isempty(hr)
                hoverOverReadoutChange(hr,event);
            end
        end

        function hoverOverSpanChange(s,action)





            p=s.PolariObj;

            if isIntensityData(p)
                z0=s.SpanZPlane_OverData;
                s.ZPlane=z0;
                updateWidgets(s);

            elseif~strcmpi(p.Style,'line')
                if strcmpi(action,'start')
                    z0=s.SpanZPlane_OverData;
                else
                    z0=s.SpanZPlane_UnderData;
                end
                s.ZPlane=z0;
                updateWidgets(s);
            end
        end
    end

    methods(Access=private)
        function initReadout(s)


            hr=internal.polariReadout(s.PolariObj);
            s.hReadout=hr;
            if~isunix
                hr.FontName='Courier';
            end
            hr.FontRelSize=-2;
            hr.TagName='polariSpanReadout';
            hr.ContextMenuFcn=@(hMenu,ev)updateReadoutContextMenu(s,hMenu);
        end

        function updateReadoutContextMenu(s,hMenu)





            delete(hMenu.Children);










            ids=modifyIDsForContextMenuDisplay(s,s.SpanIDs);
            id1=ids{1};
            id2=ids{2};

            p=s.PolariObj;
            if strcmpi(p.AngleDirection,'ccw')
                label=['<html><b>ANGLE SPAN</b><br>'...
                ,'<font size=4>'...
                ,'<i>',id1,' ',s.SymbolCCW,' ',id2,'</i></font></html>'];
            else
                label=['<html><b>ANGLE SPAN</b><br>'...
                ,'<font size=4>'...
                ,'<i>',id2,' ',s.SymbolCW,' ',id1,'</i></font></html>'];
            end

            headerOpts={hMenu,label,'','Enable','off'};
            internal.ContextMenus.createContext(headerOpts);

            opts={hMenu,'Swap Endpoints',@(~,~)m_SwapEndpoints(s),'separator','on'};
            internal.ContextMenus.createContext(opts);

            opts={hMenu,'Remove Span',...
            @(~,~)showAngleSpan(p,false)};
            internal.ContextMenus.createContext(opts);

            internal.ContextMenus.createContext({hMenu,'Export Span',...
            @(~,~)m_ExportSpan(s)});
        end

        function initListeners(s)





            deleteAllListeners(s);
            p=s.PolariObj;





            lis.Primary.AngleMarkersListListener=addlistener(p,...
            {'hCursorAngleMarkers','hPeakAngleMarkers'},...
            'PostSet',@(~,~)updateAngleMarkersList(s));


            lis.Primary.PolariAngleProps=addlistener(p,...
            {'AngleAtTop','AngleDirection','AngleDrag_Delta'},...
            'PostSet',@(~,~)angleTicksMoved(s));


            lis.Primary.PolariMagUnits=addlistener(p,...
            'MagnitudeUnits',...
            'PostSet',@(~,~)updateReadout(s));


            lis.Primary.PolariStyle=addlistener(p,...
            'Style','PostSet',@(~,~)changedPolarStyle(s,true));






            lis.Endpoints.StartMarker=[];
            lis.Endpoints.StartMarkerActiveTraceChange=[];
            lis.Endpoints.EndMarker=[];
            lis.Endpoints.EndMarkerActiveTraceChange=[];

            s.Listeners=lis;
        end

        function changedPolarStyle(s,forceUpdate)



            p=s.PolariObj;

            if isIntensityData(p)
                z0=s.SpanZPlane_OverData;
            elseif strcmpi(p.Style,'line')
                z0=s.SpanZPlane_UnderData;
            else
                z0=s.SpanZPlane_OverData;
            end
            s.ZPlane=z0;

            if(s.ZPlane~=z0)&&nargin>1&&forceUpdate&&s.Visible
                updateWidgets(s);
            end
        end

        function rebuildMarkerList(s)












            p=s.PolariObj;
            m=[p.hCursorAngleMarkers;p.hPeakAngleMarkers];
            if isempty(m)
                newIDs={};
                newCplx=[];
            else
                th=getNormalizedAngle(p,getAngleFromVec(m));
                th=mod(th,2*pi);
                [th,idx]=sort(th);
                newCplx=complex(cos(th),sin(th));
                newIDs={m(idx).ID};
            end



            oldIDs=s.AllIDs;
            oldCplx=s.AllCplx;

            [isPresent,firstMatchIdxInNew]=ismember(oldIDs,newIDs);
            removedIDs=oldIDs(~isPresent);
            removedCplx=oldCplx(~isPresent);

            newIdx=firstMatchIdxInNew(isPresent);
            oldIdx=find(isPresent);






            modifiedIDs={};
            modifiedCplx=[];
            if~isempty(oldIdx)
                oldCplx_commonIDs=oldCplx(oldIdx);
                newCplx_commonIDs=newCplx(newIdx);
                sel=oldCplx_commonIDs~=newCplx_commonIDs;
                if any(sel)
                    assert(isequal(oldIDs(oldIdx(sel)),newIDs(newIdx(sel))),'changed markers must have the same ID')
                    modifiedIDs=oldIDs(oldIdx(sel));
                    modifiedCplx={oldCplx_commonIDs,newCplx_commonIDs};
                end
            end

            info.removedIDs=removedIDs;
            info.removedCplx=removedCplx;
            info.modifiedIDs=modifiedIDs;
            info.modifiedCplx=modifiedCplx;
            info.dirty=~isempty(removedIDs)||~isempty(modifiedIDs);

            assert(~info.dirty||...
            (~isequal(newIDs,s.AllIDs)||~isequal(newCplx,s.AllCplx)))


            s.AllIDs=newIDs;
            s.AllCplx=newCplx;
            s.AllLastChange=info;
        end

        function anyChange=selectNewEndpointsIfEmpty(s)





























            c=s.AllCplx;
            [isInSet,idx]=ismember(s.SpanIDs,s.AllIDs);


            if~isInSet(1)
                c1=[];
            else
                c1=c(idx(1));
                s.SpanCplx{1}=c1;
            end
            if~isInSet(2)
                c2=[];
            else
                c2=c(idx(2));
                s.SpanCplx{2}=c2;
            end
            new_cplx={c1,c2};



            c_prior=s.SpanCplx;



            empty_ids=cellfun(@isempty,s.SpanIDs);
            if~empty_ids(1)&&~isInSet(1)
                s.SpanCplx{1}=[];
                s.SpanIDs{1}='';
            end
            if~empty_ids(2)&&~isInSet(2)
                s.SpanCplx{2}=[];
                s.SpanIDs{2}='';
            end



            if~isempty(c1)&&~isempty(c2)
                anyChange=~isequal(c_prior,new_cplx);
                if~anyChange
                    return
                end
            else
                anyChange=true;
            end























            N=numel(c);
            if N<2




                return
            end


            empty_ids=cellfun(@isempty,s.SpanIDs);
            if all(empty_ids)


                c1=c_prior{1};
                c2=c_prior{2};






                if~isempty(c1)&&~isempty(c2)

                    ang_diff=abs(c-c1);
                    [~,i1]=min(ang_diff);
                    c(i1)=inf;
                    ang_diff=abs(c-c2);
                    [~,i2]=min(ang_diff);

                elseif~isempty(c1)




                    ang_diff=abs(c-c1);
                    [~,i1]=min(ang_diff);
                    c1=c(i1);
                    c(i1)=inf;
                    ang_diff=abs(c-c1);
                    [~,i2]=min(ang_diff);

                elseif~isempty(c2)




                    ang_diff=abs(c-c2);
                    [~,i2]=min(ang_diff);
                    c2=c(i2);
                    c(i2)=inf;
                    ang_diff=abs(c-c2);
                    [~,i1]=min(ang_diff);

                else


                    if N==2






                        if internal.polariCommon.isCW(c(1),c(2))
                            i1=2;
                            i2=1;
                        else
                            i1=1;
                            i2=2;
                        end
                    else








                        c0=complex(0,1);
                        ang_diff=internal.polariCommon.cangleAbsDiff(c0,c);
                        [~,i1]=min(ang_diff);
                        ang_diff(i1)=inf;
                        [~,i2]=min(ang_diff);



                        if internal.polariCommon.cangleDiff(c(i1),c(i2))>pi



                            t=i1;i1=i2;i2=t;
                        end
                    end
                end


                idx=[i1,i2];
                s.SpanIDs=s.AllIDs(idx);
                s.SpanCplx={c(idx(1)),c(idx(2))};

            elseif~any(empty_ids)







                s.SpanCplx=new_cplx;

            else






                enum_missing_marker=find(empty_ids);
                assert(isscalar(enum_missing_marker))
                enum_existing_marker=3-enum_missing_marker;
                idx_existing_marker=idx(enum_existing_marker);





                target_c=c_prior{enum_missing_marker};
                if isempty(target_c)

                    target_c=c_prior{enum_existing_marker};


                end








                [ccw_dist,cw_dist]=internal.polariCommon.cangleDiff(target_c,c);
                [~,ccw_sort_i]=sort(ccw_dist);
                j=find(ccw_sort_i==idx_existing_marker);
                ccw_sort_i=ccw_sort_i(1:j-1);




                [~,cw_sort_i]=sort(cw_dist);
                j=find(cw_sort_i==idx_existing_marker);
                cw_sort_i=cw_sort_i(1:j-1);

                if isempty(ccw_sort_i)

                    idx_replacement_marker=cw_sort_i(1);

                elseif isempty(cw_sort_i)

                    idx_replacement_marker=ccw_sort_i(1);

                else


                    closest_ccw_idx=ccw_sort_i(1);
                    closest_ccw_dist=ccw_dist(closest_ccw_idx);
                    closest_cw_idx=cw_sort_i(1);
                    closest_cw_dist=cw_dist(closest_cw_idx);
                    if closest_ccw_dist<closest_cw_dist
                        idx_replacement_marker=closest_ccw_idx;
                    else
                        idx_replacement_marker=closest_cw_idx;
                    end
                end


                s.SpanIDs{enum_missing_marker}=s.AllIDs{idx_replacement_marker};
                s.SpanCplx{enum_missing_marker}=c(idx_replacement_marker);
            end





        end

        function addListenersOnEndpoints(s)

            deleteListenersOnEndpoints(s);

            lis=s.Listeners;
            p=s.PolariObj;

            m=findAngleMarkerByID(p,s.SpanIDs{1});
            lis.Endpoints.StartMarker=addlistener(m,...
            'MarkerChanged',...
            @(~,~)updateSpan(s));
            lis.Endpoints.StartMarkerActiveTraceChange=addlistener(m,...
            'MarkerChangedActiveTrace',...
            @(~,~)updateActiveTraceChange(s));

            m=findAngleMarkerByID(p,s.SpanIDs{2});
            lis.Endpoints.EndMarker=addlistener(m,...
            'MarkerChanged',...
            @(~,~)updateSpan(s));
            lis.Endpoints.EndMarkerActiveTraceChange=addlistener(m,...
            'MarkerChangedActiveTrace',...
            @(~,~)updateActiveTraceChange(s));

            s.Listeners=lis;
        end

        function deleteListenersOnEndpoints(s)

            s.Listeners.Endpoints=...
            internal.polariCommon.deleteListenerStruct(s.Listeners.Endpoints);
        end

        function updateActiveTraceChange(s)



            updateSpanFaceColor(s);
        end

        function updateGraphicalSpanVis(s)


            if s.Visible
                e=cellfun(@isempty,s.SpanIDs);
                if any(e)
                    hideSpan(s);
                else
                    showSpan(s);
                end
            else
                hideSpan(s);
            end
        end

        function showSpan(s)

            addListenersOnEndpoints(s);
            if isempty(s.hSpan)
                createWidgets(s);
            end
            s.hLocalXform.Visible='on';

            updateWidgets(s);

            if~isempty(s.hReadout)
                s.hReadout.Visible='on';
            end
        end

        function hideSpan(s)


            if~isempty(s.hLocalXform)
                s.hLocalXform.Visible='off';
            end

            deleteListenersOnEndpoints(s);

            if~isempty(s.hReadout)
                s.hReadout.Visible='off';
            end
        end

        function updateSpan(s)





            updateAngleMarkersList(s);




        end

        function angleTicksMoved(s)














            s.pEndpointsWereChanged=true;
            updateAngleMarkersList(s);
            s.pEndpointsWereChanged=false;
        end

        function alignWithPolarPlot(s)



            hgt=s.hLocalXform;
            if~isempty(hgt)

                p=s.PolariObj;

                thd=90-90-p.AngleAtTop-p.AngleDrag_Delta;
                if strcmpi(p.AngleDirection,'ccw')
                    thd=180-thd;
                end
                th=-thd*pi/180;





                ct=cos(th);
                st=sin(th);
                hgt.Matrix=[...
                -ct,st,0,0;...
                -st,-ct,0,0;...
                0,0,1,s.ZPlane;...
                0,0,0,1];
            end
        end
    end

    methods(Hidden)
        function tempChangeToSpanColorAndReadout(s,m1,m2)


            updateSpanFaceColor(s,...
            [getDataSetIndex(m1),getDataSetIndex(m2)]);

            updateReadout(s,m1,m2);
        end

        function tempChangeToSpanEndpoints(s,new_angles)






            [verts,faces]=internal.polariCommon.sectorsPatchRounded(...
            1.0,new_angles,s.ZPlane);

            set(s.hSpan,...
            'Faces',faces,...
            'Vertices',verts);
        end
    end

    methods(Access=private)
        function updateReadout(s,m1,m2)









            p=s.PolariObj;
            if nargin==3



                c1=getComplexAngle(m1);
                c2=getComplexAngle(m2);

                adiff=internal.polariCommon.cangleDiff(c1,c2)*180/pi;
            else



                if(nargin>1)&&m1





                    adiff=360;
                else

                    c1=s.SpanCplx{1};
                    c2=s.SpanCplx{2};
                    adiff=internal.polariCommon.cangleDiff(c1,c2)*180/pi;
                end
                m1=findAngleMarkerByID(p,s.SpanIDs{1});
                m2=findAngleMarkerByID(p,s.SpanIDs{2});
            end

            is_ccw=strcmpi(p.AngleDirection,'ccw');


            d1=getData(m1);
            d2=getData(m2);
            if is_ccw

                mdiff=d2.mag-d1.mag;
            else

                mdiff=d1.mag-d2.mag;
            end


            if isempty(d1.intensity)
                idiff=[];
            else
                if is_ccw

                    idiff=d2.intensity-d1.intensity;
                else

                    idiff=d1.intensity-d2.intensity;
                end
            end


            if isnan(mdiff)
                scale=1;
                mksUnit='';
            else
                [mdiff,scale,mksUnit]=engunits(mdiff,'unicode');
            end



            uStr=p.MagnitudeUnits;
            if isempty(uStr)&&scale==1
                units='';
            else

                if isempty(uStr)



                    units=sprintf('e%g',log10(1/scale));
                else

                    if any(uStr=='%')

                        units=sprintf(uStr,mksUnit);
                    else

                        units=[mksUnit,uStr];
                    end
                end
            end








            adiff=round(adiff*1e12)*1e-12;
            tmp=internal.polariCommon.sprintfMaxNumTotalDigits(adiff,s.MaxDigitsDeltaTheta);
            s1=sprintf('%c%c %s%s',s.SymbolDelta,s.SymbolTheta,tmp,s.SymbolDegree);


            tmp=internal.polariCommon.sprintfMaxNumTotalDigits(mdiff,s.MaxDigitsDeltaR);
            s2=sprintf('%cm %s%s',s.SymbolDelta,tmp,units);


            if isempty(idiff)
                s3='';
            else
                [idiff,scale,mksUnit]=engunits(idiff,'unicode');


                uStr=p.IntensityUnits;
                if isempty(uStr)&&scale==1
                    units='';
                else

                    if isempty(uStr)



                        units=sprintf('e%g',log10(1/scale));
                    else

                        if any(uStr=='%')

                            units=sprintf(uStr,mksUnit);
                        else

                            units=[mksUnit,uStr];
                        end
                    end
                end

                tmp=internal.polariCommon.sprintfMaxNumTotalDigits(idiff,s.MaxDigitsDeltaR);
                s3=sprintf('%ci %s%s',s.SymbolDelta,tmp,units);
            end

            if s.CursorIDsInReadout


                t=modifyIDsForContextMenuDisplay(s,{m1.ID,m2.ID});









                if is_ccw

                    s0=sprintf('%s - %s',t{2},t{1});
                else

                    s0=sprintf('%s - %s',t{1},t{2});
                end

                if isempty(s3)
                    txt={s0,s1,s2};
                else
                    txt={s0,s1,s2,s3};
                end
            else
                if isempty(s3)
                    txt={s1,s2};
                else
                    txt={s1,s2,s3};
                end
            end


            s.hReadout.Text=txt;
        end

        function updateWidgets(s)






            c=[s.SpanCplx{:}];
            if numel(c)<2

                s.hSpan.Visible='off';
                s.hReadout.Visible='off';
            else


                if strcmpi(s.hSpan.Visible,'off')


                    s.pLastSpanCCW=0;
                end

                if s.pEndpointsWereChanged




                    isFullCircle=false;
                    updateLastSpanCCW(s,c);

                    if~s.PreserveReflexAngle&&(s.pLastSpanCCW>pi)

                        c1=c(1);
                        c2=c(2);
                        c=[c2,c1];
                        s.SpanCplx={c2,c1};
                        s.SpanIDs=s.SpanIDs([2,1]);
                        updateLastSpanCCW(s,c);
                    end
                else




                    [c,isFullCircle]=applyAdaptiveReordering(s,c);
                end

                ang_c=angle(c);

                p=s.PolariObj;
                if ang_c(1)==ang_c(2)&&~isempty(p.hAntenna)
                    if((p.hCursorAngleMarkers(1).DataIndex==1&&...
                        p.hCursorAngleMarkers(2).DataIndex==numel(p.AngleData))||...
                        (p.hCursorAngleMarkers(1).DataIndex==numel(p.AngleData)&&...
                        p.hCursorAngleMarkers(2).DataIndex==1))
                        [~,isFullCircle]=internal.polariCommon.findAngleSpan(...
                        p.AngleData*pi/180);
                    end
                end

                if isFullCircle

                    ang_c(2)=ang_c(1)+2*pi;
                end



                [verts,faces]=internal.polariCommon.sectorsPatchRounded(...
                1.0,ang_c,s.ZPlane);

                set(s.hSpan,...
                'Faces',faces,...
                'Vertices',verts,...
                'Visible','on');

                updateSpanFaceColor(s);


                if s.Visible
                    updateReadout(s,isFullCircle);
                end
            end
        end

        function updateLastSpanCCW(s,c)

            s.pLastSpanCCW=internal.polariCommon.cangleDiff(c(1),c(2));
        end

        function[c,isFullCircle]=applyAdaptiveReordering(s,c)











            c1=c(1);
            c2=c(2);
            thisSpanCCW=internal.polariCommon.cangleDiff(c1,c2);

            if s.ResetAfter360Span


                swap=(thisSpanCCW>pi)...
                &&~s.PreserveReflexAngle...
                &&(s.pLastSpanCCW<=pi/2);
            else


                swap=false;
                if~s.PreserveReflexAngle
                    if(thisSpanCCW<=pi/2)&&(s.pLastSpanCCW>=3/2*pi);

                        swap=true;
                        thisSpanCCW=2*pi-thisSpanCCW;

                    elseif(thisSpanCCW>pi)&&(s.pLastSpanCCW<=pi/2)

                        swap=true;
                        thisSpanCCW=0;
                    end
                end
            end

            if swap



                c=[c2,c1];
                s.SpanCplx={c2,c1};
                s.SpanIDs=s.SpanIDs([2,1]);
            end
            s.pLastSpanCCW=thisSpanCCW;
            isFullCircle=thisSpanCCW==2*pi;
        end

        function ds_idx=getDatasetIndexForMarkers(s)






            p=s.PolariObj;

            id1=s.SpanIDs{1};
            if~isempty(id1)
                idx1=getDataSetIndex(findAngleMarkerByID(p,id1));
            else
                idx1=0;
            end

            id2=s.SpanIDs{2};
            if~isempty(id2)
                idx2=getDataSetIndex(findAngleMarkerByID(p,id2));
            else
                idx2=0;
            end

            ds_idx=[idx1,idx2];
        end

        function updateSpanFaceColor(s,ds_idx)


            if nargin<2
                ds_idx=getDatasetIndexForMarkers(s);
            end





            p=s.PolariObj;
            if any(ds_idx==0)||ds_idx(1)~=ds_idx(2)




                faceC=internal.ColorConversion.brighten(...
                p.GridForegroundColor,0.4);

            else








                c=getDatasetColor(s.PolariObj,ds_idx(1));
                faceC=internal.ColorConversion.glowColor(c,0.6);
            end
            span=s.hSpan;
            assert(~isempty(span));

            if s.Fill&&~isIntensityData(p)
                span.FaceColor=faceC;
            else

                span.FaceColor='none';

                span.EdgeColor='k';
            end









            s.hReadout.NormalBackgroundColor=...
            internal.ColorConversion.brighten(faceC,1-s.SpanAlpha);



        end

        function deleteWidgets(s)

            delete(s.hLocalXform);
            s.hLocalXform=[];
            s.hSpan=[];
        end

        function createWidgets(s)
            p=s.PolariObj;

            tagStr=sprintf('%s%d',mfilename,p.pAxesIndex);
            xfrm=hgtransform(...
            'Parent',p.hAxes,...
            'Tag',tagStr);
            s.hLocalXform=xfrm;


            b=hggetbehavior(xfrm,'DataCursor');
            b.Enable=false;
            b=hggetbehavior(xfrm,'Plotedit');
            b.Enable=false;


            figParent=ancestor(p.hAxes,'figure');

            hc=uicontextmenu(...
            'Parent',figParent,...
            'Callback',@(h,ev)updateSpanContextMenu(s,h),...
            'HandleVisibility','off');

            faceC='none';
            edgeC='none';




            ht=patch(...
            'Parent',xfrm,...
            'Tag',tagStr,...
            'XData',[],...
            'YData',[],...
            'ZData',[],...
            'FaceColor',faceC,...
            'FaceAlpha',s.SpanAlpha,...
            'EdgeColor',edgeC,...
            'Marker','none',...
            'LineStyle','-',...
            'LineWidth',1.5,...
            'Visible','on');
            s.hSpan=ht;
            set(ht,'uicontextmenu',hc);
        end
    end
end
