classdef polariMBGeneral<internal.polariMouseBehavior

    methods
        function obj=polariMBGeneral
            obj@internal.polariMouseBehavior(...
            @showToolTipAndPtr_default,...
            @internal.polariMBGeneral.wbmotion,...
            @internal.polariMBGeneral.wbdown,...
            [],...
            @internal.polariMBMagTicks.wbscroll);
        end
    end

    methods(Static)
        function wbmotion(p,ev)








            executeDelayedParamChanges(p);

            s=computeHoverLocation(p,ev);
            autoChangeMouseBehavior(p,s);









            if~p.pShownInteractiveBehaviorBanner
                ena=getappdata(0,'polarpatternSuppressInitBanner');
                if isempty(ena)||ena
                    p.pShownInteractiveBehaviorBanner=true;
                    if isDataClean(p)
                        showBannerMessage(p,'The data contains NaN or -Inf. Right click to clean data and interact with the plot');
                    else
                        showBannerMessage(p,'Right click to interact with the plot');
                        hc=p.UIContextMenu_Master;
                        h2=hc.findobj('Label','Clean Data','-depth',1);
                        h2.Visible=internal.LogicalToOnOff(0);
                    end
                end
            end
        end

        function wbdown(p,ev)







            p.hFigure.CurrentPoint=ev.Point;
            st=p.hFigure.SelectionType;
            if strcmpi(st,'open')


                s=computeHoverLocation(p,ev);



                thisFig=ev.Source;
                thisAxes=thisFig.CurrentAxes;




                if p.pAxesIndex==getappdata(thisAxes,'PolariAxesIndex')
                    if s.overGrid


                        m_addCursor(p);
                        return
                    end

                    if~s.any









                        pt=p.hAxes.CurrentPoint(1,1:2);
                        if norm(pt)>1



                            ang=atan2d(pt(2),pt(1));
                            if isempty(p.TitleTop)...
                                &&ang>=55&&ang<=145
                                p.TitleTop=p.NewTitleString;
                                changeMouseBehavior(p,'titletop');
                            elseif isempty(p.TitleBottom)...
                                &&ang<=-55&&ang>=-145
                                p.TitleBottom=p.NewTitleString;
                                changeMouseBehavior(p,'titlebottom');
                            end
                        end
                    end
                end
            end
        end
    end
end
