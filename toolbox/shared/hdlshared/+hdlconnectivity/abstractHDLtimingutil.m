classdef abstractHDLtimingutil<hgsetget










    properties
        clkEnbMap;
        addRelCEip;
        addPipeCEip;
        topClockName;
        pathDelim;
        enbWorkList;
    end

    methods
        function addPipelinedClockEnable(this,newEnbName,relEnbName,numDelays,varargin)
            hCD=hdlconnectivity.getConnectivityDirector;

            opts=this.validateAddPipeCE(newEnbName,relEnbName,numDelays,varargin{:});


            if isempty(opts.relEnbPath),
                opts.relEnbPath=hCD.getCurrentHDLPath;
            end
            if isempty(opts.newEnbPath)
                opts.newEnbPath=hCD.getCurrentHDLPath;
            end

            enbIn=this.makeEnb(opts.relEnbPath,opts.relEnbName);
            addToEnbList(this,enbIn,'addPipelined',{opts,numDelays})
        end

        function addRelativeClockEnable(this,newEnbName,relEnbName,relPhases,relWrapCnt,varargin)
            hCD=hdlconnectivity.getConnectivityDirector;

            opts=this.validateAddRelCE(newEnbName,relEnbName,relPhases,relWrapCnt,varargin{:});


            if isempty(opts.relEnbPath),
                opts.relEnbPath=hCD.getCurrentHDLPath;
            end
            if isempty(opts.newEnbPath)
                opts.newEnbPath=hCD.getCurrentHDLPath;
            end

            enbIn=this.makeEnb(opts.relEnbPath,opts.relEnbName);
            addToEnbList(this,enbIn,'addRelative',{opts,relPhases,relWrapCnt});
        end




        function enbTiming=getClockEnableTiming(this,path,enbname)

            if isempty(enbname),
                enbTiming=this.makeEnbTiming(0,1);
                return;
            end

            if this.clkEnbMap.Count==0,
                enbTiming=this.makeEnbTiming(0,1);
                return;
            end


            try
                mapKey=[path,this.pathDelim,enbname];
                enbTiming=this.clkEnbMap(mapKey);
            catch me


                if hdlgetparameter('debug'),
                    warning(message('HDLShared:hdlconnectivity:UnrecognizedClkEnb'));
                end
                enbTiming=struct([]);
            end
        end




        function setPathDelim(this,delim)
            this.pathDelim=delim;
        end

        function dispEnbs(this)

            k=keys(this.clkEnbMap);
            for ii=1:numel(k),
                fprintf('%-64s\t\t%s\n\n',k{ii},...
                hdlconnectivity.abstractHDLtimingutil.strStruct(this.clkEnbMap(k{ii})));
            end
        end

        function compileEnbList(this)

            if(this.clkEnbMap.Count==0)||(this.enbWorkList.Count==0),
                return;
            end










            while(this.enbWorkList.Count~=0)
                klist=keys(this.enbWorkList);
                enbFound_tf=isKey(this.clkEnbMap,klist);

                if~any(enbFound_tf),


                    if hdlgetparameter('debug'),
                        warning(message('HDLShared:hdlconnectivity:MissingClockEnable'));
                    end
                    break;
                end

                enbFound=klist(enbFound_tf);

                for ii=1:numel(enbFound),
                    enbWorkFcn=this.enbWorkList(enbFound{ii});
                    for jj=1:numel(enbWorkFcn),

                        eWF=enbWorkFcn(jj);
                        switch eWF.method,
                        case 'addPipelined',
                            this.privAddPipelinedClockEnable(eWF.args{:});
                        case 'addRelative',
                            this.privAddRelativeClockEnable(eWF.args{:});
                        end
                    end
                    remove(this.enbWorkList,enbFound{ii});
                end
            end
        end
    end


    methods(Access=protected)
        function privAddPipelinedClockEnable(this,opts,numDelays)



            origEnbTiming=this.getClockEnableTiming(opts.relEnbPath,opts.relEnbName);



            if(origEnbTiming.phasemax==1)&&(origEnbTiming.phases==0),

                enbTiming=hdlconnectivity.abstractHDLtimingutil.makeEnbTiming(0,1);

                this.addEnbTiming(opts.newEnbPath,opts.newEnbName,enbTiming);
            else

                newPhases=mod(origEnbTiming.phases+origEnbTiming.phasemax-numDelays,origEnbTiming.phasemax);
                newPhases=sort(newPhases);


                enbTiming=hdlconnectivity.abstractHDLtimingutil.makeEnbTiming(newPhases,origEnbTiming.phasemax);

                this.addEnbTiming(opts.newEnbPath,opts.newEnbName,enbTiming);
            end
        end

        function privAddRelativeClockEnable(this,opts,relPhases,relWrapCnt)






            origEnbTiming=this.getClockEnableTiming(opts.relEnbPath,opts.relEnbName);




























            newPhasemax=origEnbTiming.phasemax*relWrapCnt;



            orig_extended=bsxfun(@plus,origEnbTiming.phases(:),uint32(0:origEnbTiming.phasemax:newPhasemax-1));
            orig_extended=orig_extended(:)';


            new_extended=bsxfun(@plus,uint32(relPhases(:)),uint32(0:relWrapCnt:newPhasemax-1));
            new_extended=new_extended(:)';




            new_indices=new_extended(new_extended<numel(orig_extended));


            newPhases=orig_extended(new_indices+1);



            enbTiming=hdlconnectivity.abstractHDLtimingutil.makeEnbTiming(newPhases,newPhasemax);


            this.addEnbTiming(opts.newEnbPath,opts.newEnbName,enbTiming);
        end

        function opts=validateAddPipeCE(this,newEnbName,relEnbName,numDelays,varargin)
            ip=this.addPipeCEip;
            ip.parse(newEnbName,relEnbName,numDelays,varargin{:});
            opts=ip.Results;
        end

        function opts=validateAddRelCE(this,newEnbName,relEnbName,relPhases,relWrapCnt,varargin)
            ip=this.addRelCEip;
            ip.parse(newEnbName,relEnbName,relPhases,relWrapCnt,varargin{:});
            opts=ip.Results;
        end

        function init(this)
            this.clkEnbMap=containers.Map();
            this.enbWorkList=containers.Map();
            hCD=hdlconnectivity.getConnectivityDirector();
            this.pathDelim=hCD.getPathDelim();


            this.addRelCEip=inputParser;
            this.addRelCEip.addRequired('newEnbName',@ischar);
            this.addRelCEip.addRequired('relEnbName',@ischar);
            this.addRelCEip.addRequired('relDown',@isnumeric);
            this.addRelCEip.addRequired('relPhaseOffset',@isnumeric);
            this.addRelCEip.addParamValue('newEnbPath','',@ischar);
            this.addRelCEip.addParamValue('relEnbPath','',@ischar);

            this.addPipeCEip=inputParser;
            this.addPipeCEip.addRequired('newEnbName',@ischar);
            this.addPipeCEip.addRequired('relEnbName',@ischar);
            this.addPipeCEip.addRequired('numDelays',@isnumeric);
            this.addPipeCEip.addParamValue('newEnbPath','',@ischar);
            this.addPipeCEip.addParamValue('relEnbPath','',@ischar);
        end


        function addEnbTiming(this,newKeyHier,newKeyName,newEnbTiming)
            newKey=[newKeyHier,this.pathDelim,newKeyName];
            this.clkEnbMap(newKey)=newEnbTiming;
        end

        function addToEnbList(this,enbIn,funstr,funargs)

            s=struct('method',funstr,'args',{funargs});
            if isKey(this.enbWorkList,enbIn),
                this.enbWorkList(enbIn)=[this.enbWorkList(enbIn),s];
            else
                this.enbWorkList(enbIn)=s;
            end
        end

        function e=makeEnb(this,path,name)

            e=[path,this.pathDelim,name];
        end
    end

    methods(Static)
        function s=makeEnbTiming(phases_wZeros,phasemax)






            phasetmp=phases_wZeros;
            s=struct('phases',phasetmp,'phasemax',phasemax);
        end


        function c=strStruct(s)%#ok

            c=evalc('disp(s)');
            idx=regexp(c,'\n');
            c=sprintf('%-32s\t%-8s',c(1:idx-1),c(idx+1:end-2));
        end
    end
end


