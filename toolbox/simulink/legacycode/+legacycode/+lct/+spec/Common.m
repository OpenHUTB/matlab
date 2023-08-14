














































classdef Common<handle


    properties(Constant,Access=public)

        Radixes={'y','u','p','work','dsm','expr'}


        Roles={'Output','Input','Parameter','DWork','DSM','ExprArg'}


        Radix2RoleMap=containers.Map(...
        legacycode.lct.spec.Common.Radixes,...
        legacycode.lct.spec.Common.Roles)


        Role2RadixMap=containers.Map(...
        legacycode.lct.spec.Common.Roles,...
        legacycode.lct.spec.Common.Radixes)


        FunKinds={'InitializeConditions','Start','Output','Terminate'}


        LctErrIdRadix='Simulink:tools:LCT'

        SLVer=ver('simulink')
    end


    properties(SetAccess=private)
NameExpr
FunNameExpr
TypeNameExpr
ArgNameExpr
SizeFunExpr
NumelFunExpr
PvalExpr
SizeExpr
DimSizeExpr
SpecExpr
ArgSpecExpr
DimSpecExpr
    end


    methods(Access=protected)




        function this=Common()


            this.NameExpr='[a-zA-Z]\w*';


            this.FunNameExpr='[a-zA-Z_]\w*';


            this.TypeNameExpr=[this.NameExpr,'|complex\s*<\s*',this.NameExpr,'\s*>'];


            this.ArgNameExpr='(?:[yup]|work|dsm)\d+';


            this.SizeFunExpr=['size\s*\(\s*',this.ArgNameExpr,'\s*,\s*\d+\s*\)'];


            this.NumelFunExpr=['numel\s*\(\s*',this.ArgNameExpr,'\s*\)'];


            this.PvalExpr='p\d+';


            this.SizeExpr=['\s|inf|Inf|',this.PvalExpr,'|',this.SizeFunExpr,'|',this.NumelFunExpr,'|[\.*/+-\d\(\)]'];


            this.DimSpecExpr=['(?:\s*\[(?:(',this.SizeExpr,')|[^[]].*?)*\]\s*){0,}'];


            this.ArgSpecExpr=[...
            '\s*(',this.TypeNameExpr,')\s+(',this.ArgNameExpr,')\s*(',this.DimSpecExpr,')\s*',...
            '|',...
            '\s*(void)((?:\s*\*\s*){0,})\s*(',this.ArgNameExpr,')\s*',...
            '|',...
            '\s*(',this.TypeNameExpr,')\s+((?:',this.SizeExpr,')|(?:.*^,?))+\s*'...
            ];


            lhsExpr=['(',this.TypeNameExpr,')\s+(',this.ArgNameExpr,')'];
            this.SpecExpr=[...
            '\s*(void|',lhsExpr,')?',...
            '\s*(=)?\s*',...
            '(',this.FunNameExpr,')\s*',...
            '\(\s*(.*)\s*\)',...
'\s*;?\s*'...
            ];
        end

    end


    methods



        function throwError(~,varargin)
            legacycode.lct.spec.Common.error(varargin{:});
        end
    end


    methods(Static)





        function[outStr,numS,numE]=remWhiteSpaces(inStr,remTrailing)
            narginchk(1,2);
            if nargin<2
                remTrailing=true;
            end
            outStr=inStr;
            numS=0;
            numE=0;
            if~isempty(inStr)
                outStr=regexprep(inStr,'^\s*(.*?)','$1');
                numS=numel(inStr)-numel(outStr);
                if remTrailing&&~isempty(outStr)
                    str=regexprep(outStr,'(.*?)\s*$','$1');
                    numE=numel(outStr)-numel(str);
                    outStr=str;
                end
            end
        end




        function error(id,specStr,numS,numT,varargin)


            narginchk(2,nargin);
            validateattributes(specStr,{'char','string'},{'scalartext'},2);
            specStr=char(specStr);

            if isa(id,'legacycode.lct.spec.ParseException')


                validateattributes(id,{'legacycode.lct.spec.ParseException'},{'scalar','nonempty'},1);


                [expr,numS]=legacycode.lct.spec.Common.remWhiteSpaces(id.Expr);
                numS=numS+id.PosOffset-1;
                numT=numel(expr);
                errId=id.OrigId;
                extraArgs=id.ExtraArgs;

            else

                validateattributes(id,{'char','string'},{'scalartext'},1);
                errId=char(id);


                if nargin<5
                    varargin={};
                end
                if nargin<4||isempty(numS)
                    numT=0;
                end
                if nargin<3||isempty(numT)
                    numS=0;
                end

                extraArgs=varargin;
            end


            for ii=1:numel(extraArgs)
                if isa(extraArgs{ii},'message')
                    extraArgs{ii}=getString(extraArgs{ii});
                end
            end


            desc=legacycode.lct.spec.Common.genSpecAnnotation(specStr,numS,numT);
            throw(MException(message(['Simulink:tools:',errId],desc,extraArgs{:})));
        end




        function desc=genSpecAnnotation(specStr,numS,numT)


            narginchk(1,nargin);
            validateattributes(specStr,{'char','string'},{'scalartext'},1);

            if nargin<3
                numT=0;
            end
            if nargin<2
                numS=0;
            end



            numT(numel(numT)+1:numel(numS))=0;


            startStr='--> ';
            funSpec=[startStr,specStr];
            annot=repmat(' ',1,numel(startStr));
            for ii=1:numel(numS)
                annot=[annot,repmat(' ',1,numS(ii)),repmat('^',1,numT(ii))];%#ok<AGROW>
            end
            annot(end+1:numel(funSpec))=' ';

            if desktop('-inuse')
                desc=[];
                lastOpened=false;
                for ii=1:numel(funSpec)
                    if annot(ii)==' '&&lastOpened
                        lastOpened=false;
                        desc=[desc,'</a>'];%#ok<AGROW>
                    elseif annot(ii)=='^'&&~lastOpened
                        lastOpened=true;
                        desc=[desc,'<a href="matlab:doc(''legacy_code'')" style="font-weight:bold">'];%#ok<AGROW>
                    end
                    desc(end+1)=funSpec(ii);%#ok<AGROW>
                end
                if lastOpened
                    desc=[desc,'</a>'];
                end
            else
                desc=sprintf('%s\n%s',funSpec,annot);
            end
        end





        function[radix,idx]=splitIdentifier(id)


            persistent regExpr
            if isempty(regExpr)
                regExpr=['^(',strjoin(legacycode.lct.spec.Common.Radixes,'|'),')(\d+)$'];
            end


            radix='';
            idx=-1;

            if~isempty(id)&&(ischar(id)||(isstring(id)&&isscalar(id)))

                id=strtrim(char(id));
                tok=regexpi(id,regExpr,'tokens');


                if~isempty(tok)
                    radix=lower(tok{1}{1});
                    idx=sscanf(tok{1}{2},'%d');
                end
            end
        end




        function obj=instance()


            persistent singleObj
            if isempty(singleObj)
                singleObj=legacycode.lct.spec.Common();
            end

            obj=singleObj;
        end
    end

end


