function[FunctionVals,ConVals,ConEqVals,state]=SS_EvaluateSolutions(ObjFcn,PointSet,Nonlcon,options,state,xOrigShape)





















    if isempty(PointSet)
        FunctionVals=[];
        ConVals=[];
        ConEqVals=[];
        return
    else

        NPOINT=size(PointSet,1);
        FunctionVals=Inf(NPOINT,1);
        if isempty(Nonlcon)
            ConVals=[];
            ConEqVals=[];
        else
            ConVals=cell(NPOINT,1);
            ConEqVals=cell(NPOINT,1);
        end
    end



    IntensifySwitch=[];




    for SolNum=1:size(PointSet,1)


        thisSol=xOrigShape;
        thisSol(:)=PointSet(SolNum,:);
        FunctionVals(SolNum)=ObjFcn(thisSol);
        if~isempty(Nonlcon)
            [thisConVals,thisConEqVals]=Nonlcon(thisSol);
            ConVals{SolNum}=thisConVals(:)';
            ConEqVals{SolNum}=thisConEqVals(:)';
        end


        state.Evaluations=state.Evaluations+1;


        if~rem(state.Evaluations,options.OutputInterval)

            state=i_updateBestPoint(state,options.OutputInterval,...
            PointSet,FunctionVals,ConVals,ConEqVals,SolNum);
        end


        if~strcmpi(options.IntensifyMethod,'off')

            if state.IntensifyStage~=0
                state.IntensifyEvaluations=state.IntensifyEvaluations+1;
            end

            if~rem(state.Evaluations,options.IntensifyPoint)
                state.IntensifyEvaluations=0;
                switch lower(options.IntensifyMethod)
                case 'one'
                    IntensifySwitch=1;
                case 'two'
                    IntensifySwitch=2;
                case 'both'


                    IntensifySwitch=2-rem((state.Evaluations/options.IntensifyPoint),2);
                end
            elseif state.IntensifyEvaluations==options.IntensifyLength

                IntensifySwitch=0;
                state.IntensifyEvaluations=0;
            end
        end
    end

    if~isempty(IntensifySwitch)
        state.IntensifyStage=IntensifySwitch;
    end



    ConVals=cell2mat(ConVals);
    if isempty(ConVals)
        ConVals=[];
    end
    ConEqVals=cell2mat(ConEqVals);
    if isempty(ConEqVals)
        ConEqVals=[];
    end

    function state=i_updateBestPoint(state,OutputInterval,Points,...
        FunctionVals,ConVals,ConEqVals,SolNum)




        RecordIndex=ceil(state.Evaluations/OutputInterval);


        ConVals=cell2mat(ConVals);
        ConEqVals=cell2mat(ConEqVals);



        PointSet.points=[state.RefSet.points;Points(1:SolNum,:)];
        PointSet.functionVals=[state.RefSet.functionVals;FunctionVals(1:SolNum)];
        if isempty(ConVals)
            PointSet.conVals=state.RefSet.conVals;
        else
            PointSet.conVals=[state.RefSet.conVals;ConVals(1:SolNum,:)];
        end
        if isempty(ConEqVals)
            PointSet.conEqVals=state.RefSet.conEqVals;
        else
            PointSet.conEqVals=[state.RefSet.conEqVals;ConEqVals(1:SolNum,:)];
        end


        PointSet=globaloptim.globalsearch.SS_SortPoints(PointSet,state);


        state.BestPoint(RecordIndex,:)=PointSet.points(1,:);
        state.BestFval(RecordIndex)=PointSet.functionVals(1);


        if RecordIndex>1&&~isequal(state.BestPoint(RecordIndex-1,:),...
            state.BestPoint(RecordIndex,:))
            state.LastImprovementTime=cputime;
        end


