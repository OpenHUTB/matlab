classdef Data<handle&rf.internal.netparams.Interface





    properties(SetAccess=private)
NetworkData
NetworkFrequencies
NoiseData
FrequencyUnit
ParameterType
Format
ReferenceImpedance
    end

    methods
        function obj=Data(varargin)






            validateattributes(varargin{1},{'numeric','char'},{},1)


            if ischar(varargin{1})
                narginchk(1,1)
                read(obj,varargin{1})
                return
            end


            narginchk(2,4)

            netdata3d=varargin{1};
            freq=varargin{2};
            nsdata=[];
            optline='#';
            if nargin>2
                nsdata=varargin{3};

                if nargin>3
                    validateattributes(varargin{4},{'char'},{'row'},'','Option Line')
                    optline=varargin{4};
                end
            end
            createoptionlist(obj,optline)


            validateattributes(netdata3d,{'numeric'},...
            {'nonempty','3d','nonnan','finite'},'','NetworkData')
            if size(netdata3d,1)~=size(netdata3d,2)

                error(message('rf:rffile:touchstone:data:BadData'))
            end
            netdata2d=obj.rftbx2touchstone(netdata3d,obj.Format);
            obj.NetworkData=netdata2d;


            rf.internal.checkfreq(freq)
            switch lower(obj.FrequencyUnit)
            case 'hz'
                scale=1;
            case 'khz'
                scale=1e-3;
            case 'mhz'
                scale=1e-6;
            case 'ghz'
                scale=1e-9;
            end
            freq=scale*freq;
            obj.NetworkFrequencies=freq(:);


            if isempty(nsdata)
                validateattributes(nsdata,{'numeric'},{},'','Noise Data')
            else

                validateattributes(nsdata,{'numeric'},...
                {'real','2d','nonnan','ncols',5},'','Noise Data')

                if~validatefreqsfromfile(nsdata(:,1))
                    validateattributes(nsdata,{'numeric'},...
                    {'nonnegative','increasing'},'','Noise Frequencies')
                end
            end
            obj.NoiseData=nsdata;

            validateinterdependencies(obj)
        end
    end


    methods
        function set.ReferenceImpedance(obj,newRefImp)
            validateattributes(newRefImp,{'numeric'},{'scalar','real','positive','nonnan','finite'},'','ReferenceImpedance')
            obj.ReferenceImpedance=newRefImp;
        end
    end

    methods
        function write(obj,filename,varargin)


            narginchk(2,3)

            validateattributes(filename,{'char'},{'row'},'','Filename')

            if nargin==3
                nsigdig=varargin{1};
                validateattributes(nsigdig,{'numeric'},{'integer','positive'},'','Significant Digits')
            else
                nsigdig=17;
            end
            dataspaces=nsigdig+3+1+1+(nsigdig>1);
            snglnetfmt=sprintf(' %%%u.%ue',dataspaces,nsigdig-1);


            funit=upper(obj.FrequencyUnit);
            funit(end)='z';
            paramtype=upper(obj.ParameterType);
            fmt=upper(obj.Format);
            refimp=obj.ReferenceImpedance;


            freq=obj.NetworkFrequencies;
            netdata=obj.NetworkData;
            nsdata=obj.NoiseData;


            if any(freq~=round(freq))
                freqfmt='%20.15e';
            else
                dataspaces=ceil(log10(1+floor(freq(end))));
                freqfmt=sprintf('%%%uu',dataspaces);
            end


            freqpad=repmat(' ',1,dataspaces);


            [~,c]=size(netdata);
            numports=sqrt(c/2);
            switch numports
            case 1
                totnetfmt=[freqfmt,snglnetfmt,snglnetfmt,'\n'];
            case 2
                totnetfmt=[freqfmt,repmat(snglnetfmt,1,8),'\n'];
            case 3
                totnetfmt=[freqfmt,repmat(snglnetfmt,1,6),'\n',...
                freqpad,repmat(snglnetfmt,1,6),'\n',...
                freqpad,repmat(snglnetfmt,1,6),'\n'];
            otherwise
                rowsperport=ceil(numports/4);
                dataperport=2*numports-8;
                totnetfmt=[repmat(snglnetfmt,1,8),'\n'];
                for r=2:rowsperport
                    numpairs=min(8,dataperport);
                    totnetfmt=[totnetfmt,freqpad,repmat(snglnetfmt,1,numpairs),'\n'];%#ok<AGROW>
                    dataperport=dataperport-numpairs;
                end
                totnetfmt=[freqfmt,totnetfmt,repmat([freqpad,totnetfmt],1,numports-1)];
            end


            fid=fopen(filename,'wt');
            if fid==-1

                error(message('rf:rffile:shared:CannotWriteToFile',filename))
            end


            fprintf(fid,'# %s %s %s R ',funit,paramtype,fmt);


            if refimp==round(refimp)
                fprintf(fid,'%u',refimp);
            else
                fprintf(fid,'%g',refimp);
            end
            fprintf(fid,'\n\n');


            fprintf(fid,totnetfmt,[freq,netdata].');


            if~isempty(nsdata)
                fprintf(fid,'\n! Noise Data\n');
                fprintf(fid,'%20.15e %1.8e %1.8e %1.8e %1.8e\n',nsdata.');
            end

            fclose(fid);
        end

        function out=convertto3ddata(obj)
            ssdata=obj.NetworkData;
            [numfrq,ncols]=size(ssdata);
            numports=sqrt(ncols/2);
            firstcols=ssdata(:,1:2:(end-1));
            secondcols=ssdata(:,2:2:end);
            if numports==2
                firstcols(:,2)=firstcols(:,3);
                firstcols(:,3)=ssdata(:,3);
                secondcols(:,2)=secondcols(:,3);
                secondcols(:,3)=ssdata(:,4);
            end
            switch obj.Format
            case 'db'
                out2d=power(10,firstcols/20).*exp(1i*pi*secondcols/180);
            case 'ma'
                out2d=firstcols.*exp(1i*pi*secondcols/180);
            case 'ri'
                out2d=firstcols+1i*secondcols;
            end
            out=zeros(numports,numports,numfrq);
            idx=1;
            for rr=1:numports
                for cc=1:numports
                    out(rr,cc,:)=reshape(out2d(:,idx),1,1,numfrq);
                    idx=idx+1;
                end
            end
        end

        function out=smallsignalfreqsinhz(obj)
            funit=obj.FrequencyUnit;
            fdata=obj.NetworkFrequencies;
            out=rf.file.shared.getfreqinhz(funit,fdata);
        end

        function out=hasnoise(obj)
            out=~isempty(obj.NoiseData);
        end
    end

    methods(Access=private,Hidden)
        function createoptionlist(obj,optline)
            IDX=strfind(optline,'!');
            if~isempty(IDX)
                optline=strtrim(optline(1:(min(IDX)-1)));
            end
            cropline=lower(optline);

            if~strcmp('#',cropline(1))

                error(message('rf:rffile:touchstone:data:createoptionlist:BadFirstChar'))
            end

            throwerr=false;
            if length(cropline)==1

                funit=obj.getdefaultfrequnit;
                theformat=obj.getdefaultformat;
                paramtype=obj.getdefaultparam;
                refimpedance=obj.getdefaultrefimp;
            else
                if~any(strcmp(cropline(2),{' ',char(9)}))

                    warning(message('rf:rffile:touchstone:data:createoptionlist:NeedWhitespace'))
                    cropline=['# ',cropline(2:end)];
                end

                cropcell=textscan(cropline,'%s');
                cropcell=cropcell{1};
                numopts=length(cropcell);
                cntr=0;


                idx=strfind(cropline,'hz');
                if isempty(idx)
                    funit=obj.getdefaultfrequnit;
                else
                    idx=idx(1);
                    prevchar=cropline(idx-1);
                    switch prevchar
                    case{'g','m','k'}
                        funit=lower(horzcat(prevchar,'hz'));
                    case{' ',char(9)}
                        funit='hz';
                    otherwise
                        throwerr=true;
                    end
                    cntr=cntr+1;
                end


                validformats={'ma','db','ri'};
                thisformat=obj.getdefaultformat;
                for nn=1:length(validformats)
                    idx=strcmp(validformats{nn},cropcell);
                    numhits=sum(idx);
                    if numhits
                        if numhits>1
                            throwerr=true;
                        end
                        thisformat=validformats{nn};
                        cntr=cntr+1;
                        break;
                    end
                end
                theformat=lower(thisformat);


                validparamtypes={'s','y','z','g','h'};
                thisparam=obj.getdefaultparam;
                for nn=1:length(validparamtypes)
                    idx=strcmp(validparamtypes{nn},cropcell);
                    numhits=sum(idx);
                    if numhits
                        if numhits>1
                            throwerr=true;
                        end
                        thisparam=validparamtypes{nn};
                        cntr=cntr+1;
                        break;
                    end
                end
                paramtype=lower(thisparam);


                idx=find(strcmp('r',cropcell));
                if isempty(idx)
                    refimpedance=obj.getdefaultrefimp;
                else
                    idx=idx(1);
                    if idx==numopts
                        throwerr=true;
                    else
                        refimpedance=str2double(cropcell{idx+1});
                        if isnan(refimpedance)
                            throwerr=true;
                        end
                    end
                    cntr=cntr+2;
                end

                if cntr~=(numopts-1)
                    throwerr=true;
                end
            end

            if throwerr

                error(message('rf:rffile:touchstone:data:createoptionlist:BadOptLine',optline))
            end

            obj.FrequencyUnit=funit;
            obj.ParameterType=paramtype;
            obj.Format=theformat;
            obj.ReferenceImpedance=refimpedance;
        end

        function read(obj,fname)
            validateattributes(fname,{'char'},{'row'},'','Filename',1)

            fid=fopen(fname,'rt');
            if fid==-1

                error(message('rf:rffile:shared:CannotOpenFile',fname))
            end


            optstr=textscan(fid,'%s',1,'Delimiter','','CommentStyle','!');


            ssdata=[];
            while~feof(fid)

                buff=textscan(fid,'%f %f %f %f %f %f %f %f %f %f',...
                'CollectOutput',true,'CommentStyle','!');
                ssdata=vertcat(ssdata,buff{1});%#ok<AGROW>


                if~feof(fid)
                    lastnondataline=textscan(fid,'%s',1,...
                    'Delimiter','\n');
                    lastnondataline=strtrim(lastnondataline{1}{1});
                    if~any(strcmp({'#','!'},lastnondataline(1)))
                        fclose(fid);

                        error(message('rf:rffile:touchstone:data:processnetdata:ThisLineBad',lastnondataline))
                    end
                end
            end
            fclose(fid);

            if isempty(ssdata)

                error(message('rf:rffile:touchstone:data:processnetdata:AtLeastTwoLines',fname))
            end


            createoptionlist(obj,optstr{1}{1})


            numdata1=sum(~isnan(ssdata(1,:)));


            numlines=size(ssdata,1);
            if numlines==1
                if numdata1==3||numdata1==9
                    if ssdata(1)>=0
                        obj.NetworkData=ssdata(2:numdata1);
                        obj.NetworkFrequencies=ssdata(1);
                        obj.NoiseData=[];
                        return
                    end

                    error(message('rf:rffile:touchstone:data:BadData'))
                else

                    error(message('rf:rffile:touchstone:data:processnetdata:FirstAndOnlyLineBad',fname))
                end
            end


            numdata2=sum(~isnan(ssdata(2,:)));

            switch numdata1
            case 3
                if(numdata2==3)&&all(isnan(ssdata(:,4)))&&...
                    all(~isnan(ssdata(:,3)))&&...
                    validatefreqsfromfile(ssdata(:,1))
                    obj.NetworkData=ssdata(:,2:3);
                    obj.NetworkFrequencies=ssdata(:,1);
                    obj.NoiseData=[];
                    return
                end

                error(message('rf:rffile:touchstone:data:BadData'))
            case 9
                nsdata=[];
                if numdata2==9||numdata2==5
                    if isnan(ssdata(end,6))


                        isnan6thcol=isnan(ssdata(:,6));
                        idx6=find(isnan6thcol,1,'first');


                        if all(isnan6thcol(idx6:end))
                            nsdata=ssdata(idx6:end,1:5);
                            ssdata=ssdata(1:idx6-1,:);
                        else

                            error(message('rf:rffile:touchstone:data:BadData'))
                        end
                    end


                    if all(isnan(ssdata(:,10)))&&...
                        all(~isnan(ssdata(:,9)))&&...
                        validatefreqsfromfile(ssdata(:,1))&&...
                        validatenoisedatafromfile(nsdata)
                        obj.NetworkData=ssdata(:,2:9);
                        obj.NetworkFrequencies=ssdata(:,1);
                        obj.NoiseData=nsdata;
                        validateinterdependencies(obj)
                        return
                    end

                    if~validatefreqsfromfile(ssdata(:,1))

                        error(message('rf:rffile:touchstone:data:processnetdata:BadFreqData'))
                    end
                    if~isempty(nsdata)&&~validatefreqsfromfile(nsdata(:,1))

                        error(message('rf:rffile:touchstone:data:processnetdata:BadFreqData'))
                    end


                    error(message('rf:rffile:touchstone:data:BadData'))
                end


                idx9=2;
                while(idx9<=numlines)&&isnan(ssdata(idx9,9))
                    idx9=idx9+1;
                end
                idx9=idx9-1;

                dataperfreq=sum(sum(~isnan(ssdata(1:idx9,1:9))));
                guessnumports=ceil(sqrt((dataperfreq-1)/2));
                rowsperport=ceil(2*guessnumports/8);


                nonnanidx=zeros(rowsperport,1);
                nonnanidx(1)=8;
                datacount=1+2*guessnumports-9;
                for r=2:rowsperport
                    nonnanidx(r)=min(8,datacount);
                    datacount=datacount-nonnanidx(r);
                end

                nonnanidx=repmat(nonnanidx,guessnumports,1);
                nonnanidx(1)=9;

            case 7
                nonnanidx=[7;6;6];
            otherwise

                error(message('rf:rffile:touchstone:data:BadData'))
            end




            rowsperfreq=length(nonnanidx);
            colsperfreq=sum(nonnanidx);
            numfreq=numlines/rowsperfreq;

            if numfreq~=round(numfreq)

                error(message('rf:rffile:touchstone:data:BadData'))
            end

            for f=0:numfreq-1
                for r=1:rowsperfreq
                    row=f*rowsperfreq+r;
                    if~isnan(ssdata(row,1+nonnanidx(r)))||isnan(ssdata(row,nonnanidx(r)))

                        error(message('rf:rffile:touchstone:data:BadData'))
                    end
                end
            end

            ssdata=ssdata.';
            ssdata=ssdata(~isnan(ssdata));
            ssdata=reshape(ssdata,colsperfreq,numfreq).';

            if validatefreqsfromfile(ssdata(:,1))
                obj.NetworkData=ssdata(:,2:end);
                obj.NetworkFrequencies=ssdata(:,1);
                obj.NoiseData=[];
            else

                error(message('rf:rffile:touchstone:data:BadData'))
            end
        end

        function validateinterdependencies(obj)
            ssdata=obj.NetworkData;
            freq=obj.NetworkFrequencies;
            nsdata=obj.NoiseData;

            if numel(freq)~=size(ssdata,1)

                error(message('rf:rffile:touchstone:data:processnetdata:SizeNetFreqVsNetData'))
            end

            if~isempty(nsdata)
                if nsdata(1)>=freq(end)

                    error(message('rf:rffile:touchstone:data:processnetdata:NoiseFreq1vsNetFreq1'))
                end
            end
        end
    end

    methods(Hidden,Static,Access=private)
        function data2d=rftbx2touchstone(data3d,fmt)
            numports=size(data3d,1);
            numfreq=size(data3d,3);


            data2d=zeros(numfreq,2*numports^2);
            idx=1;
            for m=1:numports
                for n=1:numports
                    data=squeeze(data3d(m,n,:));
                    switch lower(fmt)
                    case 'ma'
                        data1=abs(data);
                        data2=180*angle(data)/pi;
                    case 'db'
                        data1=20*log10(abs(data));
                        data2=180*angle(data)/pi;
                    case 'ri'
                        data1=real(data);
                        data2=imag(data);
                    end
                    data2d(:,idx)=data1;
                    data2d(:,idx+1)=data2;
                    idx=idx+2;
                end
            end

            if numports==2
                temp=data2d(:,3:4);
                data2d(:,3:4)=data2d(:,5:6);
                data2d(:,5:6)=temp;
            end
        end
    end

    methods(Hidden,Static)
        function funit=getdefaultfrequnit
            funit='ghz';
        end

        function prm=getdefaultparam
            prm='s';
        end

        function fmt=getdefaultformat
            fmt='ma';
        end

        function refz=getdefaultrefimp
            refz=50;
        end
    end


    properties(Constant,Hidden)
        NetworkParameterNarginchkInputs=[1,1]
    end
    methods(Access=protected)
        function[str,data,freq,z0]=networkParameterInfo(obj,varargin)
            str=obj.ParameterType;
            data=convertto3ddata(obj);
            freq=smallsignalfreqsinhz(obj);
            z0=obj.ReferenceImpedance;
        end
    end
end

function TF=validatefreqsfromfile(newfreq)
    TF=all(newfreq>=0)&&all(diff(newfreq)>0);
end

function TF=validatenoisedatafromfile(newnsdata)
    TF=isempty(newnsdata)||(all(all(~isnan(newnsdata)))&&...
    validatefreqsfromfile(newnsdata(:,1)));
end
