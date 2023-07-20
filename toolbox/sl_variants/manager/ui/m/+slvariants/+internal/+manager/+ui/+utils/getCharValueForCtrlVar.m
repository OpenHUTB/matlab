function outVal=getCharValueForCtrlVar(inVal,isSLVarCtrl,isSimParam,isAUTOSARParam)






    if isSLVarCtrl
        inVal=inVal.Value;
    end
    if isSimParam||isAUTOSARParam
        inVal=inVal.Value;
    end
    if isa(inVal,'double')
        outVal=num2str(inVal);
    elseif isa(inVal,'Simulink.data.Expression')
        outVal=strcat('=',inVal.ExpressionString);
    elseif isenum(inVal)
        outVal=[class(inVal),'.',char(inVal)];
    elseif isnumeric(inVal)
        outVal=[class(inVal),'(',num2str(inVal),')'];
    elseif islogical(inVal)
        outVal=char(string(inVal));
    end
end


