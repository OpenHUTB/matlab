




classdef CodeCovDataGroup<codeinstrum.internal.codecov.CodeCovDataGroup

    methods



        function this=CodeCovDataGroup(varargin)
            this@codeinstrum.internal.codecov.CodeCovDataGroup();

            if nargin==1&&isa(varargin{1},'SlCov.results.CodeCovDataGroup')
                this=varargin{1};
                return
            end

            for idx=1:nargin
                arg=varargin{idx};
                validateattributes(arg,...
                {'SlCov.results.CodeCovData'},{'scalar'},'SlCov.results.CodeCovDataGroup','',idx);
                add(this,arg);
            end

        end




        function res=plus(lhs,rhs)
            validateattributes(rhs,{'SlCov.results.CodeCovDataGroup'},{'scalar'},'SlCov.results.CodeCovDataGroup.plus','',2);

            res=SlCov.results.CodeCovDataGroup.performOp(lhs,rhs,'+');
        end




        function res=minus(lhs,rhs)
            validateattributes(rhs,{'SlCov.results.CodeCovDataGroup'},{'scalar'},'SlCov.results.CodeCovDataGroup.minus','',2);

            res=SlCov.results.CodeCovDataGroup.performOp(lhs,rhs,'-');
        end




        function res=times(lhs,rhs)
            validateattributes(rhs,{'SlCov.results.CodeCovDataGroup'},{'scalar'},'SlCov.results.CodeCovDataGroup.times','',2);

            res=SlCov.results.CodeCovDataGroup.performOp(lhs,rhs,'*');
        end




        function res=mtimes(lhs,rhs)
            res=times(lhs,rhs);
        end




        function refreshModelCovIds(this,covdata)
            names=this.allNames();
            for ii=1:numel(names)
                resObj=this.Data(names{ii});
                resObj.refreshModelCovIds(covdata);
            end
        end




        function setCovData(this,covdata)
            names=this.allNames();
            for ii=1:numel(names)
                resObj=this.Data(names{ii});
                resObj.setCovData(covdata);
            end
        end




        function ver=cvDbVersion(this)
            ver='';
            cvds=this.Data.values();
            if~isempty(cvds)

                ver=cvds{1}.CvDbVersion;
            end
        end
    end

    methods(Access=protected)



        function performOpExtraOp(this,lhs,rhs)%#ok

            if isa(lhs,'SlCov.results.CodeCovDataGroup')&&isa(rhs,'SlCov.results.CodeCovDataGroup')
                this.FilteredInstances=union(lhs.FilteredInstances,rhs.FilteredInstances);
            elseif isa(lhs,'SlCov.results.CodeCovDataGroup')
                this.FilteredInstances=lhs.FilteredInstances;
            elseif isa(rhs,'SlCov.results.CodeCovDataGroup')
                this.FilteredInstances=rhs.FilteredInstances;
            end
        end
    end

    methods(Static)



        function res=performOp(lhs,rhs,opStr)
            res=performOp@codeinstrum.internal.codecov.CodeCovDataGroup(lhs,rhs,opStr,'SlCov.results.CodeCovDataGroup');
        end
    end
    methods(Static,Hidden)





        function outStr=toBase64(obj)
            validateattributes(obj,{'SlCov.results.CodeCovDataGroup'},{'scalar'},'SlCov.results.CodeCovDataGroup.toBase64','',1);
            outStr=char(matlab.internal.crypto.base64Encode(getByteStreamFromArray(obj)));
        end





        function obj=fromBase64(inStr)
            inStr=convertStringsToChars(inStr);
            validateattributes(inStr,{'char','uint8'},{'row'},'SlCov.results.CodeCovData.fromBase64','',1);
            if~ischar(inStr)
                inStr=char(inStr);
            end
            obj=getArrayFromByteStream(matlab.internal.crypto.base64Decode(string(inStr)));
        end






        function outStr=toBase64Old(obj)

            validateattributes(obj,{'SlCov.results.CodeCovDataGroup'},{'scalar'},'SlCov.results.CodeCovDataGroup.toBase64','',1);

            outStr=[];




            tmpFile=[tempname,'.mat'];
            codeCovDataGroupObj=obj;
            save(tmpFile,'codeCovDataGroupObj');
            if~isempty(dir(tmpFile))
                fid=fopen(tmpFile,'rb');
                clrObj=onCleanup(@()tmpOpenedFileClean(tmpFile,fid));
                if fid~=-1
                    fc=fread(fid,inf,'*uint8')';
                    outStr=char(matlab.internal.crypto.base64Encode(fc));
                end
            end
        end






        function obj=fromBase64Old(inStr)

            inStr=convertStringsToChars(inStr);

            validateattributes(inStr,{'char','uint8'},{'row'},'SlCov.results.CodeCovDataGroup.fromBase64','',1);
            if~ischar(inStr)
                inStr=char(inStr);
            end



            tmpFile=[tempname,'.mat'];
            fid=fopen(tmpFile,'wb');
            obj=[];
            clrObj=onCleanup(@()tmpOpenedFileClean(tmpFile,fid));
            if fid~=-1
                inStr=matlab.internal.crypto.base64Decode(string(inStr));
                fwrite(fid,inStr,'*uint8');
                if~isempty(who('-file',tmpFile,'-regexp','\<codeCovDataGroupObj\>'))
                    vars=load(tmpFile,'codeCovDataGroupObj');
                    obj=vars.codeCovDataGroupObj;
                end
            end
        end

    end
end




function tmpOpenedFileClean(fname,fid)

    if fid~=-1

        fclose(fid);
    end
    if~isempty(dir(fname))

        delete(fname);
    end
end
