function autoUpdateCallback(hAxes,e)






    hObj=hAxes.Legend;
    if isempty(hObj)||~isvalid(hObj)
        return
    end


    if strcmp(hObj.version,'on')
        return
    end

    if strcmp(hObj.AutoUpdate,'off')



        ch=hObj.PlotChildren_I(isvalid(hObj.PlotChildren_I));




        if~isempty(e.LegendableObjects)
            chToExclude=setdiff(e.LegendableObjects',hObj.PlotChildren_I,'stable');
            hObj.PlotChildrenExcluded_I=unique([hObj.PlotChildrenExcluded;chToExclude],'stable');




            loc=ismember(hObj.PlotChildrenExcluded_I,hObj.PlotChildrenSpecified_I);
            hObj.PlotChildrenExcluded_I(loc)=[];
        end

    else


        ch=e.LegendableObjects';


        ch=removeNestedObjects(hObj,ch);


        ch=processGroups(ch);


        ch=setdiff(ch,getPlotChildrenExcluded(hObj),'stable');



        spec_ch=getPlotChildrenSpecified(hObj);
        disc_ch=setdiff(ch,spec_ch,'stable');
        qual_disc_ch=disc_ch(matlab.graphics.illustration.internal.islegendable(disc_ch));


        valid_spec_ch=spec_ch(isvalid(spec_ch));


        ch=[valid_spec_ch;qual_disc_ch];




        if isempty(ch)
            ch=[];
        else

            if hObj.LimitMaxLegendEntries
                if~hObj.HasWarnedAboutMaxEntryCapping&&numel(ch)>50
                    warning(message('MATLAB:legend:CappingMaxEntries'));
                    hObj.HasWarnedAboutMaxEntryCapping=true;
                end
                ch=ch(1:min(end,50));
            end
        end

    end







    if~isequal(hObj.PlotChildren_I,ch)&&(~isempty(hObj.PlotChildren_I)||~isempty(ch))
        hObj.PlotChildren=ch;
        hObj.PlotChildrenMode='auto';
        notify(hObj,'UpdateLayout')
    end


    function ch=removeNestedObjects(hObj,ch)



        ax=hObj.Axes;

        par=get(ch,'Parent');
        if iscell(par)
            par=[par{:}]';
        end
        ch=ch(par==ax);


        function ch=processGroups(ch)


            ch=flipud(ch);
            ch=matlab.graphics.illustration.internal.expandLegendChildren(ch);
            ch=flipud(ch);
