function out=transformR2022a2PReceiverAccumulator(in)




    out=in;


    volume=stripComments(getValue(out,'volume'));
    volume_unit=getUnit(out,'volume');
    surface_area=stripComments(getValue(out,'surface_area'));
    surface_area_unit=getUnit(out,'surface_area');

    if~isempty(volume)&&~isempty(surface_area)

        if isempty(volume_unit)
            volume_unit='m^3';
        end
        if isempty(surface_area_unit)
            surface_area_unit='m^2';
        end


        surface_area_conf=getRTConfig(out,'surface_area');




        expr1=['(',volume,')^2'];
        expr2=['(',surface_area,')^2'];


        eval1=protectedNumericConversion(expr1);
        eval2=protectedNumericConversion(expr2);


        if~isempty(eval1)&&isfinite(eval1)&&~isempty(eval2)&&isfinite(eval2)
            tank_area=num2str(4*pi*double(eval1)/double(eval2),16);
        elseif~isempty(eval1)&&isfinite(eval1)
            tank_area=[num2str(4*pi*double(eval1),16),'/',expr2];
        elseif~isempty(eval2)&&isfinite(eval2)
            tank_area=[expr1,'/',num2str(double(eval2)/4/pi,16)];
        else
            tank_area=['4*pi*',expr1,'/',expr2];
        end


        tank_area_unit=['(',volume_unit,')^2 / (',surface_area_unit,')^2'];


        out=setValue(out,'tank_area',tank_area);
        out=setUnit(out,'tank_area',tank_area_unit);
        out=setRTConfig(out,'tank_area',surface_area_conf);
    end

end