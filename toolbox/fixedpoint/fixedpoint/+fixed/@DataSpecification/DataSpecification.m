classdef(Sealed)DataSpecification<fixed.ValueDomain&fixed.DataSpecificationInterface







    properties(Hidden)


SamplingMethod
    end

    properties(Dependent)



MandatoryValues
    end

    properties(Access=private)
bMandatoryValues
    end

    properties(Hidden)






ValueSetSize
    end

    methods

        function obj=DataSpecification(dataTypeArg,varargin)











            try
                nt=fixed.internal.type.extractNumericType(dataTypeArg);
            catch ME
                throw(ME);
            end
            p=inputParser;
            addParameter(p,'PreferBuiltIn',true,...
            @(x)validateattributes(x,{'logical'},{'scalar'}));
            addParameter(p,'Intervals',{{-inf,inf},{nan}});
            addParameter(p,'ExcludeDenormals',false);
            addParameter(p,'ExcludeNegativeZero',false);
            addParameter(p,'SamplingMethod','bit-pattern');
            addParameter(p,'MandatoryValues',[]);
            addParameter(p,'ValueSetSize','auto');
            addParameter(p,'Complexity','real');
            addParameter(p,'Dimensions',1);
            parse(p,varargin{:});
            r=p.Results;


            obj=obj@fixed.ValueDomain(nt,...
            'PreferBuiltIn',r.PreferBuiltIn,...
            'Intervals',r.Intervals,...
            'ExcludeDenormals',r.ExcludeDenormals,...
            'ExcludeNegativeZero',r.ExcludeNegativeZero);
            obj=obj@fixed.DataSpecificationInterface(...
            'Complexity',r.Complexity,...
            'Dimensions',r.Dimensions);


            obj.SamplingMethod=r.SamplingMethod;
            obj.MandatoryValues=r.MandatoryValues;
            obj.ValueSetSize=r.ValueSetSize;
        end


        function obj=set.SamplingMethod(obj,val)
            validateattributes(val,{'char','string'},{'scalartext'});
            obj.SamplingMethod=validatestring(val,{'disabled','bit-pattern'});
        end

        function obj=set.MandatoryValues(obj,val)
            validateattributes(val,{'numeric','logical','embedded.fi'},{'real'});
            val=fixed.internal.utility.cast(val(:),numerictype(obj.DataTypeStr),obj.IsBuiltIn);
            obj.bMandatoryValues=fixed.internal.utility.unique(val,@customlt);
        end

        function val=get.MandatoryValues(obj)
            val=obj.bMandatoryValues;
        end

        function obj=set.ValueSetSize(obj,val)
            if ischar(val)||isstring(val)
                obj.ValueSetSize=validatestring(val,{'auto','min','max'});
            else
                validateattributes(val,{'numeric'},{'scalar','real','nonnan','positive','finite'});
                obj.ValueSetSize=int32(val);
            end
        end
    end

    methods(Hidden)

        function applyOnRootInport(obj,system,inportNumber)















            warning(message("fixed:datagen:methodToDeprecate",'applyOnRootInport','R2020b'));

            narginchk(1,3);
            validateattributes(obj,{'fixed.DataSpecification'},{'scalar'},1);
            validateattributes(system,{'char','string'},{'scalartext','nonempty'},2);
            validateattributes(inportNumber,{'numeric'},{'scalar','real','integer','positive'},3);


            system=regexprep(system,'\n',' ');
            try
                inport=find_system(system,...
                'SearchDepth','1',...
                'BlockType','Inport',...
                'Port',num2str(inportNumber));
            catch ME
                throw(ME)
            end
            assert(numel(inport)==1,...
            message("fixed:datagen:rootInportNotFound",inportNumber,system));


            inportHandle=get_param(inport{1},'Handle');
            nvPairs=obj.getParamSettingsForRootInport();
            set_param(inportHandle,nvPairs{:},...
            'OutMin','[]','OutMax','[]','Interpolate','off','SampleTime','-1');
        end

        function disp(obj)
            validateattributes(obj,{'fixed.DataSpecification'},{'scalar'});
            visprop=obj.selectPropertiesForDisp;
            dispstr=obj.generateStringForDisp(visprop);
            disp(dispstr);
        end
    end

    methods(Access={...
        ?fixed.DataSpecificationInterface,...
        ?fixed.DataGeneratorEngine,...
        ?matlab.unittest.TestCase})

        function nvPairs=getParamSettingsForRootInport(obj)


            nt=numerictype(obj.DataTypeStr);
            if obj.IsBuiltIn
                dataTypeStr=tostringInternalSlName(nt);
            else
                dataTypeStr=tostringInternalFixdt(nt);
            end
            nvPairs={...
            'OutDataTypeStr',dataTypeStr,...
            'SignalType',obj.Complexity,...
            'PortDimensions',['[',num2str(obj.Dimensions),']']...
            };
        end

        function validateProperties(obj,identifier)



            if nargin==1
                identifier="DataSpecification";
            end


            if isempty(obj.EffectiveIntervals)
                throwAsCaller(MException(...
                message("fixed:datagen:expectedNonEmptyValueDomain",identifier)));
            end


            if strcmp(obj.SamplingMethod,'disabled')&&isempty(obj.MandatoryValues)
                throwAsCaller(MException(...
                message("fixed:datagen:expectedNonEmptyValueSet",identifier)));
            end


            if~isempty(obj.MandatoryValues)
                isValid=contains(obj,obj.MandatoryValues);
                if any(~isValid)
                    throwAsCaller(MException(...
                    message("fixed:datagen:expectedMandatoryValuesInDomain",identifier)));
                end
            end


            if~ischar(obj.ValueSetSize)
                [~,szmin,szmax]=getValueSetSizeInfo(obj);
                if obj.ValueSetSize<szmin||obj.ValueSetSize>szmax
                    throwAsCaller(MException(...
                    message("fixed:datagen:expectedValueSetSizeWithinRange",identifier,szmin,szmax)));
                end
            end
        end

        function[dtstr,isbuiltin]=getDataTypeInfo(obj)



            dtstr=obj.DataTypeStr;
            isbuiltin=obj.IsBuiltIn;
        end

        function[szreq,szmin,szmax]=getValueSetSizeInfo(obj)



            args=getArgumentsForMcosAPI(obj);
            szminmax=fixed.internal.queryValuePoolSizeMinMax(args{:});
            szmin=szminmax(1);
            szmax=szminmax(2);



            if ischar(obj.ValueSetSize)
                switch obj.ValueSetSize
                case 'min'
                    szreq=obj.rectifyValueSetSizeSpec(szminmax,0);
                case 'max'
                    szreq=obj.rectifyValueSetSizeSpec(szminmax,inf);
                otherwise
                    szreq=obj.rectifyValueSetSizeSpec(szminmax,-1);
                end
            else
                szreq=obj.rectifyValueSetSizeSpec(szminmax,obj.ValueSetSize);
            end
        end

        function vs=getValueSet(obj,sz)



            args=getArgumentsForMcosAPI(obj);
            vs=fixed.internal.generateValuePool(args{:},sz);
            vs=removefimath(vs(:));


            if strcmp(obj.DataTypeStr,'boolean')
                vs=logical(vs);
            end
        end
    end

    methods(Access={?matlab.unittest.TestCase})
        function args=getArgumentsForMcosAPI(obj)






            effectiveIntervals=obj.EffectiveIntervals;
            mandatoryValues=obj.MandatoryValues;
            containsNaN=any(isnan(effectiveIntervals));
            opt=struct(...
            'IncludeNaN',containsNaN,...
            'ExcludeNegativeZero',obj.ExcludeNegativeZero,...
            'SamplingMethod',obj.SamplingMethod...
            );
            if containsNaN
                effectiveIntervals(end)=[];
            end
            typedIntervalEnds=quantize(effectiveIntervals,...
            obj.DataTypeStr,'PreferBuiltIn',obj.IsBuiltIn);


            if strcmp(obj.DataTypeStr,'boolean')
                typedIntervalEnds=fi(typedIntervalEnds,0,1,0);
                mandatoryValues=fi(mandatoryValues,0,1,0);
            end
            args={opt,typedIntervalEnds,mandatoryValues};
        end

        function visprop=selectPropertiesForDisp(obj)



            visprop={'DataTypeStr','Intervals'};

            if fixed.internal.type.isAnyFloat(obj.DataTypeStr)

                visprop=[visprop,{'ExcludeDenormals','ExcludeNegativeZero'}];
            end


            visprop=[visprop,{...
            'MandatoryValues',...
            'Complexity','Dimensions'}];
        end

        function dispstr=generateStringForDisp(obj,visprop)


            dispstr=sprintf("  fixed.DataSpecification with properties:\n\n");
            for i=1:numel(visprop)
                isPropertyMandatoryValues=strcmp(visprop{i},'MandatoryValues');
                val=obj.(visprop{i});
                if islogical(val)&&~isPropertyMandatoryValues
                    valstr=string(val);
                else
                    switch class(val)
                    case 'char'
                        valstr=sprintf("'%s'",val);
                    case 'fixed.Interval'
                        if isempty(val)
                            valstr="<empty>";
                        else
                            valstr=strjoin(toDispString(val)," ");
                        end
                    otherwise
                        if isempty(val)
                            valstr="<empty>";
                        else
                            valstr=fixed.internal.utility.num2str(val,'Display');
                            if isPropertyMandatoryValues


                                valstr(fixed.internal.utility.isnegzero(val))="-0";
                            end
                            valstr=strjoin(valstr," ");
                        end
                    end
                end
                dispstr=dispstr+sprintf("%21s: %s\n",visprop{i},valstr);
            end
        end
    end

    methods(Static,Hidden)
        function szrect=rectifyValueSetSizeSpec(szminmax,szspec)



            if szspec>=0
                if szspec<=szminmax(1)
                    szrect=szminmax(1);
                elseif szspec>=szminmax(2)
                    szrect=szminmax(2);
                else
                    szrect=szspec;
                end
            else
                if szminmax(1)==szminmax(2)
                    szrect=szminmax(2);
                else
                    szrect=-1;
                end
            end
            szrect=int32(szrect);
        end

        function props=matlabCodegenNontunableProperties(~)



            props={'SamplingMethod','bMandatoryValues','ValueSetSize'};
        end
    end
end

function b=customlt(x,y)




    if isnan(x)||isnan(y)
        b=~isnan(x)&&isnan(y);
    elseif x==0&&y==0
        b=fixed.internal.utility.isnegzero(x)&&...
        ~fixed.internal.utility.isnegzero(y);
    else
        b=x<y;
    end
end
