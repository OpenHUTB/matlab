















classdef(ConstructOnLoad=true)SigSuiteSignal<handle

    properties
        Name='';
        XData=[];
        YData=[];
        UserData=[];
    end

    methods



        function this=SigSuiteSignal(varargin)

            mlock;

            if nargin==0
                this.Name='';
            elseif nargin==1
                if(isnumeric(varargin{1}))

                    this(1,varargin{1}).Name='';
                elseif isa(varargin{1},'SigSuiteSignal')
                    sigCnt_=length(varargin{1});
                    inObj=varargin{1};
                    this(1,sigCnt_).Name='';
                    for n=1:sigCnt_
                        this(n)=inObj(n).copyObj;
                    end
                else

                    if(~isa(varargin{1},'SigSuiteSignal'))
                        ME=MException('SigSuiteSignal:SigSuiteSignal:invalidSignal',...
                        '''Signals'' should be a "SigSuiteSignal" object.');
                        throw(ME);
                    end

                end





            elseif nargin>=2&&nargin<=3
                if(isstruct(varargin{2}))
                    gno=varargin{1};
                    tmpStruct=varargin{2};
                    numSignals=numel(tmpStruct.channels);

                    this(1,numSignals).Name='';
                    for n=1:numSignals
                        this(n).Name=tmpStruct.channels(n).label;
                        this(n).XData=tmpStruct.channels(n).allXData{gno};
                        this(n).YData=double(tmpStruct.channels(n).allYData{gno});
                    end

                else
                    sigNames_=[];

                    [sigCnt_,~]=size(varargin{1});

                    this(1,sigCnt_).Name='';
                    time_=varargin{2};
                    data_=varargin{1};

                    if nargin==3
                        sigNames_=varargin{3};
                        if~iscell(sigNames_)
                            sigNames_={sigNames_};
                        end
                    end

                    if~iscell(time_)
                        time_={time_};
                    end

                    if~iscell(data_)
                        data_={data_};
                    end


                    if isempty(sigNames_)
                        sigNames_=cell(1,sigCnt_);
                        for i=1:sigCnt_
                            sigNames_{i}=['Signal ',num2str(i)];
                        end
                    end
                    for n=1:sigCnt_
                        this(n).XData=time_{n};
                        this(n).YData=double(data_{n});
                        this(n).Name=sigNames_{n};
                    end
                end
            end
        end






        function newobj=copyObj(this)

            newobj=SigSuiteSignal;
            f=fieldnames(this);
            for pnum=1:numel(f)
                prop=f{pnum};
                newobj.(prop)=this.(prop);
            end
        end






        function xdata=getXData(this)
            xdata=this.XData;
        end

        function this=setXData(this,xdata,varargin)
            this.XData=xdata;
        end

        function ydata=getYData(this)
            ydata=this.YData;
        end

        function this=setYData(this,ydata,varargin)
            this.YData=double(ydata);
        end


    end

    methods(Hidden=true)
        function this=removeUnneededPoints(this)



            xnew=this.XData;
            ynew=this.YData;


            sameX=diff(this.XData)==0;


            if all(sameX==0)
                return;
            end

            I_eliminate=find(sameX(1:(end-1))&diff(sameX)==0)+1;
            xnew(I_eliminate)=[];
            ynew(I_eliminate)=[];


            I_eliminate=find(diff(xnew)==0&diff(ynew)==0);
            xnew(I_eliminate)=[];
            ynew(I_eliminate)=[];


            if diff(xnew(1:2))==0
                xnew(1)=[];
                ynew(1)=[];
            end
            if diff(xnew((end-1):end))==0
                xnew(end)=[];
                ynew(end)=[];
            end

            this.XData=xnew;
            this.YData=ynew;

        end
    end

end


