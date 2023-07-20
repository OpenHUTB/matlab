function[pass,err]=fcncallarg_postapply_cb(dlg,fca)



    unAppliedArg=Simulink.FunctionArgument;
    unAppliedArg.Name=dlg.getWidgetValue('name_tag');
    unAppliedArg.Dimensions=char(dlg.getWidgetValue('dim_tag'));

    cplxVal=dlg.getWidgetValue('complex_tag');
    if cplxVal==0
        cplxVal='auto';
    elseif cplxVal==1
        cplxVal='real';
    else
        cplxVal='complex';
    end

    minVal=char(dlg.getWidgetValue('minimum_tag'));
    if(strcmp(minVal,'[ ]')||strcmp(minVal,'[]')||isnan(str2double(minVal)))
        minVal=[];
    else
        minVal=str2double(minVal);
    end
    maxVal=char(dlg.getWidgetValue('maximum_tag'));
    if(strcmp(maxVal,'[ ]')||strcmp(maxVal,'[]')||isnan(str2double(maxVal)))
        maxVal=[];
    else
        maxVal=str2double(maxVal);
    end

    unAppliedArg.Complexity=cplxVal;
    unAppliedArg.Min=minVal;
    unAppliedArg.Max=maxVal;
    unAppliedArg.DataType=dlg.getWidgetValue('datatypetag');
    unAppliedArg.UUID=fca.getUUID;



    list=evalin('base','who');
    currID=fca.getUUID();
    for cnt=1:length(list)
        varName=list{cnt};
        className=evalin('base',['class(',varName,')']);

        if strcmp(className,'Simulink.FunctionArgument')
            varID=evalin('base',[varName,'.getUUID()']);
            if isequal(varID,currID)
                assignin('base',varName,unAppliedArg);
                break;
            end
        end
    end

    pass=true;
    err=[];