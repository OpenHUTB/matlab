






classdef ParamSourceInfo


    properties(Dependent=true,Access=public)


        BlockPath;


        Label;


        ParamName;


        VarName;


        Element;


        WksType;

    end


    methods


        function obj=ParamSourceInfo(varargin)

            if nargin>0
                id=varargin{1};

                validateattributes(varargin{1},{'char'},{});
                obj.UUID=id;
            else

                obj.UUID=sdi.Repository.generateUUID();
            end
        end


        function val=get.BlockPath(this)
            val=this.BlockPath_;
        end
        function this=set.BlockPath(this,val)
            try
                if isa(val,'Simulink.BlockPath')
                    this.BlockPath_=val;
                else
                    this.BlockPath_=Simulink.BlockPath(val);
                end
            catch me
                throwAsCaller(me);
            end
        end


        function val=get.Label(this)
            val=this.Label_;
        end
        function this=set.Label(this,val)
            if~ischar(val)
                DAStudio.error('SimulinkHMI:errors:InvalidParamLabel');
            end
            this.Label_=val;
        end


        function val=get.ParamName(this)
            val=this.ParamName_;
        end
        function this=set.ParamName(this,val)
            if~ischar(val)
                DAStudio.error('SimulinkHMI:errors:InvalidParamName');
            end
            this.ParamName_=val;
        end


        function val=get.VarName(this)
            val=this.VarName_;
        end
        function this=set.VarName(this,val)
            if~ischar(val)
                DAStudio.error('SimulinkHMI:errors:InvalidVarName');
            end
            this.VarName_=val;
        end


        function val=get.Element(this)
            val=this.ElementRawInput_;
        end
        function this=set.Element(this,val)
            userRawInput=val;
            if ischar(val)||isStringScalar(val)
                if isStringScalar(val)
                    val=convertStringsToChars(val);
                end
                val=val(~isspace(val));
                if isempty(val)
                    this.Element_=val;
                else

                    if~(val(1)=='('||val(1)=='.')
                        val=strcat('.',val);
                    end
                    randomVarName=genvarname('',who);
                    try
                        eval([randomVarName,val,'=0;']);
                    catch me
                        error(message('SimulinkHMI:errors:InvalidElementName',userRawInput));
                    end
                    clear(randomVarName);
                    this.Element_=val;
                end
            else

                try
                    validateattributes(val,{'numeric'},{'scalar','integer','positive'});
                catch me
                    error(message('SimulinkHMI:errors:InvalidElement'));
                end
                this.Element_=['(',num2str(val),')'];
            end
            this.ElementRawInput_=userRawInput;
        end


        function val=get.WksType(this)
            val=this.WksType_;
        end
        function this=set.WksType(this,val)

            if ischar(val)&&Simulink.HMI.ParamSourceInfo.isSLDD(val)
                this.WksType_=val;
                return;
            end

            if~ischar(val)||...
                (~isempty(val)&&~strcmpi(val,'base')&&~strcmpi(val,'model'))
                DAStudio.error('SimulinkHMI:errors:InvalidWksType');
            end
            this.WksType_=lower(val);
        end


        function val=getValue(this)

            val=nan;


            blk=this.getSourceBlock();
            if isempty(blk)
                return;
            end
            if Simulink.HMI.ParamSourceInfo.isSLDD(this.WksType_)
                try
                    ddict=Simulink.data.dictionary.open(this.WksType_);
                    dDataSectObj=getSection(ddict,'Design Data');
                    ent=getEntry(dDataSectObj,this.VarName);
                    val=ent.getValue;
                catch me %#ok<NASGU>
                    val=nan;
                end
            else

                try
                    switch this.WksType_
                    case ''
                        str=this.getValueString;
                        val=Simulink.HMI.ParamSourceInfo.evalLiteralParam(str);
                    case 'base'
                        val=evalin('base',this.VarName_);
                    case 'model'
                        mdl=Simulink.SimulationData.BlockPath.getModelNameForPath(blk);
                        mdl_wks=get_param(mdl,'ModelWorkspace');
                        val=mdl_wks.getVariable(this.VarName_);
                    end
                catch me %#ok<NASGU>
                    val=nan;
                end
            end
            if isscalar(val)&&~isstruct(val)&&~isa(val,'Simulink.Parameter')
                try
                    if isnan(val)
                        return;
                    end
                catch
                end
            end
            if~isempty(this.Element_)
                try
                    val=this.getElementValue(val,this.Element_);
                catch me
                    if isempty(this.WksType_)
                        error(message('SimulinkHMI:errors:DataAccessInvalidElement',[this.ParamName_,this.Element_]));
                    else
                        error(message('SimulinkHMI:errors:DataAccessInvalidElement',[this.VarName_,this.Element_]));
                    end
                end
            end
        end


        function val=getValueString(this)

            blk=this.getSourceBlock;
            try
                val=get_param(blk,this.ParamName_);
            catch me
                throwAsCaller(me);
            end



            if strcmpi(this.ParamName_,'SimulationStatus')
                mode=get_param(blk,'SimulationMode');
                if strcmpi(mode,'external')
                    val=get_param(blk,'ExtModeTargetSimStatus');
                    if strcmpi(val,'running')
                        val='external';
                    end
                end
            end
        end


        function val=getDoubleValue(this)

            val=this.getValue;
            if isa(val,'Simulink.Parameter')
                val=val.Value;
            end
            if~isempty(val)&&(~isscalar(val)||isstruct(val))
                val=nan;
                error(message('SimulinkHMI:errors:InvalidNonScalarTuningElement'));
            end
            val=double(val);
        end


        function str=getComponentLabel(this)

            if~isempty(this.VarName_)
                str=this.VarName_;
            else
                blk=this.getSourceBlock();
                blkName=get_param(blk,'Name');
                str=sprintf('%s:%s',blkName,this.ParamName_);
            end
        end


        function[minVal,maxVal]=getMinMax(this)

            minVal=[];
            maxVal=[];
            val=this.getValue;
            if isa(val,'Simulink.Parameter')
                if isscalar(val.Min)&&isfinite(val.Min)
                    minVal=val.Min;
                end
                if isscalar(val.Max)&&isfinite(val.Max)
                    maxVal=val.Max;
                end
            end
        end


        function bTunable=isTunableInlineVariable(this,varargin)




            bTunable=false;
            if~strcmp(this.WksType_,'base')
                return;
            end



            val=this.getValue;
            if isa(val,'Simulink.Parameter')
                bTunable=~strcmpi(val.CoderInfo.StorageClass,'Auto');
                return;


            elseif length(varargin)==1
                vars=varargin{1};
                bTunable=ismember(this.VarName,vars);
            end
        end


        function new_val=setValue(this,val,mdl)



            if strcmp(this.BindingRule_,'not found')
                DAStudio.error('SimulinkHMI:errors:UnboundParamBinding');
            end

            try

                new_val=this.getTypedValue(val);
                if isa(new_val,'Simulink.Parameter')
                    new_val=new_val.Value;
                end

                varExistCmd=['exist(''',this.VarName_,''', ''var'')'];

                if Simulink.HMI.ParamSourceInfo.isSLDD(this.WksType_)
                    try
                        ddict=Simulink.data.dictionary.open(this.WksType_);
                        dDataSectObj=getSection(ddict,'Design Data');
                        dEntryObj=getEntry(dDataSectObj,this.VarName);
                        existing_val=getValue(dEntryObj);
                        slParamObj=[];
                        if isa(existing_val,'Simulink.Parameter')
                            slParamObj=existing_val;
                            existing_val=existing_val.Value;
                        end
                        if~isempty(this.Element_)
                            str=this.convertNonCompositeScalarToString(new_val);
                            new_val=existing_val;
                            evalStr=sprintf('new_val%s = %s;',this.Element_,str);
                            eval(evalStr);
                        end

                        matching=Simulink.HMI.ParamSourceInfo.compareValues(existing_val,new_val);
                        if(~all(matching(:)))
                            if~isempty(slParamObj)
                                slParamObj.Value=new_val;
                                setValue(dEntryObj,slParamObj);
                            else
                                setValue(dEntryObj,new_val);
                            end
                        end
                    catch me %#ok<NASGU>


                    end
                else
                    switch this.WksType_
                    case ''
                        blk=this.getSourceBlock();


                        sw=warning('off','Simulink:Commands:SetParamLinkChangeWarn');
                        tmp=onCleanup(@()warning(sw));
                        str=this.convertNonCompositeScalarToString(new_val);
                        valueStr=this.getValueString;
                        value=Simulink.HMI.ParamSourceInfo.evalLiteralParam(valueStr);
                        exprToAssignNewValue=sprintf(['value',this.Element_,'=%s;'],str);
                        eval(exprToAssignNewValue);
                        str=this.convertCompositeToString(value);
                        set_param(blk,this.ParamName_,str);

                    case 'base'
                        if(evalin('base',varExistCmd)==1)
                            new_val=this.getTypedValue(val);
                            if isa(new_val,'Simulink.Parameter')
                                str=this.convertNonCompositeScalarToString(new_val.Value);
                                evalin('base',[this.VarName_,'.Value',this.Element_,'=',str,';']);
                            else
                                str=this.convertNonCompositeScalarToString(new_val);
                                evalin('base',[this.VarName_,this.Element_,'=',str,';']);
                            end
                        end

                    case 'model'
                        blk=this.getSourceBlock();
                        mdlName=Simulink.SimulationData.BlockPath.getModelNameForPath(blk);
                        mdl_wks=get_param(mdlName,'ModelWorkspace');
                        new_val=this.getTypedValue(val);
                        if mdl_wks.hasVariable(this.VarName_)
                            existing_val=mdl_wks.getVariable(this.VarName_);
                            existing_val=this.getElementValue(existing_val,this.Element_);
                            if~Simulink.HMI.ParamSourceInfo.compareValues(existing_val,new_val)
                                if isa(new_val,'Simulink.Parameter')
                                    str=this.convertNonCompositeScalarToString(new_val.Value);
                                    evalin(mdl_wks,[this.VarName_,'.Value',this.Element_,' = ',str,';']);
                                else
                                    str=this.convertNonCompositeScalarToString(new_val);
                                    evalin(mdl_wks,[this.VarName_,this.Element_,' = ',str,';']);
                                end
                            end
                        end
                    end
                end


                status=get_param(mdl,'SimulationStatus');
                isExtMode=strcmpi(status,'external');
                isRunningWksVar=...
                ~isempty(this.WksType_)&&...
                ismember(status,{'running','paused'});
                if isExtMode||isRunningWksVar
                    this.updateDiagram(mdl,isExtMode);
                end
            catch me
                Simulink.output.error(me);
            end
        end


        function this=applyRebindingRules(this,mdl,systemPath)



            this=this.applyBlockPathBinding(mdl,systemPath);
            if isempty(this.CachedBlockHandles_)
                this=this.applySIDBinding(systemPath);
            end
            if isempty(this.CachedBlockHandles_)
                this=this.applyVarNameBinding(systemPath);
            end


            if(isempty(this.CachedBlockHandles_)&&...
                ~strcmp(this.BindingRule_,'update needed'))
                this.BindingRule_='not found';
                return;
            end


            blk=this.getSourceBlock();
            if~isempty(this.ParamName_)
                params=get_param(blk,'DialogParameters');
                if~isfield(params,this.ParamName_)
                    this.BindingRule_='not found';
                    this.CachedBlockHandles_=[];
                    return
                end
            end



            isVariable=~isempty(this.WksType_);
            if~isVariable
                str=this.getValueString;
                if~Simulink.HMI.ParamSourceInfo.isReservedKeyword(str)
                    val=Simulink.HMI.ParamSourceInfo.evalLiteralParam(str);
                    if isscalar(val)&&~isstruct(val)
                        try
                            if isnan(val)
                                this.BindingRule_='not found';
                                this.CachedBlockHandles_=[];
                                return;
                            end
                        catch
                        end
                    end
                end
            end




            try
                this.getDoubleValue;
            catch me
                this.BindingRule_='invalid composite binding';
                this.CachedBlockHandles_=[];
                return;
            end







            try
                commented=get_param(blk,'Commented');
            catch
                return;
            end

            if(strcmp(commented,'on'))
                this.BindingRule_='commented';
            elseif strcmp(commented,'through')
                this.BindingRule_='through';
            end


            this.BlockPath_=Simulink.BlockPath(blk);
        end


        function iseq=isequal(obj1,obj2)



            if isempty(obj1)||isempty(obj2)||...
                ~isa(obj2,'Simulink.HMI.ParamSourceInfo')||...
                ~isequal(size(obj1),size(obj2))
                iseq=false;
                return
            end
            iseqarray=eq(obj1,obj2);
            iseq=all(iseqarray(:));
        end


        function iseq=eq(obj1,obj2)


            if isempty(obj1)&&isempty(obj2)
                iseq=[];
                return
            end



            if numel(obj1)==1&&~isempty(obj2)
                iseq=false(size(obj2));
                for k=1:numel(obj2)
                    iseq(k)=compareScalars(obj1,obj2(k));
                end
                return
            end


            assert(isequal(size(obj1),size(obj2)));
            iseq=false(size(obj2));
            for k=1:numel(obj1)
                iseq(k)=compareScalars(obj1(k),obj2(k));
            end
        end

        function isBoundValue=isBound(this)
            isBoundValue=~strcmp(this.BindingRule_,'not found')&&~strcmp(this.BindingRule_,'not bindable')&&~strcmp(this.BindingRule_,'invalid composite binding');
        end

        function elementToDisplay=getElementToDisplay(this)
            elementToDisplay=this.Element_;
            if~isempty(elementToDisplay)
                if elementToDisplay(1)=='.'
                    elementToDisplay=elementToDisplay(2:end);
                elseif elementToDisplay(1)=='('&&elementToDisplay(end)==')'&&all(isstrprop(elementToDisplay(2:(end-1)),'digit'))
                    elementToDisplay=elementToDisplay(2:(end-1));
                end
            end
        end
    end


    methods(Access=private)


        function blk=getSourceBlock(this)

            if~isempty(this.CachedBlockHandles_)
                try
                    obj=get_param(this.CachedBlockHandles_(1),'Object');
                    blk=obj.getFullName;
                    return;
                catch me %#ok<NASGU>

                end
            end
            if isempty(this.BlockPath_)
                blk='';
                return;
            end
            len=this.BlockPath_.getLength();
            if~len
                blk='';
            else
                blk=this.BlockPath_.getBlock(len);
            end
        end


        function val=getTypedValue(this,new_val)


            val=this.getValue();
            if isa(val,'Simulink.Parameter')
                cmd=sprintf('%s(new_val)',class(val.Value));
                val.Value=eval(cmd);
            elseif strcmp(class(val),class(new_val))
                val=new_val;
            else
                cmd=sprintf('%s(new_val)',class(val));
                val=eval(cmd);
            end
        end


        function this=applyBlockPathBinding(this,~,systemPath)



            this.CachedBlockHandles_=[];
            relPath=this.getSourceBlock;
            if~isempty(relPath)
                fullPath=relPath;
            else
                fullPath=[systemPath,'/',relPath];
            end


            try
                get_param(fullPath,this.ParamName_);
                this.CachedBlockHandles_=get_param(fullPath,'Handle');
                this.BindingRule_='blockpath';
            catch me %#ok<NASGU>
                this.CachedBlockHandles_=[];
            end

        end


        function this=applySIDBinding(this,~)



            bp=this.BlockPath_.refreshFromSSIDcache(false);
            if isequal(bp,this.BlockPath_)
                return;
            end
            len=bp.getLength();
            fullPath=bp.getBlock(len);


            try
                get_param(fullPath,this.ParamName_);
                this.CachedBlockHandles_=get_param(fullPath,'Handle');
                this.BindingRule_='sid';
            catch me %#ok<NASGU>
                this.CachedBlockHandles_=[];
            end
        end


        function this=applyVarNameBinding(this,systemPath)

            oldMdl='';
            this.BindingRule_='';
            if~isempty(this.WksType_)
                if Simulink.HMI.ParamSourceInfo.isSLDD(this.WksType_)
                    try
                        vars=Simulink.findVars(systemPath,...
                        'SearchMethod','cached',...
                        'Name',this.VarName_);
                        for i=1:length(vars)
                            if strcmpi(vars(i).Source,this.WksType_)
                                fullPath=vars.Users{1};
                                oldMdl=Simulink.SimulationData.BlockPath.getModelNameForPath(fullPath);
                                this.CachedBlockHandles_=get_param(fullPath,'Handle');
                                this.BindingRule_='variable';
                                break;
                            end
                        end
                    catch me %#ok<NASGU>
                        this.CachedBlockHandles_=[];




                        if(strcmp(me.identifier,'Simulink:Data:CannotRetrieveCachedInformationBeforeUpdate')||...
                            ~strcmp(oldMdl,systemPath))
                            this.BindingRule_='update needed';
                        end
                    end
                else
                    try
                        vars=Simulink.findVars(systemPath,...
                        'SearchMethod','cached',...
                        'WorkspaceType',this.WksType_,...
                        'Name',this.VarName_);
                        if length(vars)==1
                            fullPath=vars.Users{1};
                            oldMdl=Simulink.SimulationData.BlockPath.getModelNameForPath(fullPath);
                            this.CachedBlockHandles_=get_param(fullPath,'Handle');
                            this.BindingRule_='variable';
                        end
                    catch me %#ok<NASGU>
                        this.CachedBlockHandles_=[];




                        if(strcmp(me.identifier,'Simulink:Data:CannotRetrieveCachedInformationBeforeUpdate')||...
                            ~strcmp(oldMdl,systemPath))
                            this.BindingRule_='update needed';
                        end
                    end
                end
            end
        end


        function iseq=compareScalars(obj1,obj2)


            iseq=...
            isequal(obj1.UUID,obj2.UUID)&&...
            isequal(obj1.BlockPath_,obj2.BlockPath_)&&...
            isequal(obj1.Label_,obj2.Label_)&&...
            isequal(obj1.ParamName_,obj2.ParamName_)&&...
            isequal(obj1.VarName_,obj2.VarName_)&&...
            isequal(obj1.Element_,obj2.Element_)&&...
            isequal(obj1.WksType_,obj2.WksType_);
        end


        function updateDiagram(this,mdl,isExtMode)



            blk=this.getSourceBlock();
            h=Simulink.PluginMgr;

            if isempty(this.WksType_)
                h.EvalParams(blk);
            elseif isExtMode
                isExtModeBatchMode=strcmp(get_param(mdl,'ExtModeBatchMode'),'on');
                if~isExtModeBatchMode






                    set_param(mdl,'SimulationCommand','update');
                end
            else
                wksType={'WorkspaceType',this.WksType_};
                if Simulink.HMI.ParamSourceInfo.isSLDD(this.WksType_)
                    wksType={'SourceType','data dictionary'};
                end
                vars=Simulink.findVars(mdl,...
                'SearchMethod','cached',...
                wksType{:},...
                'Name',this.VarName_);
                for idx=1:length(vars(1).Users)
                    h.EvalParams(vars(1).Users{idx});
                end
            end
        end
    end


    methods(Static=true,Access=private)


        function literalVal=evalLiteralParam(str)





            sw2c7c63a9e5604d8d9400384d9cbc7448=warning('off','all');
            tp2c7c63a9e5604d8d9400384d9cbc7448=onCleanup(...
            @()warning(sw2c7c63a9e5604d8d9400384d9cbc7448));

            try
                literalVal=eval(str);
            catch me %#ok<NASGU>
                literalVal=nan;
            end

        end
    end
    methods(Hidden=true,Static=true)

        function updateValue(model,path,label,paramName,varName,element,wks,val)

            paramSource=Simulink.HMI.ParamSourceInfo;
            if isempty(model)
                paramSource.BlockPath=Simulink.BlockPath(path);
            elseif iscell(path)
                paramSource.BlockPath=Simulink.BlockPath([model,'/',path{1}]);
            else
                paramSource.BlockPath=Simulink.BlockPath([model,'/',path]);
            end
            paramSource.Label=label;
            paramSource.ParamName=paramName;
            paramSource.VarName=varName;
            paramSource.Element=element;
            paramSource.WksType=wks;

            len=paramSource.BlockPath.getLength();
            if len>0
                blk=paramSource.BlockPath.getBlock(1);
                mdl=Simulink.SimulationData.BlockPath.getModelNameForPath(blk);


                sw=warning('off','Simulink:Commands:SetParamLinkChangeWarn');
                tmp=onCleanup(@()warning(sw));
                paramSource.setValue(val,mdl);
            end
        end


        function bVal=isSLDD(val)
            [~,~,ext]=fileparts(val);
            bVal=false;
            if strcmpi(ext,'.sldd')
                bVal=true;
            end
        end


        function bMatch=compareValues(existing_val,new_val)
            if isa(existing_val,'Simulink.Parameter')
                bMatch=isequal(existing_val.Value,new_val.Value);
            else
                bMatch=isequal(existing_val,new_val);
            end
        end


        function value=getElementValue(value,element)
            if~isempty(element)
                if isa(value,'Simulink.Parameter')
                    value=eval(['Simulink.Parameter(value.Value',element,')']);
                else
                    value=eval(['value',element]);
                end
            end
        end


        function bKeyword=isReservedKeyword(valString)


            bKeyword=false;
            if~isempty(valString)&&(strcmpi(valString,'auto')||strcmpi(valString,'nan'))
                bKeyword=true;
            end
        end


        function reportError(errID,varargin)

            try
                error(message(errID,varargin{:}));
            catch me
                Simulink.output.error(me);
            end
        end


        function str=convertNonCompositeScalarToString(new_val)
            if isa(new_val,'double')

                str=num2str(new_val,16);
            elseif isa(new_val,'single')

                str=sprintf('%s(%s)','single',num2str(new_val,7));
            else
                str=sprintf('%s(%s)',class(new_val),num2str(new_val));
            end
        end


        function str=convertStructToString(val)
            str='struct(';

            fieldNameList=fieldnames(val);
            for m=1:length(fieldNameList)
                if~strcmp(str,'struct(')
                    str=strcat(str,', ');
                end
                fieldName=fieldNameList{m};

                str=strcat(str,['''',fieldName,''', ']);
                fieldValue=eval(['val.',fieldName]);


                str=strcat(str,Simulink.HMI.ParamSourceInfo.convertCompositeToString(fieldValue));
            end
            str=strcat(str,')');
        end


        function str=convertArrayToString(val)


            assert(length(size(val))==2);
            [numRows,numCols]=size(val);

            str='[';
            for m=1:numRows

                if~strcmp(str,'[')
                    str=strcat(str,'; ');
                end
                for n=1:numCols


                    str=strcat(str,Simulink.HMI.ParamSourceInfo.convertCompositeToString(val(m,n)));


                    if n~=numCols
                        str=strcat(str,', ');
                    end
                end
            end
            str=strcat(str,']');
        end














        function str=convertCompositeToString(val)




            if(isnumeric(val)||islogical(val))&&isscalar(val)&&isreal(val)
                str=Simulink.HMI.ParamSourceInfo.convertNonCompositeScalarToString(val);

            else

                if isscalar(val)
                    assert(isstruct(val));
                    str=Simulink.HMI.ParamSourceInfo.convertStructToString(val);

                else
                    str=Simulink.HMI.ParamSourceInfo.convertArrayToString(val);
                end
            end
        end
    end


    properties(Hidden=true)
        BlockPath_=Simulink.BlockPath;
        Label_='';
        ParamName_='';
        VarName_='';
        Element_='';
        ElementRawInput_='';
        WksType_='';
        UUID;
    end


    properties(Transient=true,Hidden=true)
        CachedBlockHandles_;
        BindingRule_='';
    end

end
