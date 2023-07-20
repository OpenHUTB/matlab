function plist=getClientPropertyList






    persistent plist_stored

    if isempty(plist_stored)

        clist=getClientClassList;

        for aClass=clist

            try
                eval(['aPropList=',aClass{1},'.getCCPropertyList;']);
                plist_stored=[plist_stored,aPropList];
            catch

            end;

        end

    end

    plist=plist_stored;


