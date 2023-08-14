classdef MulticyclePathConstraintGenerator<hgsetget



















































    properties
mcp




delim

        arrayDeref='()';
        partSelDeref='<>';
langDeref


        pmCache;
uniqueEnbMap
uniqueEnbPhases
uniqueEnbPhaseMax
uniqueEnbIds

    end

    methods

        function this=MulticyclePathConstraintGenerator(hCD)


            if~isempty(hCD)

                this.mcp=[];
                this.langDeref=hdlgetparameter('array_deref');
                rr=hCD.getReg2RegPaths;
                this.pmCache=containers.Map();
                this.delim=hCD.getPathDelim;


                hCD.compileClockEnables;


                tU=hCD.getTimingUtil;
                allEnbs=keys(tU.clkEnbMap);
                numEnbs=numel(allEnbs);


                if numEnbs==0
                    this.uniqueEnbMap=[];
                else
                    this.uniqueEnbMap=containers.Map(allEnbs,zeros(1,numEnbs));
                end
                this.pmCache=zeros(numEnbs);
                this.uniqueEnbPhases={};
                this.uniqueEnbPhaseMax={};
                this.uniqueEnbIds=[];


                for ii=1:length(rr),
                    rr(ii).pathmult=this.derivePM(rr(ii).FROM,rr(ii).TO,hCD);
                end


                if~hdlgetparameter('debug')&&~isempty(rr),


                    rr([rr.pathmult]==1)=[];
                end
                this.mcp=rr;
            end
        end

    end

    methods

        writeTXT(this,mdlname);
    end

    methods(Access=private)





        function pm=derivePM(this,from,to,hCD)




            toUid=getUniqueId(this,to.clock_enable,hCD);
            fromUid=getUniqueId(this,from.clock_enable,hCD);
            pm=cacheLookup(this,toUid,fromUid);
            if isempty(pm),

                pm=numericDerivePM(this,fromUid,toUid);
            end
        end

        function uid=getUniqueId(this,enbh,hCD)









            signame=[enbh.path,this.delim,enbh.name];



            try
                uid=this.uniqueEnbMap(signame);
                if uid~=0&&isscalar(uid)
                    return;
                end
            catch me


            end


            [phases,phasemax]=this.getRegTimingInfo(enbh,hCD);
            uid=findUniqueIdMatch(this,phases,phasemax);

            if isempty(uid)
                uid=addUniqueEnb(this,phases,phasemax);
            end

            this.uniqueEnbMap(signame)=uid;
        end

        function uid=findUniqueIdMatch(this,phases,phasemax)


            if numel(this.uniqueEnbIds)>0,
                phasemaxfh=@(x)isequal(x,phasemax);
                phasesfh=@(x)isequal(x,phases);
                pmlidx=cellfun(phasemaxfh,this.uniqueEnbPhaseMax);
                plidx=cellfun(phasesfh,this.uniqueEnbPhases);
                lidx=pmlidx&plidx;
                uid=this.uniqueEnbIds(lidx);
            else
                uid=[];
            end

        end

        function newid=addUniqueEnb(this,phases,phasemax)



            newid=numel(this.uniqueEnbIds)+1;
            this.uniqueEnbIds(end+1)=newid;
            this.uniqueEnbPhases{end+1}=phases;
            this.uniqueEnbPhaseMax{end+1}=phasemax;
        end

        function pm=cacheLookup(this,toUid,fromUid)






            [r,c]=size(this.pmCache);
            if(toUid>r||fromUid>c),
                pm=[];
            else
                pm=this.pmCache(toUid,fromUid);
                if pm==0,
                    pm=[];
                end

            end
        end

        function addToCache(this,toid,fromid,pm)

            this.pmCache(toid,fromid)=pm;
        end

        function pm=numericDerivePM(this,fromid,toid)





            tophases=this.uniqueEnbPhases{toid};
            tophasemax=this.uniqueEnbPhaseMax{toid};

            fromphases=this.uniqueEnbPhases{fromid};
            fromphasemax=this.uniqueEnbPhaseMax{fromid};


            newPhasemax=lcm(tophasemax,fromphasemax);






            if((newPhasemax~=tophasemax)||(newPhasemax~=fromphasemax)),



                newToPhases=bsxfun(@plus,tophases(:),uint32(0:tophasemax:2*newPhasemax-1));
                newToPhases=newToPhases(:)';

                newFromPhases=bsxfun(@plus,fromphases(:),uint32(0:fromphasemax:newPhasemax-1));
                newFromPhases=newFromPhases(:)';


                newToid=findUniqueIdMatch(this,newToPhases,newPhasemax);
                newFromid=findUniqueIdMatch(this,newFromPhases,newPhasemax);



                if isempty(newToid),
                    newToid=addUniqueEnb(this,newToPhases,newPhasemax);
                end
                if isempty(newFromid),
                    newFromid=addUniqueEnb(this,newFromPhases,newPhasemax);
                end

                pm=[cacheLookup(this,newToid,newFromid),...
                cacheLookup(this,toid,newFromid),...
                cacheLookup(this,newToid,fromid)];
            else


                pm=[];
                newToid=toid;
                newFromid=fromid;
                newFromPhases=fromphases;
                newPhasemax=tophasemax;
                newToPhases=bsxfun(@plus,tophases(:),uint32(0:tophasemax:2*newPhasemax-1));
                newToPhases=newToPhases(:)';
            end


            if isempty(pm),



                pm=hdlconnectivity.MulticyclePathConstraintGenerator.computePMfromPhases(newFromPhases,newToPhases,newPhasemax);
            else


                pm=min(pm);
            end


            this.addToCache(toid,fromid,pm);


            this.addToCache(toid,newFromid,pm);
            this.addToCache(newToid,fromid,pm);
            this.addToCache(newToid,newFromid,pm);
        end

        function[phases,phasemax]=getRegTimingInfo(~,enb,hCD)





            tU=hCD.getTimingUtil;
            enb_timing_struct=struct([]);
            for jj=1:numel(enb),



                enb_timing_struct=cat(2,enb_timing_struct,tU.getClockEnableTiming(enb(jj).path,enb(jj).name));
            end























            if numel(enb_timing_struct)>1,
                enb_timing_struct=enb_timing_struct(1);
            end


            if~isempty(enb_timing_struct),
                phases=enb_timing_struct.phases;
                phasemax=enb_timing_struct.phasemax;
            else
                phases=0;
                phasemax=1;
            end
            phases=sort(phases);

        end

    end
    methods(Static=true);
        function pm=computePMfromPhases(fromPhases,toPhases,phaseMax)


            if(phaseMax==1),
                pm=1;
                return;
            else
                high=(0:(phaseMax-1));
                if(isequal(fromPhases,high))||(isequal(toPhases(1:(numel(toPhases)/2)),high)),
                    pm=1;
                    return;
                end
            end


            pmmax=max(max(fromPhases),max(toPhases));
            pm=pmmax;
            tofrom_diff=zeros(size(fromPhases));
            for ii=1:numel(toPhases)
                tofrom_diff(:)=toPhases(ii)-fromPhases;
                tofrom_diff(tofrom_diff<1)=pmmax;
                currmin=min(tofrom_diff);
                pm=min(pm,currmin);
                if pm==1,

                    return;
                end
            end

            if isempty(pm),
                pm=1;
            end
        end
    end
end



