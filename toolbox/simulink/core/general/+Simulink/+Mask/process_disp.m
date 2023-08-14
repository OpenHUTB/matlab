function svgString=process_disp(obj,params)




    if(length(params)>1&&strcmpi(params{2},'texmode'))


        if(strcmpi(obj.Units,'normalized'))
            svgString=Simulink.Mask.processTextIndividual(obj,'disp',{0.5,0.5,params{1},'texmode','on'});



        else
            svgString=Simulink.Mask.processTextIndividual(obj,'disp',{obj.Width/2,obj.Height/2,params{1},'texmode','on'});
        end
        return;
    end


    if(strcmpi(obj.Units,'normalized'))
        svgString=Simulink.Mask.processTextIndividual(obj,'disp',{0.5,0.5,params{1},'horizontalAlignment','center','verticalAlignment','middle'});



    else
        svgString=Simulink.Mask.processTextIndividual(obj,'disp',{obj.Width/2,obj.Height/2,params{1},'horizontalAlignment','center','verticalAlignment','middle'});
    end
end