function old=printingFontUpdate(allFont,input,old)
















    printUtility=matlab.graphics.internal.printUtility;


    if~isempty(input.FontMode)&&~strcmp(input.FontMode,'none')
        oldfontsize=printUtility.getValuesAsCell(allFont,'FontSize');
        oldfontsizemode=printUtility.getValuesAsCell(allFont,'FontSizeMode');
        oldfontunits=printUtility.getValuesAsCell(allFont,'FontUnits');
        oldfontunitsmode=printUtility.getValuesAsCell(allFont,'FontUnitsMode');



        printUtility.setValues(allFont,'FontUnits','points');
        oldfontsizePoints=printUtility.getValuesAsCell(allFont,'FontSize');

        switch(input.FontMode)
        case 'fixed'
            printUtility.setValues(allFont,'FontSize',input.FixedFontSize);
        case 'scaled'


            if isfield(input,'ApplyFontSizeMinToScale')&&~input.ApplyFontSizeMinToScale


                fontsize=cell2mat(oldfontsizePoints);
                fontsize=fontsize*input.ScaledFontSize/100.0;
                set(allFont,{'FontSize'},num2cell(fontsize));

            else
                if strcmp(input.ScaledFontSize,'auto')
                    scale=input.sizescale;
                else
                    scale=input.ScaledFontSize/100;
                end


                newfonts=matlab.graphics.internal.printUtility.scaleValues(oldfontsizePoints,scale,input.FontSizeMin);
                printUtility.setValues(allFont,'FontSize',newfonts);
            end
        otherwise
            error(message('MATLAB:hgexport:InvalidFontModeParam'));
        end




        old=printUtility.pushOldData(old,allFont,'FontSizeMode',oldfontsizemode);
        old=printUtility.pushOldData(old,allFont,'FontSize',oldfontsize);
        old=printUtility.pushOldData(old,allFont,'FontUnitsMode',oldfontunitsmode);
        old=printUtility.pushOldData(old,allFont,'FontUnits',oldfontunits);
    end


    if~isempty(input.FontName)&&~strcmp(input.FontName,'auto')
        oldnamesmode=printUtility.getValuesAsCell(allFont,'FontNameMode');
        oldnames=printUtility.getValuesAsCell(allFont,'FontName');
        printUtility.setValues(allFont,'FontName',input.FontName);
        old=printUtility.pushOldData(old,allFont,{'FontNameMode'},oldnamesmode);
        old=printUtility.pushOldData(old,allFont,{'FontName'},oldnames);
    end


    if~isempty(input.FontWeight)&&~strcmp(input.FontWeight,'auto')
        oldweightsmode=printUtility.getValuesAsCell(allFont,'FontWeightMode');
        oldweights=printUtility.getValuesAsCell(allFont,'FontWeight');
        printUtility.setValues(allFont,'FontWeight',input.FontWeight);
        old=printUtility.pushOldData(old,allFont,{'FontWeightMode'},oldweightsmode);
        old=printUtility.pushOldData(old,allFont,{'FontWeight'},oldweights);
    end


    if~isempty(input.FontAngle)&&~strcmp(input.FontAngle,'auto')
        oldanglesmode=printUtility.getValuesAsCell(allFont,'FontAngleMode');
        oldangles=printUtility.getValuesAsCell(allFont,'FontAngle');
        printUtility.setValues(allFont,'FontAngle',input.FontAngle);
        old=printUtility.pushOldData(old,allFont,{'FontAngleMode'},oldanglesmode);
        old=printUtility.pushOldData(old,allFont,{'FontAngle'},oldangles);
    end
end