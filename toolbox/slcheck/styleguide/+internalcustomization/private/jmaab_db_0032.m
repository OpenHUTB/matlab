function jmaab_db_0032





    rec=Advisor.Utils.getDefaultCheckObject('mathworks.jmaab.db_0032',false,@CheckAlgo,'None');
    rec.setLicense({styleguide_license});


    entries={'Disable',...
    ['db_0032_a1:',DAStudio.message('ModelAdvisor:jmaab:db_0032_a1_subtitle')],...
    ['db_0032_a2:',DAStudio.message('ModelAdvisor:jmaab:db_0032_a2_subtitle')]};

    ipA=ModelAdvisor.InputParameter;
    ipA.ColSpan=[1,4];
    ipA.RowSpan=[1,4];
    ipA.Name=DAStudio.message('ModelAdvisor:jmaab:db_0032_a_group_title');
    ipA.Entries=entries;
    ipA.Value=1;
    ipA.Type='RadioButton';
    ipA.Visible=false;

    n=5;
    ipB=Advisor.Utils.getInputParam_Bool('ModelAdvisor:jmaab:db_0032_b_subtitle',[n,n],[1,4]);
    ipC=Advisor.Utils.getInputParam_Bool('ModelAdvisor:jmaab:db_0032_c_subtitle',[n+1,n+1],[1,4]);
    ipD=Advisor.Utils.getInputParam_Bool('ModelAdvisor:jmaab:db_0032_d_subtitle',[n+2,n+2],[1,4]);
    ipE=Advisor.Utils.getInputParam_Bool('ModelAdvisor:jmaab:db_0032_e_subtitle',[n+3,n+3],[1,4]);


    ipB.Name=['db_0032_b:',ipB.Name];
    ipC.Name=['db_0032_c:',ipC.Name];
    ipD.Name=['db_0032_d:',ipD.Name];
    ipE.Name=['db_0032_e:',ipE.Name];


    paramFollowLinks=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    paramLookUnderMasks=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');

    paramFollowLinks.RowSpan=[n+4,n+4];
    paramFollowLinks.ColSpan=[1,2];

    paramLookUnderMasks.RowSpan=[n+4,n+4];
    paramLookUnderMasks.ColSpan=[3,4];

    paramThreshold=Advisor.Utils.getInputParam_String('ModelAdvisor:jmaab:db_0032_threshold',[n+5,n+5],[1,2],'0');
    paramThreshold.Enable=true;

    rec.setInputParametersLayoutGrid([10,4]);
    rec.setInputParameters({ipA,ipB,ipC,ipD,ipE,paramFollowLinks,paramLookUnderMasks,paramThreshold});

    rec.setInputParametersCallbackFcn(@inputParamCallBack);
    rec.setReportStyle('ModelAdvisor.Report.SmartStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.SmartStyle'});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_jmaab_group,sg_maab_group});
end


function inputParamCallBack(taskobj,tag,handle)

    if isa(taskobj,'ModelAdvisor.Task')
        inputParameters=taskobj.Check.InputParameters;
    elseif isa(taskobj,'ModelAdvisor.ConfigUI')
        inputParameters=taskobj.InputParameters;
    else
        return
    end

    ip=collectInputParameters(inputParameters,false);

    if~(ip.A1||ip.A2||ip.B||ip.C||ip.D||ip.E)
        warndlgHandle=warndlg(DAStudio.message('ModelAdvisor:engine:SubCheck_InputParam_SelectionWarning'));
        set(warndlgHandle,'Tag','MACEInvalidSubCheckSelection');
        if isa(taskobj.MAObj,'Simulink.ModelAdvisor')
            taskobj.MAObj.DialogCellArray{end+1}=warndlgHandle;
        end

        inputParameters{1}.Value=1;
    end
end

function violations=CheckAlgo(system)
    maObj=Simulink.ModelAdvisor.getModelAdvisor(system);


    ip=collectInputParameters(maObj,true);


    violations=[];






    if ip.A2&&~strcmp(get_param(0,'EditorPathXStyle'),'hop')
        currentValue=get_param(0,'EditorPathXStyle');
        viola=ModelAdvisor.ResultDetail;
        viola.Title=DAStudio.message(strcat('ModelAdvisor:jmaab:db_0032_a2_subtitle'));
        viola.Status=DAStudio.message(strcat('ModelAdvisor:jmaab:db_0032_a2_warn'));
        viola.RecAction=DAStudio.message(strcat('ModelAdvisor:jmaab:db_0032_a2_rec_action'));
        ModelAdvisor.ResultDetail.setData(viola,'Model',bdroot(system),'Parameter','EditorPathXStyle',...
        'CurrentValue',currentValue,'RecommendedValue','hop');
        violations=viola;
    end






    allSubsystems=find_system(system,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks',ip.FL,...
    'LookUnderMasks',ip.LUM,...
    'BlockType','SubSystem',...
    'IsSimulinkFunction','off');


    allSubsystems=Advisor.Utils.Naming.filterUsersInShippingLibraries(allSubsystems);



    if isequal(system,bdroot(system))
        allSubsystems=[allSubsystems;system];
    end


    allSubsystems=maObj.filterResultWithExclusion(allSubsystems);


    for dx=1:numel(allSubsystems)
        subSystem=allSubsystems{dx};
        lineSegments=[];
        blockSegments=[];

        if~isValidSubsystem(subSystem)
            continue;
        end


        if Stateflow.SLUtils.isStateflowBlock(subSystem)
            continue;
        end






        lines=find_system(subSystem,...
        'FollowLinks',ip.FL,...
        'MatchFilter',@Simulink.match.allVariants,...
        'LookUnderMasks',ip.LUM,...
        'SearchDepth','1','FindAll','on','Type','line');


        if isempty(lines)
            continue;
        end


        for ldx=1:numel(lines)
            if ip.D&&isMultipleBranchesFromSamePoint(lines(ldx))
                violations=[violations;createResultDetail(lines(ldx),'d')];%#ok<AGROW>       
            end
            lineSegments=[lineSegments;getSplitSegmentsFromLine(lines(ldx))];%#ok<AGROW>
        end









        for idx=1:numel(lineSegments)




            if ip.E
                if isDiagonal(lineSegments(idx))
                    violations=[violations;createResultDetail(lineSegments(idx).line,'e')];%#ok<AGROW>
                    continue;
                end
            end

            if ip.A1||ip.B
                for jdx=idx+1:numel(lineSegments)
                    res=segmentsIntersect(lineSegments(idx),lineSegments(jdx),ip);
                    if res.status&&~strcmp(res.subcheck,'c')
                        violations=[violations;createResultDetail(lineSegments(idx).line,res.subcheck)];%#ok<AGROW>
                        break;
                    end
                end
            end
        end





        if ip.C

            blocks=find_system(subSystem,...
            'FollowLinks',ip.FL,...
            'LookUnderMasks',ip.LUM,...
            'SearchDepth','1','Type','Block');





            blocks=setdiff(blocks,subSystem);


            for kdx=1:numel(blocks)
                blockSegments=[blockSegments;getBoundingBoxPoints(blocks{kdx})];%#ok<AGROW>
            end





            n=numel(lineSegments);
            for idx=1:n


                res=blockIntersection(lineSegments(idx),blockSegments,ip);
                if res
                    violations=[violations;createResultDetail(lineSegments(idx).line,'c')];%#ok<AGROW>
                end
            end
        end

    end






    threshold=str2double(ip.Threshold);
    if~isnan(threshold)


        allLines=find_system(system,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'FollowLinks',ip.FL,...
        'LookUnderMasks',ip.LUM,...
        'FindAll','on','Type','line');
        count=length(allLines);
        if length(violations)<((threshold/100)*count)
            violations=[];
        end
    end
end


function segment=getBoundingBoxPoints(block)
    segment.block=block;




    pos=get_param(block,'position');


    segment.horizontal(1).left=[pos(1),pos(4)];
    segment.horizontal(1).right=[pos(3),pos(4)];
    segment.horizontal(2).left=[pos(1),pos(2)];
    segment.horizontal(2).right=[pos(3),pos(2)];


    segment.vertical(1).left=[pos(1),pos(4)];
    segment.vertical(1).right=[pos(1),pos(2)];
    segment.vertical(2).left=[pos(3),pos(4)];
    segment.vertical(2).right=[pos(3),pos(2)];
end


function segments=getSplitSegmentsFromLine(line)




    segments=[];
    points=get_param(line,'points');
    for sdx=2:size(points,1)
        segment.line=line;
        segment.left=points(sdx-1,:);
        segment.right=points(sdx,:);
        segments=[segments;segment];%#ok<AGROW>
    end
end


function res=blockIntersection(lineSegment,blockSegments,ip)









    res=true;


    num=lineSegment.right(2)-lineSegment.left(2);
    den=lineSegment.right(1)-lineSegment.left(1);


    if num~=0&&den~=0
        res=true;
    end


    ipNew=ip;
    ipNew.B=true;


    for i=1:numel(blockSegments)

        if(den==0)&&...
            (segmentsIntersect(lineSegment,blockSegments(i).horizontal(1),ipNew).status)&&...
            (segmentsIntersect(lineSegment,blockSegments(i).horizontal(2),ipNew).status)
            return;
        end


        if(num==0)&&...
            (segmentsIntersect(lineSegment,blockSegments(i).vertical(1),ipNew).status)&&...
            (segmentsIntersect(lineSegment,blockSegments(i).vertical(2),ipNew).status)
            return;
        end
    end
    res=false;
end


function res=segmentsIntersect(a,b,ip)







    res.status=false;
    res.subcheck='a1';

    d1=direction(b.left,b.right,a.left);
    d2=direction(b.left,b.right,a.right);
    d3=direction(a.left,a.right,b.left);
    d4=direction(a.left,a.right,b.right);

    if ip.A1||ip.C
        if((d1>0&&d2<0)||(d1<0&&d2>0))&&((d3>0&&d4<0)||(d3<0&&d4>0))
            res.status=true;
            if ip.A1
                res.subcheck='a1';
            else
                res.subcheck='c';
            end
            return;
        end
    end

    if ip.B

        if(d1==0&&d2==0)&&...
            (onSegment(b.left,b.right,a.left)||...
            onSegment(b.left,b.right,a.right))
            res.status=~isTapping(a,b)&&~isSameLine(a,b);
            res.subcheck='b';
            return;
        end


        if(d3==0&&d4==0)&&...
            (onSegment(a.left,a.right,b.left)||...
            onSegment(a.left,a.right,b.right))
            res.status=~isTapping(a,b)&&~isSameLine(a,b);
            res.subcheck='b';
        end
    end

end


function res=direction(i,j,k)



    res=(i(1)-k(1))*(j(2)-k(2))-(j(1)-k(1))*(i(2)-k(2));
end


function res=onSegment(i,j,k)


    xBound=isInBounds(k(1),min(i(1),j(1)),max(i(1),j(1)));
    yBound=isInBounds(k(2),min(i(2),j(2)),max(i(2),j(2)));
    if xBound&&yBound
        res=true;
    else
        res=false;
    end
end


function res=isInBounds(value,low,high)

    if(value>=low)&&(value<=high)
        res=true;
    else
        res=false;
    end
end


function res=isTapping(a,b)



    res=false;




    if~(isfield(a,'line')&&isfield(b,'line'))
        return;
    end

    aParent=get_param(a.line,'LineParent');
    bParent=get_param(b.line,'LineParent');

    if(aParent==-1)&&(bParent==-1)
        return;
    end

    if(aParent==bParent)||...
        (isequal(a.line,bParent))||...
        (isequal(b.line,aParent))
        res=true;
    end
end


function res=isValidSubsystem(subsystem)
    res=true;


    if~isequal(bdroot(subsystem),subsystem)&&...
        isequal(get_param(subsystem,'MaskType'),'Sigbuilder block')
        res=false;
    end
end


function res=isDiagonal(lineSegment)
    res=false;

    num=lineSegment.right(2)-lineSegment.left(2);
    den=lineSegment.right(1)-lineSegment.left(1);


    if num~=0&&den~=0
        res=true;
    end
end


function ip=collectInputParameters(maObj,bRetrieve)
    if bRetrieve
        inputParams=maObj.getInputParameters;
    else
        inputParams=maObj;
    end

    if ischar(inputParams{1}.Value)
        ip1=str2double(inputParams{1}.Value);
    else
        ip1=inputParams{1}.Value;
    end

    if ip1==0
        ip.A1=false;
        ip.A2=false;
    elseif ip1==1
        ip.A1=true;
        ip.A2=false;
    else
        ip.A1=false;
        ip.A2=true;
    end

    ip.B=logical(inputParams{2}.Value);
    ip.C=logical(inputParams{3}.Value);
    ip.D=logical(inputParams{4}.Value);
    ip.E=logical(inputParams{5}.Value);
    ip.FL=inputParams{6}.Value;
    ip.LUM=inputParams{7}.Value;
    ip.Threshold=inputParams{8}.Value;
end


function viola=createResultDetail(line,id)
    viola=ModelAdvisor.ResultDetail;

    viola.Title=DAStudio.message(strcat('ModelAdvisor:jmaab:db_0032_',id,'_subtitle'));
    viola.Status=DAStudio.message(strcat('ModelAdvisor:jmaab:db_0032_',id,'_warn'));
    viola.RecAction=DAStudio.message(strcat('ModelAdvisor:jmaab:db_0032_',id,'_rec_action'));
    viola.Description='IGNORE';

    ModelAdvisor.ResultDetail.setData(viola,'Signal',line);
end


function res=isMultipleBranchesFromSamePoint(signal)
    res=false;
    if strcmp(get_param(signal,'SegmentType'),'trunk')

        trunkSegment=getSplitSegmentsFromLine(signal);
        trunkSegment=trunkSegment(1);
        children=get_param(signal,'LineChildren');

        if numel(children)<=2
            return;
        end

        childPoints=get_param(children,'points');

        if isempty(childPoints)
            return;
        end


        num=trunkSegment.right(2)-trunkSegment.left(2);
        den=trunkSegment.right(1)-trunkSegment.left(1);

        if num==0

            branchesY=cellfun(@(x)x(:,2),childPoints,'UniformOutput',false);
            minY=min(cellfun(@(x)min(x),branchesY));
            maxY=max(cellfun(@(x)max(x),branchesY));
            trunkY=trunkSegment.right(2);
            if minY<trunkY&&trunkY<maxY
                res=true;
            end
        elseif den==0

            branchesX=cellfun(@(x)x(:,1),childPoints,'UniformOutput',false);
            minX=min(cellfun(@(x)min(x),branchesX));
            maxX=max(cellfun(@(x)max(x),branchesX));
            trunkX=trunkSegment.right(1);
            if minX<trunkX&&trunkX<maxX
                res=true;
            end
        end
    end
end


function res=isSameLine(a,b)

    res=false;


    if isequal(get_param(a.line,'SrcBlockHandle'),get_param(b.line,'SrcBlockHandle'))&&...
        isequal(get_param(a.line,'DstBlockHandle'),get_param(b.line,'DstBlockHandle'))
        res=true;
    end
end
