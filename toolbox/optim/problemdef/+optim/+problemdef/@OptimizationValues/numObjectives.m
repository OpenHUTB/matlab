function nObj=numObjectives(val)






    nObj=sum(structfun(@prod,val.ObjectiveSize));

end