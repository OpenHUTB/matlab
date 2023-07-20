

function lampProperties=getLampProperties(widgetId,model)


    lampProperties={};
    lampDlgSrc='';
    dlgs=DAStudio.ToolRoot.getOpenDialogs(true);
    for i=1:length(dlgs)
        dlgSrc=dlgs(i).getSource;
        if utils.isWidgetDialog(dlgSrc,widgetId,model)
            lampDlgSrc=dlgSrc;
            break;
        end
    end

    if~isempty(lampDlgSrc)
        block=get(lampDlgSrc.getBlock(),'Handle');
        lampProperties{1}=lampDlgSrc.States;
        lampProperties{2}=lampDlgSrc.StateColors;
        lampProperties{3}=lampDlgSrc.DefaultColor;


        if isa(lampDlgSrc.getBlock(),'Simulink.CustomWebBlock')
            lampProperties{4}=0;
            lampProperties{5}=0;
            lampProperties{6}=0;
        else
            lampProperties{4}=get_param(block,'Icon');
            lampProperties{5}=1;
            lampProperties{6}=get_param(block,'CustomIcon');
        end
    else
        lampProperties{1}={'0'};
        lampProperties{2}=[100,212,19];
        lampProperties{3}=[200,200,200];
        lampProperties{4}='Default';

        lampProperties{5}=1;
        lampProperties{6}='';
    end

end


