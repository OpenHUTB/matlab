



classdef ParamInterface<handle


    properties(Dependent=true,Access=public)


        Model;

    end


    methods


        function val=get.Model(this)
            val=this.Model_;
        end


        function bTunable=blockHasTunableParams(this,bpath)




            narginchk(2,2);
            if ishandle(bpath)
                blkObj=get_param(bpath,'Object');
                bpath=blkObj.getFullName;
            end


            bTunable=~isempty(this.getTunableParams(bpath,bpath));
        end


        function bBindable=blockHasBindableParams(this,bpath)



            narginchk(2,2);
            if ishandle(bpath)
                blkObj=get_param(bpath,'Object');
                bpath=blkObj.getFullName;
            end


            [bparams,bRefresh]=this.getBindableParams(bpath);
            bBindable=bRefresh||~isempty(bparams);
        end


        function[bparams,bRefreshNeeded,bHasTunableParams]=...
            getBindableParams(this,bpath)

            bparams=Simulink.HMI.ParamSourceInfo.empty;
            bRefreshNeeded=false;


            narginchk(2,2);
            if ishandle(bpath)
                blkObj=get_param(bpath,'Object');
                bpath=blkObj.getFullName;
            end
            try
                bpath=Simulink.BlockPath(bpath);
            catch me
                throwAsCaller(me);
            end


            len=bpath.getLength;
            if len<1
                return;
            end
            blk=bpath.getBlock(len);
            blkMdl=Simulink.SimulationData.BlockPath.getModelNameForPath(blk);
            if~strcmp(blkMdl,this.Model_)
                DAStudio.error(...
                'SimulinkHMI:errors:ParamInterBlkNotInMdl',...
                blk,this.Model_)
            end


            try
                bpath.validate(true);
            catch me
                throwAsCaller(me);
            end


            tunable=this.getTunableParams(blk,bpath);
            bHasTunableParams=~isempty(tunable);


            [literal,non_literal]=this.getLiteralScalarParams(tunable);


            hChart=sfprivate('block2chart',blk);


            wks_vars=Simulink.HMI.ParamSourceInfo.empty;
            if~isempty(non_literal)
                [wks_vars,bRefreshNeeded]=...
                this.getTunableWksVars(blk,non_literal);
            end
            if hChart
                [wks_vars,bRefreshNeeded]=...
                this.getChartParams(blk,hChart,wks_vars,bRefreshNeeded);
            end


            bparams=[wks_vars,literal];


            bparams=this.filterNonTunableInlineParams(bparams);
        end


        function refreshWksParamCache(this)


            try
                this.FindVarsActive_=true;
                Simulink.findVars(this.Model_,'SearchMethod','compiled');
                this.FindVarsActive_=false;
            catch me
                this.FindVarsActive_=false;
                throwAsCaller(me);
            end
        end

    end


    methods(Hidden=true)


        function obj=ParamInterface(mdl)

            obj.Model_=mdl;
        end


        function renameModel(this,newName)

            this.Model_=newName;
        end

    end


    methods(Access=private)


        function params=getTunableParams(~,blk,fullPath)


            params=Simulink.HMI.ParamSourceInfo.empty;


            dlg_params=get_param(blk,'DialogParameters');
            if isempty(dlg_params)
                return;
            end
            bparams=fieldnames(dlg_params);


            for idx=1:length(bparams)
                paramName=bparams{idx};
                attribs=dlg_params.(paramName).Attributes;
                if~any(strcmp(attribs,'read-only-if-compiled'))&&...
                    ~any(strcmp(attribs,'read-only'))



                    label=dlg_params.(paramName).Prompt;
                    if~isempty(label)
                        if label(end)==':'
                            label=label(1:end-1);
                        end
                        params(end+1).BlockPath=fullPath;%#ok<AGROW>
                        params(end).Label=label;
                        params(end).ParamName=paramName;
                    end
                end
            end
        end


        function[literal,non_literal]=getLiteralScalarParams(this,tunable)


            literal=Simulink.HMI.ParamSourceInfo.empty;
            non_literal=Simulink.HMI.ParamSourceInfo.empty;
            for idx=1:length(tunable)
                val=tunable(idx).getValue();
                try
                    valString=tunable(idx).getValueString;
                catch me %#ok<NASGU>
                    continue;
                end
                if isscalar(val)&&...
                    (isnumeric(val)||islogical(val))&&...
                    isnan(val)&&...
                    ~Simulink.HMI.ParamSourceInfo.isReservedKeyword(valString)
                    non_literal=[non_literal,tunable(idx)];%#ok<AGROW>
                elseif this.isSupportedParamValue(val)
                    literal=[literal,tunable(idx)];%#ok<AGROW>
                end
            end
        end


        function[wks_vars,bRefreshNeeded]=getTunableWksVars(this,blk,non_literal)


            wks_vars=Simulink.HMI.ParamSourceInfo.empty;
            bRefreshNeeded=false;

            for pIdx=1:length(non_literal)


                paramName=non_literal(pIdx).ParamName;
                [vars,bRefreshNeeded]=this.findWksVars(blk,paramName);


                for vIdx=1:length(vars)
                    if strcmpi(vars(vIdx).SourceType,'data dictionary')||...
                        ~strcmpi(vars(vIdx).WorkspaceType,'mask')
                        param=non_literal(pIdx);
                        param.Label=['''',vars(vIdx).Name,''''];
                        param.VarName=vars(vIdx).Name;
                        if(strcmpi(vars(vIdx).SourceType,'data dictionary'))
                            param.WksType=vars(vIdx).Source;
                        else
                            param.WksType=vars(vIdx).WorkspaceType;
                        end

                        val=param.getValue();
                        if this.isSupportedParamValue(val)

                            if~this.isDuplicateParam(wks_vars,param)
                                wks_vars=[wks_vars,param];%#ok<AGROW>
                            end
                        end
                    end
                end
            end
        end


        function[wks_vars,bRefreshNeeded]=getChartParams(this,blk,hChart,wks_vars,bRefreshNeeded)


            prms=sfprivate('get_wksp_data_names_for_chart',hChart);
            if isempty(prms)
                return
            end


            try
                vars=Simulink.findVars(...
                blk,...
                'SearchMethod','cached');
            catch me %#ok<NASGU>
                bRefreshNeeded=true;
                return;
            end


            for idx=1:length(vars)
                if~strcmpi(vars(idx).SourceType,'mask workspace')
                    param=Simulink.HMI.ParamSourceInfo;
                    param.BlockPath=blk;
                    param.Label=['''',vars(idx).Name,''''];
                    param.VarName=vars(idx).Name;
                    if strcmpi(vars(idx).SourceType,'data dictionary')
                        param.WksType=vars(idx).Source;
                    else
                        param.WksType=vars(idx).WorkspaceType;
                    end

                    val=param.getValue();
                    if this.isSupportedParamValue(val)
                        if~this.isDuplicateParam(wks_vars,param)
                            wks_vars=[wks_vars,param];%#ok<AGROW>
                        end
                    end
                end
            end
        end


        function bIsDuplicate=isDuplicateParam(~,wks_vars,param)

            bIsDuplicate=false;
            for i=1:length(wks_vars)
                if(strcmp(wks_vars(i).VarName,param.VarName)&&...
                    strcmp(wks_vars(i).WksType,param.WksType))
                    bIsDuplicate=true;
                    break;
                end
            end
        end


        function[vars,bRefreshNeeded]=findWksVars(this,blk,paramName)


            bRefreshNeeded=false;



            try
                vars=Simulink.findVars(...
                blk,...
                'DirectUsageDetails.Properties',paramName,...
                'SearchMethod','cached');
            catch me %#ok<NASGU>
                bRefreshNeeded=true;
                vars=[];
                return;
            end


            isCompiled=get_param(this.Model_,'CompiledSinceLastChange');
            if strcmpi(isCompiled,'off')
                bRefreshNeeded=true;
            end
        end


        function bValid=isSupportedParamValue(~,val)



            if isscalar(val)&&isa(val,'Simulink.Parameter')
                val=val.Value;
            end


            isRealNumeric=(isnumeric(val)||islogical(val))&&isreal(val)&&~isempty(val);
            isStruct=isstruct(val);
            bValid=isRealNumeric||isStruct;
        end


        function params=filterNonTunableInlineParams(this,params)





            if~strcmp(get_param(this.Model_,'InlineParams'),'on')||...
                slfeature('InlinePrmsAsCodeGenOnlyOption')
                return;
            end


            idxToRemove=[];
            modelVars=get_param(this.Model_,'TunableVars');
            modelVars=strsplit(modelVars,',');
            for idx=1:length(params)


                if~strcmp(params(idx).WksType_,'base')
                    idxToRemove=[idxToRemove,idx];%#ok<AGROW>
                    continue;
                end


                if~params(idx).isTunableInlineVariable(modelVars);
                    idxToRemove=[idxToRemove,idx];%#ok<AGROW>
                    continue;
                end
            end


            params(idxToRemove)=[];
        end

    end


    properties(Hidden=true)
        Model_;
        FindVarsActive_=false;
    end

end
