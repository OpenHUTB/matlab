function svgString=process_plot(obj,params)



    svgString='';
    if(numel(params)==0)
        return;
    end




    if(numel(params)>=4&&all(cellfun(@(x)isnumeric(x)&&(numel(x)==1),{params{1:4}})))

        svgString=Simulink.Mask.process_plot(obj,{params{5:numel(params)}});
        return;
    end




    if(numel(params)==1)
        y=params{1};
        x=1:numel(y);

        if(isempty(obj.MinX)||isnan(obj.MinX))
            obj.MinX=1;
            obj.MaxX=numel(y);
            obj.MinY=min(y);
            obj.MaxY=max(y);
        end

        svgString=Simulink.Mask.processPlotIndividual(obj,{x,y},[obj.MinX,obj.MaxX,obj.MinY,obj.MaxY]);
        return;
    end



    for i=1:2:length(params)
        svgString=[svgString,Simulink.Mask.processPlotIndividual(obj,{params{i},params{i+1}},[obj.MinX,obj.MaxX,obj.MinY,obj.MaxY]),sprintf('\n')];
    end

    svgString=strjoin(string(svgString),'');
end