classdef LoopStreamInfo<handle




    properties(GetAccess=public,SetAccess=immutable)

idxName


idxDesc




        loopIsStartStepStop(1,1)logical




        numLoopBodies(1,1)double




        iterations(1,1)double



        idxType(1,1)internal.mtree.Type=internal.mtree.type.UnknownType



        iterType(1,1)internal.mtree.Type=internal.mtree.type.UnknownType



        start(1,1)double
        step(1,1)double
        stop(1,1)double







        counterBias(1,1)internal.mtree.Constant=...
        internal.mtree.Constant('',[],'')














        idxNodes(1,:)cell


        location(1,:)char
    end

    properties(Access=public)



        iterNode=[];
    end

    methods(Access=public)

        function this=LoopStreamInfo(idxName,idxDesc,idxVals,streamFactor,location)
            assert(numel(idxVals)>0);

            this.idxName=idxName;
            this.idxDesc=idxDesc;
            this.location=location;





            [this.loopIsStartStepStop,loopStart,loopStep,loopIterations]=...
            this.getLoopStartStepIterations(idxVals);


            this.idxType=internal.mtree.Type.fromValue(loopStart);




            [this.numLoopBodies,this.iterations]=...
            this.handleFactor(loopIterations,streamFactor);


            if this.loopIsStartStepStop
                [this.start,this.step,this.stop,this.counterBias]=...
                this.getCounterInfoForStartStepStopLoop(loopStart,loopStep);
            else

                this.start=1;
                this.step=1;
                this.stop=this.iterations;
            end



            this.iterType=this.getIterType();



            this.idxNodes=this.getIdxNodes(idxVals);
        end

    end

    methods(Static,Access=public)
        function realFactor=getRealFactor(loopIterations,streamFactor)
            if isempty(streamFactor)||streamFactor>loopIterations



                realFactor=loopIterations;

            elseif mod(loopIterations,streamFactor)==0


                realFactor=streamFactor;

            else


                for i=streamFactor+1:loopIterations
                    if mod(loopIterations,i)==0
                        realFactor=i;
                        return
                    end
                end
            end
        end

    end

    methods(Access=private)

        function[loopIsStartStepStop,loopStart,loopStep,loopIterations]=...
            getLoopStartStepIterations(~,idxVals)



            loopIterations=0;
            loopStart=[];
            loopStep=0;
            currVal=[];
            loopIsStartStepStop=true;

            for val=idxVals
                loopIterations=loopIterations+1;

                if loopIterations==1

                    loopStart=val;
                    currVal=val;
                    loopIsStartStepStop=isnumeric(loopStart)&&...
                    isscalar(loopStart)&&...
                    isequal(floor(loopStart),loopStart);

                elseif loopIsStartStepStop&&loopIterations==2

                    loopStep=val-loopStart;
                    currVal=cast(currVal+loopStep,'like',loopStep);
                    loopIsStartStepStop=isequal(currVal,val)&&...
                    ~isequal(loopStep,0)&&...
                    isequal(floor(loopStep),loopStep);

                elseif loopIsStartStepStop


                    currVal=cast(currVal+loopStep,'like',loopStep);
                    loopIsStartStepStop=isequal(currVal,val);
                end
            end

            assert(loopIterations>0);



            if~loopIsStartStepStop
                loopStep=[];
            end
        end

        function[numLoopBodies,iterations]=handleFactor(this,loopIterations,streamFactor)

            realFactor=this.getRealFactor(loopIterations,streamFactor);

            numLoopBodies=loopIterations/realFactor;
            iterations=realFactor;
        end

        function iterType=getIterType(this)
            if this.loopIsStartStepStop&&(this.idxType.isFi||this.idxType.isInt)




                iterType=this.idxType;
            else



                iterType=internal.mtree.Type.getIntToHold(this.stop,1);
            end
        end

        function[start,step,stop,counterBias]=...
            getCounterInfoForStartStepStopLoop(this,loopStart,loopStep)


            assert(this.loopIsStartStepStop&&~this.idxType.isUnknown&&...
            this.numLoopBodies>0&&this.iterations>0);



            start=loopStart;




            step=loopStep*this.numLoopBodies;



            stop=start+step*(this.iterations-1);

            if this.numLoopBodies==1


                counterBias=internal.mtree.Constant('',[],'bias');
            else


                counterBias=internal.mtree.Constant('',...
                this.idxType.castValueToType(loopStep),...
                'bias');
            end
        end

        function idxNodes=getIdxNodes(this,idxVals)


            assert(this.iterations>0&&this.numLoopBodies>0);

            idxNodes=repmat({cell(1,this.iterations)},1,this.numLoopBodies);
            totalIterations=0;
            outerIdx=0;
            innerIdx=1;








            for val=idxVals
                totalIterations=totalIterations+1;
                outerIdx=outerIdx+1;

                if outerIdx>this.numLoopBodies
                    outerIdx=1;
                    innerIdx=innerIdx+1;
                    assert(innerIdx<=this.iterations);
                end

                idxNodes{outerIdx}{innerIdx}=internal.mtree.Constant('',...
                val,[this.idxName,'_',num2str(totalIterations)]);
            end
        end

    end
end


