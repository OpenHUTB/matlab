function old=printingAxesTickLabelUpdate(h,input,old)

















    allCartesian=findall(h,'Type','axes');
    allAxesRulers=matlab.graphics.internal.printUtility.getAxesAllRulers(allCartesian,{'XAxis','YAxis','ZAxis'});


    if strcmp(input.LockAxes,'on')
        old=LocalManualAxesMode(old,allCartesian,'LimMode',allAxesRulers,'LimitsMode');


        if strcmp(input.LockAxesTicks,'on')
            old=LocalManualAxesMode(old,allCartesian,'TickMode',allAxesRulers,'TickValuesMode');
            old=LocalManualAxesMode(old,allCartesian,'TickLabelMode',allAxesRulers,'TickLabelsMode');
        end
    end
end



function old=LocalManualAxesMode(old,allAxes,base,allRulers,rulerProp)






    printUtility=matlab.graphics.internal.printUtility;

    xs=['X',base];
    ys=['Y',base];
    zs=['Z',base];


    oldXMode=printUtility.getValuesAsCell(allAxes,xs);
    oldYMode=printUtility.getValuesAsCell(allAxes,ys);
    oldZMode=printUtility.getValuesAsCell(allAxes,zs);
    oldRulerMode=printUtility.getValuesAsCell(allRulers,rulerProp);


    old=printUtility.pushOldData(old,allRulers,{rulerProp},oldRulerMode);
    old=printUtility.pushOldData(old,allAxes,{xs},oldXMode);
    old=printUtility.pushOldData(old,allAxes,{ys},oldYMode);
    old=printUtility.pushOldData(old,allAxes,{zs},oldZMode);


    printUtility.setValues(allAxes,xs,'manual');
    printUtility.setValues(allAxes,ys,'manual');
    printUtility.setValues(allAxes,zs,'manual');
    printUtility.setValues(allRulers,rulerProp,'manual');
end