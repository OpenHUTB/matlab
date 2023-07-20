function juliandate=aeroblkcalcJulianDate(month,day,year)






%#codegen

    coder.allowpcode('plain');
    coder.license('checkout','Aerospace_Toolbox');
    coder.license('checkout','Aerospace_Blockset');

    if month<=2
        year=year-1;
        month=month+12;
    end

    temp1=floor(year/100);
    temp2=2-temp1+floor(temp1/4);

    juliandate=floor(365.25*(year+4716.0))+...
    floor(30.6001*(month+1.0))+temp2+day-1524.0;
end
