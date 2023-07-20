



classdef CodeEmitter<handle


    properties(SetAccess=protected)
        LctSpecInfo legacycode.lct.LCTSpecInfo
    end


    methods




        function this=CodeEmitter(lctObj)

            narginchk(0,1);
            if nargin==1
                this.setLctSpecInfo(lctObj);
            end
        end
    end


    methods(Abstract)
        emit(this,varargin);
    end


    methods(Access=protected)





        function setLctSpecInfo(this,lctObj)
            validateattributes(lctObj,...
            {'legacycode.LCT','legacycode.lct.LCTSpecInfo','struct'},...
            {'nonempty','scalar'},1);

            if isstruct(lctObj)||isa(lctObj,'legacycode.LCT')

                this.LctSpecInfo=legacycode.lct.LCTSpecInfo(lctObj);
            else

                this.LctSpecInfo=lctObj;
            end
        end

    end


    methods(Static)








        apiInfo=getApiInfo(dataSpec,apiKind)






        ptrCastStr=genPtrCastForNDArg(kind,arg1,arg2)








        function linIdx=genSubscripts2Index(subs,dims,isColMajor)
            if nargin<3
                isColMajor=true;
            end


            linIdx='';
            revDimIdx=numel(dims);
            for dimIdx=1:numel(dims)

                if isColMajor
                    idx=revDimIdx;
                else
                    idx=dimIdx;
                end

                if dimIdx==1
                    offset='';
                else
                    if dimIdx>2
                        linIdx=['(',linIdx,')'];%#ok<AGROW>
                    end
                    offset=[linIdx,'*',dims{idx},' + '];
                end


                linIdx=[offset,subs{idx}];
                revDimIdx=revDimIdx-1;
            end
        end
    end
end


