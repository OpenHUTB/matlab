function tf=isLinkToOwnEML(destDomain,doc,srcPath)









    [~,srcName]=fileparts(srcPath);

    if iscell(destDomain)
        tf=false(size(destDomain));
        for i=1:length(tf)
            tf(i)=isOneLinkToOwnEML(destDomain{i},doc{i},srcName);
        end
    else
        tf=isOneLinkToOwnEML(destDomain,doc,srcName);
    end
end

function yesno=isOneLinkToOwnEML(destDomain,doc,srcName)
    if any(strcmp(destDomain,{'linktype_rmi_matlab','linktype_rmi_simulink'}))
        if rmisl.isHarnessIdString(doc)
            yesno=false;





        else
            docPrefix=strtok(doc,':');
            yesno=strcmp(docPrefix,srcName);
        end
    else
        yesno=false;
    end
end
