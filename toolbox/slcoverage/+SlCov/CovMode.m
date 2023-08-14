



classdef(Enumeration)CovMode<uint32

    enumeration
        Normal(0)
        Accel(1)
        RapidAccel(2)
        SIL(3)
        PIL(4)
        ModelRefAccel(5)
        ModelRefSIL(6)
        ModelRefPIL(7)
        Mixed(8)
        Unknown(9)
        SFunction(10)
        SFCustomCode(11)
        ModelRefTopSIL(12)
        ModelRefTopPIL(13)
        SLCustomCode(14)
    end

    methods



        function out=eq(this,rhs)
            try
                out=uint32(this)==uint32(SlCov.CovMode.fromString(rhs));
            catch Me
                throwAsCaller(Me)
            end
        end




        function out=ne(this,rhs)
            try
                out=uint32(this)~=uint32(SlCov.CovMode.fromString(rhs));
            catch Me
                throwAsCaller(Me)
            end
        end
    end

    methods(Static,Hidden)




        function values=getSupportedValues()
            values=[0,1,3,4,6:8,10:14];
        end




        function values=getApiSupportedValues()
            values=[0,1,8,SlCov.CovMode.getGeneratedCodeValues()];
        end





        function values=getGeneratedCodeValues()
            values=[3,4,6,7,12,13];
        end




        function values=getSILValues()
            values=[3,6,12];
        end




        function values=getPILValues()
            values=[4,7,13];
        end




        function state=isSupported(obj)
            validateattributes(obj,{'SlCov.CovMode','numeric'},{'nonempty','>=',0,'<=',13},1);

            state=false(size(obj));
            for ii=1:numel(obj)
                if isnumeric(obj(ii))
                    val=SlCov.CovMode(obj(ii));
                else
                    val=obj(ii);
                end
                state(ii)=ismember(val,SlCov.CovMode.getSupportedValues());
            end
        end




        function str=toString(obj)
            if ischar(obj)||isstring(obj)
                validateattributes(obj,{'char','string'},{'nonempty','scalartext'},1);
                obj=char(obj);
            else
                validateattributes(obj,{'SlCov.CovMode','numeric'},{'nonempty'},1);
            end

            if~isa(obj,'SlCov.CovMode')
                obj=SlCov.CovMode(obj);
            end

            if numel(obj)==1
                str=char(obj);
            else
                str=cell(size(obj));
                for ii=1:numel(obj)
                    str{ii}=char(obj(ii));
                end
            end
        end




        function obj=fromString(str,varargin)

            if isa(str,'SlCov.CovMode')
                obj=str;
                return
            elseif isnumeric(str)
                obj=SlCov.CovMode(str);
                return
            end

            if ischar(str)||isstring(str)
                str={str};
            end

            if iscell(str)
                for ii=1:numel(str)
                    validateattributes(str{ii},{'char','string'},{'nonempty','scalartext'},1);
                    str{ii}=char(str{ii});
                end
            end

            str=cellstr(str);

            allowedStr=SlCov.CovMode.getAllowedStrings(varargin{:});

            obj=repmat(SlCov.CovMode(0),size(str));
            for ii=1:numel(str)
                val=str{ii};
                if val=="DV_SIMMODE_NORMAL"
                    val='Normal';
                elseif val=="DV_SIMMODE_SIL"
                    val='SIL';
                elseif val=="DV_SIMMODE_REFSIL"
                    val='ModelRefSIL';
                end
                val=validatestring(val,allowedStr,1);
                obj(ii)=eval(['SlCov.CovMode.',val]);
            end
        end




        function str=getAllowedStrings(forApi)
            persistent ALL_ALLOWED_STR;
            persistent API_ALLOWED_STR;
            if isempty(ALL_ALLOWED_STR)||isempty(API_ALLOWED_STR)
                mc=metaclass(SlCov.CovMode.Normal);
                strs={mc.EnumerationMemberList.Name};
                [~,idx]=unique(lower(strs),'stable');
                ALL_ALLOWED_STR=strs(idx);
                objs=SlCov.CovMode(SlCov.CovMode.getApiSupportedValues());
                API_ALLOWED_STR=cell(1,numel(objs));
                for ii=1:numel(objs)
                    API_ALLOWED_STR{ii}=char(objs(ii));
                end
            end
            if nargin<1||~forApi
                str=ALL_ALLOWED_STR;
            else
                str=API_ALLOWED_STR;
            end
        end




        function res=isGeneratedCode(obj)
            if isempty(obj)
                res=false;
                return
            end

            if ischar(obj)||isstring(obj)
                obj=SlCov.CovMode.fromString(obj);
            elseif isa(obj,'internal.polyspace.codecov.CovMode')
                obj=SlCov.CovMode(uint32(obj));
            else
                obj=SlCov.CovMode(obj);
            end

            res=ismember(obj,SlCov.CovMode.getGeneratedCodeValues());
        end




        function res=isNormal(obj)
            if ischar(obj)||isstring(obj)
                validateattributes(obj,{'char','string'},{'nonempty','scalartext'},1);
            else
                validateattributes(obj,{'SlCov.CovMode','numeric'},{'nonempty'},1);
                if isnumeric(obj)
                    obj=SlCov.CovMode(obj);
                end
                obj=char(obj);
            end
            res=obj=="DV_SIMMODE_NORMAL"||obj=="Normal";
        end






        function res=isXIL(obj,refOnly)
            if nargin<2
                refOnly=false;
            end
            res=SlCov.CovMode.isSIL(obj,refOnly)||SlCov.CovMode.isPIL(obj,refOnly);
        end






        function res=isSIL(obj,refOnly)
            if nargin<2
                refOnly=false;
            end
            if isempty(obj)
                res=false;
                return
            end

            if ischar(obj)||(isstring(obj)&&numel(obj)==1)
                if obj=="DV_SIMMODE_SIL"
                    res=~refOnly;
                    return
                elseif obj=="DV_SIMMODE_REFSIL"
                    res=true;
                    return
                elseif obj=="DV_SIMMODE_NORMAL"
                    res=false;
                    return
                end
                obj=SlCov.CovMode.fromString(obj);
            else
                obj=SlCov.CovMode(obj);
            end

            if refOnly
                res=obj==SlCov.CovMode.ModelRefSIL;
            else
                res=ismember(obj,SlCov.CovMode.getSILValues());
            end

        end






        function res=isPIL(obj,refOnly)
            if nargin<2
                refOnly=false;
            end
            if isempty(obj)
                res=false;
                return
            end

            if ischar(obj)||(isstring(obj)&&numel(obj)==1)
                if obj=="DV_SIMMODE_NORMAL"
                    res=false;
                    return
                end
                obj=SlCov.CovMode.fromString(obj);
            else
                obj=SlCov.CovMode(obj);
            end

            if refOnly
                res=obj==SlCov.CovMode.ModelRefPIL;
            else
                res=ismember(obj,SlCov.CovMode.getPILValues());
            end

        end




        function str=toDescription(obj)
            if ischar(obj)||isstring(obj)
                validateattributes(obj,{'char','string'},{'nonempty','scalartext'},1);
            else
                validateattributes(obj,{'SlCov.CovMode','numeric'},{'nonempty'},1);
            end

            if~isa(obj,'SlCov.CovMode')
                obj=SlCov.CovMode(obj);
            end

            if numel(obj)==1
                switch obj
                case SlCov.CovMode.SIL
                    str='Software-in-the-loop (SIL)';
                case SlCov.CovMode.ModelRefSIL
                    str='Model reference Software-in-the-loop (SIL)';
                case SlCov.CovMode.PIL
                    str='Processor-in-the-loop (PIL)';
                case SlCov.CovMode.ModelRefPIL
                    str='Model reference Processor-in-the-loop (PIL)';
                otherwise
                    str=char(obj);
                end
            else
                str=cell(size(obj));
                for ii=1:numel(obj)
                    str{ii}=SlCov.CovMode.toDescription(obj(ii));
                end
            end
        end




        function str=toShortDescription(obj)
            if ischar(obj)||isstring(obj)
                validateattributes(obj,{'char','string'},{'nonempty','scalartext'},1);
            else
                validateattributes(obj,{'SlCov.CovMode','numeric'},{'nonempty'},1);
            end

            if~isa(obj,'SlCov.CovMode')
                obj=SlCov.CovMode(obj);
            end

            if numel(obj)==1
                switch obj
                case{SlCov.CovMode.SIL,SlCov.CovMode.ModelRefSIL}
                    str=getString(message('Slvnv:simcoverage:cvmodelview:LabelSILShort'));
                case{SlCov.CovMode.PIL,SlCov.CovMode.ModelRefPIL}
                    str=getString(message('Slvnv:simcoverage:cvmodelview:LabelSILShort'));
                case SlCov.CovMode.Normal
                    str=getString(message('Slvnv:simcoverage:cvmodelview:LabelNormalShort'));
                otherwise
                    str=char(obj);
                end
            else
                str=cell(size(obj));
                for ii=1:numel(obj)
                    str{ii}=SlCov.CovMode.toDescription(obj(ii));
                end
            end
        end




        function str=toSimulationMode(obj)
            if ischar(obj)||isstring(obj)
                validateattributes(obj,{'char','string'},{'nonempty','scalartext'},1);
            else
                validateattributes(obj,{'SlCov.CovMode','numeric'},{'nonempty'},1);
            end

            if~isa(obj,'SlCov.CovMode')
                obj=SlCov.CovMode(obj);
            end

            if numel(obj)==1
                switch obj
                case{SlCov.CovMode.SIL,SlCov.CovMode.ModelRefSIL}
                    str='Software-in-the-loop (SIL)';
                case{SlCov.CovMode.PIL,SlCov.CovMode.ModelRefPIL}
                    str='Processor-in-the-loop (PIL)';
                case{SlCov.CovMode.Accel,SlCov.CovMode.ModelRefAccel}
                    str='Accelerator';
                case SlCov.CovMode.RapidAccel
                    str='Rapid-Accelerator';
                otherwise
                    str='Normal';
                end
            else
                str=cell(size(obj));
                for ii=1:numel(obj)
                    str{ii}=SlCov.CovMode.toSimulationMode(obj(ii));
                end
            end
        end





        function obj=fixTopMode(obj)
            if obj==SlCov.CovMode.ModelRefTopSIL
                obj=SlCov.CovMode.SIL;
            elseif obj==SlCov.CovMode.ModelRefTopPIL
                obj=SlCov.CovMode.PIL;
            end
        end
    end
end
