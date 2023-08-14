function objs=getAllQuantityObjects(modelObj)













    validateattributes(modelObj,{'SimBiology.Model'},{'scalar'},mfilename,'modelObj');




    objs=[modelObj.Compartments;modelObj.Species;findobj(modelObj,'Type','parameter')];
end
