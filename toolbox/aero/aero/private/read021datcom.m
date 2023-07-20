function[caseno,casedata]=read021datcom(files,usenan,verbose)









    caseno=0;


    idxaph=1;


    casesetup=struct('mach',[],'alt',[],'alpha',[],...
    'nalpha',0,'beta',0,'total_col',[],'deriv_col',[],...
    'config',struct(...
    'fin1',struct('delta',zeros(1,8)),...
    'fin2',struct('delta',zeros(1,8)),...
    'fin3',struct('delta',zeros(1,8)),...
    'fin4',struct('delta',zeros(1,8))),...
    'version',2007);

    for fcnt=1:length(files)
        filename=files(fcnt);
        if(verbose=="1")
            fprintf('\nLoading file ''%s''.\n',filename)
        elseif(verbose=="2")
            hw=waitbar(0,'Progress: 0%','name',sprintf('Loading: %s',filename));
            for z=0.1:0.1:0.2
                waitbar(z,hw)
                pause(0.1)
            end
        end
        caseno=caseno+1;
        firstinput=1;
        try
            fid=fopen(filename,'r');
            if(fid<0)
                error(message('aero:loadfiles:cannotOpen',filename));
            end

            state='checkFile';
            linetype='';


            casedata{caseno}=struct();%#ok<AGROW>


            while~feof(fid)
                line=fgetl(fid);

                if(verbose=="1")
                    if firstinput
                        fprintf('Reading input data from file ''%s''.\n',filename)
                        firstinput=0;
                    end
                elseif(verbose=="2")
                    z=z+0.01;
                    if z>0.95
                        z=0.95;
                    end
                    set(hw,'name',sprintf('Reading input data: %s',filename))
                    waitbar(z,hw,sprintf('Progress: %3.0f%%',z*100))
                end


                linetype=getLineType();


                [state]=getReaderState(state);

                switch state
                case 'lost'

                    lostwarning();

                case 'exit'

                    error(message('aero:datcomimport:invalidFile',filename));
                otherwise

                end

                getData();
            end
            fclose(fid);

            if strcmpi(state,'headerRead')
                caseno=caseno-1;
            end
            if(verbose=="2")
                set(hw,'Name',sprintf('Reading completed: %s',filename))
                waitbar(1,hw,'Progress: 100%')
                pause(0.5)
            end
        catch readError
            if(exist('fid','var')&&~any(fid==[-1,0,1,2]))
                fclose(fid);
            end
            if exist('hw')%#ok<EXIST>
                close(hw);
            end
            rethrow(readError)
        end
        if exist('hw')%#ok<EXIST>
            close(hw);
        end
    end


    function linetype=getLineType()

        if~isempty(regexp(line,...
            '\<VARIABLES: MACH,ALTITUDE,SIDESLIP,DEL1,DEL2,DEL3,DEL4\>','once'))
            linetype='varHeader1';
        elseif~isempty(regexp(line,...
            '\<ROWS, TOTAL COLUMNS, COLUMNS OF DERIVATIVES\>','once'))
            linetype='varHeader2';
        elseif~isempty(regexp(line,...
            '\<DATA: ALPHA     CN           CM           CA           CY          CLN          CLL          CNAD\>','once'))
            linetype='dataHeader';
        else
            linetype=testline();
        end

        function linetype=testline()

            switch length(line)
            case{218,458}
                linetype='varData1';
            case 24
                linetype='varData2';
            case{348,88}
                linetype='data';
            otherwise
                linetype='unknown';
            end
        end

    end

    function state=getReaderState(state)

        switch state
        case 'checkFile'
            statecell={'exit','headerRead'};
            typecell={'varHeader1'};

        case 'headerRead'
            statecell={'lost','headerRead','headerRead','headerRead','dataRead'};
            typecell={'varHeader2','dataHeader','varData1','varData2'};

        case 'dataRead'
            statecell={'lost','dataRead','dataRead','dataRead'};
            typecell={'varData1','varData2','data'};

        otherwise
            statecell={'lost','lost','lost','lost'...
            ,'lost','lost','lost'};
            typecell={'varHeader1','varHeader2','dataHeader'...
            ,'varData1','varData2','data'};
        end
        stateidx=find(strcmp(typecell,linetype));
        if isempty(stateidx)
            stateidx=0;
        end
        state=statecell{stateidx+1};

    end

    function getData()

        switch linetype
        case{'varHeader1','varHeader2'}


        case 'dataHeader'


        case 'varData1'
            if strcmpi(state,'dataRead')
                caseno=caseno+1;
            end

            casedata{caseno}=casesetup;

            if(length(line)==458)
                casedata{caseno}.version=2008;
            end

            casedata{caseno}.mach=getcoeffs(line(1:8));
            casedata{caseno}.alt=getcoeffs(line(9:17));
            casedata{caseno}.beta=getcoeffs(line(18:25));
            casedata{caseno}.config.fin1.delta=getcoeffs(line(27:74));
            casedata{caseno}.config.fin2.delta=getcoeffs(line(75:122));
            casedata{caseno}.config.fin3.delta=getcoeffs(line(123:170));
            casedata{caseno}.config.fin4.delta=getcoeffs(line(171:218));

        case 'varData2'
            casedata{caseno}.nalpha=getcoeffs(line(1:8));
            casedata{caseno}.total_col=getcoeffs(line(9:16));
            casedata{caseno}.deriv_col=getcoeffs(line(17:24));


            staticinit();
            if(casedata{caseno}.total_col==27)&&(casedata{caseno}.deriv_col==20)
                dynamicinit();
            end

            idxaph=1;

        case 'data'

            staticread();
            if(casedata{caseno}.total_col==27)&&(casedata{caseno}.deriv_col==20)
                dynamicread();
            end

            idxaph=idxaph+1;

        otherwise

            lostwarning();
        end
    end

    function lostwarning()
        warning(message('aero:datcomimport:algorithmError'));
    end

    function staticinit()
        if~isfield(casedata{caseno},'cd')
            nalpha=casedata{caseno}.nalpha;

            casedata{caseno}.alpha=99999*ones(1,nalpha);
            casedata{caseno}.cn=99999*ones(1,nalpha);
            casedata{caseno}.cm=99999*ones(1,nalpha);
            casedata{caseno}.ca=99999*ones(1,nalpha);
            casedata{caseno}.cy=99999*ones(1,nalpha);
            casedata{caseno}.cln=99999*ones(1,nalpha);
            casedata{caseno}.cll=99999*ones(1,nalpha);
        end
    end

    function staticread()

        replacenandm()

        casedata{caseno}.alpha(idxaph)=getcoeffs(line(1:10));
        casedata{caseno}.cn(idxaph)=getcoeffs(line(13:23));
        casedata{caseno}.cm(idxaph)=getcoeffs(line(26:36));
        casedata{caseno}.ca(idxaph)=getcoeffs(line(39:49));
        casedata{caseno}.cy(idxaph)=getcoeffs(line(52:62));
        casedata{caseno}.cln(idxaph)=getcoeffs(line(65:75));
        casedata{caseno}.cll(idxaph)=getcoeffs(line(78:88));

    end

    function dynamicinit()
        if~isfield(casedata{caseno},'cmad')
            nalpha=casedata{caseno}.nalpha;

            casedata{caseno}.cnad=99999*ones(1,nalpha);
            casedata{caseno}.cmad=99999*ones(1,nalpha);
            casedata{caseno}.cnq=99999*ones(1,nalpha);
            casedata{caseno}.cmq=99999*ones(1,nalpha);
            casedata{caseno}.caq=99999*ones(1,nalpha);
            casedata{caseno}.cyq=99999*ones(1,nalpha);
            casedata{caseno}.clnq=99999*ones(1,nalpha);
            casedata{caseno}.cllq=99999*ones(1,nalpha);
            casedata{caseno}.cnp=99999*ones(1,nalpha);
            casedata{caseno}.cmp=99999*ones(1,nalpha);
            casedata{caseno}.cap=99999*ones(1,nalpha);
            casedata{caseno}.cyp=99999*ones(1,nalpha);
            casedata{caseno}.clnp=99999*ones(1,nalpha);
            casedata{caseno}.cllp=99999*ones(1,nalpha);
            casedata{caseno}.cnr=99999*ones(1,nalpha);
            casedata{caseno}.cmr=99999*ones(1,nalpha);
            casedata{caseno}.car=99999*ones(1,nalpha);
            casedata{caseno}.cyr=99999*ones(1,nalpha);
            casedata{caseno}.clnr=99999*ones(1,nalpha);
            casedata{caseno}.cllr=99999*ones(1,nalpha);
        end
    end

    function dynamicread()

        replacenandm()

        casedata{caseno}.cnad(idxaph)=getcoeffs(line(91:101));
        casedata{caseno}.cmad(idxaph)=getcoeffs(line(104:114));
        casedata{caseno}.cnq(idxaph)=getcoeffs(line(117:127));
        casedata{caseno}.cmq(idxaph)=getcoeffs(line(130:140));
        casedata{caseno}.caq(idxaph)=getcoeffs(line(143:153));
        casedata{caseno}.cyq(idxaph)=getcoeffs(line(156:166));
        casedata{caseno}.clnq(idxaph)=getcoeffs(line(169:179));
        casedata{caseno}.cllq(idxaph)=getcoeffs(line(182:192));
        casedata{caseno}.cnp(idxaph)=getcoeffs(line(195:205));
        casedata{caseno}.cmp(idxaph)=getcoeffs(line(208:218));
        casedata{caseno}.cap(idxaph)=getcoeffs(line(221:232));
        casedata{caseno}.cyp(idxaph)=getcoeffs(line(234:244));
        casedata{caseno}.clnp(idxaph)=getcoeffs(line(247:257));
        casedata{caseno}.cllp(idxaph)=getcoeffs(line(260:270));
        casedata{caseno}.cnr(idxaph)=getcoeffs(line(273:283));
        casedata{caseno}.cmr(idxaph)=getcoeffs(line(286:296));
        casedata{caseno}.car(idxaph)=getcoeffs(line(299:309));
        casedata{caseno}.cyr(idxaph)=getcoeffs(line(312:322));
        casedata{caseno}.clnr(idxaph)=getcoeffs(line(325:335));
        casedata{caseno}.cllr(idxaph)=getcoeffs(line(338:348));
    end

    function output=getcoeffs(line)

        output=str2num(line);%#ok<ST2NM>

        if isempty(output)
            output=99999;
        end
    end

    function replacenandm()

        if usenan
            line=strrep(line,'NA ','NaN');
            line=strrep(line,'NDM','NaN');
        else
            line=strrep(line,'NA','00');
            line=strrep(line,'NDM','000');
        end


        line=strrep(line,'************','000000000000');
        line=strrep(line,'***********','00000000000');
        line=strrep(line,'**********','0000000000');
        line=strrep(line,'*******','0000000');
        line=strrep(line,'******','000000');
        line=strrep(line,'*****','00000');
    end

end

