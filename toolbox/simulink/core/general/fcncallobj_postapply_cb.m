function[pass,err]=fcncallobj_postapply_cb(dlg,fco)


    if~strcmp(class(dlg),'DAStudio.Dialog')
        return;
    end

    currCache=slInternal('FcnCallEditorCache',dlg);

    if strcmp(currCache.ArgType,'input')
        fco.Arguments(currCache.ArgIdx)=currCache.Arg;
    end

    inSelIdx=dlg.getWidgetValue('obj_in_arg_sel_tag');
    outSelIdx=dlg.getWidgetValue('obj_out_arg_sel_tag');

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
    if(strcmp(minVal,'[ ]')||strcmp(minVal,'[]')||isnan(minVal))
        minVal=[];
    end
    maxVal=char(dlg.getWidgetValue('maximum_tag'));
    if(strcmp(maxVal,'[ ]')||strcmp(maxVal,'[]')||isnan(maxVal))
        maxVal=[];
    end

    unAppliedArg.Complexity=cplxVal;
    unAppliedArg.Min=minVal;
    unAppliedArg.Max=maxVal;
    unAppliedArg.DataType=dlg.getWidgetValue('datatypetag');
    unAppliedArg.UUID=fco.getUUID;

    if(isempty(inSelIdx)&&isempty(outSelIdx))


        inSelIdx=0;
    end

    if~isempty(inSelIdx)
        fco.Arguments(inSelIdx+1)=unAppliedArg;
        currCache.ArgType='input';
        currCache.ArgIdx=inSelIdx+1;
    end


    currCache.Arg=unAppliedArg;
    slInternal('FcnCallEditorCache',currCache);



    list=evalin('base','who');
    currID=fco.getUUID();
    for cnt=1:length(list)
        varName=list{cnt};
        className=evalin('base',['class(',varName,')']);

        if strcmp(className,'Simulink.FunctionSignature')
            varID=evalin('base',[varName,'.getUUID()']);
            if isequal(varID,currID)
                assignin('base',varName,fco);
                dlg.setSource(fco);
                break;
            end
        end
    end

    pass=true;
    err=[];