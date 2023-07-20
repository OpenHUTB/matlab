classdef cvdatagroup<cv.internal.cvdatagroup

    properties(Access=private)
        cachedMdlBlkToCopyMdlMap=[]
    end
    properties(GetAccess=public,SetAccess=public,Dependent=true,Hidden=true)
mdlBlkToCopyMdlMap
    end

    methods

        function this=cvdatagroup(varargin)










            if~isempty(varargin)&&nargin>=1&&isa(varargin{1},'cv.cvdatagroup')
                if nargin==1

                    this=varargin{1};

                elseif nargin==2

                    mode=cv.internal.cvdatagroup.checkSimulationMode(varargin{2},'cv.cvdatagroup',2);


                    this.init();


                    data=varargin{1}.getAll(mode);
                    for ii=1:numel(data)
                        this.add(data{ii});
                    end

                else
                    narginchk(1,2);
                end
            elseif~isempty(varargin)&&(ischar(varargin{1})||isstring(varargin{1}))
                srcCvdatagroup='';
                if nargin>1
                    srcCvdatagroup=varargin{2};
                end

                fileName=convertStringsToChars(varargin{1});
                uuids=[];
                if~isempty(srcCvdatagroup)
                    allCvds=srcCvdatagroup.getAll;
                    for idx=1:numel(allCvds)
                        uuids=[uuids,{allCvds{idx}.uniqueId}];%#ok<AGROW>
                    end
                end
                this=cv.internal.cvdata.setupFileRef(this,fileName,uuids);
            else


                this.init();


                for idx=1:nargin
                    testId=varargin{idx};
                    for n=1:numel(testId)
                        cvd=cvdata(testId(n));
                        this.add(cvd);
                    end
                end

            end
        end


        function load(this)
            if this.isLoaded
                return;
            end
            cvdg=cvdata.loadFileRef(this);
            this.isLoaded=true;
            this.copy(cvdg);
        end


        function val=get.mdlBlkToCopyMdlMap(this)
            if~isa(this.cachedMdlBlkToCopyMdlMap,'containers.Map')
                names=this.m_data.keys();
                cvd=this.m_data(names{1});
                modelcovId=cv('get',cvd.rootId,'.modelcov');
                topModelcovId=cv('get',modelcovId,'.topModelcovId');
                str=cv('get',topModelcovId,'.mdlBlkToCopyMdlKeyValues');
                this.cachedMdlBlkToCopyMdlMap=parseMdlMapStr(str);
            end
            val=this.cachedMdlBlkToCopyMdlMap;
        end


        function set.mdlBlkToCopyMdlMap(this,mmap)
            this.cachedMdlBlkToCopyMdlMap=mmap;
        end


        function this=commitdd(this)
            names=this.m_data.keys();
            for idx=1:numel(names)
                nm=names{idx};
                cvd=this.m_data(nm);
                if cvd.id==0
                    this.m_data(nm)=commitdd(cvd);
                end
            end
        end
    end

    methods(Hidden)

        function yesno=hasMdlBlkToCopyMdlMap(this)
            yesno=~isempty(this.cachedMdlBlkToCopyMdlMap)&&...
            isa(this.cachedMdlBlkToCopyMdlMap,'containers.Map');
        end


        function data=getRefCvDataForNormalMdlCopy(this,blockPathObj)
            blockPathObj.validate();

            mdlName=bdroot(blockPathObj.getBlock(1));
            mbMap=this.mdlBlkToCopyMdlMap;



            numBlks=blockPathObj.getLength;
            for i=1:numBlks-1
                sid=[mdlName,':',get_param(blockPathObj.getBlock(i),'SID')];
                mdlName=mbMap(sid);
            end
            data=this.get(mdlName);
        end
    end

    methods(Access=protected,Hidden)

        function qname=getCvDataGroupClassName(this)%#ok<MANU>
            qname='cv.cvdatagroup';
        end


        function qname=getCvDataClassName(this)%#ok<MANU>
            qname='cvdata';
        end
    end

    methods(Static)
        function str=serializeMdlBlkToCopyMdlMap(mdlBlkMap)
            str='';
            if isa(mdlBlkMap,'containers.Map')
                keys=mdlBlkMap.keys;
                values=mdlBlkMap.values;
                str=cell(length(keys)*2,1);
                for i=1:length(keys)
                    str{2*i-1}=keys{i};
                    str{2*i}=values{i};
                end
                str=strjoin(str,',');
            end
        end

    end
end


function mdlBlkToCopyMdlMap=parseMdlMapStr(str)
    mdlBlkToCopyMdlMap=containers.Map('keytype','char','valuetype','char');
    if~isempty(str)
        res=strsplit(str,',');
        for i=1:2:length(res)
            mdlBlkToCopyMdlMap(res{i})=res{i+1};
        end
    end
end


