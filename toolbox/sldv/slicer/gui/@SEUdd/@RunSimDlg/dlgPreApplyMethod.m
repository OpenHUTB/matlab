function[status,msg]=dlgPreApplyMethod(this,dlg)





    msg='';
    sc=this.Model;

    if~slavteng('feature','EnhancedCoverageSlicer')
        StartTimeStr=dlg.getWidgetValue('SimStartTime');
        [SimStartTime,statusSart]=modelslicerprivate('evalinModel',sc.modelSlicer.model,StartTimeStr);
    else
        statusSart=1;
        SimStartTime=0;
    end

    StopTimeStr=dlg.getWidgetValue('SimStopTime');
    [SimStopTime,statusStop]=modelslicerprivate('evalinModel',sc.modelSlicer.model,StopTimeStr);


    if statusSart&&statusStop...
        &&isfinite(SimStopTime)&&isfinite(SimStartTime)...
        &&SimStartTime<SimStopTime&&SimStartTime>=0

        status=true;
    else
        status=false;
    end
    if status
        this.SimStartTime=SimStartTime;
        this.SimStopTime=SimStopTime;
    else
        msg=getString(message('Sldv:ModelSlicer:gui:InvalidTimeWindow'));
    end
    this.SaveFilePath=dlg.getWidgetValue('CvSaveFileName');
end
