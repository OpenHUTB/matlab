function hilite_system_legend(this,hilite_data,overlay)




    assert(nargin==2||nargin==3,'hilite_system_legend must have 2-3 arguments');
    if nargin==2

        overlay=false;
    end


    if(isempty(hilite_data))
        return;
    end

    if(isequal(hilite_data.type,'task'))
        [stylerId,triggeredStylerName]=this.getHiliteStyler(hilite_data.modelName,'task');
    else
        [stylerId,triggeredStylerName]=this.getHiliteStyler(hilite_data.modelName);
    end



    editor=GLUE2.Util.findAllEditors(hilite_data.modelName);
    if(isequal(length(editor),1))
        studio=[];
        studio=editor.getStudio;
        studio.show;
    end


    findOpts=Simulink.FindOptions('LookUnderMasks','all','FollowLinks',true);
    sysHandle=Simulink.findBlocks(hilite_data.modelName,findOpts);
    sysHandle=num2cell(sysHandle);

    if(isequal(hilite_data.type,'source'))
        lines=[];
    else


        lines=find_system(hilite_data.modelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FindAll','on','LookUnderMasks','all','FollowLinks','on','Type','line');
        lines=lines';
    end

    hiliteAncestorsOn={'HiliteAncestors','on'};
    hiliteAncestorsOff={'HiliteAncestors','off'};

    if~overlay

        set_param(hilite_data.modelName,'HiliteAncestors','fade');
    end

    if(isempty(hilite_data.hilitePathSet))
        return;
    end

    [styleFunId,triggleStyleFunId]=this.getHiliteStyleClass(...
    hilite_data.modelName,hilite_data.Annotation);

    hiliteHandleSet=num2cell(hilite_data.hilitePathSet);

    trysetparam(hilite_data.hilitePathSet,hiliteAncestorsOff{:});


    StylerName=char(stylerId);
    styler=diagram.style.getStyler(StylerName);
    if isempty(styler)
        diagram.style.createStyler(StylerName);
        styler=diagram.style.getStyler(StylerName);
    end

    if~overlay


        styler.clearAllClasses();
    end

    if(isempty(hilite_data.hilitePathSet))
        return;
    end

    if(isequal(hilite_data.colorRGB,[-1,-1,-1]))


        trysetparam(hilite_data.hilitePathSet,hiliteAncestorsOn{:});

        lineAnnotationMatch=isLineAnnotationMatch(lines,hilite_data.Annotation);
        lines2Hilite=lines(lineAnnotationMatch);
        trysetparam(lines2Hilite,hiliteAncestorsOn{:});
    else
        hiliteStyle=diagram.style.Style;
        hiliteStyle.set('StrokeColor',[hilite_data.colorRGB,1]);


        glow=MG2.GlowEffect;
        glow.Spread=3;
        glow.Gain=8;
        glow.Color=[hilite_data.colorRGB,0.3];
        hiliteStyle.set('Glow',glow);

        hiliteStyle.set('FillColor',[hilite_data.colorRGB,0.3]);
        hiliteStyle.set('FillStyle','Solid');
        hiliteStyle.set('TextColor',[hilite_data.colorRGB,1.0]);

        styler.removeClass(sysHandle',styleFunId);

        hiliteSelector=diagram.style.ClassSelector(styleFunId);
        styler.addRule(hiliteStyle,hiliteSelector);
        styler.applyClass(hiliteHandleSet,styleFunId);

        if(~isempty(hilite_data.Annotation))
            lineAnnotationMatch=isLineAnnotationMatch(lines,hilite_data.Annotation);
            lines2Hilite=num2cell(lines(lineAnnotationMatch));
            if~isempty(lines2Hilite)
                styler.applyClass(lines2Hilite,styleFunId);
            end
        end

        triggeredStyler=diagram.style.getStyler(triggeredStylerName);
        if isempty(triggeredStyler)
            diagram.style.createStyler(triggeredStylerName);
            triggeredStyler=diagram.style.getStyler(triggeredStylerName);
        end
        triggeredStyler.clearAllClasses();

        if(isequal(hilite_data.Value,[-1,-1])||isequal(hilite_data.type,'source'))




            hiliteStyleTrig=diagram.style.Style;
            hiliteStyleTrig.set('StrokeColor',[hilite_data.colorRGB,1]);


            glow=MG2.GlowEffect;
            glow.Spread=8;
            glow.Gain=10;
            glow.Color=[hilite_data.colorRGB,0.5];
            hiliteStyleTrig.set('Glow',glow);
            triggeredStyler.removeClass(sysHandle',triggleStyleFunId);
            hiliteSelectorTrig=diagram.style.ClassSelector(triggleStyleFunId);
            triggeredStyler.addRule(hiliteStyleTrig,hiliteSelectorTrig);

            hiliteHandleSetTrig=getFullParentBlkList(hilite_data.hilitePathSet,hilite_data.modelName);
            triggeredStyler.applyClass(hiliteHandleSetTrig,triggleStyleFunId);
        end
    end

    if(length(hiliteHandleSet)<100)
        try
            Simulink.scrollToVisible(hiliteHandleSet,'ensureFit','off','panMode','minimal');
        catch ME %#ok<NASGU>


        end
    end
end

function lineAnnotationMatch=isLineAnnotationMatch(lines,Annotation)








    lineAnnotation=get_param(lines,'SampleTimeAnnotation');

    lineAnnotationMatch=strcmp(lineAnnotation,Annotation(1));

    if(length(Annotation)>1)
        for idx=2:length(Annotation)
            lineAnnotationMatch=(lineAnnotationMatch)|(strcmp(lineAnnotation,Annotation(idx)));


        end
    end

    lineAnnotationMatch=reshape(lineAnnotationMatch,size(lines));
end

function fullParentBlkList=getFullParentBlkList(PathSet,mdl)
    hbdroot=get_param(mdl,'Handle');
    parentBlkList=containers.Map(hbdroot,true);
    for idx=1:length(PathSet)
        currentPath=PathSet(idx);

        try
            currentBlk=get_param(get_param(currentPath,'parent'),'Handle');
        catch
            currentBlk=-1;
        end
        while(currentBlk>0)
            if(~isKey(parentBlkList,currentBlk))
                parentBlkList(currentBlk)=true;
                try
                    parentBlk=get_param(get_param(currentBlk,'parent'),'Handle');
                catch
                    parentBlk=-1;
                end
                currentBlk=parentBlk;
            else
                break;
            end
        end
    end
    remove(parentBlkList,hbdroot);
    fullParentBlkList=keys(parentBlkList);
end

function trysetparam(handleset,varargin)


    for idx=1:length(handleset)
        try
            set_param(handleset(idx),varargin{:});
        catch
        end
    end
end
