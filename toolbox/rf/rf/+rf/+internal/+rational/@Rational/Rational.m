classdef Rational





%#codegen

    properties(SetAccess=immutable)
NumPorts
NumPoles
    end

    properties(SetAccess=private)
Poles
Residues
DirectTerm
ErrDB
    end

    properties(Access=protected)
Impedance
Frequencies
Data
FitArray
    end

    properties(Constant,Access=private)
        Version=1.0
    end

    methods(Static,Access=protected)
        [fit,errdb,err,stats]=fitter(freq,data,varargin)
    end

    methods(Static,Access={?rational,?rfmodel.rational})
        resp=freqRespShared(freq,m,n,a,c,d,e,delay)
        resp=freqRespUnshared(freq,m,n,numPoles,a,c,d,e,delay)
        generateSPICEcore(A,B,C,D,filename,varargin)
    end

    methods
        function self=Rational(varargin)

            validateattributes(varargin{1},...
            {'sparameters','rfmodel.rational','numeric','char',...
            'string'},{},'','',1)
            if isa(varargin{1},'sparameters')
                S=varargin{1};
                self.Frequencies=S.Frequencies;
                self.Data=S.Parameters;
                self.Impedance=S.Impedance;
                argsStart=2;
                needToFit=true;
            elseif isa(varargin{1},'char')||isa(varargin{1},'string')
                S=sparameters(varargin{1});
                self.Frequencies=S.Frequencies;
                self.Data=S.Parameters;
                self.Impedance=S.Impedance;
                argsStart=2;
                needToFit=true;
            elseif isa(varargin{1},'rfmodel.rational')
                validateattributes(varargin{1},...
                {'rfmodel.rational'},{'square'},'','',1)
                sharedPoles=(all(length(varargin{1}(1).A)==...
                cellfun(@length,{varargin{1}(:).A}))&&...
                all(varargin{1}(1).A==[varargin{1}(:).A],'all'));
                if~sharedPoles
                    error(message('rf:rational:NeedSharedPoles'));
                end
                self.FitArray=copy(varargin{1});
                validateattributes(varargin{2},{'sparameters'},...
                {'nonempty','scalar'},'','',2)
                S=varargin{2};
                self.Frequencies=S.Frequencies;
                self.Data=S.Parameters;
                self.Impedance=S.Impedance;
                if nargin<3
                    resp=freqresp(self.FitArray,self.Frequencies);
                    if isvector(resp)
                        resp=reshape(resp,1,1,[]);
                    end
                    err=resp-self.Data;
                    errdb=rf.internal.rational.errcalc(...
                    err,self.Data,2,'Absolute');
                else
                    errdb=varargin{3};
                end
                needToFit=false;
            else
                freq=varargin{1};
                nfreq=numel(freq);
                data=varargin{2};
                coder.varsize('data',[1002,100,100]);
                datasize=size(data);
                if length(datasize)==3
                    ndatafreq=datasize(3);
                elseif length(datasize)==2
                    ndatafreq=datasize(1);
                    if ndatafreq~=nfreq
                        data=data.';
                        datasize=size(data);
                        ndatafreq=datasize(1);
                    end
                elseif length(datasize)==1
                    ndatafreq=datasize(1);
                else
                    error(message('rf:rational:WrongFreqOrDataInput'))
                end
                if nfreq~=ndatafreq
                    error(message('rf:rational:WrongFreqOrDataInput'))
                end
                [freq,i]=unique(freq);
                if numel(freq)<nfreq
                    error(message('rf:rational:FrequenciesNotUnique'))
                end
                self.Frequencies=freq;
                if length(datasize)==3
                    self.Data=data(:,:,i);
                elseif length(datasize)==2
                    self.Data=1i*ones(1,size(data,2),length(i));
                    self.Data(1,:,:)=data(i,:).';
                else
                    self.Data(1,1,:)=data(i);
                end
                self.Impedance=NaN;
                argsStart=3;
                needToFit=true;
            end
            if needToFit
                [self.FitArray,errdb]=...
                rf.internal.rational.Rational.fitter(...
                self.Frequencies,self.Data,varargin{argsStart:end});
            end
            s1=size(self.Data,1);
            s2=size(self.Data,2);
            self.Poles=self.FitArray(1).A;
            self.Residues=zeros(s1,s2,self.NumPoles);
            for i=1:s1
                for j=1:s2
                    self.Residues(i,j,:)=self.FitArray(i,j).C;
                end
            end

            self.DirectTerm=reshape([self.FitArray.D],s1,s2);
            self.ErrDB=errdb;
        end

        function result=get.NumPorts(self)
            dsize=size(self.DirectTerm);
            if dsize(1)==dsize(2)
                result=dsize(1);
            else
                result=dsize;
            end
        end

        function result=get.NumPoles(self)
            result=length(self.Poles);
        end

        function fit=rationalfit(self)
            fit=copy(self.FitArray);
        end
    end

end