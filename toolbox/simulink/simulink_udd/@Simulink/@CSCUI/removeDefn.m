function removeDefn(hUI)




    whichDefns=hUI.mainActiveTab+1;
    currIndex=hUI.Index(whichDefns);
    currDefn=hUI.AllDefns{whichDefns}(currIndex+1);





    oldLen=length(hUI.AllDefns{whichDefns});
    if oldLen<=1
        msg=DAStudio.message('Simulink:dialog:CSCUIRemoveDefnAtleastOneItem');
        errordlg(msg,...
        DAStudio.message('Simulink:dialog:CSCDesignerTitle'),'non-modal');
        return;
    end






    found=find(hUI.AllDefns{whichDefns},'Name',currDefn.Name);
    isUniq=length(found)<2;

    if isUniq&&whichDefns==2


        found=[];
        if~isempty(hUI.AllDefns{1})
            found=find(hUI.AllDefns{1},'MemorySection',currDefn.Name);
        end
        inUse=length(found)>0;

        if inUse
            msg=DAStudio.message('Simulink:dialog:CSCUIRemoveDefnEntryInUse');
            errordlg(msg,...
            DAStudio.message('Simulink:dialog:CSCDesignerTitle'),'non-modal');
            return;
        end
    end

    tmpDefns=[];
    for i=1:oldLen
        if i~=currIndex+1
            tmpDefns=[tmpDefns;hUI.AllDefns{whichDefns}(i)];
        end
    end

    hUI.AllDefns{whichDefns}=tmpDefns;

    newLen=length(hUI.AllDefns{whichDefns});
    if(currIndex>0)&&(currIndex>newLen-1)
        hUI.setIndex(currIndex-1);
    end


    hUI.IsDirty=true;



