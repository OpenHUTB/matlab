


function props=getMultiStateImageProperties(widgetId,model)
    props{1}={'0'};
    props{2}={''};
    props{3}={''};
    props{4}={{'0','0'}};
    props{5}={''};
    props{6}={''};
    props{7}={'0','0'};
    props{8}='0';


    dlgSrc=[];
    dlgs=DAStudio.ToolRoot.getOpenDialogs(true);
    for i=1:length(dlgs)
        curSrc=dlgs(i).getSource;
        if utils.isWidgetDialog(curSrc,widgetId,model)
            dlgSrc=curSrc;
            break;
        end
    end


    props=locGetPropsCoreBlock(dlgSrc);
end


function props=locGetPropsCoreBlock(dlgSrc)
    states=dlgSrc.blockObj.States;
    props{1}=cellfun(@num2str,{states.State},'UniformOutput',false);
    props{2}={states.Image};
    props{3}={states.Thumbnail};
    props{4}={};

    defImage=dlgSrc.blockObj.DefaultImage;
    props{5}={defImage.Image};
    props{6}={defImage.Thumbnail};
    props{7}={defImage.Size};

    scaleMode=simulink.hmi.getModePosition(dlgSrc.blockObj.ScaleMode);
    props{8}=num2str(scaleMode);
end
