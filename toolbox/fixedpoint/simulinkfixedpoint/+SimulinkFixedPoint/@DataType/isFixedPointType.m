function res=isFixedPointType(dt)








    strTemp='Fixed-point: ';

    res=~isstruct(dt)&&strncmp(dt.DataTypeMode,strTemp,length(strTemp));
