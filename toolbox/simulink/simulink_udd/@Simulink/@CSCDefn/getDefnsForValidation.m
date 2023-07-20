function[tmpCSCDefn,tmpMSDefn]=getDefnsForValidation(currDefn,hUI)






    tmpCSCDefn=currDefn;


    tmpMSDefn=LocalGetMSDefn(hUI,currDefn);







    function msDefn=LocalGetMSDefn(hUI,cscDefn)

        msDefn=[];

        if isempty(cscDefn)
            return;
        end

        for i=1:length(hUI.AllDefns{2})
            tmpDefn=hUI.AllDefns{2}(i);
            if strcmp(tmpDefn.Name,cscDefn.MemorySection)
                msDefn=tmpDefn;
                break;
            end
        end




