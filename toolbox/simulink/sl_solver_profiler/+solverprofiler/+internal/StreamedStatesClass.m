
classdef StreamedStatesClass<handle
    properties(SetAccess=private)
FileLocation
Tout
Xout
ToutForDeriv
XoutValueIdxForDeriv
StatesRange
BlockStateStats




StateIndices
    end

    methods


        function obj=StreamedStatesClass(varargin)
            if nargin==1
                stats=varargin{1};
                obj.BlockStateStats=stats;
            else
                obj.cleanUp();
            end
        end


        function delete(obj)
            obj.cleanUp();
        end

        function cleanUp(obj)
            obj.FileLocation=[];
            obj.Tout=[];
            obj.Xout=[];
            obj.ToutForDeriv=[];
            obj.XoutValueIdxForDeriv=[];
            obj.StatesRange=[];
            obj.BlockStateStats=[];
            obj.StateIndices=[];
        end


        function attachData(obj,arg,tout)
            import solverprofiler.util.*
            obj.Tout=tout;
            if ischar(arg)
                obj.FileLocation=arg;
                try
                    obj.Xout=Simulink.SimulationData.DatasetRef(arg,'xout');
                catch
                    obj.cleanUp();
                    utilPopMsgBox('',utilDAGetString('xoutFileMissing'),'xoutFileMissing');
                end
            else
                obj.FileLocation=[];
                obj.Xout=arg;




                startT=obj.Xout(1).time(1);
                obj.Tout=obj.Tout(obj.Tout>=startT);
            end


            if obj.isStateObjectValid()
                obj.fillStateIndices();
            end
        end


        function fillStateIndices(obj)
            import solverprofiler.util.*
            for i=1:obj.numElements()
                [dimension,stateNameRaw]=obj.getContinuousStateAttribute(i);
                if(dimension==-1),continue;end

                for j=1:dimension

                    stateName=utilFormatBlockPathIfWithinModelRef(stateNameRaw);
                    if(dimension>1)
                        stateName=[stateName,'(',num2str(j),')'];
                    end

                    if~obj.BlockStateStats.stateExist(stateName)





                        if~obj.BlockStateStats.stateExist([stateName,' '])
                            continue;
                        else
                            stateIdx=obj.BlockStateStats.getStateStatsIndex([stateName,' ']);
                        end
                    else
                        stateIdx=obj.BlockStateStats.getStateStatsIndex(stateName);
                    end


                    obj.StateIndices=[obj.StateIndices;stateIdx,i,j];
                end
            end
        end


        function list=getStateIndexList(obj)
            list=obj.StateIndices(:,1);
        end


        function setStateRange(obj,data)
            obj.StatesRange=rmfield(data,{'time','value'});
        end



        function skipTimePointsForDerivEstiamtion(obj,tVec)
            obj.ToutForDeriv=setdiff(obj.Tout,tVec);
            [~,obj.XoutValueIdxForDeriv,~]=intersect(obj.Tout,obj.ToutForDeriv);
        end


        function value=numElements(obj)
            if obj.isStreamed()
                value=obj.Xout.numElements;
            else
                value=length(obj.Xout);
            end
        end


        function isValid=isStateObjectValid(obj)
            isValid=false;
            if~isempty(obj.Xout)
                if obj.isStreamed()
                    if obj.isStateRefValid()
                        isValid=true;
                    end
                else
                    isValid=true;
                end
            end
        end

        function flag=isStreamed(obj)
            flag=isa(obj.Xout,'Simulink.SimulationData.DatasetRef');
        end


        function isValid=isStateRefValid(obj)
            try
                obj.Xout.numElements();
                isValid=true;
            catch
                isValid=false;
            end
        end


        function deleteStreamedStateFile(obj)
            if~isempty(obj.FileLocation)&&exist(obj.FileLocation,'file')==2
                delete(obj.FileLocation);
            end
        end



        function[dimension,stateName]=getContinuousStateAttribute(obj,signalIdx)
            stateName='';
            dimension=-1;
            if obj.isStreamed()
                state=obj.Xout.get(signalIdx);
                label=state.Label;
                if~strcmp(label,'CSTATE')
                    return;
                end
                [~,dimension]=size(state.Values.Data);
                stateName=state.Name;


                if isempty(stateName)||...
                    (~contains(stateName,'/')&&~contains(stateName,'.'))
                    mdlRefLevel=state.BlockPath.getLength();
                    formattedPath=state.BlockPath.getBlock(1);
                    if mdlRefLevel>1
                        for i=2:mdlRefLevel
                            blockPath=state.BlockPath.getBlock(i);
                            formattedPath=[formattedPath,'|',blockPath];
                        end
                    end

                    if(isempty(stateName))
                        stateName=formattedPath;
                    else
                        stateName=[formattedPath,'/',stateName];
                    end
                end
            else
                stateName=obj.Xout(signalIdx).name;
                if~contains(stateName,'/')&&~contains(stateName,'.')
                    blockName=...
                    solverprofiler.util.utilFormatBlockPathIfWithinModelRef(obj.Xout(signalIdx).block);
                    stateName=[blockName,'/',stateName];
                end
                dimension=1;
            end
            stateName=strrep(stateName,newline,' ');
        end

        function[time,value]=getStateValue(obj,stateIdx)
            import solverprofiler.util.*
            time=[];
            value=[];
            if isempty(obj.StateIndices),return;end
            index=find(obj.StateIndices(:,1)==stateIdx);
            if isempty(index)
                return;
            else
                signalIdx=obj.StateIndices(index,2);
                localIdx=obj.StateIndices(index,3);
            end

            try
                time=obj.Tout;
                if obj.isStreamed()
                    value=obj.Xout.get(signalIdx).Values.Data(:,localIdx);
                else
                    value=restoreStateExtrap(obj.Xout(signalIdx).time,...
                    obj.Xout(signalIdx).value,obj.Tout);
                end
            catch
                value=[];
            end
        end



        function[time,value]=estimateStateDeriv(obj,stateIdx)
            time=[];
            value=[];
            if isempty(obj.StateIndices),return;end
            index=find(obj.StateIndices(:,1)==stateIdx);
            if length(obj.ToutForDeriv)<2||isempty(index)
                return;
            end

            signalIdx=obj.StateIndices(index,2);
            localIdx=obj.StateIndices(index,3);
            try
                if obj.isStreamed()

                    time=obj.ToutForDeriv;
                    x=obj.Xout.get(signalIdx).Values.Data(:,localIdx);
                    valIdx=obj.XoutValueIdxForDeriv;
                    xdot=zeros(length(time),1);

                    if~isempty(valIdx)
                        x=x(valIdx);
                        xdot(1:end-1)=double(diff(x))./diff(time);
                        xdot(end)=xdot(end-1);
                        value=xdot;
                    else
                        time=[];
                        value=[];
                    end
                else

                    t=obj.Xout(signalIdx).time;
                    x=obj.Xout(signalIdx).value;
                    idxs=ismembc(t,obj.ToutForDeriv);
                    t=t(idxs);
                    x=x(idxs);
                    if length(t)>1
                        xdot=zeros(1,length(t));
                        xdot(1:end-1)=double(diff(x))./diff(t);
                        xdot(end)=xdot(end-1);
                        time=t;
                        value=xdot;
                    else
                        time=[];
                        value=[];
                    end
                end
            catch
                time=[];
                value=[];
            end


        end


        function[stateIdxLst,scores]=getScoreBasedOnStateDeriv(obj,tLeft,tRight,mode)
            numStates=length(obj.StateIndices(:,1));
            scores=zeros(numStates,1);
            if obj.isStreamed()

                idxL=find(obj.ToutForDeriv>=tLeft,1);
                idxR=find(obj.ToutForDeriv<=tRight,1,'last');
                tDeriv=obj.ToutForDeriv(idxL:idxR);
                valIdx=obj.XoutValueIdxForDeriv(idxL:idxR);
                for i=1:numStates
                    signalIdx=obj.StateIndices(i,2);
                    localIdx=obj.StateIndices(i,3);
                    x=obj.Xout.get(signalIdx).Values.Data(:,localIdx);
                    x=x(valIdx);
                    if length(x)<=2
                        scores(i)=0;
                    else
                        xdot=zeros(length(x),1);
                        xdot(1:end-1)=double(diff(x))./diff(tDeriv);
                        xdot(end)=xdot(end-1);
                        if strcmp(mode,'derivative')
                            scores(i)=max(abs(xdot))+mean(abs(xdot));
                        else
                            scores(i)=max(abs(xdot));
                        end
                    end
                end
            else

                for i=1:numStates
                    signalIdx=obj.StateIndices(i,2);
                    t=obj.Xout(signalIdx).time;
                    x=obj.Xout(signalIdx).value;
                    idxL=find(t>=tLeft,1);
                    idxR=find(t<=tRight,1,'last');
                    t=t(idxL:idxR);
                    x=x(idxL:idxR);
                    idxs=ismembc(t,obj.ToutForDeriv);
                    t=t(idxs);
                    x=x(idxs);
                    if length(t)>1
                        xdot=zeros(1,length(t));
                        xdot(1:end-1)=double(diff(x))./diff(t);
                        xdot(end)=xdot(end-1);
                        if strcmp(mode,'derivative')
                            scores(i)=max(abs(xdot))+mean(abs(xdot));
                        else
                            scores(i)=max(abs(xdot));
                        end
                    else
                        scores(i)=0;
                    end
                end
            end


            scores=round(scores*1000/norm(scores));
            stateIdxLst=obj.StateIndices(:,1);
        end


        function[stateIdxLst,scores]=getScoresBasedOnStatesValue(obj,tLeft,tRight)
            numStates=length(obj.StateIndices(:,1));
            scores=zeros(numStates,1);
            if obj.isStreamed()

                idxL=find(obj.Tout>=tLeft,1);
                idxR=find(obj.Tout<=tRight,1,'last');
                for i=1:numStates
                    signalIdx=obj.StateIndices(i,2);
                    localIdx=obj.StateIndices(i,3);
                    x=obj.Xout.get(signalIdx).Values.Data(:,localIdx);
                    x=x(idxL:idxR);
                    scores(i)=max(abs(x));
                end
            else

                for i=1:numStates
                    signalIdx=obj.StateIndices(i,2);
                    t=obj.Xout(signalIdx).time;
                    x=obj.Xout(signalIdx).value;
                    idxL=find(t>=tLeft,1);
                    idxR=find(t<=tRight,1,'last');
                    x=x(idxL:idxR);
                    scores(i)=max(abs(x));
                end
            end


            scores=round(scores*1000/norm(scores));
            stateIdxLst=obj.StateIndices(:,1);
        end

        function[minMaxValue,stateIdxList]=getInaccurateStateStats(obj,aTol)
            stateIdxList=[];
            minMaxValue=[];
            for i=1:length(obj.StatesRange)
                name=obj.StatesRange(i).name;
                xmin=obj.StatesRange(i).xmin;
                xmax=obj.StatesRange(i).xmax;
                val=max(abs(xmin),abs(xmax));
                if(val<=aTol&&obj.BlockStateStats.stateExist(name))
                    stateIdxList=[stateIdxList;obj.BlockStateStats.getStateStatsIndex(name)];
                    minMaxValue=[minMaxValue;xmin,xmax];
                end
            end
        end

        function copyFileToLocation(obj,destination)
            import solverprofiler.util.*
            try
                if~strcmp(obj.FileLocation,destination)
                    copyfile(obj.FileLocation,destination);
                end
            catch exception
                utilPopMsgBox('',utilDAGetString('statesCannotBeCopied',exception.message),'statesCannotBeCopied');
            end
        end


    end

end