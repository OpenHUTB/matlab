function addAnnotation(sysH,side)
    if side==0
        msg=message('Simulink:Harness:InputconversionSSAnnotationText');
    else
        msg=message('Simulink:Harness:OutputconversionSSAnnotationText');
    end
    text=sprintf('%s/%s/%s',get_param(sysH,'Parent'),get_param(sysH,'Name'),msg.getString());
    ann=Simulink.Annotation(text);
    ann.Position=[350,20,650,28];
    ann.FontName='Courier';
    ann.FontSize=8;
    ann.FontWeight='normal';
    ann.FontAngle='normal';
end


