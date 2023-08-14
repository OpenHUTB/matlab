
function varargout=annotationddg_cb(dlg,action,varargin)



    if~isempty(dlg)
        h=dlg.getDialogSource;
    end

    CUSTOM_COLOR_ITEM=0;

    switch action

    case 'doApply'

        isRichTextAnnotation=strcmp(h.Interpreter,'rich');

        if(~isRichTextAnnotation)
            texVal=dlg.getWidgetValue('interpreter');
            if(texVal)
                h.Interpreter='tex';
            elseif strcmp(h.Interpreter,'tex')
                h.Interpreter='off';
            end
        end


        setAlignment(h,alignmentPropName(dlg.getWidgetValue('alignment')));


        bgud=dlg.getUserData('background');
        if(bgud.wasSet)
            bgcolor=dlg.getWidgetValue('background');
            if(bgcolor>CUSTOM_COLOR_ITEM)
                h.BackgroundColor=colorPropName(bgcolor);
            else
                customColorStr=sprintf('[%f, %f, %f]',bgud.customColor(1),bgud.customColor(2),bgud.customColor(3));
                h.BackgroundColor=customColorStr;
            end
        end
        bgud.wasSet=false;
        dlg.setUserData('background',bgud);


        fgud=dlg.getUserData('foreground');
        if(fgud.wasSet)
            fgcolor=dlg.getWidgetValue('foreground');
            if(fgcolor>0)
                h.ForegroundColor=colorPropName(fgcolor);
            else
                customColorStr=sprintf('[%f, %f, %f]',fgud.customColor(1),fgud.customColor(2),fgud.customColor(3));
                h.ForegroundColor=customColorStr;
            end
        end
        fgud.wasSet=false;
        dlg.setUserData('foreground',fgud);


        leftMargin=str2double(dlg.getWidgetValue('LeftMarginEdit'));
        topMargin=str2double(dlg.getWidgetValue('TopMarginEdit'));
        rightMargin=str2double(dlg.getWidgetValue('RightMarginEdit'));
        bottomMargin=str2double(dlg.getWidgetValue('BottomMarginEdit'));
        set_param(h.Handle,'InternalMargins',sprintf('[%d %d %d %d]',leftMargin,topMargin,rightMargin,bottomMargin));


        if(isempty(dlg.getWidgetValue('text')))

            dlg.setWidgetValue('text',h.PlainText);
        end

        if(~isRichTextAnnotation)

            h.Text=dlg.getWidgetValue('text');
        end


        if(dlg.getWidgetValue('useTextAsClickFcn'))
            dlg.setWidgetValue('clickFcnEdit',dlg.getWidgetValue('text'))
            h.clickFcn=dlg.getWidgetValue('text');
        end


        dlg.refresh();

    case 'doUseTextAsClickFcn'
        if(dlg.getWidgetValue('useTextAsClickFcn'))
            dlg.setUserData('clickFcnEdit',dlg.getWidgetValue('clickFcnEdit'));
            dlg.setWidgetValue('clickFcnEdit',dlg.getWidgetValue('text'));
            dlg.setEnabled('clickFcnEdit',false);
        else
            dlg.setWidgetValue('clickFcnEdit',dlg.getUserData('clickFcnEdit'));
            dlg.setEnabled('clickFcnEdit',true);
        end

    case 'doBackground'
        color=dlg.getWidgetValue('background');
        bgud=dlg.getUserData('background');

        if(color==CUSTOM_COLOR_ITEM)
            customColor=h.showColorDialog(false);

            if(customColor(1)>=0)
                bgud.wasSet=true;
                bgud.customColor=customColor;
            end
        else
            bgud.wasSet=true;
        end
        dlg.setUserData('background',bgud);

    case 'doForeground'
        color=dlg.getWidgetValue('foreground');
        fgud=dlg.getUserData('foreground');


        if(color==CUSTOM_COLOR_ITEM)
            customColor=h.showColorDialog(true);

            if(customColor(1)>=0)
                fgud.wasSet=true;
                fgud.customColor=customColor;
            end
        else
            fgud.wasSet=true;
        end
        dlg.setUserData('foreground',fgud);
    end

    varargout{1}=1;
    varargout{2}='';





    function setAlignment(h,newVal)
        slprivate('setAnnotationAlignment',h.Handle,newVal);


        function name=alignmentPropName(index)
            names={'left','center','right'};
            name=names{index+1};

            function name=colorPropName(index)
                names={'black','white','red','green','blue','yellow','magenta','cyan','gray','orange','lightBlue','darkGreen','automatic'};
                name=names{index};
