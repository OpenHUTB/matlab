classdef(Sealed)Interval






    properties(SetAccess=private)

        LeftEnd(1,1)embedded.fi{mustBeReal(LeftEnd)}=0

        RightEnd(1,1)embedded.fi{mustBeReal(RightEnd)}=1

        IsLeftClosed(1,1)logical=true

        IsRightClosed(1,1)logical=true
    end

    methods

        function obj=Interval(varargin)












































            numArgIn=nargin;
            if numArgIn>0

                for i=1:numArgIn
                    if~isempty(varargin{i})
                        validateattributes(true(size(varargin{i})),{'logical'},{'vector'},i);
                    end
                end
                if all(cellfun(@iscell,varargin))


                    obj=fixed.Interval(varargin{1}{:});
                    if numArgIn>1
                        outputRow=isrow(obj);
                        for i=2:numArgIn
                            I=fixed.Interval(varargin{i}{:});
                            outputRow=outputRow&&isrow(I);
                            obj=[obj(:);I(:)];
                        end
                        if outputRow
                            obj=obj';
                        end
                    elseif numel(varargin{1})>1&&all(cellfun(@iscell,varargin{1}))
                        if isrow(varargin{1})
                            obj=obj(:)';
                        else
                            obj=obj(:);
                        end
                    end
                elseif~(isnumeric(varargin{1})||islogical(varargin{1}))

                    narginchk(1,1);
                    try
                        nt=fixed.internal.type.extractNumericType(varargin{1});
                    catch ME
                        throw(ME);
                    end
                    obj=fixed.Interval(...
                    fixed.internal.type.minFiniteRepresentableVal(nt),...
                    fixed.internal.type.maxFiniteRepresentableVal(nt));
                    if fixed.internal.type.isAnyFloat(nt)
                        ntName=nt.tostringInternalSlName;
                        ntInf=inf(ntName);
                        ntNaN=nan(ntName);
                        obj=[-ntInf,obj,ntInf,ntNaN];
                    end
                else

                    narginchk(1,6);

                    sz=fixed.internal.utility.accommodatesize(varargin{:});

                    obj=repmat(obj,sz);
                    if~isempty(obj)

                        obj=setProperty(obj,'LeftEnd',varargin{1});
                        if numArgIn==1
                            obj=setProperty(obj,'RightEnd',[obj.LeftEnd]);
                        else
                            obj=setProperty(obj,'RightEnd',varargin{2});
                            if numArgIn==3
                                endNotes=arrayfun(...
                                @(x)validatestring(x,["[]","[)","(]","()"]),...
                                string(varargin{3}));
                                obj=setProperty(obj,'IsLeftClosed',startsWith(endNotes,"["));
                                obj=setProperty(obj,'IsRightClosed',endsWith(endNotes,"]"));
                            elseif numArgIn>3
                                p=inputParser;
                                addParameter(p,'IsLeftClosed',[]);
                                addParameter(p,'IsRightClosed',[]);
                                parse(p,varargin{3:end});
                                props=setdiff(p.Parameters,p.UsingDefaults);
                                for i=1:numel(props)
                                    obj=setProperty(obj,props{i},p.Results.(props{i}));
                                end
                            end


                            obj(arrayfun(@(x)scalarCompareLeftAgainstRight(x,x)>0,obj))=[];

                            isNaN=isnan(obj);
                            obj(isNaN)=repmat(fixed.Interval(nan),size(obj(isNaN)));
                        end
                    end
                end
            end
        end


        function bool=isnan(obj)










            if isempty(obj)
                bool=false(size(obj));
            else
                bool=arrayfun(@scalarIsNaN,obj);
            end
        end

        function bool=isLeftBounded(obj)










            if isempty(obj)
                bool=false(size(obj));
            else
                bool=arrayfun(@scalarIsLeftBounded,obj);
            end
        end

        function bool=isRightBounded(obj)










            if isempty(obj)
                bool=false(size(obj));
            else
                bool=arrayfun(@scalarIsRightBounded,obj);
            end
        end

        function bool=isDegenerate(obj)











            if isempty(obj)
                bool=false(size(obj));
            else
                bool=arrayfun(@scalarIsDegenerate,obj);
            end
        end


        function bool=contains(obj,U)










            if~isa(U,'fixed.Interval')
                U=fixed.Interval(U);
            end

            validateattributes(true(size(obj)),{'logical'},{'vector'},1);
            validateattributes(true(size(U)),{'logical'},{'vector'},2);

            bool=fixed.internal.utility.bsxfun(...
            @(x1,x2)scalarContains(x1,x2),obj,U);
        end

        function bool=overlaps(obj,U)










            if~isa(U,'fixed.Interval')
                U=fixed.Interval(U);
            end

            validateattributes(true(size(obj)),{'logical'},{'vector'},1);
            validateattributes(true(size(U)),{'logical'},{'vector'},2);

            bool=fixed.internal.utility.bsxfun(...
            @(x1,x2)scalarOverlaps(x1,x2),obj,U);
        end


        function Y=unique(obj)










            Y=reduceToVector(obj);
            outputRow=isrow(Y);



            isYNaN=isnan(Y);
            Y(isYNaN)=[];
            hasNaN=any(isYNaN);

            i=numel(Y);
            if~(i<=1||all(arrayfun(@scalarCompareLeftAgainstRight,Y(2:end),Y(1:end-1))>0))






                Y=fixed.internal.utility.sort(Y,@(x1,x2)scalarCompareLeft(x1,x2)<0);
                discard=false([i,1]);
                fmaxr=@(x)fixed.internal.utility.extreme(x,@(x1,x2)scalarCompareRight(x1,x2)>0);
                imaxr=i;
                while i>1
                    if imaxr==i


                        [~,imaxr]=fmaxr(Y(1:i-1));
                    end
                    if scalarCompareLeftAgainstRight(Y(i),Y(imaxr))<=0
                        if scalarCompareRight(Y(i),Y(imaxr))>0
                            Y(imaxr).RightEnd=Y(i).RightEnd;
                            Y(imaxr).IsRightClosed=Y(i).IsRightClosed;
                        end
                        discard(i)=true;
                    end
                    i=i-1;
                end
                Y(discard)=[];
            end

            if hasNaN
                if outputRow
                    Y=[Y,fixed.Interval(nan)];
                else
                    Y=[Y;fixed.Interval(nan)];
                end
            end
        end

        function Y=union(obj,U)












            X=reduceToVector(obj);
            if~isa(U,'fixed.Interval')
                U=fixed.Interval(U);
            end
            U=reduceToVector(U);
            outputRow=isrow(X)&&isrow(U);

            Y=unique([X(:);U(:)]);

            if outputRow
                Y=Y';
            end
        end

        function Y=intersect(obj,U)












            X=reduceToVector(obj);
            if~isa(U,'fixed.Interval')
                U=fixed.Interval(U);
            end
            U=reduceToVector(U);
            outputRow=isrow(X)&&isrow(U);


            X=unique(X(:));
            U=unique(U(:));

            if isempty(X)||isempty(U)

                Y=fixed.Interval(zeros([0,1]));
            else


                xHasNaN=isnan(X(end));
                if xHasNaN
                    X(end)=[];
                end
                uHasNaN=isnan(U(end));
                if uHasNaN
                    U(end)=[];
                end
                hasNaN=xHasNaN&&uHasNaN;


                uox=overlaps(U,X');
                numuox=nnz(uox);
                Y=fixed.Interval(zeros([numuox,1]));
                if numuox>0

                    szy=0;
                    for ix=1:numel(X)
                        numuoxi=nnz(uox(:,ix));
                        if numuoxi>0
                            iy=szy+1;
                            szy=szy+numuoxi;
                            Y(iy:szy)=U(uox(:,ix));
                            if scalarCompareLeft(X(ix),Y(iy))>0
                                Y(iy).LeftEnd=X(ix).LeftEnd;
                                Y(iy).IsLeftClosed=X(ix).IsLeftClosed;
                            end
                            if scalarCompareRight(X(ix),Y(szy))<0
                                Y(szy).RightEnd=X(ix).RightEnd;
                                Y(szy).IsRightClosed=X(ix).IsRightClosed;
                            end
                        end
                    end
                end

                if hasNaN
                    Y=[Y;fixed.Interval(nan)];
                end
            end

            if outputRow
                Y=Y';
            end
        end

        function Y=setdiff(obj,U)












            X=reduceToVector(obj);
            if~isa(U,'fixed.Interval')
                U=fixed.Interval(U);
            end
            U=reduceToVector(U);
            outputRow=isrow(X);


            X=unique(X(:));
            U=unique(U(:));

            if isempty(X)||isempty(U)

                Y=X;
            else


                xHasNaN=isnan(X(end));
                if xHasNaN
                    X(end)=[];
                end
                uHasNaN=isnan(U(end));
                if uHasNaN
                    U(end)=[];
                end
                hasNaN=xHasNaN&&~uHasNaN;


                uox=overlaps(U(:),X(:)');
                numuox=nnz(uox);
                if numuox==0
                    Y=X;
                else

                    Y=[X;U];
                    szy=0;
                    for ix=1:numel(X)
                        numuoxi=nnz(uox(:,ix));
                        if numuoxi==0
                            szy=szy+1;
                            Y(szy)=X(ix);
                        else
                            Uoxi=U(uox(:,ix));
                            if scalarCompareLeft(X(ix),Uoxi(1))<0
                                szy=szy+1;
                                Y(szy).LeftEnd=X(ix).LeftEnd;
                                Y(szy).IsLeftClosed=X(ix).IsLeftClosed;
                                Y(szy).RightEnd=Uoxi(1).LeftEnd;
                                Y(szy).IsRightClosed=~Uoxi(1).IsLeftClosed;
                            end
                            for iuox=1:numuoxi-1
                                szy=szy+1;
                                Y(szy).LeftEnd=Uoxi(iuox).RightEnd;
                                Y(szy).IsLeftClosed=~Uoxi(iuox).IsRightClosed;
                                Y(szy).RightEnd=Uoxi(iuox+1).LeftEnd;
                                Y(szy).IsRightClosed=~Uoxi(iuox+1).IsLeftClosed;
                                if scalarCompareLeftAgainstRight(Y(szy),Y(szy))>0
                                    szy=szy-1;
                                end
                            end
                            if scalarCompareRight(X(ix),Uoxi(numuoxi))>0
                                szy=szy+1;
                                Y(szy).LeftEnd=Uoxi(numuoxi).RightEnd;
                                Y(szy).IsLeftClosed=~Uoxi(numuoxi).IsRightClosed;
                                Y(szy).RightEnd=X(ix).RightEnd;
                                Y(szy).IsRightClosed=X(ix).IsRightClosed;
                            end
                        end
                    end
                    Y(szy+1:end)=[];
                end

                if hasNaN
                    Y=[Y;fixed.Interval(nan)];
                end
            end

            if outputRow
                Y=Y';
            end
        end


        function typedEnds=quantize(obj,nt,varargin)































            narginchk(2,6);
            try
                nt=fixed.internal.type.extractNumericType(nt);
            catch ME
                throw(ME);
            end
            assert(~nt.isscalingunspecified,...
            message("fixed:valuedomain:expectedSpecifiedScaling"));
            p=inputParser;
            addParameter(p,'PreferBuiltIn',true,...
            @(x)validateattributes(x,{'numeric','logical'},{'scalar'}));
            addParameter(p,'PreferStrict',false,...
            @(x)validateattributes(x,{'numeric','logical'},{'scalar'}));
            parse(p,varargin{:});
            r=p.Results;


            Itype=fixed.Interval(nt.tostringInternalSlName);
            Ivalid=intersect(obj(:),Itype(:));



            if isempty(Ivalid)
                typedEnds=fixed.internal.utility.cast(zeros(0,2),nt,r.PreferBuiltIn);
            else
                hasNaN=isnan(Ivalid(end));
                if hasNaN
                    Ivalid(end)=[];
                end

                [leftEnd,rightEnd,success]=arrayfun(@(x)...
                scalarQuantize(x,nt,r.PreferBuiltIn,r.PreferStrict),Ivalid);

                if~any(success)
                    typedEnds=fixed.internal.utility.cast(zeros(0,2),nt,r.PreferBuiltIn);
                else
                    typedEnds=[leftEnd(success),rightEnd(success)];
                end

                if hasNaN
                    typedEnds=[typedEnds;
                    fixed.internal.utility.cast([nan,nan],nt,r.PreferBuiltIn)];
                end
            end
        end


        function disp(obj)



            notation=toDispString(obj);
            if isscalar(notation)
                notation=sprintf("    %s\n\n",notation);
            else
                notation=regexprep(evalc('disp(notation)'),'"','');
            end


            sz=size(obj);
            dimstr=strjoin(string(sz),'x');
            structure=sprintf("  %s fixed.Interval with properties:\n\n",dimstr);
            if isscalar(obj)
                structure=structure+sprintf(repmat('%21s: %s\n',[1,4]),...
                "LeftEnd",fixed.internal.utility.num2str(obj.LeftEnd,'Display'),...
                "RightEnd",fixed.internal.utility.num2str(obj.RightEnd,'Display'),...
                "IsLeftClosed",string(obj.IsLeftClosed),...
                "IsRightClosed",string(obj.IsRightClosed));
            else
                structure=structure+sprintf(repmat('%21s\n',[1,4]),...
                "LeftEnd",...
                "RightEnd",...
                "IsLeftClosed",...
                "IsRightClosed");
            end


            fprintf("%s%s",notation,structure);
        end
    end

    methods(Hidden)
        function str=toDispString(obj)
            if isempty(obj)
                str=string(zeros(size(obj)));
            else
                str=arrayfun(@scalarToDispString,obj);
            end
        end
    end

    methods(Hidden,Static)
        function I=denormal(ntName)
            narginchk(1,1);
            ntName=validatestring(ntName,{'double','single','half'});
            ntZero=cast(0,ntName);
            switch ntName
            case 'half'
                ntRealmin=half.realmin;
            otherwise
                ntRealmin=realmin(ntName);
            end
            I=fixed.Interval({-ntRealmin,ntZero,'()'},{ntZero,ntRealmin,'()'});
        end
    end

    methods(Access=?matlab.unittest.TestCase)
        function obj=setProperty(obj,prop,val)





            try
                if numel(obj)<=1

                    obj=scalarSetProperty(obj,prop,val);
                elseif isscalar(val)

                    obj(:)=arrayfun(@(x)scalarSetProperty(x,prop,val),obj);
                else

                    obj(:)=arrayfun(@(x1,x2)scalarSetProperty(x1,prop,x2),obj,reshape(val,size(obj)));
                end
            catch ME
                throwAsCaller(ME);
            end
        end

        function obj=scalarSetProperty(obj,prop,val)
            if isnumeric(val)
                if~isfi(val)

                    if strcmp(class(val),'half')%#ok

                        val=fi(single(val),numerictype('single'));
                    else
                        val=fi(val,fixed.internal.type.extractNumericType(val));
                    end
                end
            end
            obj.(prop)=val;
        end

        function bool=scalarIsNaN(obj)
            bool=isnan(obj.LeftEnd)||isnan(obj.RightEnd);
        end

        function bool=scalarIsLeftBounded(obj)
            bool=~(isnan(obj.LeftEnd)||(isinf(obj.LeftEnd)&&obj.LeftEnd<0));
        end

        function bool=scalarIsRightBounded(obj)
            bool=~(isnan(obj.RightEnd)||(isinf(obj.RightEnd)&&obj.RightEnd>0));
        end

        function rel=scalarCompareLeft(obj,u)







            if isnan(obj.LeftEnd)||isnan(u.LeftEnd)
                rel=nan;
            elseif obj.LeftEnd<u.LeftEnd
                rel=-1;
            elseif obj.LeftEnd>u.LeftEnd
                rel=1;
            else
                rel=u.IsLeftClosed-obj.IsLeftClosed;
            end
        end

        function rel=scalarCompareRight(obj,u)







            if isnan(obj.RightEnd)||isnan(u.RightEnd)
                rel=nan;
            elseif obj.RightEnd<u.RightEnd
                rel=-1;
            elseif obj.RightEnd>u.RightEnd
                rel=1;
            else
                rel=obj.IsRightClosed-u.IsRightClosed;
            end
        end

        function rel=scalarCompareLeftAgainstRight(obj,u)







            if isnan(obj.LeftEnd)||isnan(u.RightEnd)
                rel=nan;
            elseif obj.LeftEnd<u.RightEnd
                rel=-1;
            elseif obj.LeftEnd>u.RightEnd
                rel=1;
            else
                rel=1-(obj.IsLeftClosed&&u.IsRightClosed);
            end
        end

        function rel=scalarCompareRightAgainstLeft(obj,u)







            rel=-scalarCompareLeftAgainstRight(u,obj);
        end

        function bool=scalarIsDegenerate(obj)
            bool=scalarCompareLeftAgainstRight(obj,obj)==0;
        end

        function bool=scalarContains(obj,u)
            bool=(scalarIsNaN(obj)&&scalarIsNaN(u))||(...
            scalarCompareLeft(obj,u)<=0&&...
            scalarCompareRight(obj,u)>=0);
        end

        function bool=scalarOverlaps(obj,u)
            bool=(scalarIsNaN(obj)&&scalarIsNaN(u))||(...
            scalarCompareLeftAgainstRight(obj,u)<=0&&...
            scalarCompareRightAgainstLeft(obj,u)>=0);
        end

        function[leftend,rightend,success]=scalarQuantize(obj,nt,preferBuiltIn,preferStrict)


            if ishalf(nt)
                orgLeftEnd=double(obj.LeftEnd);
                orgRightEnd=double(obj.RightEnd);
            else
                orgLeftEnd=obj.LeftEnd;
                orgRightEnd=obj.RightEnd;
            end


            leftend=fixed.internal.utility.cast(obj.LeftEnd,nt,preferBuiltIn);
            if(~obj.IsLeftClosed&&leftend<=orgLeftEnd)...
                ||(preferStrict&&leftend<orgLeftEnd)
                [leftend,~]=fixed.internal.math.nextFiniteRepresentable(leftend);
            end


            rightend=fixed.internal.utility.cast(obj.RightEnd,nt,preferBuiltIn);
            if(~obj.IsRightClosed&&rightend>=orgRightEnd)...
                ||(preferStrict&&rightend>orgRightEnd)
                [rightend,~]=fixed.internal.math.prevFiniteRepresentable(rightend);
            end


            success=leftend<=rightend;
        end

        function str=scalarToDispString(obj)



            if scalarIsDegenerate(obj)||scalarIsNaN(obj)
                str="["+fixed.internal.utility.num2str(obj.LeftEnd,'Display')+"]";
            else
                midstr=fixed.internal.utility.num2str(obj.LeftEnd,'Display')+...
                ","+fixed.internal.utility.num2str(obj.RightEnd,'Display');
                switch 2*obj.IsLeftClosed+obj.IsRightClosed
                case 0
                    str="("+midstr+")";
                case 1
                    str="("+midstr+"]";
                case 2
                    str="["+midstr+")";
                otherwise
                    str="["+midstr+"]";
                end
            end
        end
    end
end

function arg=reduceToVector(arg)
    if~(isempty(arg)||isvector(arg))
        arg=arg(:);
    end
end
