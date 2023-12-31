classdef VersionHandler<handle










    properties(Constant,Hidden)


        allVersion={...
6.4...
        ,6.5...
        ,6.6...
        ,7.0...
        ,7.1...
        ,7.2...
        ,7.3...
        ,7.4...
        ,7.5...
        ,7.6...
        ,7.7...
        ,7.8...
        ,7.9...
        ,8.0...
        ,8.1...
        ,8.2...
        ,8.3...
        ,8.4...
        ,8.5...
        ,8.6...
        ,8.7...
        ,8.8...
        ,8.9...
        ,9.0...
        ,9.1...
        ,9.2...
        ,9.3...
        ,10.0...
        ,10.1...
        ,10.2...
        ,10.3...
        ,10.4...
        ,10.5...
        ,10.6
        };
        allRelease={...
'R2006a'...
        ,'R2006b'...
        ,'R2007a'...
        ,'R2007b'...
        ,'R2008a'...
        ,'R2008b'...
        ,'R2009a'...
        ,'R2009b'...
        ,'R2010a'...
        ,'R2010b'...
        ,'R2011a'...
        ,'R2011b'...
        ,'R2012a'...
        ,'R2012b'...
        ,'R2013a'...
        ,'R2013b'...
        ,'R2014a'...
        ,'R2014b'...
        ,'R2015a'...
        ,'R2015b'...
        ,'R2016a'...
        ,'R2016b'...
        ,'R2017a'...
        ,'R2017b'...
        ,'R2018a'...
        ,'R2018b'...
        ,'R2019a'...
        ,'R2019b'...
        ,'R2020a'...
        ,'R2020b'...
        ,'R2021a'...
        ,'R2021b'...
        ,'R2022a'...
        ,'R2022b'
        };
        allInfo=containers.Map(slreq.utils.VersionHandler.allRelease,slreq.utils.VersionHandler.allVersion);
    end

    properties(Access=private)
        saveVersion;
    end

    methods(Static)
        function[matlabVersions,productVersions]=getPreviousVersions()
            function result=countDownTo17b()
                result={};

                for i=numel(slreq.utils.VersionHandler.allRelease):-1:1
                    ver=slreq.utils.VersionHandler.allRelease{i};

                    if isequal(ver,'R2017a')
                        break;
                    end

                    result{end+1,1}=ver;%#ok<AGROW>
                end

            end

            function productVersions=constructProductVersions(matlabVersions)







                slreqProductName='Requirements Toolbox';
                major=1;
                minor=0;
                productVersions=cell(size(matlabVersions));

                for i=numel(matlabVersions):-1:1
                    productVersions{i}=sprintf('%s %d.%d',slreqProductName,major,minor);
                    minor=minor+1;
                end

            end

            matlabVersions=countDownTo17b();
            productVersions=constructProductVersions(matlabVersions);
        end
    end

    methods

        function this=VersionHandler(verStr)
            ri=strcmpi(this.allRelease,verStr);

            if any(ri)
                this.saveVersion=verStr;
            else
                allKeys=keys(this.allInfo);
                vi=find([allKeys{:}]==str2double(verStr));

                if any(vi)
                    this.saveVersion=allKeys(vi);
                else
                    error(message('Slvnv:slreq:InvalidReleaseName'))
                end

            end

        end

        function rel=release(this)
            rel=this.saveVersion;
        end

        function tf=isSLReqVersion(this)
            tf=this.allInfo(this.saveVersion)>this.allInfo('R2017a');
        end

        function tf=isDotReqVersion(this)
            tf=this.allInfo(this.saveVersion)>this.allInfo('R2012a')...
            &&this.allInfo(this.saveVersion)<=this.allInfo('R2017a');
        end

    end

end
