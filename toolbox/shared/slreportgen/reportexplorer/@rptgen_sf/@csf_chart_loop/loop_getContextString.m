function cs=loop_getContextString(c)






    if strcmp(c.LoopType,'auto')

        switch lower(getContextType(rptgen_sf.appdata_sf,c,false))
        case 'machine'
            cs=getString(message('RptgenSL:rsf_csf_chart_loop:allChartsLabel'));
        case{'chart','state','object'}
            cs=getString(message('RptgenSL:rsf_csf_chart_loop:currentChartLabel'));
        otherwise
            cs=findContextBlocksDesc(rptgen_sl.appdata_sl,...
            c,'chart');
        end
    elseif isempty(c.ObjectList)
        cs=getString(message('RptgenSL:rsf_csf_chart_loop:noSelectedChartsLabel'));
    else
        cs=rptgen.toString(c.ObjectList,16,' ');
    end
