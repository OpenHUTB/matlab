function isTopModel=isComponentTopModel(obj,comp)







    comp=get_param(comp,'handle');
    topModel=get_param(obj.topModel,'handle');
    isTopModel=comp==topModel;
end

