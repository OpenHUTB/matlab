classdef(SupportClassFunctions=true)AllParameters<...
    matlab.mixin.CustomDisplay&rf.internal.netparams.Interface










    properties(Dependent,SetAccess=protected)
NumPorts
    end
    properties(Dependent)

Parameters
Frequencies
    end


    properties(Access=protected)
StoredData
    end
    properties(Abstract,Constant,Access=protected)
CanAcceptImpedanceInput
TypeFlag
    end
    properties(Constant,Hidden)
        DefaultImpedance=50
    end


    methods
        function outobj=AllParameters(inobj,varargin)

            if~isdeployed&&~(builtin('license','test','RF_Toolbox')||...
                builtin('license','test','Antenna_Toolbox'))

                error(message('rflib:shared:NetParamConvert'))
            end


            if ischar(inobj)
                narginchk(1,1)

                if~isdeployed&&~(builtin('license','checkout','RF_Toolbox'))
                    error(message('rflib:shared:ReadRFFileNoRFTbxLicense',class(inobj)))
                end


                inobj=outobj.readRFFile(inobj);
            end


            if isa(inobj,'rf.internal.netparams.AllParameters')
                narginchk(1,1+outobj.CanAcceptImpedanceInput)
                if nargin==1
                    varargin={getDefaultInputImpedance(inobj)};
                end
                inobj=convertImpedance(inobj,varargin{:});
            end

            if isa(inobj,'rf.internal.netparams.Interface')


                validateattributes(inobj,{class(inobj)},...
                {'nonempty','scalar'},class(outobj),'',1)
                narginLimits=inobj.NetworkParameterNarginchkInputs;
                narginchk(narginLimits(1),narginLimits(2))
                [str,data,freq,z0]=networkParameterInfo(inobj,varargin{:});
                data=outobj.convert2me(str,data,z0);
            elseif isnumeric(inobj)

                narginchk(2,2+outobj.CanAcceptImpedanceInput)
                data=inobj;
                freq=varargin{1};
                if nargin>2
                    z0=varargin{2};
                else
                    z0=outobj.DefaultImpedance;
                end
            else

                error(message('MATLAB:UndefinedFunctionTextInputArgumentsType',class(outobj),class(inobj)))
            end

            outobj=assignProperties(outobj,data,freq,z0);
        end
    end


    methods
        function obj=set.Frequencies(obj,newFreq)
            pair=obj.StoredData;
            pair{2}=newFreq;
            obj.StoredData=pair;
        end

        function obj=set.Parameters(obj,newParam)
            pair=obj.StoredData;
            pair{1}=newParam;
            obj.StoredData=pair;
        end

        function obj=set.StoredData(obj,newPair)
            if isvector(newPair{1})






                temp(1,1,:)=newPair{1};
                newPair{1}=temp;
            end
            obj.validateParameters(newPair{1})
            rf.internal.checkfreq(newPair{2})
            newPair{2}=newPair{2}(:);


            validateattributes(newPair{1},{'numeric'},...
            {'size',[NaN,NaN,numel(newPair{2})]},...
            class(obj),'Parameters')

            obj.StoredData=newPair;
        end
    end


    methods
        function f=get.Frequencies(obj)
            f=obj.StoredData{2};
        end

        function p=get.Parameters(obj)
            p=obj.StoredData{1};
        end

        function np=get.NumPorts(obj)
            np=size(obj.Parameters,1);
        end
    end


    methods
        data=rfparam(obj,m,n)
    end


    methods(Hidden)
        fileobj=readRFFile(obj,filename)
    end


    methods(Access=protected)
        function group=getPropertyGroups(obj)
            if isscalar(obj)
                plist1=buildScalarPropertyList(obj);
            else
                plist1=obj.buildNonScalarPropertyList;
            end

            group=matlab.mixin.util.PropertyGroup(plist1);
        end

        function plist1=buildScalarPropertyList(obj)
            plist1=struct('NumPorts',obj.NumPorts,...
            'Frequencies',obj.Frequencies,...
            'Parameters',obj.Parameters);
        end

        function str=getHeader(obj)
            if isscalar(obj)
                link=matlab.mixin.CustomDisplay.getClassNameForHeader(obj);
                str=sprintf('  %s: %s-parameters object\n',...
                link,obj.TypeFlag);
            else
                str=getHeader@matlab.mixin.CustomDisplay(obj);
            end
        end

        function str=getFooter(obj)
            if isscalar(obj)
                str=sprintf('  %s%s\n',...
                rf.internal.makehelplinkstr('rfparam'),...
                customFooter(obj));
            else
                str=getFooter@matlab.mixin.CustomDisplay(obj);
            end
        end

        function str=customFooter(obj)
            str=sprintf('(obj,i,j) returns %s-parameter %sij',...
            obj.TypeFlag,obj.TypeFlag);
        end
    end
    methods(Access=protected,Static)
        function plist1=buildNonScalarPropertyList
            plist1={'NumPorts','Frequencies','Parameters'};
        end
    end


    methods(Access=protected)
        function obj=assignProperties(obj,varargin)
            obj.StoredData=varargin(1:2);
        end

        function str=calculateLegendText(obj,row,col)
            if row>9||col>9
                comma=',';
            else
                comma='';
            end
            str=sprintf('%s_{%d%s%d}',obj.TypeFlag,row,comma,col);
        end
    end


    methods(Abstract,Static,Access=protected)
        validateParameters(newParam,objclass)
        outobj=convertImpedance(inobj,newZ0)
        outdata=convert2me(str,indata,z0)
    end
    methods(Abstract,Access=protected)
        z0=getDefaultInputImpedance(obj)
    end
    methods(Abstract,Static,Hidden)
        outobj=loadobj(in)
    end


    properties(Constant,Hidden)
        NetworkParameterNarginchkInputs=[1,2]
    end

    methods(Access=protected)
        function[str,data,freq,z0]=networkParameterInfo(obj,varargin)
            str=obj.TypeFlag;
            data=obj.Parameters;
            freq=obj.Frequencies;
            z0=varargin{1};
        end
    end
end
