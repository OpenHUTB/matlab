function displayNonScalarObject(obj)








    disp(getHeader(obj));


    groups=getPropertyGroups(obj);




    thisNumValues=obj.NumValues;
    obj.NumValues=1;


    matlab.mixin.CustomDisplay.displayPropertyGroups(obj,groups);


    obj.NumValues=thisNumValues;

end