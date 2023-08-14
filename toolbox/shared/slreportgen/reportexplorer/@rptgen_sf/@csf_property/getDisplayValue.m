function[dValue,dName]=getDisplayValue(h,dName)





    adSF=rptgen_sf.appdata_sf;
    currObj=adSF.CurrentObject;
    if isempty(currObj)|~ishandle(currObj)
        error(message('RptgenSL:rsf_csf_property:noSFObjectLabel'));
    end

    [dValue,dName]=getPropValue(rptgen_sf.propsrc_sf,...
    currObj,...
    dName);
    dValue=dValue{1};