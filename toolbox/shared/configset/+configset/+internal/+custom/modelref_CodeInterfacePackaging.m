function result=modelref_CodeInterfacePackaging(csTop,csChild,varargin)














    topCodeInterfacePackaging=csTop.get_param('CodeInterfacePackaging');
    childCodeInterfacePackaging=csChild.get_param('CodeInterfacePackaging');
    result=~isequal(topCodeInterfacePackaging,childCodeInterfacePackaging);



    if result
        isTopCPPClassGenMode=strcmpi(csTop.get_param('IsCPPClassGenMode'),'on');
        isChildCPPClassGenMode=strcmpi(csChild.get_param('IsCPPClassGenMode'),'on');

        if isTopCPPClassGenMode&&~isChildCPPClassGenMode
            result=false;
        end
    end
end
