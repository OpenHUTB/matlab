function svgString=process_fprintf(obj,params)



    svgString='';
    if~(length(params)~=1||length(params)~=2)
        return;
    end



    if(length(params)==1)
        Output=sprintf('%s',params{:});
    else
        Output=sprintf(params{:});
    end



    if(strcmpi(obj.Units,'normalized'))
        svgString=Simulink.Mask.processTextIndividual(obj,'fprintf',{0.5,0.5,Output,'horizontalAlignment','center','verticalAlignment','middle'});


    else
        svgString=Simulink.Mask.processTextIndividual(obj,'fprintf',{obj.Width/2,obj.Height/2,Output,'horizontalAlignment','center','verticalAlignment','middle'});
    end
end