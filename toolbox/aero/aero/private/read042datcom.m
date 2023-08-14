function[CaseNumber,CaseData]=read042datcom(files,usenan,verbose)









    CaseNumber=0;


    IndexAlpha=1;
    IndexMach=1;


    CaseSetup=struct('case',1,'totalCol',[],'mach',[],'alt',[],'alpha',[],...
    'nmach',1,'nalpha',0,'rnnub',[],'q',[],'beta',0,'phi',0,'sref',[],...
    'cbar',[],'blref',[],'xcg',[],'xmrp',[],'deriv','deg','trim',false,...
    'damp',false,'build',1,'part',false,'nolat',true,...
    'config',struct('body',true,...
    'fin1',struct('avail',false,'npanel',[],'delta',[]),...
    'fin2',struct('avail',false,'npanel',[],'delta',[]),...
    'fin3',struct('avail',false,'npanel',[],'delta',[]),...
    'fin4',struct('avail',false,'npanel',[],'delta',[])),...
    'version',2008);

    for fcnt=1:length(files)
        FileName=files(fcnt);
        if(verbose=="1")
            fprintf('\nLoading file ''%s''.\n',FileName)
        elseif(verbose=="2")
            hw=waitbar(0,'Progress: 0%','name',sprintf('Loading: %s',FileName));
            for z=0.1:0.1:0.2
                waitbar(z,hw)
                pause(0.1)
            end
        end
        CaseNumber=CaseNumber+1;
        FirstInput=1;
        try
            fid=fopen(FileName,'r');
            if(fid<0)
                error(message('aero:loadfiles:cannotOpen',FileName));
            end

            State='CheckFile';
            LineType='';


            CaseData{CaseNumber}=struct();%#ok<AGROW>


            while~feof(fid)
                Line=fgetl(fid);
                if(~ischar(Line)&&~isstring(Line))
                    if(verbose=="1")
                        fprintf('File ''%s'' is empty.\n',FileName)
                    elseif(verbose=="2")
                        waitbar(z,hw,sprintf('File is empty.'))
                        pause(0.5)
                    end
                    break
                end

                if(verbose=="1")
                    if FirstInput
                        fprintf('Reading input data from file ''%s''.\n',FileName)
                        FirstInput=0;
                    end
                elseif(verbose=="2")
                    z=z+0.01;
                    if z>0.95
                        z=0.95;
                    end
                    set(hw,'name',sprintf('Reading input data: %s',FileName))
                    waitbar(z,hw,sprintf('Progress: %3.0f%%',z*100))
                end


                LineType=GetLineType();


                [State]=GetReaderState(State);

                switch State
                case 'Lost'

                    LostWarning();

                case 'Exit'

                    error(message('aero:datcomimport:invalidFile',FileName));
                otherwise

                end

                GetData();
            end
            fclose(fid);

            if strcmpi(State,'HeaderRead')
                CaseNumber=CaseNumber-1;
            end
            if(verbose=="2")
                set(hw,'Name',sprintf('Reading completed: %s',FileName))
                waitbar(1,hw,'Progress: 100%')
                pause(0.5)
            end
        catch ReadError
            if(exist('fid','var')&&~any(fid==[-1,0,1,2]))
                fclose(fid);
            end
            if exist('hw')%#ok<EXIST>
                close(hw);
            end
            rethrow(ReadError)
        end
        if exist('hw')%#ok<EXIST>
            close(hw);
        end
    end


    function LineType=GetLineType()

        if~isempty(regexp(Line,...
            '\<''SIZES'',     ''NVARS'',','once'))
            LineType='VarHeader';
        elseif~isempty(regexp(Line,...
            '\<''CASE'',      ''RAD\?'',     ''TRIM\?'',      ''MACH'',        ''RE'',','once'))
            LineType='DataHeader';


            if~isempty(regexp(Line,'''ALT'',         ''Q'',','once'))

                CaseData{CaseNumber}.q=1;
            end

            if~isempty(regexp(Line,'''DEFL_1_','once'))

                CaseData{CaseNumber}.config.body=true;
                CaseData{CaseNumber}.config.fin1.avail=true;
                CaseData{CaseNumber}.config.fin1.npanel=numel(regexp(Line,'''DEFL_1_'));
                if~isempty(regexp(Line,'''DEFL_2_','once'))
                    CaseData{CaseNumber}.config.fin2.avail=true;
                    CaseData{CaseNumber}.config.fin2.npanel=numel(regexp(Line,'''DEFL_2_'));
                    if~isempty(regexp(Line,'''DEFL_3_','once'))
                        CaseData{CaseNumber}.config.fin3.avail=true;
                        CaseData{CaseNumber}.config.fin3.npanel=numel(regexp(Line,'''DEFL_3_'));
                        if~isempty(regexp(Line,'''DEFL_4_','once'))
                            CaseData{CaseNumber}.config.fin4.avail=true;
                            CaseData{CaseNumber}.config.fin4.npanel=numel(regexp(Line,'''DEFL_4_'));
                        end
                    end
                end
            end

            if~isempty(regexp(Line,'''TRIM_DELT'',   ''TRIM_CL'',','once'))

                CaseData{CaseNumber}.trim=true;
                CaseData{CaseNumber}.version=2008;
            end
            if~isempty(regexp(Line,'''TRIM_DELT'',   ''TRIM_CN'',','once'))

                CaseData{CaseNumber}.trim=true;
                CaseData{CaseNumber}.version=2011;
            end
            if~isempty(regexp(Line,'''CN'',        ''CM'',        ''CA'',','once'))

                if~isempty(regexp(Line,'''BA_CN'',','once'))

                    CaseData{CaseNumber}.part=true;
                    CaseData{CaseNumber}.build=2;
                    CaseData{CaseNumber}.config.body=true;
                    CaseData{CaseNumber}.config.fin1.avail=true;
                    if~isempty(regexp(Line,'''B\+1_CN'',','once'))
                        CaseData{CaseNumber}.build=3;
                        CaseData{CaseNumber}.config.fin2.avail=true;
                        if~isempty(regexp(Line,'''B\+2_CN'',','once'))
                            CaseData{CaseNumber}.build=4;
                            CaseData{CaseNumber}.config.fin3.avail=true;
                            if~isempty(regexp(Line,'''B\+3_CN'',','once'))
                                CaseData{CaseNumber}.build=5;
                                CaseData{CaseNumber}.config.fin4.avail=true;
                            end
                        end
                    end
                end
                if~isempty(regexp(Line,'''CYB'',      ''CLNB'',      ''CLLB'',','once'))

                    CaseData{CaseNumber}.nolat=false;


                end
            end
            if~isempty(regexp(Line,'''CNQ'',       ''CMQ'',       ''CAQ'',','once'))

                CaseData{CaseNumber}.damp=true;


                if~isempty(regexp(Line,'''CYR'',      ''CLNR'',      ''CLLR'',','once'))

                    CaseData{CaseNumber}.nolat=false;


                end
            end
            if~isempty(regexp(Line,'''F1A\-CN'',','once'))

                CaseData{CaseNumber}.build=1;
                CaseData{CaseNumber}.config.body=false;
                CaseData{CaseNumber}.config.fin1.avail=true;
            end
        else
            if((CaseData{CaseNumber}.version==2011)&&(CaseData{CaseNumber}.trim==true))


                expectedLength=(CaseData{CaseNumber}.totalCol+6)*13;
            else
                expectedLength=CaseData{CaseNumber}.totalCol*13;
            end
            if(length(Line)==expectedLength)
                LineType='Data';
            else
                LineType='Unknown';
            end
        end

    end

    function State=GetReaderState(State)

        switch State
        case 'CheckFile'
            StateCell={'Exit','HeaderRead'};
            TypeCell={'VarHeader'};

        case 'HeaderRead'
            StateCell={'Lost','DataRead'};
            TypeCell={'DataHeader'};

        case 'DataRead'
            StateCell={'Lost','DataRead','DataRead','DataRead'};
            TypeCell={'VarHeader','DataHeader','Data'};

        otherwise
            StateCell={'Lost','Lost','Lost','Lost'};
            TypeCell={'VarHeader','DataHeader','Data'};
        end
        StateIndex=find(strcmp(TypeCell,LineType));
        if isempty(StateIndex)
            StateIndex=0;
        end
        State=StateCell{StateIndex+1};

    end

    function GetData()

        switch LineType
        case 'VarHeader'

            if strcmpi(State,'DataRead')
                CaseNumber=CaseNumber+1;
            end

            CaseData{CaseNumber}=CaseSetup;


            CaseData{CaseNumber}.totalCol=GetCoefficients(Line(27:38));
            CaseData{CaseNumber}.nalpha=GetCoefficients(Line(57:64));
            CaseData{CaseNumber}.nmach=GetCoefficients(Line(85:90));

        case 'DataHeader'
            NumberAlpha=CaseData{CaseNumber}.nalpha;
            NumberMach=CaseData{CaseNumber}.nmach;

            CaseData{CaseNumber}.alpha=99999*ones(1,NumberAlpha);
            CaseData{CaseNumber}.mach=99999*ones(1,NumberMach);
            CaseData{CaseNumber}.rnnub=99999*ones(1,NumberMach);

            if~isempty(CaseData{CaseNumber}.q)

                CaseData{CaseNumber}.alt=99999*ones(1,NumberMach);
                CaseData{CaseNumber}.q=99999*ones(1,NumberMach);
            end

            if~(CaseData{CaseNumber}.config.body)

                FinOneOnlyInitialization();
            else
                if(CaseData{CaseNumber}.trim)
                    CaseData{CaseNumber}.nolat=true;

                    TrimInitialization();
                else

                    StaticInitialization();
                    if(CaseData{CaseNumber}.damp)
                        DynamicInitialization();
                    end
                end
            end

            IndexAlpha=1;
            IndexMach=1;

        case 'Data'

            derivString={'deg','rad'};

            CaseData{CaseNumber}.case=GetCoefficients(Line(7:12));
            CaseData{CaseNumber}.deriv=derivString{GetCoefficients(Line(20:25))+1};
            CaseData{CaseNumber}.trim=logical(GetCoefficients(Line(33:38)));
            CaseData{CaseNumber}.mach(IndexMach)=GetCoefficients(Line(40:51));
            CaseData{CaseNumber}.rnnub(IndexMach)=GetCoefficients(Line(53:64));


            if~isempty(CaseData{CaseNumber}.q)

                IndexAltitude=66;
                CaseData{CaseNumber}.alt(IndexMach)=GetCoefficients(Line(IndexAltitude:IndexAltitude+11));
                CaseData{CaseNumber}.q(IndexMach)=GetCoefficients(Line(IndexAltitude+13:IndexAltitude+24));
                IndexBeta=92;
                IndexBeginNext=183;
            else
                IndexBeta=66;
                IndexBeginNext=157;
            end

            CaseData{CaseNumber}.beta=GetCoefficients(Line(IndexBeta:IndexBeta+11));
            CaseData{CaseNumber}.phi=GetCoefficients(Line(IndexBeta+13:IndexBeta+24));
            CaseData{CaseNumber}.sref=GetCoefficients(Line(IndexBeta+26:IndexBeta+37));
            CaseData{CaseNumber}.xcg=GetCoefficients(Line(IndexBeta+39:IndexBeta+50));
            CaseData{CaseNumber}.xmrp=GetCoefficients(Line(IndexBeta+52:IndexBeta+63));
            CaseData{CaseNumber}.cbar=GetCoefficients(Line(IndexBeta+65:IndexBeta+76));
            CaseData{CaseNumber}.blref=GetCoefficients(Line(IndexBeta+78:IndexBeta+89));


            if(CaseData{CaseNumber}.config.fin1.avail==true)
                for ii=1:CaseData{CaseNumber}.config.fin1.npanel
                    CaseData{CaseNumber}.config.fin1.delta(ii)=GetCoefficients(Line(IndexBeginNext:IndexBeginNext+11));
                    IndexBeginNext=IndexBeginNext+13;
                end
            end
            if(CaseData{CaseNumber}.config.fin2.avail==true)
                for ii=1:CaseData{CaseNumber}.config.fin2.npanel
                    CaseData{CaseNumber}.config.fin2.delta(ii)=GetCoefficients(Line(IndexBeginNext:IndexBeginNext+11));
                    IndexBeginNext=IndexBeginNext+13;
                end
            end
            if(CaseData{CaseNumber}.config.fin3.avail==true)
                for ii=1:CaseData{CaseNumber}.config.fin3.npanel
                    CaseData{CaseNumber}.config.fin3.delta(ii)=GetCoefficients(Line(IndexBeginNext:IndexBeginNext+11));
                    IndexBeginNext=IndexBeginNext+13;
                end
            end
            if(CaseData{CaseNumber}.config.fin4.avail==true)
                for ii=1:CaseData{CaseNumber}.config.fin4.npanel
                    CaseData{CaseNumber}.config.fin4.delta(ii)=GetCoefficients(Line(IndexBeginNext:IndexBeginNext+11));
                    IndexBeginNext=IndexBeginNext+13;
                end
            end


            CaseData{CaseNumber}.alpha(IndexAlpha)=GetCoefficients(Line(IndexBeginNext:IndexBeginNext+11));
            IndexBeginNext=IndexBeginNext+13;

            if~(CaseData{CaseNumber}.config.body)

                FinOneOnlyRead(IndexBeginNext);
            else
                if(CaseData{CaseNumber}.trim)

                    CaseData{CaseNumber}.nolat=true;
                    TrimRead(IndexBeginNext);
                else

                    IndexBeginNext=StaticRead(IndexBeginNext);
                    if(CaseData{CaseNumber}.damp)
                        IndexBeginNext=DynamicRead(IndexBeginNext);
                    end
                    if(CaseData{CaseNumber}.part)

                        PartialStaticDynamicRead(IndexBeginNext);
                    end
                end
            end

            IndexAlpha=IndexAlpha+1;
            if IndexAlpha>CaseData{CaseNumber}.nalpha
                IndexAlpha=1;
                IndexMach=IndexMach+1;
            end

        otherwise

            LostWarning();
        end
    end

    function LostWarning()
        warning(message('aero:datcomimport:algorithmError'));
    end

    function StaticInitialization()
        if~isfield(CaseData{CaseNumber},'cd')
            NumberAlpha=CaseData{CaseNumber}.nalpha;
            NumberMach=CaseData{CaseNumber}.nmach;
            NumberBuild=CaseData{CaseNumber}.build;


            CaseData{CaseNumber}.cn=99999*ones(NumberAlpha,NumberMach,NumberBuild);
            CaseData{CaseNumber}.cm=99999*ones(NumberAlpha,NumberMach,NumberBuild);
            CaseData{CaseNumber}.ca=99999*ones(NumberAlpha,NumberMach,NumberBuild);
            CaseData{CaseNumber}.caZeroBase=99999*ones(NumberAlpha,NumberMach,NumberBuild);
            CaseData{CaseNumber}.caFullBase=99999*ones(NumberAlpha,NumberMach,NumberBuild);
            CaseData{CaseNumber}.cy=99999*ones(NumberAlpha,NumberMach,NumberBuild);
            CaseData{CaseNumber}.cln=99999*ones(NumberAlpha,NumberMach,NumberBuild);
            CaseData{CaseNumber}.cll=99999*ones(NumberAlpha,NumberMach,NumberBuild);
            CaseData{CaseNumber}.cl=99999*ones(NumberAlpha,NumberMach,NumberBuild);
            CaseData{CaseNumber}.cd=99999*ones(NumberAlpha,NumberMach,NumberBuild);
            CaseData{CaseNumber}.clod=99999*ones(NumberAlpha,NumberMach,NumberBuild);
            CaseData{CaseNumber}.xcp=99999*ones(NumberAlpha,NumberMach,NumberBuild);
            CaseData{CaseNumber}.cna=99999*ones(NumberAlpha,NumberMach,NumberBuild);
            CaseData{CaseNumber}.cma=99999*ones(NumberAlpha,NumberMach,NumberBuild);
            if(~CaseData{CaseNumber}.nolat)

                CaseData{CaseNumber}.cyb=99999*ones(NumberAlpha,NumberMach,NumberBuild);
                CaseData{CaseNumber}.cnb=99999*ones(NumberAlpha,NumberMach,NumberBuild);
                CaseData{CaseNumber}.clb=99999*ones(NumberAlpha,NumberMach,NumberBuild);
            end
        end
    end

    function IndexBeginNext=StaticRead(IndexBeginNext)

        ReplaceNT()

        IndexBuild=CaseData{CaseNumber}.build;


        CaseData{CaseNumber}.cn(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext:IndexBeginNext+11));
        CaseData{CaseNumber}.cm(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+13:IndexBeginNext+24));
        CaseData{CaseNumber}.ca(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+26:IndexBeginNext+37));
        CaseData{CaseNumber}.caZeroBase(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+39:IndexBeginNext+50));
        CaseData{CaseNumber}.caFullBase(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+52:IndexBeginNext+63));
        CaseData{CaseNumber}.cy(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+65:IndexBeginNext+76));
        CaseData{CaseNumber}.cln(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+78:IndexBeginNext+89));
        CaseData{CaseNumber}.cll(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+91:IndexBeginNext+102));
        CaseData{CaseNumber}.cl(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+104:IndexBeginNext+115));
        CaseData{CaseNumber}.cd(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+117:IndexBeginNext+128));
        CaseData{CaseNumber}.clod(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+130:IndexBeginNext+141));
        CaseData{CaseNumber}.xcp(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+143:IndexBeginNext+154));
        CaseData{CaseNumber}.cna(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+156:IndexBeginNext+167));
        CaseData{CaseNumber}.cma(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+169:IndexBeginNext+180));
        IndexBeginNext=IndexBeginNext+182;
        if(~CaseData{CaseNumber}.nolat)

            CaseData{CaseNumber}.cyb(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext:IndexBeginNext+11));
            CaseData{CaseNumber}.cnb(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+13:IndexBeginNext+24));
            CaseData{CaseNumber}.clb(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+26:IndexBeginNext+37));
            IndexBeginNext=IndexBeginNext+39;
        end
    end

    function DynamicInitialization()
        if~isfield(CaseData{CaseNumber},'cmad')
            NumberAlpha=CaseData{CaseNumber}.nalpha;
            NumberMach=CaseData{CaseNumber}.nmach;
            NumberBuild=CaseData{CaseNumber}.build;


            CaseData{CaseNumber}.cnq=99999*ones(NumberAlpha,NumberMach,NumberBuild);
            CaseData{CaseNumber}.cmq=99999*ones(NumberAlpha,NumberMach,NumberBuild);
            CaseData{CaseNumber}.caq=99999*ones(NumberAlpha,NumberMach,NumberBuild);
            CaseData{CaseNumber}.cnad=99999*ones(NumberAlpha,NumberMach,NumberBuild);
            CaseData{CaseNumber}.cmad=99999*ones(NumberAlpha,NumberMach,NumberBuild);
            CaseData{CaseNumber}.cyq=99999*ones(NumberAlpha,NumberMach,NumberBuild);
            CaseData{CaseNumber}.clnq=99999*ones(NumberAlpha,NumberMach,NumberBuild);
            CaseData{CaseNumber}.cllq=99999*ones(NumberAlpha,NumberMach,NumberBuild);
            if(~CaseData{CaseNumber}.nolat)

                CaseData{CaseNumber}.cyr=99999*ones(NumberAlpha,NumberMach,NumberBuild);
                CaseData{CaseNumber}.clnr=99999*ones(NumberAlpha,NumberMach,NumberBuild);
                CaseData{CaseNumber}.cllr=99999*ones(NumberAlpha,NumberMach,NumberBuild);
                CaseData{CaseNumber}.cyp=99999*ones(NumberAlpha,NumberMach,NumberBuild);
                CaseData{CaseNumber}.clnp=99999*ones(NumberAlpha,NumberMach,NumberBuild);
                CaseData{CaseNumber}.cllp=99999*ones(NumberAlpha,NumberMach,NumberBuild);
                CaseData{CaseNumber}.cnp=99999*ones(NumberAlpha,NumberMach,NumberBuild);
                CaseData{CaseNumber}.cmp=99999*ones(NumberAlpha,NumberMach,NumberBuild);
                CaseData{CaseNumber}.cap=99999*ones(NumberAlpha,NumberMach,NumberBuild);
                CaseData{CaseNumber}.cnr=99999*ones(NumberAlpha,NumberMach,NumberBuild);
                CaseData{CaseNumber}.cmr=99999*ones(NumberAlpha,NumberMach,NumberBuild);
                CaseData{CaseNumber}.car=99999*ones(NumberAlpha,NumberMach,NumberBuild);
            end
        end
    end

    function IndexBeginNext=DynamicRead(IndexBeginNext)

        ReplaceNT()

        IndexBuild=CaseData{CaseNumber}.build;


        CaseData{CaseNumber}.cnq(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext:IndexBeginNext+11));
        CaseData{CaseNumber}.cmq(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+13:IndexBeginNext+24));
        CaseData{CaseNumber}.caq(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+26:IndexBeginNext+37));
        CaseData{CaseNumber}.cnad(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+39:IndexBeginNext+50));
        CaseData{CaseNumber}.cmad(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+52:IndexBeginNext+63));
        CaseData{CaseNumber}.cyq(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+65:IndexBeginNext+76));
        CaseData{CaseNumber}.clnq(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+78:IndexBeginNext+89));
        CaseData{CaseNumber}.cllq(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+91:IndexBeginNext+102));
        IndexBeginNext=IndexBeginNext+104;
        if(~CaseData{CaseNumber}.nolat)

            CaseData{CaseNumber}.cyr(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext:IndexBeginNext+11));
            CaseData{CaseNumber}.clnr(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+13:IndexBeginNext+24));
            CaseData{CaseNumber}.cllr(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+26:IndexBeginNext+37));
            CaseData{CaseNumber}.cyp(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+39:IndexBeginNext+50));
            CaseData{CaseNumber}.clnp(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+52:IndexBeginNext+63));
            CaseData{CaseNumber}.cllp(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+65:IndexBeginNext+76));
            CaseData{CaseNumber}.cnp(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+78:IndexBeginNext+89));
            CaseData{CaseNumber}.cmp(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+91:IndexBeginNext+102));
            CaseData{CaseNumber}.cap(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+104:IndexBeginNext+115));
            CaseData{CaseNumber}.cnr(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+117:IndexBeginNext+128));
            CaseData{CaseNumber}.cmr(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+130:IndexBeginNext+141));
            CaseData{CaseNumber}.car(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+143:IndexBeginNext+154));
            IndexBeginNext=IndexBeginNext+156;
        end
    end

    function IndexBeginNext=PartialStaticDynamicRead(IndexBeginNext)

        ReplaceNT()

        for ii=1:CaseData{CaseNumber}.build-1

            IndexBuild=ii;


            CaseData{CaseNumber}.cn(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext:IndexBeginNext+11));
            CaseData{CaseNumber}.cm(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+13:IndexBeginNext+24));
            CaseData{CaseNumber}.ca(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+26:IndexBeginNext+37));
            CaseData{CaseNumber}.cy(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+39:IndexBeginNext+50));
            CaseData{CaseNumber}.cln(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+52:IndexBeginNext+63));
            CaseData{CaseNumber}.cll(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+65:IndexBeginNext+76));
            CaseData{CaseNumber}.cl(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+78:IndexBeginNext+89));
            CaseData{CaseNumber}.cd(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+91:IndexBeginNext+102));
            CaseData{CaseNumber}.clod(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+104:IndexBeginNext+115));
            CaseData{CaseNumber}.xcp(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+117:IndexBeginNext+128));
            CaseData{CaseNumber}.cna(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+130:IndexBeginNext+141));
            CaseData{CaseNumber}.cma(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+143:IndexBeginNext+154));
            IndexBeginNext=IndexBeginNext+156;
            if(~CaseData{CaseNumber}.nolat)

                CaseData{CaseNumber}.cyb(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext:IndexBeginNext+11));
                CaseData{CaseNumber}.cnb(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+13:IndexBeginNext+24));
                CaseData{CaseNumber}.clb(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+26:IndexBeginNext+37));
                IndexBeginNext=IndexBeginNext+39;
            end
            if(CaseData{CaseNumber}.damp)

                CaseData{CaseNumber}.cnq(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext:IndexBeginNext+11));
                CaseData{CaseNumber}.cmq(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+13:IndexBeginNext+24));
                CaseData{CaseNumber}.caq(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+26:IndexBeginNext+37));
                CaseData{CaseNumber}.cnad(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+39:IndexBeginNext+50));
                CaseData{CaseNumber}.cmad(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+52:IndexBeginNext+63));
                CaseData{CaseNumber}.cyq(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+65:IndexBeginNext+76));
                CaseData{CaseNumber}.clnq(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+78:IndexBeginNext+89));
                CaseData{CaseNumber}.cllq(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+91:IndexBeginNext+102));
                IndexBeginNext=IndexBeginNext+104;
                if(~CaseData{CaseNumber}.nolat)

                    CaseData{CaseNumber}.cyr(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext:IndexBeginNext+11));
                    CaseData{CaseNumber}.clnr(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+13:IndexBeginNext+24));
                    CaseData{CaseNumber}.cllr(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+26:IndexBeginNext+37));
                    CaseData{CaseNumber}.cyp(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+39:IndexBeginNext+50));
                    CaseData{CaseNumber}.clnp(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+52:IndexBeginNext+63));
                    CaseData{CaseNumber}.cllp(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+65:IndexBeginNext+76));
                    CaseData{CaseNumber}.cnp(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+78:IndexBeginNext+89));
                    CaseData{CaseNumber}.cmp(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+91:IndexBeginNext+102));
                    CaseData{CaseNumber}.cap(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+104:IndexBeginNext+115));
                    CaseData{CaseNumber}.cnr(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+117:IndexBeginNext+128));
                    CaseData{CaseNumber}.cmr(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+130:IndexBeginNext+141));
                    CaseData{CaseNumber}.car(IndexAlpha,IndexMach,IndexBuild)=GetCoefficients(Line(IndexBeginNext+143:IndexBeginNext+154));
                    IndexBeginNext=IndexBeginNext+156;
                end
            end
        end
    end

    function FinOneOnlyInitialization()
        if~isfield(CaseData{CaseNumber},'cd')
            NumberAlpha=CaseData{CaseNumber}.nalpha;
            NumberMach=CaseData{CaseNumber}.nmach;


            CaseData{CaseNumber}.cn=99999*ones(NumberAlpha,NumberMach);
            CaseData{CaseNumber}.cm=99999*ones(NumberAlpha,NumberMach);
            CaseData{CaseNumber}.ca=99999*ones(NumberAlpha,NumberMach);
            CaseData{CaseNumber}.cl=99999*ones(NumberAlpha,NumberMach);
            CaseData{CaseNumber}.cd=99999*ones(NumberAlpha,NumberMach);
            CaseData{CaseNumber}.clod=99999*ones(NumberAlpha,NumberMach);
            CaseData{CaseNumber}.xcp=99999*ones(NumberAlpha,NumberMach);
            CaseData{CaseNumber}.cna=99999*ones(NumberAlpha,NumberMach);
            CaseData{CaseNumber}.cma=99999*ones(NumberAlpha,NumberMach);
        end
    end

    function IndexBeginNext=FinOneOnlyRead(IndexBeginNext)

        ReplaceNT()


        CaseData{CaseNumber}.cn(IndexAlpha,IndexMach)=GetCoefficients(Line(IndexBeginNext:IndexBeginNext+11));
        CaseData{CaseNumber}.cm(IndexAlpha,IndexMach)=GetCoefficients(Line(IndexBeginNext+13:IndexBeginNext+24));
        CaseData{CaseNumber}.ca(IndexAlpha,IndexMach)=GetCoefficients(Line(IndexBeginNext+26:IndexBeginNext+37));
        CaseData{CaseNumber}.cl(IndexAlpha,IndexMach)=GetCoefficients(Line(IndexBeginNext+39:IndexBeginNext+50));
        CaseData{CaseNumber}.cd(IndexAlpha,IndexMach)=GetCoefficients(Line(IndexBeginNext+52:IndexBeginNext+63));
        CaseData{CaseNumber}.clod(IndexAlpha,IndexMach)=GetCoefficients(Line(IndexBeginNext+65:IndexBeginNext+76));
        CaseData{CaseNumber}.xcp(IndexAlpha,IndexMach)=GetCoefficients(Line(IndexBeginNext+78:IndexBeginNext+89));
        CaseData{CaseNumber}.cna(IndexAlpha,IndexMach)=GetCoefficients(Line(IndexBeginNext+91:IndexBeginNext+102));
        CaseData{CaseNumber}.cma(IndexAlpha,IndexMach)=GetCoefficients(Line(IndexBeginNext+104:IndexBeginNext+115));
        IndexBeginNext=IndexBeginNext+117;
    end

    function TrimInitialization()
        if~isfield(CaseData{CaseNumber},'cd')
            NumberAlpha=CaseData{CaseNumber}.nalpha;
            NumberMach=CaseData{CaseNumber}.nmach;


            CaseData{CaseNumber}.cn=99999*ones(NumberAlpha,NumberMach);
            CaseData{CaseNumber}.ca=99999*ones(NumberAlpha,NumberMach);
            CaseData{CaseNumber}.cl=99999*ones(NumberAlpha,NumberMach);
            CaseData{CaseNumber}.cd=99999*ones(NumberAlpha,NumberMach);
            CaseData{CaseNumber}.delta=99999*ones(NumberAlpha,NumberMach);
            if(CaseData{CaseNumber}.version==2011)

                CaseData{CaseNumber}.caZeroBase=99999*ones(NumberAlpha,NumberMach);
                CaseData{CaseNumber}.caFullBase=99999*ones(NumberAlpha,NumberMach);
                CaseData{CaseNumber}.cy=99999*ones(NumberAlpha,NumberMach);
                CaseData{CaseNumber}.cln=99999*ones(NumberAlpha,NumberMach);
                CaseData{CaseNumber}.cll=99999*ones(NumberAlpha,NumberMach);
                CaseData{CaseNumber}.clod=99999*ones(NumberAlpha,NumberMach);
            end
        end
    end

    function IndexBeginNext=TrimRead(IndexBeginNext)

        ReplaceNT()


        if(CaseData{CaseNumber}.version==2011)

            CaseData{CaseNumber}.delta(IndexAlpha,IndexMach)=GetCoefficients(Line(IndexBeginNext:IndexBeginNext+11));
            CaseData{CaseNumber}.cn(IndexAlpha,IndexMach)=GetCoefficients(Line(IndexBeginNext+13:IndexBeginNext+24));
            CaseData{CaseNumber}.ca(IndexAlpha,IndexMach)=GetCoefficients(Line(IndexBeginNext+26:IndexBeginNext+37));
            CaseData{CaseNumber}.caZeroBase(IndexAlpha,IndexMach)=GetCoefficients(Line(IndexBeginNext+39:IndexBeginNext+50));
            CaseData{CaseNumber}.caFullBase(IndexAlpha,IndexMach)=GetCoefficients(Line(IndexBeginNext+52:IndexBeginNext+63));
            CaseData{CaseNumber}.cy(IndexAlpha,IndexMach)=GetCoefficients(Line(IndexBeginNext+65:IndexBeginNext+76));
            CaseData{CaseNumber}.cln(IndexAlpha,IndexMach)=GetCoefficients(Line(IndexBeginNext+78:IndexBeginNext+89));
            CaseData{CaseNumber}.cll(IndexAlpha,IndexMach)=GetCoefficients(Line(IndexBeginNext+91:IndexBeginNext+102));
            CaseData{CaseNumber}.cl(IndexAlpha,IndexMach)=GetCoefficients(Line(IndexBeginNext+104:IndexBeginNext+115));
            CaseData{CaseNumber}.cd(IndexAlpha,IndexMach)=GetCoefficients(Line(IndexBeginNext+117:IndexBeginNext+128));
            CaseData{CaseNumber}.clod(IndexAlpha,IndexMach)=GetCoefficients(Line(IndexBeginNext+130:IndexBeginNext+141));
            IndexBeginNext=IndexBeginNext+143;
        else

            CaseData{CaseNumber}.delta(IndexAlpha,IndexMach)=GetCoefficients(Line(IndexBeginNext:IndexBeginNext+11));
            CaseData{CaseNumber}.cl(IndexAlpha,IndexMach)=GetCoefficients(Line(IndexBeginNext+13:IndexBeginNext+24));
            CaseData{CaseNumber}.cd(IndexAlpha,IndexMach)=GetCoefficients(Line(IndexBeginNext+26:IndexBeginNext+37));
            CaseData{CaseNumber}.cn(IndexAlpha,IndexMach)=GetCoefficients(Line(IndexBeginNext+39:IndexBeginNext+50));
            CaseData{CaseNumber}.ca(IndexAlpha,IndexMach)=GetCoefficients(Line(IndexBeginNext+52:IndexBeginNext+63));
            IndexBeginNext=IndexBeginNext+65;
        end
    end

    function Output=GetCoefficients(Line)

        Output=str2num(Line);%#ok<ST2NM>

        if isempty(Output)
            Output=99999;
        end
    end

    function ReplaceNT()

        if usenan
            Line=strrep(Line,'''*NT*''','   NaN');
        else
            Line=strrep(Line,'''*NT*''','000000');
        end

    end

end




