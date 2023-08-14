function out=PurelyIntegerCodeValues(cs,~,direction,widgetVals)


    if direction==0
        val=cs.get_param('PurelyIntegerCode');

        if strcmpi(val,'on')
            val='off';
        else
            val='on';
        end
        out={val,message('RTW:configSet:ERTDialogSupportName').getString};
    elseif direction==1
        out=~widgetVals{1};
    end