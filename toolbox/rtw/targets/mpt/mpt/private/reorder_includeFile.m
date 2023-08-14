function objNameNew=reorder_includeFile(objName)













    userTypes=rtwprivate('rtwattic','AtticData','userTypes');

    userTypeDepend='';
    objNameNew=objName;

    for i=1:length(userTypes)
        userTypeDepend{i}=userTypes{i}.userTypeDepend;
    end
    userTypeDepend=unique(userTypeDepend);
    for j=length(userTypeDepend):-1:1
        Ifirst=1;
        for i=1:length(objName)
            if isequal(objName{i},userTypeDepend{j})
                Ifirst=i;
                break;
            end
        end
        if Ifirst>1
            objNameNew{1}=objName{Ifirst};
            for i=1:Ifirst-1
                objNameNew{i+1}=objName{i};
            end
            for i=Ifirst+1:length(objName)
                objNameNew{i}=objName{i};
            end
        end
    end
