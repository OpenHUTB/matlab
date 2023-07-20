



classdef cvdatagroup<cv.internal.cvdatagroup

    methods
        function this=cvdatagroup(varargin)
            if nargin>=1&&(ischar(varargin{1})||isstring(varargin{1}))
                fileName=convertStringsToChars(varargin{1});
                uuids=[];
                if nargin==2&&isa(varargin{2},'cv.coder.cvdatagroup')
                    allCvds=varargin{2}.getAll();
                    for idx=1:numel(allCvds)
                        uuids=[uuids,{allCvds{idx}.uniqueId}];%#ok<AGROW>
                    end
                end
                this=cv.internal.cvdata.setupFileRef(this,fileName,uuids);
            elseif nargin>=1&&isa(varargin{1},'cv.coder.cvdatagroup')
                if nargin==1

                    this=varargin{1};
                elseif nargin==2

                    mode=cv.internal.cvdatagroup.checkSimulationMode(varargin{2},'cv.coder.cvdatagroup',2);


                    this.init();


                    data=varargin{1}.getAll(mode);
                    for ii=1:numel(data)
                        this.add(data{ii});
                    end
                else
                    narginchk(1,2);
                end
            else

                this.init();


                for idx=1:numel(varargin)
                    arg=varargin{idx};
                    validateattributes(arg,{'cv.coder.cvdata'},{'nonempty'},idx);
                    for n=1:numel(arg)
                        this.add(arg(n));
                    end
                end
            end
        end

        function load(this)
            if this.isLoaded
                return
            end
            cvdg=cv.coder.cvdata.loadFileRef(this);
            this.isLoaded=true;
            this.copy(cvdg);
        end
    end

    methods(Access=protected,Hidden)
        function qname=getCvDataGroupClassName(this)%#ok<MANU>
            qname='cv.coder.cvdatagroup';
        end

        function qname=getCvDataClassName(this)%#ok<MANU>
            qname='cv.coder.cvdata';
        end
    end
end


