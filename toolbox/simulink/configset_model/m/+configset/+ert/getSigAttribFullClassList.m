function retList=getSigAttribFullClassList(currClass,addCustomizeListMenuItem)






    defaultClassList=Simulink.data.findValidClasses('Signal');
    if(size(defaultClassList,2)>1)
        defaultClassList=defaultClassList';
    end


    if~ismember(currClass,defaultClassList)
        defaultClassList=[currClass;defaultClassList];
    end


    if addCustomizeListMenuItem==1
        defaultClassList{end+1}=DAStudio.message('modelexplorer:DAS:ME_SIMULINK_OBJECT_LIST_CUSTOMIZE_MENU_ITEM');
    end

    retList=defaultClassList;

end