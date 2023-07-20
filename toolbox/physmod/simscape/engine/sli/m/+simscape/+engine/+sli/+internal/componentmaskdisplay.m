function maskDisplay=componentmaskdisplay(id)





    persistent componentDisplay
    persistent unresolvedDisplay
    persistent unspecifiedDisplay

    switch id
    case 'SimscapeComponentName'
        if isempty(componentDisplay)
            componentDisplay=sprintf(getBaseString(),'',...
            message('physmod:simscape:engine:sli:block:SimscapeComponentName').getString());
        end
        maskDisplay=componentDisplay;
    case 'UnspecifiedComponentName'
        if isempty(unspecifiedDisplay)
            unspecifiedDisplay=sprintf(getBaseString(),'color(''red'');',...
            message('physmod:simscape:engine:sli:block:UnspecifiedComponentName').getString());
        end
        maskDisplay=unspecifiedDisplay;
    case 'UnresolvedComponentName'
        if isempty(unresolvedDisplay)
            unresolvedDisplay=sprintf(getBaseString(),'color(''red'');',...
            message('physmod:simscape:engine:sli:block:UnresolvedComponentName').getString());
        end
        maskDisplay=unresolvedDisplay;
    end

    function baseString=getBaseString()
        baseString='%splot([0 1 1 0 0],[0 0 1 1 0]);plot([0.7,1],[1,0.7]);plot(-2,-1.75);plot(3, 1);disp(''\\n.ssc\\n%s'')';
    end

end