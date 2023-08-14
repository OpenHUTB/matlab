classdef BlockProperties








    properties

        Name='';
        Position=[10,10,60,60];
        Orientation='right';
        DropShadow='off';
        FontName='auto';
        FontSize=-1;
        Tag='';
        Mask='on';
        MaskSelfModifiable='on';
        MaskIconRotate='none';
        MaskType='';
        MaskInitialization='';
        MaskHelp='';
        MaskIconUnits='pixels';
        MaskDescription='';
        MaskDisplay='';
        MaskRunInitForIconRedraw='on';
        MaskIconFrame='on';
        MaskIconOpaque='off';


        LoadFcn='';
        InitFcn='';
        CopyFcn='';
        PreCopyFcn='';
        PreDeleteFcn='';
        DeleteFcn='';
        ModelCloseFcn='';
        PreSaveFcn='';
        PostSaveFcn='';
        OpenFcn='';
        CloseFcn='';
        StartFcn='';
        StopFcn='';
        UndoDeleteFcn='';
        NameChangeFcn='';
    end

    methods
        function slBlkInfo=BlockProperties()
        end

        function thisSLProps=set.Name(thisSLProps,value)
            thisSLProps.Name=checkString('Tag',value);
        end

        function thisSLProps=set.Position(thisSLProps,value)
            if(length(value)==4)&&all(isnumeric(value))&&all(value>=0)
                thisSLProps.Position=value;
            else
                pm_error('physmod:pm_sli:sli:blockproperties:InvalidPropValue','Position','1x4 vector of doubles');
            end
        end

        function thisSLProps=set.Orientation(thisSLProps,value)
            thisSLProps.Orientation=checkOrientation('Orientation',value);
        end

        function thisSLProps=set.DropShadow(thisSLProps,dropShadow)
            thisSLProps.DropShadow=checkBoolean('DropShadow',dropShadow);
        end

        function thisSLProps=set.FontName(thisSLProps,value)
            thisSLProps.FontName=checkString('FontName',value);
        end

        function thisSLProps=set.FontSize(thisSLProps,value)
            if isscalar(value)&&isnumeric(value)&&((value>0)||(value==-1))
                thisSLProps.FontSize=round(value);
            else
                pm_error('physmod:pm_sli:sli:blockproperties:InvalidPropValue','FontSize','scalar integer');
            end
        end

        function thisSLProps=set.Tag(thisSLProps,value)
            thisSLProps.Tag=checkString('Tag',value);
        end

        function thisSLProps=set.Mask(thisSLProps,value)
            thisSLProps.Mask=checkBoolean('Mask',value);
        end

        function thisSLProps=set.MaskSelfModifiable(thisSLProps,value)
            thisSLProps.MaskSelfModifiable=checkBoolean('MaskSelfModifiable',value);
        end

        function thisSLProps=set.MaskIconRotate(thisSLProps,value)
            value=lower(value);
            switch(value)
            case{'none','port'}
                thisSLProps.MaskIconRotate=value;
            otherwise
                pm_error('physmod:pm_sli:sli:blockproperties:InvalidPropValue','MaskIconRotate','none/port');
            end
        end

        function thisSLProps=set.MaskType(thisSLProps,value)
            thisSLProps.MaskType=checkString('MaskType',value);
        end

        function thisSLProps=set.MaskInitialization(thisSLProps,maskInit)
            thisSLProps.MaskInitialization=checkString('MaskInitialization',maskInit);
        end

        function thisSLProps=set.MaskHelp(thisSLProps,helpStr)
            thisSLProps.MaskHelp=checkString('MaskHelp',helpStr);
        end

        function thisSLProps=set.MaskIconUnits(thisSLProps,iconUnits)
            checkString('MaskIconUnits',iconUnits);
            iconUnits=lower(iconUnits);
            switch(iconUnits)
            case{'pixels','normalized','autoscale'}
                thisSLProps.MaskIconUnits=iconUnits;
            otherwise
                pm_error('physmod:pm_sli:sli:blockproperties:InvalidPropValue','MaskIconUnits','pixels, normalized or autoscale');
            end
        end

        function thisSLProps=set.MaskDescription(thisSLProps,descStr)
            thisSLProps.MaskDescription=checkString('MaskDescription',descStr);
        end

        function thisSLProps=set.MaskDisplay(thisSLProps,maskInit)
            thisSLProps.MaskDisplay=checkString('MaskDisplay',maskInit);
        end

        function thisSLProps=set.MaskRunInitForIconRedraw(thisSLProps,value)
            thisSLProps.MaskRunInitForIconRedraw=checkBoolean('MaskRunInitForIconRedraw',value);
        end

        function thisSLProps=set.MaskIconFrame(thisSLProps,showFrame)
            thisSLProps.MaskIconFrame=checkBoolean('MaskIconFrame',showFrame);
        end



        function thisSLProps=set.LoadFcn(thisSLProps,CBStr)
            thisSLProps.LoadFcn=checkString('LoadFcn',CBStr);
        end

        function thisSLProps=set.CopyFcn(thisSLProps,CBStr)
            thisSLProps.CopyFcn=checkString('CopyFcn',CBStr);
        end

        function thisSLProps=set.PreCopyFcn(thisSLProps,CBStr)
            thisSLProps.PreCopyFcn=checkString('PreCopyFcn',CBStr);
        end

        function thisSLProps=set.PreDeleteFcn(thisSLProps,CBStr)
            thisSLProps.PreDeleteFcn=checkString('PreDeleteFcn',CBStr);
        end

        function thisSLProps=set.DeleteFcn(thisSLProps,CBStr)
            thisSLProps.DeleteFcn=checkString('DeleteFcn',CBStr);
        end

        function thisSLProps=set.ModelCloseFcn(thisSLProps,CBStr)
            thisSLProps.ModelCloseFcn=checkString('ModelCloseFcn',CBStr);
        end

        function thisSLProps=set.PreSaveFcn(thisSLProps,CBStr)
            thisSLProps.PreSaveFcn=checkString('PreSaveFcn',CBStr);
        end

        function thisSLProps=set.PostSaveFcn(thisSLProps,CBStr)
            thisSLProps.PostSaveFcn=checkString('PostSaveFcn',CBStr);
        end

        function thisSLProps=set.OpenFcn(thisSLProps,CBStr)
            thisSLProps.OpenFcn=checkString('OpenFcn',CBStr);
        end

        function thisSLProps=set.CloseFcn(thisSLProps,CBStr)
            thisSLProps.CloseFcn=checkString('CloseFcn',CBStr);
        end

        function thisSLProps=set.StartFcn(thisSLProps,CBStr)
            thisSLProps.StartFcn=checkString('StartFcn',CBStr);
        end

        function thisSLProps=set.StopFcn(thisSLProps,CBStr)
            thisSLProps.StopFcn=checkString('StopFcn',CBStr);
        end

        function thisSLProps=set.UndoDeleteFcn(thisSLProps,CBStr)
            thisSLProps.UndoDeleteFcn=checkString('UndoDeleteFcn',CBStr);
        end

        function thisSLProps=set.NameChangeFcn(thisSLProps,CBStr)
            thisSLProps.NameChangeFcn=checkString('NameChangeFcn',CBStr);
        end

        function thisSLProps=set.InitFcn(thisSLProps,CBStr)
            thisSLProps.InitFcn=checkString('InitFcn',CBStr);
        end
    end
end

function propValue=checkBoolean(propName,propValue)
    switch(lower(propValue))
    case 'on'
        propValue='on';
    case 'off'
        propValue='off';
    case 1
        propValue='on';
    case 0
        propValue='off';
    otherwise
        pm_error('physmod:pm_sli:sli:blockproperties:InvalidPropValue',propName,'boolean(''on'',''off'',1,0)');
    end
end

function propValue=checkOrientation(propName,propValue)
    propValue=lower(propValue);
    switch(lower(propValue))
    case{'right','left','up','down'}
    otherwise
        pm_error('physmod:pm_sli:sli:blockproperties:InvalidPropValue',propName,'right,left,up,down');
    end
end

function propValue=checkString(propName,propValue)
    if~ischar(propValue)
        pm_error('physmod:pm_sli:sli:blockproperties:InvalidPropValue',propName,'string');
    end
end