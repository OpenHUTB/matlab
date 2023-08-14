function jmaab_jc_0739

    rec=ModelAdvisor.Check('mathworks.jmaab.jc_0739');

    rec.Title=DAStudio.message('ModelAdvisor:jmaab:jc_0739_title');
    rec.TitleTips=[DAStudio.message('ModelAdvisor:jmaab:jc_0739_guideline'),newline,newline,DAStudio.message('ModelAdvisor:jmaab:jc_0739_tip')];

    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='jc_0739';

    rec.setCallbackFcn(@(system,checkObj)Advisor.Utils.genericCheckCallback(system,checkObj,'ModelAdvisor:jmaab:jc_0739',@hCheckAlgo),'None','DetailStyle');

    rec.Value=true;
    rec.SupportHighlighting=true;
    rec.SupportLibrary=true;
    rec.SupportExclusion=true;


    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';
    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='graphical';

    rec.setInputParametersLayoutGrid([1,4]);
    rec.setInputParameters(inputParamList);

    rec.setLicense({styleguide_license,'Stateflow'});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});

end

function violations=hCheckAlgo(system)

    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdlAdvObj.getInputParameters;

    allStates=Advisor.Utils.Stateflow.sfFindSys(system,inputParams{1}.Value,inputParams{2}.Value,{'-isa','Stateflow.State','-or','-isa','Stateflow.SimulinkBasedState'},true);
    allStates=mdlAdvObj.filterResultWithExclusion(allStates);

    flags=false(1,length(allStates));
    for i=1:numel(allStates)
        stateBoundingBox=getStateBoundingBox(allStates{i});
        internalBoundingBox=getInternalBoundingBox(allStates{i});
        if~box_contains(stateBoundingBox,internalBoundingBox)
            flags(i)=true;
        end
    end

    violations=allStates(flags);
end

function box=getStateBoundingBox(stateObj)








    mPos=fix(stateObj.position);
    if isprop(stateObj,'IsSubchart')&&stateObj.IsSubchart
        mPos=fix(sf('get',stateObj.id,'.subviewS.pos'));
    end

    box.x1=mPos(1);
    box.y1=mPos(2);
    box.x2=box.x1+mPos(3);
    box.y2=box.y1+mPos(4);
end

function box=getInternalBoundingBox(stateObj)

    box=struct();


    m3it=StateflowDI.Util.getDiagramElement(stateObj.Id);
    m3iObj=m3it.temporaryObject;

    children=stateObj.find('-depth',1);

    chart=stateObj.Chart;
    annots=chart.find('-isa','Stateflow.Annotation');
    for i=1:length(annots)
        if~ismember(annots(i),children)&&overlaps(annots(i),stateObj)
            children(end+1)=annots(i);%#ok<AGROW>
        end
    end

    if numel(children)>1
        children=children(2:end);
    else
        children=[];
    end



    if isempty(children)||isa(stateObj,'Stateflow.SimulinkBasedState')




        mPos=stateObj.position;
        if isprop(stateObj,'IsSubchart')&&stateObj.IsSubchart
            mPos=fix(sf('get',stateObj.id,'.subviewS.pos'));
        end
        bound_x1=mPos(1);
        bound_y1=mPos(2);

        box.x1=bound_x1+fix(m3iObj.labelPosition(1));
        box.y1=bound_y1+fix(m3iObj.labelPosition(2));
        box.x2=box.x1+fix(m3iObj.labelSize(1));
        box.y2=box.y1+fix(m3iObj.labelSize(2));

    else


        [box.x1,box.y1]=deal(intmax);
        [box.x2,box.y2]=deal(0);
        for i=1:numel(children)

            if isa(children(i),'Stateflow.Transition')&&sf('get',children(i).Id,'.type')~=0
                continue;
            end

            [bound_x1,bound_y1,bound_x2,bound_y2]=getBounds(children(i));
            if isempty(bound_x1)||isempty(bound_y1)||isempty(bound_x2)||isempty(bound_y2)
                continue;
            end

            [label_x1,label_y1,label_x2,label_y2]=getLabelBounds(children(i));

            box.x1=min([box.x1,bound_x1,label_x1]);
            box.y1=min([box.y1,bound_y1,label_y1]);
            box.x2=max([box.x2,bound_x2,label_x2]);
            box.y2=max([box.y2,bound_y2,label_y2]);

        end


    end
end


function bResult=box_contains(box1,box2)

    bResult=box1.x1<=box2.x1&&box1.y1<=box2.y1&&box1.x2>=box2.x2&&box1.y2>=box2.y2;
end

function bResult=overlaps(o1,o2)
    [x1,y1,x2,y2]=getBounds(o2);
    [x3,y3,x4,y4]=getBounds(o1);

    bResult=x1<x4&&x2>x3&&y1<y4&&y2>y3;
end

function[x1,y1,x2,y2]=getBounds(sfObj)
    switch class(sfObj)
    case{'Stateflow.State','Stateflow.Box','Stateflow.SimulinkBasedState','Stateflow.Function','Stateflow.SLFunction','Stateflow.TruthTable','Stateflow.EMFunction','Stateflow.Annotation'}
        x1=fix(sfObj.position(1));
        y1=fix(sfObj.position(2));
        x2=x1+fix(sfObj.position(3));
        y2=y1+fix(sfObj.position(4));
    case 'Stateflow.Transition'
        x1=fix(sfObj.SourceEndpoint(1));
        y1=fix(sfObj.SourceEndpoint(2));
        x2=fix(sfObj.DestinationEndpoint(1));
        y2=fix(sfObj.DestinationEndpoint(2));
    case 'Stateflow.Junction'
        pos=sfObj.Position;
        x1=fix(pos.Center(1))-pos.Radius;
        y1=fix(pos.Center(2))-pos.Radius;
        x2=fix(pos.Center(1))+pos.Radius;
        y2=fix(pos.Center(2))+pos.Radius;
    otherwise
        [x1,y1,x2,y2]=deal([]);

    end
end

function[x1,y1,x2,y2]=getLabelBounds(sfObj)
    m3it=StateflowDI.Util.getDiagramElement(sfObj.Id);
    ch_m3i=m3it.temporaryObject;
    switch class(sfObj)
    case{'Stateflow.State','Stateflow.Box','Stateflow.SimulinkBasedState','Stateflow.Function','Stateflow.SLFunction','Stateflow.TruthTable','Stateflow.EMFunction','Stateflow.Annotation'}
        x1=fix(sfObj.position(1))+fix(ch_m3i.labelPosition(1));
        y1=fix(sfObj.position(2))+fix(ch_m3i.labelPosition(2));
        x2=x1+fix(ch_m3i.labelSize(1));
        y2=y1+fix(ch_m3i.labelSize(2));
    case 'Stateflow.Transition'
        x1=fix(sfObj.LabelPosition(1));
        y1=fix(sfObj.LabelPosition(2));
        x2=x1+fix(sfObj.LabelPosition(3));
        y2=y1+fix(sfObj.LabelPosition(4));
    otherwise
        [x1,y1,x2,y2]=deal([]);

    end
end